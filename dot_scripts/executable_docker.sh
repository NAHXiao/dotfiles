#!/bin/bash
selfpath=$0
function print_help() {
    echo "Usage: $selfpath <build|start|stop|rm> [CONTAINER_NAME[:IMAGE_NAME]] [-p port]"
}
if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

IMAGE_NAME="base"
CONTAINER_NAME="basec"
MOUNT_FROM="$HOME/workspace"
MOUNT_POINT="/home/ubuntu/workspace"
SSH_PORT=2222

COMMAND="$1"
shift

# 处理各命令的参数
case "$COMMAND" in
    build|stop|rm)
        # 这些命令无选项，直接处理容器名:镜像名
        if [ -n "$1" ]; then
            TMP_CONTAINER_NAME=$(echo "$1" | cut -d: -f1)
            [ -n "$TMP_CONTAINER_NAME" ] && CONTAINER_NAME=$TMP_CONTAINER_NAME
            TMP_IMAGE_NAME=$(echo "$1" | cut -d: -f2-)
            [ -n "$TMP_IMAGE_NAME" ] && IMAGE_NAME=$TMP_IMAGE_NAME
            shift
        fi
        ;;
    start)
        # 处理容器名:镜像名
        if  [[ -n "$1" && ! "$1" =~ -+ ]]; then
            TMP_CONTAINER_NAME=$(echo "$1" | cut -d: -f1)
            [ -n "$TMP_CONTAINER_NAME" ] && CONTAINER_NAME=$TMP_CONTAINER_NAME
            TMP_IMAGE_NAME=$(echo "$1" | cut -d: -f2-)
            [ -n "$TMP_IMAGE_NAME" ] && IMAGE_NAME=$TMP_IMAGE_NAME
            shift
        fi
        # 处理start的选项
        while getopts "p:" opt; do
            case "$opt" in
                p) SSH_PORT="$OPTARG";;
                *) print_help; exit 1 ;;
            esac
        done
        shift $((OPTIND - 1))
        ;;
    *)
        print_help
        exit 1
        ;;
esac

echo "ARG:IMAGE_NAME     : $IMAGE_NAME"
echo "ARG:CONTAINER_NAME : $CONTAINER_NAME"
echo "ARG:SSH_PORT       : $SSH_PORT"

case "$COMMAND" in
    build)
            args=()
            [[ -n $HTTP_PROXY ]] && args+=(--build-arg "HTTP_PROXY=$HTTP_PROXY")
            [[ -n $HTTPS_PROXY ]] && args+=(--build-arg "HTTPS_PROXY=$HTTPS_PROXY")
            [[ -n $socks_proxy ]] && args+=(--build-arg "socks_proxy=$socks_proxy")
            echo "${args[@]}"
            docker build "${args[@]}" -t "$IMAGE_NAME" - < "$HOME/.scripts/Dockerfile"
        ;;
    start)
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
            docker exec "$CONTAINER_NAME" bash -c "grep -qF 'HTTP_PROXY' /etc/profile || echo -e 'export HTTP_PROXY=$HTTP_PROXY\nexport HTTPS_PROXY=$HTTPS_PROXY\nexport http_proxy=$HTTP_PROXY\nexport https_proxy=$HTTPS_PROXY' >> /etc/profile"
            if docker exec "$CONTAINER_NAME" which zsh >/dev/null; then
                docker exec "$CONTAINER_NAME" bash -c "grep -qF 'source /etc/profile' /etc/zsh/zprofile || echo 'source /etc/profile' >> /etc/zsh/zprofile"
            fi
            CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
            docker exec "$CONTAINER_NAME" bash -c "mkdir -p /run/user/1000"
        fi
        docker port "$CONTAINER_NAME"
        ;;
    stop)
        if docker ps --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
            docker stop "$CONTAINER_NAME"
        else
            echo "$CONTAINER_NAME is not running"
            exit 1
        fi
        ;;
    rm)
        if docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" | grep -qw "$CONTAINER_NAME"; then
            docker stop "$CONTAINER_NAME" >/dev/null 2>&1
            docker rm "$CONTAINER_NAME"
            echo "Container $CONTAINER_NAME removed."
        fi
        ;;
    *)
        print_help
        exit 1
        ;;
esac
