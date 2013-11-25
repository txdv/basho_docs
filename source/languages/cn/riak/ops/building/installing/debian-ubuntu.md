---
title: 在 Debian 和 Ubuntu 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, debian, ubuntu, linux]
prev: "[[安装 Erlang]]"
up:   "[[安装和升级]]"
next: "[[在 RHEL 和 CentOS 中安装]]"
download:
  key: debian
  name: "Debian or Ubuntu"
---

在基于 Debian 或 Ubuntu 的系统中可以使用二进制安装包安装 Riak，也可以[[编译源码安装|从源码编译安装 Riak]]。下面介绍的安装方法在 **Debian 6.05** and **Ubuntu 12.04** 上测试可行。

## 使用 Apt-Get 安装

如果你只想简简单单的安装 Riak，就使用 `apt-get` 吧。

首先需要获得签名密钥。

```bash
curl http://apt.basho.com/gpg/basho.apt.key | sudo apt-key add -
```

然后把 Basho 仓库添加到 apt 源列表（然后更新源）。

```
sudo bash -c "echo deb http://apt.basho.com $(lsb_release -sc) main > /etc/apt/sources.list.d/basho.list"
sudo apt-get update
```

现在可以安装 Riak 了。

```bash
sudo apt-get install riak
```

就这么简单。

## 使用包安装

如果想手动安装 deb 包，请阅读下面的说明。

### 在非 LTS Ubuntu 上安装

为了集中精力开发和测试功能，我们一般只为 LTS 版本提供的安装包。某些情况下，例如 Ubuntu 11.04 (Natty)，系统的变动影响了 Riak 的打包方式，所以我们针对这一版的非 LTS 单独发布了安装包。大多数情况下，如果你使用的是非 LTS（例如 12.10），完全可以按照下面针对 LTS 的说明安装。如果使用的是 12.10，参照针对 Ubuntu 12.04 的说明即可。

### Ubuntu 对 SSL 库的需求

在某些 Ubuntu 版本中，Riak 需要 libssl 0.9.8 的支持。从 Ubuntu 12.04 开始就没有这种要求了。在 Ubuntu 上使用安装包安装 Riak 之前，请先安装 `libssl0.9.8` 包。注意，这个版本的 libssl 可以和现有的 libssl 安全并存。

请执行下面的命令安装 libssl 0.9.8：

```bash
sudo apt-get install libssl0.9.8
```

安装 libssl 后，安装预先编译好的安装包请执行下面针对各平台的命令。

### 安装 64 位 Riak

#### Ubuntu Lucid Lynx (10.04)

{{#1.2.0-}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0-}}
{{#1.2.0+}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/ubuntu/lucid/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0+}}

#### Ubuntu Natty Narwhal (11.04)

{{#1.2.0-}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0-}}
{{#1.2.0+}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/ubuntu/natty/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0+}}


#### Ubuntu Precise Pangolin (12.04)

{{#1.2.0-}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0-}}
{{#1.2.0+}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/ubuntu/precise/riak_{{V.V.V}}-1_amd64.deb
sudo dpkg -i riak_{{V.V.V}}-1_amd64.deb
```

{{/1.2.0+}}


{{#1.2.1-1.3.9}}

### 安装 32 位 Riak

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/ubuntu/lucid/riak_{{V.V.V}}-1_i386.deb
sudo dpkg -i riak_{{V.V.V}}-1_i386.deb
```

<div class="note">
<div class="title">升级 Riak</div>

如果升级 Riak 包，用户 “riak” 将没有家目录，在启动 Riak 之前，请为其创建家目录（`/var/lib/riak`），然后执行 `chown riak:riak /var/lib/riak` 命令。
</div>

{{/1.2.1-1.3.9}}

<a id="Installing-From-Source"></a>
## 从源码安装 Riak

首先，使用 apt 安装 Riak 的依赖库：

```bash
sudo apt-get install build-essential libc6-dev-i386 git
```

Riak 需要 [Erlang](http://www.erlang.org/) R15B01 的支持。*注意：暂时不要使用 Erlang R15B02 或 R15B03，因为这两个版本会导致 [riak-admin status 命令出错](https://github.com/basho/riak/issues/227)。*

如果还没安装 Erlang，在继续阅读之前请先安装之。（详细方法请阅读“[[安装 Erlang]]”一文）

安装 Erlang 后，就可以下载、安装 Riak 了：

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}.tar.gz
tar zxvf riak-{{V.V.V}}.tar.gz
cd riak-{{V.V.V}}
make rel
```

如果编译成功，一个新 Riak 版本会出现在 `rel/riak` 目录中。

## 然后呢？

现在 Riak 已经安装好了，请阅读下面的文章：

-   [[安装之后要做的事|安装之后]]：安装后检查 Riak 的状态
-   [[花五分钟安装]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
