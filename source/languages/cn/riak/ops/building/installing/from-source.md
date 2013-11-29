---
title: 从源码编译安装 Riak
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, suse]
prev: "[[在 AWS Marketplace 中安装]]"
up:   "[[安装和升级]]"
next: "[[安装之后]]"
download:
  key: source
  name: "any OS in Source Form"
---

如果没有针对你所用平台的安装包，或者想对 Riak 开发做贡献，那就应该从源码安装 Riak。

## 依赖库

Riak 需要 [[Erlang|http://www.erlang.org/]] R15B01 的支持。*注意：暂时不要使用 Erlang R15B02 或 R15B03，因为这两个版本会导致 [riak-admin status 命令出错](https://github.com/basho/riak/issues/227)。*

如果还没有安装 Erlang，请参照“[[安装 Erlang]]”一文。不用担心，很简单！

Riak 依赖存储在多个 Git 仓库中的源码，在编译之前请确保系统中安装了 Git。

<div class='note'>Riak 不兼容 Clang，请确保 C/C++ 的默认编译器是 GCC。</div>

## 安装

下面介绍的方法会安装一个完整的 Riak，保存在 `$RIAK/rel/riak` 目录中，其中 `$RIAK` 是源码解压后的目录，或者克隆的源码所在目录。

### 从源码包安装

从[[下载中心|http://basho.com/resources/downloads/]]下载 Riak 源码包，然后编译：

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}.tar.gz
tar zxvf riak-{{V.V.V}}.tar.gz
cd riak-{{V.V.V}}
make rel
```

{{#1.4.0-}}
<div class='note'>如果遇到错误 `fatal: unable to connect to github.com`，请查看如下的说明，介绍如何在没有网络连接的系统上安装。</div>

### 在无网络连接的系统中安装

编译源码时遇到 `fatal: unable to connect to github.com` 错误是因为所在的系统无法连接到 GitHub。不是基于安全考虑关闭了端口，就是碰巧所用电脑无法连接到外部网络。要解决这个问题，下载源码时还要下载一个额外的文件。

下载针对 Riak {{VERSION}} 的 `leveldb`：

{{#1.3.0+}}`https://github.com/basho/leveldb/zipball/{{VERSION}}`{{/1.3.0+}}

{{#1.2.1}}`https://github.com/basho/leveldb/zipball/1.2.2p5`{{/1.2.1}}
{{#1.2.0}}`https://github.com/basho/leveldb/zipball/2aebdd9173a7840f9307e30146ac95f49fbe8e64`{{/1.2.0}}
{{#1.2.0-}}`https://github.com/basho/leveldb/zipball/14478f170bbe3d13bc0119d41b70e112b3925453`{{/1.2.0-}}

{{#1.3.0-}}

以下的步骤基于 Riak 1.2.0，请把相应文件修改为针对你所安装的版本。

下载完后，执行下面的命令：

```bash
$ mv 2aebdd9173a7840f9307e30146ac95f49fbe8e64 riak-1.2.0/deps/eleveldb/c_src/leveldb.zip
$ cd riak-1.2.0/deps/eleveldb/c_src/
$ unzip leveldb.zip
$ mv basho-leveldb-* leveldb
$ cd ../../../
$ make rel
```

{{/1.3.0-}}
{{#1.3.0+}}

以下的步骤基于 Riak 1.3.0，请把相应文件修改为针对你所安装的版本。

下载完后，执行下面的命令：

```bash
$ mv {{VERSION}} riak-{{VERSION}}/deps/eleveldb/c_src/leveldb.zip
$ cd riak-{{VERSION}}/deps/eleveldb/c_src/
$ unzip leveldb.zip
$ mv basho-leveldb-* leveldb
$ cd ../../
$ cp -R lager riaknostic/deps
$ cp -R getopt riaknostic/deps
$ cp -R meck riaknostic/deps
$ cd ../
$ make rel
```

{{/1.3.0+}}
{{/1.4.0-}}

### 从 GitHub 安装

[[Riak 在 Github 上的仓库|http://github.com/basho/riak]] 有从源码编译安装 Riak 更详细的介绍。克隆源码编译，请参照如下的步骤：

使用 [[Git|http://git-scm.com/]] 克隆仓库，然后编译：

```bash
git clone git://github.com/basho/riak.git
cd riak
make rel
```

## 针对特定平台的说明

针对特定平台的说明请参阅：

  * [[在 Debian 和 Ubuntu 中安装]]
  * [[在 Mac OS X 中安装]]
  * [[在 RHEL 和 CentOS 中安装]]
  * [[在 SUSE 中安装]]

如果你要安装 Riak 的平台没有列出了，而且需要一些帮助，请加入 Riak 邮件列表，然后发起新讨论。我们很乐意帮助你安装 Riak。

### Windows

Riak 现在无法在 Microsoft Windows 上安装。

## 然后呢？

请阅读下面的文章：

-   [[安装之后要做的事|安装之后]]：安装后检查 Riak 的状态
-   [[花五分钟安装]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
