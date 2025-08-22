#!/bin/bash
MOUNT_FROM="$HOME/workspace"
MOUNT_POINT="/home/ubuntu/workspace"

COMMAND=""
IMAGE_NAME=""
TAG_NAME="latest"
CONTAINER_NAME=""
SSH_PORT=2222

parse_args() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 {build|start|stop|rm} ..." >&2
        return 1
    fi

    COMMAND="$1"
    shift

    case "$COMMAND" in
        build)
            if [ $# -ne 1 ]; then
                echo "Usage: $0 build IMAGE_NAME[:TAG_NAME]" >&2
                return 1
            fi
            local image_spec="$1"
            if [[ "$image_spec" == *:* ]]; then
                IMAGE_NAME="${image_spec%:*}"
                TAG_NAME="${image_spec#*:}"
            else
                IMAGE_NAME="$image_spec"
            fi
            ;;

        start)
            if [ $# -lt 1 ]; then
                echo "Usage: $0 start CONTAINER_NAME:IMAGE_NAME[:TAG_NAME] [-p SSH_PORT]" >&2
                return 1
            fi
            local container_spec="$1"
            shift
            CONTAINER_NAME="${container_spec%%:*}"
            local image_spec="${container_spec#*:}"
            if [[ "$image_spec" == *:* ]]; then
                IMAGE_NAME="${image_spec%:*}"
                TAG_NAME="${image_spec#*:}"
            else
                IMAGE_NAME="$image_spec"
            fi
            while [ $# -gt 0 ]; do
                case "$1" in
                    -p)
                        if [ $# -lt 2 ]; then
                            echo "Error: -p requires SSH_PORT argument" >&2
                            return 1
                        fi
                        SSH_PORT="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1" >&2
                        return 1
                        ;;
                esac
            done
            ;;

        stop|rm)
            if [ $# -ne 1 ]; then
                echo "Usage: $0 $COMMAND CONTAINER_NAME" >&2
                return 1
            fi
            CONTAINER_NAME="$1"
            ;;

        *)
            echo "Unknown command: $COMMAND" >&2
            echo "Available commands: build, start, stop, rm" >&2
            return 1
            ;;
    esac

    return 0
}
parse_args "$@" || exit 1
case "$COMMAND" in
    build)#IMAGE_NAME[:TAG_NAME]
        echo "ARG:IMAGE_NAME     : $IMAGE_NAME"
        echo "ARG:TAG_NAME       : $TAG_NAME"
        args=()
        [[ -n $HTTP_PROXY ]] && args+=(--build-arg "HTTP_PROXY=$HTTP_PROXY")
        [[ -n $HTTPS_PROXY ]] && args+=(--build-arg "HTTPS_PROXY=$HTTPS_PROXY")
        [[ -n $socks_proxy ]] && args+=(--build-arg "socks_proxy=$socks_proxy")
        echo "${args[@]}"
        docker build "${args[@]}" -t "$IMAGE_NAME" - < "$HOME/.scripts/Dockerfile"
        ;;
    start)#CONTAINER_NAME:IMAGE_NAME[:TAG_NAME]
        echo "ARG:IMAGE_NAME     : $IMAGE_NAME"
        echo "ARG:TAG_NAME       : $TAG_NAME"
        echo "ARG:CONTAINER_NAME : $CONTAINER_NAME"
        echo "ARG:SSH_PORT       : $SSH_PORT"
        if docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
            if docker ps --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
                echo "$CONTAINER_NAME is already running"
                false
            else
                docker start "$CONTAINER_NAME"
            fi
        else
            docker run -d \
                --name "$CONTAINER_NAME" \
                -p "$SSH_PORT":22 \
                --mount type=bind,source="$MOUNT_FROM",target="$MOUNT_POINT" \
                --restart=unless-stopped \
                "$IMAGE_NAME"
        fi

        if [ $? -eq 0 ]; then
            # docker exec "$CONTAINER_NAME" bash -c "grep -qF 'HTTP_PROXY' /etc/profile || echo -e 'export HTTP_PROXY=$HTTP_PROXY\nexport HTTPS_PROXY=$HTTPS_PROXY\nexport http_proxy=$HTTP_PROXY\nexport https_proxy=$HTTPS_PROXY' >> /etc/profile"
            docker exec "$CONTAINER_NAME" bash -c "cat <<'EOF' >/etc/profile.d/99-docker.user-proxy.sh
export HTTP_PROXY=\"$HTTP_PROXY\"
export http_proxy=\"$http_proxy\"
export HTTPS_PROXY=\"$HTTPS_PROXY\"
export https_proxy=\"$https_proxy\"

curl -sf http://www.msftconnecttest.com/connecttest.txt --max-time 1 -o/dev/null || {
  unset HTTP_PROXY
  unset http_proxy
  unset HTTPS_PROXY
  unset https_proxy
}
EOF"
            if docker exec "$CONTAINER_NAME" which zsh >/dev/null; then
                docker exec "$CONTAINER_NAME" bash -c "grep -qF 'source /etc/profile' /etc/zsh/zprofile || echo 'source /etc/profile' >> /etc/zsh/zprofile"
            fi
            CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
            docker exec "$CONTAINER_NAME" bash -c "mkdir -p /run/user/1000"
        fi
        docker port "$CONTAINER_NAME"
        ;;
    stop)#CONTAINER_NAME
        echo "ARG:CONTAINER_NAME : $CONTAINER_NAME"
        if docker ps --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
            docker stop "$CONTAINER_NAME"
        else
            echo "$CONTAINER_NAME is not running"
            exit 1
        fi
        ;;
    rm)#CONTAINER_NAME
        echo "ARG:CONTAINER_NAME : $CONTAINER_NAME"
        if docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
            docker stop "$CONTAINER_NAME" >/dev/null 2>&1
            docker rm "$CONTAINER_NAME"
            echo "Container $CONTAINER_NAME removed."
        fi
        ;;
esac
