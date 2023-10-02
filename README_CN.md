<div align="center">
  <img src="images/example.png">
</div>


<div align="center">

# NoPwnDocker

> **[ENGLISH](README.md) | 中文**

<a href="./LICENSE">
    <img src="https://img.shields.io/github/license/Nova-Noir/NoPwnDocker.svg" alt="license">
</a>

</div>


## 包含
- [zsh](https://www.zsh.org/)
- [oh-my-zsh](https://ohmyz.sh/)
- [starship](https://starship.rs/)
- [pwntools](https://github.com/Gallopsled/pwntools)  —— CTF framework and exploit development library
- [gef](https://github.com/hugsy/gef)
- [pwndbg](https://github.com/pwndbg/pwndbg)  —— a GDB plug-in that makes debugging with GDB suck less, with a focus on features needed by low-level software developers, hardware hackers, reverse-engineers and exploit developers
- [pwngdb](https://github.com/scwuaptx/Pwngdb) —— gdb for pwn
- [ROPgadget](https://github.com/JonathanSalwan/ROPgadget)  —— facilitate ROP exploitation tool
- [one_gadget](https://github.com/david942j/one_gadget) —— A searching one-gadget of execve('/bin/sh', NULL, NULL) tool for amd64 and i386
- [seccomp-tools](https://github.com/david942j/seccomp-tools) —— Provide powerful tools for seccomp analysis
- [ltrace](https://linux.die.net/man/1/ltrace)      —— trace library function call
- [strace](https://linux.die.net/man/1/strace)     —— trace system call

## 怎么使用
### Compose
```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
sudo docker compose up -d
sudo docker exec -it nopwndocker:ubuntu20.04 /bin/zsh
```

> 取决于你的电脑性能，镜像可能需要编译 30+ 分钟
> 会消耗 17GB~ 的磁盘空间

将你的 CTF 文件和自定义 GLIBC 放入 `challenge` 文件夹中

### 手动

```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
docker build . -t nopwndocker:ubuntu22.04 \
       --build-arg image=ubuntu22.04 --build-arg proxy=http://172.17.0.1:7890 --build-arg python-version=3.11.5
docker run -it \
           --platform linux/amd64 \
           --security-opt seccomp:unconfined \
           --cap-add SYS_PTRACE \
           --add-host host.docker.internal:host-gateway \
           -v "$(pwd)/challenge:/home/nopwn" \
           --tty nopwndocker:ubuntu22.04
```

## 用法和特点
### gdb
`init-gef`、`init-pwndbg` 来使用不同的 gdb 插件
### zsh
`zsh-autosuggestions` 插件
### build_glibc
一个一键编译带有调试符号的 glibc 的 shell 文件
`bash ~/build_glibc.sh -h`
> 在编译老版本的时候可能存在 BUG
> 在下面可以看到解决方法 (至少对我有效的)
#### `loc1@GLIBC_2.2.5' can't be versioned to common symbol 'loc1'
see https://patchwork.ozlabs.org/project/glibc/patch/20170623161158.GA5384@gmail.com/


## 更新日志
### 2023/10/02
:recycle: 重构 Dockerfile 和 docker-compose.yml 文件
### 2023/03/23  
:fire: 删除 `build_glibc32.sh` 以及 `build_glibc64.sh`, 添加通用脚本 `build_glibc.sh`。

:fire: 删除内建的 glibc 以缩小 Docker 大小与构建时间。