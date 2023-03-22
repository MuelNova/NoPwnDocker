# NoPwnDocker
> **ENGLISH | [中文](README_CN.md)**

Beautiful and powerful terminal Docker environment for Pwn in CTF! Fuck the environment setup that's why this repo created.


I created this just for myself. It is my very first time making an image.

If you wish, you can modify it on your own, or open an issue to suggest how should I improve it. (Or simply open a PR!)

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

## How to use?
```bash
git clone https://github.com/Nova-Noir/NoPwnDocker
cd NoPwnDocker
sudo docker compose up -d
sudo docker exec -it ub18 /bin/zsh
```

## Configuration
There's not much can be modified. But you do can change something.
- open `Dockerfile`, you can change the version and proxy and thread number.
- open `docker-compose.yml`, you can change the container name.
- modify `starship.toml` to use your own starship style.
- modify `build_glibc*.sh` to change the directory( could be improved next version ).
- modify `.gdbinit` to use your own gdbinit config.


## Usage or features
### gdb
`init-gef`、`init-pwndbg` to load different gdb plugin.
### zsh
`zsh-syntax-highlighting` and `zsh-autosuggestions` plugins


## Update frequency
Maybe never. Or once I come up with some useful utilities in Pwn.

## command question
### `loc1@GLIBC_2.2.5' can't be versioned to common symbol 'loc1'
see https://patchwork.ozlabs.org/project/glibc/patch/20170623161158.GA5384@gmail.com/ (will be fixed in next version)