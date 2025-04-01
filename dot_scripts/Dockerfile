FROM ubuntu:latest

#must
RUN set -e && apt-get update && apt-get install -y apt-utils 

#tools
RUN set -e && apt-get install -y ranger sudo neovim ripgrep fd-find

#conf
RUN set -e && apt-get install -y file zsh unzip git curl &&\
    echo ${HTTP_PROXY} &&\
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply NAHXiao --exclude encrypted --mode=file && \
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

#apt
RUN set -e && echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99retries

# 开放端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
