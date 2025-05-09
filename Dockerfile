ARG IMAGE=ubuntu:20.04
FROM ${IMAGE} AS base

# Args
ARG PROXY
ARG USE_MIRROR=no
ARG NO_PROXY="localhost,127.0.0.1"

# Env
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

ENV HTTP_PROXY=${PROXY}
ENV HTTPS_PROXY=${PROXY}
ENV NO_PROXY=${NO_PROXY}

RUN if [ "$PROXY" != "" ]; then \
        echo "Using proxy: ${PROXY}" && \
        echo "Acquire::http::Proxy \"${PROXY}\";" > /etc/apt/apt.conf.d/proxy.conf && \
        echo "Acquire::https::Proxy \"${PROXY}\";" >> /etc/apt/apt.conf.d/proxy.conf; \
    fi

RUN if [ "$USE_MIRROR" = "yes" ]; then \
        sed -i 's@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
        sed -i 's@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list; \
    fi

# Install
RUN apt-get update && apt-get install -y build-essential wget


# --- Stage 2: Build Python ---
FROM base AS python-build
ARG PYTHON_VERSION=3.12.0

RUN apt-get install -y zlib1g-dev \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    liblzma-dev \
    libreadline-dev \
    libncursesw5-dev \
    libgdbm-dev \
    libnss3-dev \
    uuid-dev && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}*


# --- Stage 3: gdb ---
FROM python-build AS gdb-build

ARG GDB_VERSION=15.2
ARG GDB_MULTIARCH=no

RUN apt-get install -y libgmp-dev libmpfr-dev&& \
    wget https://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.gz && \
    tar xzf gdb-${GDB_VERSION}.tar.gz && \
    cd gdb-${GDB_VERSION} && \
    if [ "$GDB_MULTIARCH" = "yes" ]; then \
        ./configure --with-python=python3 --enable-targets=all; \
    else \
        ./configure --with-python=python3; \
    fi && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf gdb-${GDB_VERSION}* && \
    rm -rf /var/lib/apt/lists/*

# --- Stage 4: Ruby ---
FROM base AS ruby-build

ARG RUBY_VERSION=3.2.6

RUN apt-get install -y \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    autoconf \
    bison \
    libyaml-dev \
    libgdbm-dev \
    libncurses5-dev \
    libffi-dev

RUN wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-${RUBY_VERSION}.tar.gz && \
    tar xzf ruby-${RUBY_VERSION}.tar.gz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure --disable-install-doc && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf ruby-${RUBY_VERSION}* && \
    rm -rf /var/lib/apt/lists/*

# --- Stage 5: Final ---
FROM base AS final

ARG EXTRA_PACKAGES=""

COPY --from=gdb-build /usr/local /usr/local
COPY --from=ruby-build /usr/local /usr/local

RUN apt-get install -y libyaml-0.2 git tmux && \
    if [ "$HTTP_PROXY" != "" ]; then \
        echo "Using proxy: ${HTTP_PROXY}" && \
        git config --global http.proxy ${HTTP_PROXY} && \
        git config --global https.proxy ${HTTP_PROXY}; \
    fi && \
    gem install --no-document one_gadget seccomp-tools && \
    pip3 install --no-cache-dir ropgadget pwntools ropper pwno

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg ~/.local/pwndbg && \
    cd ~/.local/pwndbg && \
    ./setup.sh && \
    git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/.local/Pwngdb && \
    wget -q https://raw.githubusercontent.com/bata24/gef/dev/install.sh -O- | sh && \
    mkdir -p ~/.local/gef && \
    mv /root/.gdbinit-gef.py ~/.local/gef/gef.py

RUN apt-get install -y fish curl && \
    mkdir -p ~/.config/fish && \
    # 安装 fisher 包管理器
    wget -qO- https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | \
    fish -c "source && fisher install jorgebucaran/fisher" && \
    # 安装一些有用的 fish 插件
    fish -c "fisher install jethrokuan/z" && \
    fish -c "fisher install PatrickF1/fzf.fish" && \
    # 设置为默认 shell
    chsh -s /usr/bin/fish

RUN if [ -n "$EXTRA_PACKAGES" ]; then \
    apt-get install -y $EXTRA_PACKAGES --no-install-recommends; \
fi

RUN apt-get remove -y ruby-dev python3-pip gdb python3-dev python3-venv python3-setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.cache/pypoetry/* && \
    pip3 cache purge && \
    rm -rf ~/.cache/pip && \
    gem cleanup && \
    rm -rf /usr/local/lib/ruby/gems/*/cache/ && \
    rm -rf ~/.gem && \
    # 一些优化
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3 /usr/local/bin/pip

COPY scripts/.gdbinit /root/.gdbinit
COPY scripts/config.fish /root/.config/fish/config.fish
COPY scripts/.tmux.conf /root/.tmux.conf

COPY scripts/compress_fs /usr/local/bin/compress_fs
COPY scripts/extract_fs /usr/local/bin/extract_fs

CMD ["/usr/bin/fish"]
