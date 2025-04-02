FROM ubuntu:latest
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG socks_proxy=""
RUN set -e && useproxy() { env http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY socks_proxy=$socks_proxy no_proxy=$NO_PROXY "$@"; } && \
    apt-get update && apt-get install -y apt-utils && \
    apt-get install -y iproute2 sudo ranger tar unzip curl wget libglib2.0-bin && \
    apt-get install -y neovim ripgrep fd-find jq && \
    sh -c "$(useproxy curl --retry 10 --retry-delay 2 --retry-connrefused -fsLS get.chezmoi.io)" -- -b /usr/local/bin && \
    apt-get install -y file zsh git && \
    echo ${HTTP_PROXY} && \
    useproxy /usr/local/bin/chezmoi init --apply NAHXiao --exclude encrypted --mode=file && \
    chsh -s /bin/zsh && \
    apt-get install -y gcc g++ gdb make cmake build-essential ninja-build pkg-config libtool autoconf automake clang-format clangd cppcheck valgrind strace ltrace && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get install -y openjdk-17-jdk && \
    apt-get install -y nodejs npm && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    wget -tries=10 -qO- 'https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz' | tar xz -C /usr/local/bin && \
    wget -O/tmp/bw.zip -tries=10 'https://bitwarden.com/download/?app=cli&platform=linux' && unzip /tmp/bw.zip -d /usr/local/bin && rm /tmp/bw.zip && \
    echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99retries

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
