# Modified from `skysider/pwndocker`

#############################
## Change the version here ##
#############################
FROM ubuntu:18.04
LABEL maintainer="Miu-Nova <n@ova.moe>"


#############################
## Change the config here  ##
#############################

# proxy
ENV HTTP_PROXY=http://172.17.0.1:7899

#############################
##       Config end        ##
#############################


ENV DEBIAN_FRONTEND noninteractive

ENV TZ Asia/Shanghai
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt install -y \
    libc6:i386 \
    libc6-dbg:i386 \
    libc6-dbg \
    locales \
    lib32stdc++6 \
    g++-multilib \
    cmake \
    curl \
    ipython3 \
    vim \
    net-tools \
    iputils-ping \
    libffi-dev \
    libssl-dev \
    python3-dev \
    python3-pip \
    build-essential \
    ruby \
    ruby-dev \
    tmux \
    strace \
    ltrace \
    nasm \
    wget \
    gdb \
    gdb-multiarch \
    netcat \
    socat \
    git \
    patchelf \
    gawk \
    file \
    python3-distutils \
    bison \
    rpm2cpio cpio \
    zstd \
    tzdata --fix-missing && \
    rm -rf /var/lib/apt/list/*


RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN python3 -m pip install -U pip && \
    python3 -m pip config set global.index-url http://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
    python3 -m pip install --no-cache-dir \
    ropgadget \
    z3-solver \
    smmap2 \
    apscheduler \
    ropper \
    unicorn \
    keystone-engine \
    capstone \
    angr \
    pebble \
    r2pipe \
    pwntools

RUN gem install one_gadget seccomp-tools && rm -rf /var/lib/gems/2.*/cache/*

RUN git config --global http.proxy ${HTTP_PROXY} && \
    git config --global https.proxy `echo ${HTTP_PROXY} | sed "s?http?https?g"`
RUN git clone --depth 1 https://github.com/pwndbg/pwndbg ~/pwndbg && \
    cd ~/pwndbg && chmod +x setup.sh && ./setup.sh

RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb

RUN curl -L https://raw.githubusercontent.com/hugsy/gef/main/gef.py -o  ~/.gdbinit-gef.py 

COPY content/.gdbinit /root/.gdbinit

RUN apt install -y zsh && chsh -s /bin/zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zsh-autosuggestions && \
    echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc


RUN curl -LO https://starship.rs/install.sh && sh install.sh --yes && \
    echo "eval \"$(starship init zsh)\"" >> ~/.zshrc && \
    rm install.sh && \
    mkdir -p ~/.config

COPY content/starship.toml /root/.config/starship.toml


# glibc
RUN apt-get install -y \
    gcc \
    make \
    libgetopt-argvfile-perl &&\
    rm -rf /var/lib/apt/list/*

WORKDIR /ctf/
COPY content/build_glibc.sh ./build_glibc.sh

RUN  chmod +x build_glibc.sh

RUN git clone --depth 1 https://github.com/niklasb/libc-database.git /ctf/libc-database
RUN git clone --depth 1 https://github.com/matrix1001/glibc-all-in-one /ctf/glibc_all_in_one && \
    cd /ctf/glibc_all_in_one && chmod +x update_list && \
    python3 update_list

# Utilities
RUN sed -i "s?# export PATH?export PATH?g" /root/.zshrc && \
    echo "export LANG=C.UTF-8" >> /root/.zshrc

RUN unset HTTP_PROXY


CMD /bin/zsh