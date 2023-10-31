ARG image=ubuntu:20.04

FROM $image as builder

WORKDIR /home/ctf
ARG proxy=
ARG python_version=3.11.5
ARG BUILD_MULTI=false

ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list

RUN apt update && apt install build-essential zlib1g-dev libncurses5-dev dpkg-dev libgmp3-dev lsb-release \
    libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev curl libbz2-dev pkg-config texinfo -y

RUN curl -LO https://www.python.org/ftp/python/$python_version/Python-$python_version.tgz && \
    tar -xf Python-$python_version.tgz && \
    cd Python-$python_version/ && \
    ./configure --enable-optimizations && \
    mkdir /root/build && \
    make -j$(nproc) && make altinstall -j$(nproc) DESTDIR=/root/build

RUN curl -fsSL https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.xz | tar -xJ && \
    cd gdb-13.2 && \
    if [ "$(lsb_release -rs)" != "16.04" ] && [ "$BUILD_MULTI" = "true" ]; then \
        ./configure --enable-targets=all --with-python=python; \
    else \
        ./configure --with-python=python; \
    fi && \
    # gdb cannot specify the python in /root/build, so we have to copy it.
    mkdir -p /root/build && cp -r /root/build/usr / && \
    ln -sf /usr/local/bin/python$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/python && \
    make -j$(nproc) && make install -j$(nproc) DESTDIR=/root/build


FROM $image as p

ARG proxy=
ARG python_version=3.11.5

ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy
ENV NO_PROXY="security.ubuntu.com,mirrors.tuna.tsinghua.edu.cn"
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/nopwn

# # 换源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    echo "Acquire::http::Proxy false;\nAcquire::https::Proxy false;" >> /etc/apt/apt.conf.d/10-no-https-proxy
    # sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    # sed -i 's/http:/https:/g' /etc/apt/sources.list
    
RUN dpkg --add-architecture i386 && apt-get update && \
    apt-get install git vim tzdata libc6:i386 \
    libncurses5:i386 libstdc++6:i386 \
    patchelf net-tools gnupg2 netcat socat g++-multilib lib32stdc++6 \
    libffi-dev libssl-dev gcc-multilib make strace ltrace file sudo elfutils \ 
    curl zsh lsb-release -y --fix-missing

COPY --from=builder /root/build/ /

RUN ln -sf /usr/local/bin/python$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    pip install --upgrade pip && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
    pip install --no-cache-dir pwntools ropgadget ropper

RUN if [ "$(lsb_release -rs)" = "22.04" ]; then \
        apt-get install -y software-properties-common && \
        apt-add-repository -y ppa:rael-gc/rvm && \
        apt-get update && apt install -y --allow-downgrades libssl-dev=1.1.1l-1ubuntu1.4 ca-certificates; \
    fi && \
    mkdir ~/.gnupg && \
    if [ "$(lsb_release -rs)" != "16.04" ]; then \
        echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
    else \ 
        dirmngr </dev/null; \
    fi && \
    gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -ksSL https://get.rvm.io | bash -s stable && \
    /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm install 2.7" && \
    ln -sf /usr/local/rvm/rubies/ruby-2.*/bin/ruby /usr/local/bin/ruby && \
    ln -sf /usr/local/rvm/rubies/ruby-2.*/bin/gem /usr/local/bin/gem && \
    if [ "$(lsb_release -rs)" = "22.04" ]; then \
        # Revoke changes.
        apt-add-repository -ry ppa:rael-gc/rvm && \
        apt-get remove -y software-properties-common && \
        apt-get install -y libssl-dev; \
    fi

RUN gem install one_gadget seccomp-tools && \
    ln -sf /usr/local/rvm/rubies/ruby-2.*/bin/one_gadget /usr/local/bin/one_gadget && \
    ln -sf /usr/local/rvm/gems/ruby-2.*/bin/seccomp-tools /usr/local/bin/seccomp-tools

COPY content/pwndbg.sh /tmp/pwndbg.sh

RUN if [ -n "$proxy" ]; then \
    git config --global http.proxy $proxy; \
    git config --global https.proxy $proxy; \
    fi && git clone --depth 1 https://github.com/pwndbg/pwndbg /usr/local/pwndbg && \
    cd /usr/local/pwndbg && mv /tmp/pwndbg.sh install.sh && ./install.sh && \
    git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git /usr/local/Pwngdb && \
    cd /usr/local/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source /usr/local/peda/peda.py?g" .gdbinit-pwngdb && \
    curl -L https://raw.githubusercontent.com/hugsy/gef/main/gef.py -o  /usr/local/.gdbinit-gef.py 


# Install oh-my-zsh
RUN chsh -s /bin/zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zsh-autosuggestions && \
    sed -i '/^plugins=(/ s/)/ zsh-autosuggestions z sudo)/' ~/.zshrc && \
    curl -LO https://starship.rs/install.sh && sh install.sh --yes && \
    echo "eval \"$(starship init zsh)\"" >> ~/.zshrc && \
    rm install.sh && \
    mkdir -p ~/.config && \
    sed -i "s?# export PATH?export PATH?g" ~/.zshrc && \
    echo "export LANG=C.UTF-8" >> ~/.zshrc

RUN find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/list/* /usr/local/rvm/gems/ruby-2.*/cache/* /tmp/* /var/tmp/*

COPY content/starship.toml /root/.config/starship.toml
COPY content/.gdbinit /root/.gdbinit
COPY content/build_glibc.sh .

RUN cp -r /root/.gdbinit /root/.config /root/.oh-my-zsh /root/.zshrc /etc/skel/ && \
    adduser --disabled-password --gecos '' --shell /bin/zsh ctf && \
    echo "ctf ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


FROM scratch
# squash image

ARG proxy=
COPY --from=p / /
WORKDIR /home/ctf
ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy
USER ctf


CMD [ "/bin/zsh" ]