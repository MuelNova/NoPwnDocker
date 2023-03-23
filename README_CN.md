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


拥有高颜值强大终端的 PWN CTF 的 Docker 环境! 创建的原因是我再也不想配 pwn 环境啦！


这仅仅是我用于个人的仓库。这也是我第一次自己构建镜像。

你可以随心所欲修改自己的东西，或是提交一个 issue 告诉我你的建议（或者直接 PR 搞定！）

## 包含
- [zsh](https://www.zsh.org/)
- [oh-my-zsh](https://ohmyz.sh/)
- [starship](https://starship.rs/)
- [pwntools](https://github.com/Gallopsled/pwntools)  —— CTF framework and exploit development library
- [gef](https://github.com/hugsy/gef)
- [pwndbg](https://github.com/pwndbg/pwndbg)  —— a GDB plug-in that makes debugging with GDB suck less, with a focus on features needed by low-level software developers, hardware hackers, reverse-engineers and exploit developers
- [pwngdb](https://github.com/scwuaptx/Pwngdb) —— gdb for pwn
- [ROPgadget](https://github.com/JonathanSalwan/ROPgadget)  —— facilitate ROP exploitation tool
- [roputils](https://github.com/inaz2/roputils) 	—— A Return-oriented Programming toolkit
- [one_gadget](https://github.com/david942j/one_gadget) —— A searching one-gadget of execve('/bin/sh', NULL, NULL) tool for amd64 and i386
- [angr](https://github.com/angr/angr)   ——  A platform-agnostic binary analysis framework
- [seccomp-tools](https://github.com/david942j/seccomp-tools) —— Provide powerful tools for seccomp analysis
- [tmux](https://tmux.github.io/) 	—— a terminal multiplexer
- [ltrace](https://linux.die.net/man/1/ltrace)      —— trace library function call
- [strace](https://linux.die.net/man/1/strace)     —— trace system call

## 怎么使用
最简单
```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
sudo docker compose up -d
sudo docker exec -it ub18 /bin/zsh
```
推荐
```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
export ctf_name="<FOLDER_NAME>"
docker build . -t nopwndocker:ubuntu18.04
docker run  -it \
            -h ${ctf_name} \
            --name ${ctf_name} \
            -v $(pwd)/${ctf_name}:/ctf/ \
            --cap-add=SYS_PTRACE \
            nopwndocker:ubuntu18.04
```

## 配置
没有什么可以自定义的，但你确实有一些可以操作
- 打开 `Dockerfile`, 你能修改使用的版本，代理。
- 打开 `docker-compose.yml`, 你能修改容器名
- 修改 `starship.toml` 来使用你自己的 starship 样式
- 修改 `.gdbinit` 来使用你自己的 gdbinit 配置


## 用法和特点
### gdb
`init-gef`、`init-pwndbg` 来使用不同的 gdb 插件
### zsh
`zsh-syntax-highlighting` 和 `zsh-autosuggestions` 插件
### build_glibc
一个一键编译带有调试符号的 glibc 的 shell 文件
`bash ~/build_glibc.sh -h`
> 在编译老版本的时候可能存在 BUG
> 在下面可以看到解决方法 (至少对我有效的)
#### `loc1@GLIBC_2.2.5' can't be versioned to common symbol 'loc1'
see https://patchwork.ozlabs.org/project/glibc/patch/20170623161158.GA5384@gmail.com/



## 更新频率
可能永远不会。或是当我想起来有什么有趣的东西可以被加入的时候。

## 更新日志
### 2023/03/23  
:fire: 删除 `build_glibc32.sh` 以及 `build_glibc64.sh`, 添加通用脚本 `build_glibc.sh`。

:fire: 删除内建的 glibc 以缩小 Docker 大小与构建时间。