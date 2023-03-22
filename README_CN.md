# NoPwnDocker
> **ENGLISH | [中文](README_CN.md)**

拥有高颜值强大终端的 PWN CTF 的 Docker 环境! 创建的原因是我再也不想配 pwn 环境啦！


这仅仅是我用于个人的仓库。这也是我第一次自己构建镜像。

你可以随心所欲修改自己的东西，或是提交一个 issue 告诉我你的建议（或者直接 PR 搞定！）

## Included
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
```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
docker compose up -d
```

## 配置
没有什么可以自定义的，但你确实有一些可以操作
- 打开 `Dockerfile`, 你能修改使用的版本，代理以及线程数。
- 打开 `docker-compose.yml`, 你能修改容器名
- 修改 `starship.toml` 来使用你自己的 starship 样式
- 修改 `build_glibc*.sh` 来更改存放路径（可能在下个版本中修改）
- 修改 `.gdbinit` 来使用你自己的 gdbinit 配置


## 用法和特点
### gdb
`init-gef`、`init-pwndbg` 来使用不同的 gdb 插件
### zsh
`zsh-syntax-highlighting` 和 `zsh-autosuggestions` 插件



## 更新频率
可能永远不会。或是当我想起来有什么有趣的东西可以被加入的时候。