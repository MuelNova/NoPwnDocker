# NoPwnDocker

Ubuntu16.04 到 Ubuntu24.04，一键 Pwn Docker 环境

## 程序

| 程序名称                                                    | 说明                                          | 快捷键/用法                    |
| ----------------------------------------------------------- | --------------------------------------------- | ------------------------------ |
| python                                                      | python3.12                                    | `python`                       |
| [pwndbg](https://github.com/pwndbg/pwndbg)                  | GDB 调试增强插件                              | `gdb`                          |
| [Pwngdb](https://github.com/scwuaptx/Pwngdb)                | GDB 调试增强插件                              | `gdb`                          |
| [gef](https://github.com/bata24/gef)                        | GDB 调试增强插件，bata24 魔改，对内核支持更强 | `gdb`，输入 `gef-init`         |
| [one_gadget](https://github.com/david942j/one_gadget)       | 快速查找 libc 中的 execve("/bin/sh")          | `one_gadget libc.so.6`         |
| [ROPgadget](https://github.com/JonathanSalwan/ROPgadget)    | ROP gadget 查找工具                           | `ROPgadget --binary ./program` |
| [pwntools](https://github.com/Gallopsled/pwntools)          | PWN 开发框架                                  | Python 中 `from pwn import *`  |
| [seccomp-tools](https://github.com/david942j/seccomp-tools) | Seccomp 规则分析工具                          | `seccomp-tools dump ./program` |
| [ropper](https://github.com/sashs/Ropper)                   | 另一个 ROP gadget 查找工具                    | `ropper -f ./program`          |
| [tmux](https://github.com/tmux/tmux)                        | 终端复用工具                                  | `tmux` (前缀键 Ctrl+a)         |
| [fish](https://github.com/fish-shell/fish-shell)            | 友好的交互式 shell                            | 默认 shell                     |
| [z](https://github.com/jethrokuan/z)                        | 快速目录跳转                                  | `z 目录名`                     |
| [fzf.fish](https://github.com/PatrickF1/fzf.fish)           | 模糊查找增强                                  | Ctrl+R (历史), Ctrl+F (文件)   |

## 安装

```bash
git clone https://github.com/MuelNova/NoPwnDocker
cd NoPwnDocker
docker compose build
# or
# docker compose up -d
```

## 运行

如果使用 docker compose:

```bash
docker attach NoPwn2404
```

如果仅运行

```bash
docker run -it --rm \  # 如果需要持久化，则去掉 --rm
           --security-opt seccomp:unconfined \
           --cap-add SYS_PTRACE \
           --add-host host.docker.internal:host-gateway \
           -v "$(pwd):/ctf" nopwnv2:18.04  # 或是其他版本
```

## 配置

Docker 中 Python GDB 版本等均可自定义，至于 Proxy，思想实验觉得是可以设置的，未实验。

`docker-compose.ymlw`

```yaml
# 通用的构建参数
x-build-args: &build-args
  # 代理地址，在 Docker 中使用 host.docker.internal 访问主机
  # PROXY: "http://host.docker.internal:7897"
  PROXY: ""
  NO_PROXY: "localhost,127.0.0.1"
  # 使用国内镜像下载 apt
  USE_MIRROR: "no" # or "yes"
  # 额外包安装
  EXTRA_PACKAGES: "vim nano"

# 通用的服务配置
x-common: &common
  volumes:
    - ~/ctf:/ctf # 修改为你的目录
  cap_add:
    - SYS_PTRACE
  security_opt:
    - seccomp=unconfined
  extra_hosts:
    - "host.docker.internal:host-gateway"
  stdin_open: true
  tty: true

services:
  ubuntu24.04:
    build:
      context: .
      args:
        IMAGE: ubuntu:24.04
        <<: *build-args
        PYTHON_VERSION: 3.12.0
        GDB_VERSION: 15.2
        GDB_MULTIARCH: no
        RUBY_VERSION: 3.2.6
    <<: *common
    image: nopwnv2:24.04
    hostname: NoPwnV2_24.04
    container_name: NoPwn2404
```

```bash
docker compose build ubuntu24.04
```

## 信息

在 `amd R7 8845H + 32G RAM`，代理网络速度大约在 `7Mb/s` 的情况下，总共花费大约 `1600s` 完成镜像编译。

每个镜像在 `2.35GB ~ 2.77GB` 之间。
