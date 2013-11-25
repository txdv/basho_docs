---
title: 安装 Erlang
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, erlang]
prev: "[[安装和升级]]"
up:   "[[安装和升级]]"
next: "[[在 Debian 和 Ubuntu 中安装]]"
---

Riak 需要 [[Erlang|http://erlang.org/]] {{#1.2.0+}}R15B01{{/1.2.0+}}{{#1.2.0-}}R14B03{{/1.2.0-}} 的支持。

为了能编译安装 Erlang，所用的操作系统必须安装兼容 GNU 的编译系统，还要绑定 ncurses 和 openssl。

<div class="note">
<div class="title">Erlang 版本提醒</div>
针对 Debian、Ubuntu、Mac OS X、RHEL 和 CentOS 的 Riak 二进制安装包中已经包含了 Erlang，因此无需再编译 Erlang 源码。不过，<strong>如果要完成“[[花五分钟安装]]”一文中介绍的内容，必须下载安装 Erlang</strong>。
</div>

## 使用 kerl 安装

如果想方便的安装不同的 Erlang 版本，可以使用 [kerl](https://github.com/spawngrid/kerl) 脚本。kerl 应该是从源码安装 Erlang 最简单的方式，一般只需执行几个命令即可。请执行下面的命令安装 kerl：

```bash
curl -O https://raw.github.com/spawngrid/kerl/master/kerl; chmod a+x kerl
```

若要在 Mac OS X 上安装 64 位 Erlang，必须明确告知 kerl，向 `configure` 命令传入正确的旗标。最简单的方法是创建 `~/.kerlrc` 文件，写入如下内容：

```text
KERL_CONFIGURE_OPTIONS="--disable-hipe --enable-smp-support --enable-threads
                        --enable-kernel-poll  --enable-darwin-64bit"
```

注意，在 FreeBSD/Solaris（包括 SmartOS）系统上编译 Erlang 时，必须禁用 HIPE，通过上面所示的 --disable-hipe` 选项设定。

在 GNU/Linux 上使用 kerl 编译和从源码编译的要求一样。

安装的 Erlang 版本是个硬性要求，从 Riak 1.2 其，必须使用 Erlang R15B01，命令如下：

```bash
./kerl build R15B01 r15b01
```

上述命令会自动编译 Erlang，代替你执行手动安装所需的步骤。

成功编译后，可以使用下面的命令安装：

```bash
./kerl install r15b01 ~/erlang/r15b01
. ~/erlang/r15b01/activate
```

最后一个命令激活了刚编译的 Erlang，并将其安装到 `~/erlang/r15b01`。更多可用的命令参见 [[kerl 自述文件|https://github.com/spawngrid/kerl]]。

如果你选择从源码手动安装 Erlang，请阅读下面的内容。

## 在 GNU/Linux 上安装

大多数 GNU/Linux 发行版本自带的并不是最新的 Erlang 版本，**因此需要自行从源码安装**。

首先，确保系统中安装了可用的编译系统，以及其他必要的依赖库。

### Debian/Ubuntu 系统的依赖库

使用下面的命令安装必要的依赖包：

```bash
sudo apt-get install build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev
```

如果你使用的是图形化环境（例如开发需要），而且想使用 Erlang 的 GUI 工具，还需要再安装一些依赖库。

<div class="info">注意，这些依赖库并不是操作 Riak 必须要安装的。如果在非图形化的服务器环境中安装 Riak，编译时提示缺少 wxWidgets，可以直接忽略。</div>

要安装支持图形化界面的包，请执行下面的命令：

```bash
sudo apt-get install libwxbase2.8 libwxgtk2.8-dev libqt4-opengl-dev
```

### RHEL/CentOS 系统的依赖库

使用下面的命令安装必要的依赖包：

```bash
sudo yum install gcc glibc-devel make ncurses-devel openssl-devel autoconf
```

### Erlang

然后，下载、编译 Erlang：

```bash
wget http://erlang.org/download/otp_src_R15B01.tar.gz
tar zxvf otp_src_R15B01.tar.gz
cd otp_src_R15B01
./configure && make && sudo make install
```

## 在 Mac OS X 上安装

在 Mac OS X 上安装 Erlang 有几种方法：从源码安装，使用 Homebrew 安装，使用 MacPorts 安装。

### 从源码安装

要想从源码安装，必须安装 Mac 附带 CD 中的 Xcode 工具包（还可以从 [Apple 开发者网站](http://developer.apple.com/)上下载）。

首先，下载然后解压源码：

```bash
curl -O http://erlang.org/download/otp_src_R15B01.tar.gz
tar zxvf otp_src_R15B01.tar.gz
cd otp_src_R15B01
```

然后设置 Erlang。


**Mountain Lion (OS X 10.8) 和 Lion (OS X 10.7)**
如果你使用的是 Mountain Lion (OS X 10.8) 或 Lion (OS X 10.7)，可以使用 LLVM（默认）或 GCC 编译 Erlang。

使用 LLVM：

```text
CFLAGS=-O0 ./configure --disable-hipe --enable-smp-support --enable-threads \
--enable-kernel-poll --enable-darwin-64bit
```

如果喜欢使用 GCC：

```text
CC=gcc-4.2 CPPFLAGS='-DNDEBUG' MAKEFLAGS='-j 3' \
./configure --disable-hipe --enable-smp-support --enable-threads \
--enable-kernel-poll --enable-darwin-64bit
```

**Snow Leopard (OS X 10.6)**
如果你使用的是 Snow Leopard (OS X 10.6) 或 Leopard (OS X 10.5)，且处理器是英特尔的：

```bash
./configure --disable-hipe --enable-smp-support --enable-threads \
--enable-kernel-poll  --enable-darwin-64bit
```

如果处理器不是英特尔的，或者使用的是更旧版本的 OS X：

```bash
./configure --disable-hipe --enable-smp-support --enable-threads \
--enable-kernel-poll
```

然后编译安装：

```bash
make && sudo make install
```

应该或提示你输入密码：

### 使用 Homebrew 安装

如果使用 Homebre 安装 Riak，请参照 [[Mac OS X 安装文档|在 Mac OS X 中安装]]中的步骤，会自动安装 Erlang。

要想使用 Homebrew 单独安装 Erlang，请执行下面的命令：

```bash
brew install erlang
```

### 使用 MacPorts 安装

使用 MacPorts 安装也很简单：

```bash
port install erlang +ssl
```
