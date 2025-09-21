# FROM ubuntu:latest
FROM ubuntu:20.04
# FROM ubuntu:18.04 #无ripgrep,fd-find
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG socks_proxy=""
RUN printf '#!/bin/bash\n' > /usr/local/bin/useproxy || exit 127
RUN printf 'env http_proxy=%s https_proxy=%s socks_proxy=%s "$@"\n' "$HTTP_PROXY" "$HTTPS_PROXY" "$socks_proxy" >> /usr/local/bin/useproxy || exit 127
RUN chmod +x /usr/local/bin/useproxy || exit 127
RUN printf '#!/bin/bash\n' > /usr/local/bin/retry || exit 127
RUN printf 'while ! "$@" ; do echo ----------RETRY----------;done\n' >> /usr/local/bin/retry || exit 127
RUN chmod +x /usr/local/bin/retry || exit 127

RUN set -e &&\
    echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99retries && \
    #must \
    useproxy retry apt-get update &&\
    useproxy retry apt-get install -y apt-utils dialog openssl && \
    #sys tools
    useproxy retry apt-get install -y iproute2 sudo tar zip unzip p7zip curl wget libglib2.0-bin tmux file zsh tree && \
    #dev tools
    useproxy retry apt-get install -y ripgrep fd-find jq git && \
    #cpp
    useproxy retry apt-get install -y gcc g++ clang gdb make cmake build-essential ninja-build pkg-config libtool autoconf automake clang-format clangd cppcheck valgrind strace ltrace && \
    #py
    useproxy retry apt-get install -y python3 python3-pip python3-venv && \
    #java
    useproxy retry apt-get install -y openjdk-21-jdk && \
    #node
    useproxy retry apt-get install -y nodejs npm && \
    #ssh
    useproxy retry apt-get install -y openssh-server || exit 127

RUN set -e && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    { \ 
    if ! id ubuntu 2>/dev/null ;then \
    groupadd --system ubuntu --gid 1000 && \
    useradd --uid 1000 --system --gid ubuntu --home-dir /home/ubuntu --create-home --comment "Docker image user" ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu ;\
    mkdir -p /run/user/$(id -u ubuntu);\
    chown ubuntu:ubuntu /run/user/$(id -u ubuntu);\
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
    retry apt-get install -y locales && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 || exit 127

#neovim
RUN tmpdir=$(mktemp -d /tmp/nvim-XXXXXX) && cd $tmpdir && useproxy retry git clone https://github.com/neovim/neovim && cd neovim && git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && cd build && cpack -G DEB && dpkg -i nvim-linux-*.deb || exit 127

#bitwarden
RUN set -e && \
    useproxy retry wget -O/tmp/bw.zip -tries=10 'https://bitwarden.com/download/?app=cli&platform=linux' && unzip /tmp/bw.zip -d /usr/local/bin && rm /tmp/bw.zip && [ -f /usr/local/bin/bw ] || exit 127

#chezmoi
RUN set -e && \
    useproxy retry sh -c "$(curl --retry 10 --retry-delay 2 --retry-connrefused -fsLS get.chezmoi.io)" -- -b /usr/local/bin && [ -f /usr/local/bin/chezmoi ] || exit 127

#yazi
RUN set -e  && \
    useproxy retry wget -L https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip -O/tmp/yazi.zip && \
    tmpdir=$(mktemp -d /tmp/yazi-XXXXXX) && \
    unzip /tmp/yazi.zip -d $tmpdir && \
    cd $tmpdir/yazi-x86_64-unknown-linux-musl&& \
    mkdir -p /usr/share/bash-completion/completions /usr/share/zsh/site-functions /usr/share/fish/vendor_completions.d /usr/share/nushell/vendor/autoload && \
    cp ya yazi /usr/local/bin && \
    cp completions/ya.bash /usr/share/bash-completion/completions && \
    cp completions/yazi.bash /usr/share/bash-completion/completions && \
    cp completions/_ya /usr/share/zsh/site-functions && \
    cp completions/_yazi /usr/share/zsh/site-functions && \
    cp completions/ya.fish /usr/share/fish/vendor_completions.d && \
    cp completions/yazi.fish /usr/share/fish/vendor_completions.d && \
    cp completions/ya.nu /usr/share/nushell/vendor/autoload && \
    cp completions/yazi.nu /usr/share/nushell/vendor/autoload && \
    [ -f /usr/local/bin/ya ] && [ -f /usr/local/bin/yazi ] || exit 127

USER ubuntu
#fnm
RUN set -e && useproxy retry bash -c 'curl -fsSL https://fnm.vercel.app/install | bash' || exit 127
RUN useproxy retry /usr/local/bin/chezmoi init --apply NAHXiao --branch chezmoi --exclude encrypted --mode=file || exit 127
USER root
RUN rm /usr/local/bin/useproxy || exit 127
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
