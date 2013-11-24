---
title: 在 FreeBSD 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, freebsd]
prev: "[[在 Mac OS X 中安装]]"
up:   "[[安装和升级]]"
next: "[[在 SmartOS 中安装]]"
download:
  key: freebsd
  name: "FreeBSD"
---

在 AMD 64 位架构的 FreeBSD 系统上安装 Riak，可以使用二进制安装包或者从源码安装。

## 使用二进制安装包安装

<div class="info">
<div class="title">注意</div>
Riak 1.2 的安装包只支持 FreeBSD 9。很多用户反馈，在很多其他版本中从源码安装能成功。
</div>

从安装包安装 Riak 是最简单的，需要最少的依赖库，也比从源码安装用时少。

### 要求和依赖库

如果 Riak 命令行工具由 *riak* 之外的用户使用，需要 `sudo` 的支持。请确保在安装 Riak 包之前安装了 `sudo` 包。

Riak 安装包还需要 OpenSSL 的支持，在 FreeBSD 9 中安装 Riak 1.2 之前，需要先安装 `openssl-1.0.0_7`。

### 安装

在 FreeBSD 上安装 Riak 安装包，可以使用 `pkg_add` 的远程选项。这里我们要安装的是 `riak-{{V.V.V}}-FreeBSD-amd64.tbz`。

```bash
sudo pkg_add -r http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/freebsd/9/riak-{{V.V.V}}-FreeBSD-amd64.tbz
```

Riak 安装成功后，会显示一个消息，列出安装信息和文档的位置。

```text
Thank you for installing Riak.

Riak has been installed in /usr/local owned by user:group riak:riak

The primary directories are:

    {platform_bin_dir, "/usr/local/sbin"}
    {platform_data_dir, "/var/db/riak"}
    {platform_etc_dir, "/usr/local/etc/riak"}
    {platform_lib_dir, "/usr/local/lib/riak"}
    {platform_log_dir, "/var/log/riak"}

These can be configured and changed in the platform_etc_dir/app.config.

Add /usr/local/sbin to your path to run the riak, riak-admin, and search-cmd
scripts directly.

Man pages are available for riak(1), riak-admin(1), and search-cmd(1)
```

如果没显示这个消息，在安装过程中却显示了一个和 OpenSSL 相关的错误信息，类似下面这个：

```text
Package dependency openssl-1.0.0_7 for /tmp/riak-{{V.V.V}}-FreeBSD-amd64.tbz not found!
```

请确保按照**要求和依赖库**一节的说明安装了正确版本的 OpenSSL。

## 从源码安装

在 FreeBSD 上从源码安装 Riak 很显然在编译之前需要安装更多的依赖库（例如 Erlang），也比使用安装包用时久。

从源码安装可以更灵活的掌控设置，数据根目录，以及某些依赖库的版本。

### 要求和依赖库

从源码安装 Riak，在编译之前要安装一些依赖库。

如果还没有安装下面列出的软件，请通过包安装之。

* Erlang（也可以使用 kerl 安装，参见“[[安装 Erlang]]”一文）
* Curl
* Git
* OpenSSL（1.0.0_7）
* Python
* sudo

### 安装

首先从 [Basho 下载页面](http://basho.com/resources/downloads/)下载想要安装的版本。

然后，解压并编译源码：

```bash
tar zxf <riak-x.x.x>
cd riak-x.x.x
gmake rel
```

编译成功后，在 `rel/riak` 目录中会包含一个完整的 Raik 节点环境，包含设置、数据和日志子目录。

```text
bin               # Riak binaries
data              # Riak data and metadata
erts-5.9.2        # Erlang Run-Time System
etc               # Riak Configuration
lib               # Third party libraries
log               # Operational logs
releases          # Release information
```

如果需要搭建一个包含 4 个节点的开发环境，变成集群，把编译的目标由 `rel` 改成 `devrel`，如下所示：

```bash
gmake devrel
```

## 然后呢？

请阅读下面的文章：

-   [[安装之后要做的事|安装之后]]：安装后检查 Riak 的状态
-   [[花五分钟安装]]：介绍如何搭建一个包含 5 个节点的集群，并且概览了 Riak 的主要功能
-   [[基本设置]]：介绍如何从一个节点开始，变的比 Google 的节点还多！

## 资源列表

* [Basho 下载页面](http://basho.com/resources/downloads/)
* [[安装和升级]]
* [[安装 Erlang]]
* [使用 FreeBSD 的包系统](http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/packages-using.html)
* [使用 FreeBSD 的 Ports Collection](http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/ports-using.html)
