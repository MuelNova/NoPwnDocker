ARG image=ubuntu:20.04
ARG proxy=

FROM $image as builder

WORKDIR /home/ctf
ARG proxy=
ARG python_version=3.11.5

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
    make -j$(nproc) && make altinstall -j$(nproc) && \
    make clean -j$(nproc) && cd .. && rm -rf Python-$python_version.tgz Python-$python_version && \
    ln -sf /usr/local/bin/python$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

RUN curl -fsSL https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.xz | tar -xJ && \
    cd gdb-13.2 && \
    if [ "$(lsb_release -rs)" != "16.04" ]; then \
        ./configure --enable-targets=all --with-python=python; \
    else \
        ./configure --with-python=python; \
    fi && \
    make -j$(nproc) && make install -j$(nproc)

RUN mkdir -p NoPwn/DEBIAN && mkdir -p NoPwn/usr/local/bin && mkdir -p NoPwn/usr/local/lib && mkdir -p NoPwn/usr/local/include && mkdir -p NoPwn/usr/share && \
    cp -r /usr/local/bin/python$(echo $python_version | awk -F. '{print $1"."$2}') NoPwn/usr/local/bin/ && \
    cp -r /usr/local/bin/pip$(echo $python_version | awk -F. '{print $1"."$2}') NoPwn/usr/local/bin/ && \
    cp -r /usr/local/lib/python$(echo $python_version | awk -F. '{print $1"."$2}') NoPwn/usr/local/lib/ && \
    cp -r /usr/local/include/python$(echo $python_version | awk -F. '{print $1"."$2}') NoPwn/usr/local/include/ && \
    cp -r /usr/local/bin/gdb* NoPwn/usr/local/bin/ && \
    cp -r /usr/local/include/gdb NoPwn/usr/local/include/ && \
    touch NoPwn/DEBIAN/control && \
    echo "Package: NoPwn\nVersion: $python_version\nSection: base\nPriority: optional\nArchitecture: amd64\nEssential: no\nMaintainer: NoPwn\nDescription: NoPwn" >> NoPwn/DEBIAN/control && \
    dpkg-deb -b NoPwn


FROM $image as p

ARG proxy=
ARG python_version=3.11.5

ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy
ENV NO_PROXY="security.ubuntu.com,mirrors.tuna.tsinghua.edu.cn"
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/nopwn

# COPY --from=builder /var/lib/apt/lists/* /var/lib/apt/lists/
# COPY --from=builder /usr/local/bin/gdb* /usr/local/bin/

# 换源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    echo "Acquire::http::Proxy false;\nAcquire::https::Proxy false;" >> /etc/apt/apt.conf.d/10-no-https-proxy
    # sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    # sed -i 's/http:/https:/g' /etc/apt/sources.list
    
RUN dpkg --add-architecture i386 && apt-get update && \
    apt-get install git vim tzdata libc6:i386 \
    libncurses5:i386 libstdc++6:i386 \
    patchelf net-tools gnupg2 netcat socat g++-multilib lib32stdc++6 \
    libffi-dev libssl-dev gcc-multilib make strace ltrace file \ 
    curl zsh lsb-release -y --fix-missing

COPY --from=builder /home/ctf/NoPwn.deb .

RUN dpkg -i NoPwn.deb && rm NoPwn.deb && \
    ln -sf /usr/local/bin/python$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip$(echo $python_version | awk -F. '{print $1"."$2}') /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

RUN pip install --upgrade pip && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
    pip install --no-cache-dir pwntools ropgadget ropper

RUN mkdir ~/.gnupg && if [ "$(lsb_release -rs)" != "16.04" ]; then \
        echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
    else \ 
        dirmngr </dev/null; \
    fi && \
    gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -ksSL https://get.rvm.io | bash -s stable && \
    if [ "$(lsb_release -rs)" != "22.04" ]; then \
        /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm install 2.7" && \
        ln -sf /usr/local/rvm/rubies/ruby-2.7.*/bin/ruby /usr/local/bin/ruby && \
        ln -sf /usr/local/rvm/rubies/ruby-2.7.*/bin/gem /usr/local/bin/gem; \
    else \
        apt-get install build-essential perl zlib1g-dev -y && \
        cd /usr/local/src/ && curl -LO https://www.openssl.org/source/openssl-1.1.1c.tar.gz && \
        tar -xf openssl-1.1.1c.tar.gz && cd openssl-1.1.1c && \
        ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib && \
        make -j$(nproc) && make install -j$(nproc) && \
        ln -sf /etc/ssl/certs/ certs && \
        /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm install 2.7 --with-openssl-dir=/usr/local/ssl" && \
        apt install openssl -y && \
        rm -rf /usr/local/src/openssl-1.1.1c.tar.gz /usr/local/src/openssl-1.1.1c && \
        ln -sf /usr/local/rvm/rubies/ruby-2.7.*/bin/ruby /usr/local/bin/ruby && \
        ln -sf /usr/local/rvm/rubies/ruby-2.7.*/bin/gem /usr/local/bin/gem && \
        echo "---\n:backtrace: false\n:bulk_threshold: 1000\n:sources:\n- http://rubygems.org/\n:update_sources: true\n:verbose: true\n:concurrent_downloads: 8" > ~/.gemrc; \
    fi 

RUN gem install one_gadget seccomp-tools && \
    ln -sf /usr/local/rvm/rubies/ruby-2.7.*/bin/one_gadget /usr/local/bin/one_gadget && \
    ln -sf /usr/local/rvm/gems/ruby-2.*/bin/seccomp-tools /usr/local/bin/seccomp-tools

COPY content/pwndbg.sh /tmp/pwndbg.sh
RUN git clone --depth 1 https://github.com/pwndbg/pwndbg ~/pwndbg && \
    cd ~/pwndbg && mv /tmp/pwndbg.sh install.sh && ./install.sh && \
    git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb && \
    curl -L https://raw.githubusercontent.com/hugsy/gef/main/gef.py -o  ~/.gdbinit-gef.py 


# Install oh-my-zsh
RUN chsh -s /bin/zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zsh-autosuggestions && \
    echo "plugins=(git z zsh-autosuggestions sudo)" >> ~/.zshrc && \
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

FROM scratch
# squash image

ARG proxy=
COPY --from=p / /
WORKDIR /home/ctf
ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy


CMD [ "/bin/zsh" ]