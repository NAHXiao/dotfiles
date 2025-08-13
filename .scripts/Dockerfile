FROM ubuntu:latest
# FROM ubuntu:20.04
# FROM ubuntu:18.04
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG socks_proxy=""

RUN cat  <<-EOF > /usr/local/bin/useproxy && chmod +x /usr/local/bin/useproxy
#!/bin/bash
env http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY socks_proxy=$socks_proxy no_proxy=$NO_PROXY "\$@"; 
EOF

RUN set -e &&\
    echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99retries && \
    #must \
    apt-get update && apt-get install -y apt-utils dialog openssl && \
    #sys tools
    apt-get install -y iproute2 sudo ranger tar zip unzip p7zip curl wget libglib2.0-bin tmux file zsh tree && \
    #dev tools
    apt-get install -y neovim ripgrep fd-find jq git && \
    #cpp
    apt-get install -y gcc g++ clang gdb make cmake build-essential ninja-build pkg-config libtool autoconf automake clang-format clangd cppcheck valgrind strace ltrace && \
    #py
    apt-get install -y python3 python3-pip python3-venv && \
    #java
    apt-get install -y openjdk-21-jdk && \
    #node
    apt-get install -y nodejs npm && \
    #ssh
    apt-get install -y openssh-server || exit 127
    
RUN set -e && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    { \ 
        if ! id ubuntu 2>/dev/null ;then \
            groupadd --system ubuntu --gid 1000 && \
            useradd --uid 1000 --system --gid ubuntu --home-dir /home/ubuntu --create-home --comment "Docker image user" ubuntu && \
            chown -R ubuntu:ubuntu /home/ubuntu ;\
        fi \ 
    } && \
    usermod --password $(openssl passwd -6 root) root && \
    usermod --password $(openssl passwd -6 ubuntu) ubuntu && \
    usermod -aG sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ubuntu && \
    chmod 440 /etc/sudoers.d/ubuntu &&\
    # echo 'root:root' | chpasswd && \
    # echo 'ubuntu:ubuntu' | chpasswd && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    mkdir -p /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chown ubuntu:ubuntu -R /home/ubuntu/.ssh && \
    chsh -s /bin/zsh ubuntu || exit 127
RUN set -e && \
    #lemonade
    useproxy wget -tries=10 -qO- 'https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz' | tar xz -C /usr/local/bin && \
    #bitwarden
    useproxy wget -O/tmp/bw.zip -tries=10 'https://bitwarden.com/download/?app=cli&platform=linux' && unzip /tmp/bw.zip -d /usr/local/bin && rm /tmp/bw.zip && \
    #chezmoi
    useproxy sh -c "$(curl --retry 10 --retry-delay 2 --retry-connrefused -fsLS get.chezmoi.io)" -- -b /usr/local/bin && [ -f /usr/local/bin/chezmoi ] || exit 127
USER ubuntu
RUN useproxy /usr/local/bin/chezmoi init --apply NAHXiao --exclude encrypted --mode=file || exit 127
USER root
RUN rm /usr/local/bin/useproxy || exit 127
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
