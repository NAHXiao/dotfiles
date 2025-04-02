FROM ubuntu:latest

#must
RUN set -e && apt-get update && apt-get install -y apt-utils 

#sys tools
RUN set -e apt-get install -y iproute2 sudo ranger tar unzip 7zip curl wget  libglib2.0-bin

#dev tools
RUN set -e && apt-get install -y neovim ripgrep fd-find jq

#chezmoi
RUN set -e && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

#conf
RUN set -e && apt-get install -y file zsh unzip git curl &&\
    echo ${HTTP_PROXY} &&\
    /usr/local/bin/chezmoi init --apply NAHXiao --exclude encrypted --mode=file && \
    chsh -s /bin/zsh

#cpp
RUN set -e && apt-get install -y gcc g++ gdb make cmake build-essential ninja-build pkg-config libtool autoconf automake clang-format clangd cppcheck valgrind strace ltrace 

#py
RUN set -e && apt-get install -y python3 python3-pip python3-venv

#java
RUN set -e && apt install -y openjdk-17-jdk

#node
RUN set -e && apt-get install -y nodejs npm

#ssh
RUN set -e && apt-get update && apt-get install -y openssh-server 
RUN set -e && mkdir /var/run/sshd
RUN set -e && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN set -e && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN set -e && echo 'root:root' | chpasswd
RUN set -e && mkdir -p /root/.ssh
RUN set -e && chmod 700 /root/.ssh

#lemonade ssh剪贴板
RUN set -e && wget -tries=10 -qO- https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz | tar xz -C /usr/local/bin

#bitwarden-cli
RUN set -e && wget -O/tmp/bw.zip 'https://bitwarden.com/download/?app=cli&platform=linux' && unzip /tmp/bw.zip -d /usr/local/bin && rm /tmp/bw.zip

#apt
RUN set -e && echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99retries

# 开放端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
