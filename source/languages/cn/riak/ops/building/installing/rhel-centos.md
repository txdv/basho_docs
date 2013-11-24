---
title: 在 RHEL 和 CentOS 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, rhel, centos, linux]
prev: "[[在 Debian 和 Ubuntu 中安装]]"
up:   "[[安装和升级]]"
next: "[[在 Mac OS X 中安装]]"
download:
  key: rhel
  name: "Red Hat or CentOS"
---

如果要在 CentOS 或 Red Hat 上安装 Riak，可以从源码安装，也可以使用我们提供的 .rpm 包。

## 注意

* CentOS 默认启用了 SELinux，如果遇到错误，或许需要将其禁用。
* Erlang OTP R15B01 和 Riak Enterprise 1.2 无法在 CentOS 5.2 上使用，但在 CentOS 5.3 及其以上版本中可以正常使用。

## 使用我们提供的 .rpm 包安装

### 针对 Centos 5 / RHEL 5

你可以使用 yum 安装（*推荐*），

```
sudo yum install http://yum.basho.com/gpg/basho-release-5-1.noarch.rpm
sudo yum install riak
```

也可以手动安装 rpm 包。

{{#1.2.0-}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}-1.el5.x86_64.rpm
sudo rpm -Uvh riak-{{V.V.V}}-1.el5.x86_64.rpm
```

{{/1.2.0-}}
{{#1.2.0+}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/rhel/5/riak-{{V.V.V}}-2.el5.x86_64.rpm
sudo rpm -Uvh riak-{{V.V.V}}-2.el5.x86_64.rpm
```

{{/1.2.0+}}

### 针对 Centos 6 / RHEL 6

你可以使用 yum 安装（*推荐*），

```
sudo yum install http://yum.basho.com/gpg/basho-release-6-1.noarch.rpm
sudo yum install riak
```

也可以手动安装 rpm 包。

{{#1.2.0-}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}-1.el6.x86_64.rpm
sudo rpm -Uvh riak-{{V.V.V}}-1.el6.x86_64.rpm
```

{{/1.2.0-}}
{{#1.2.0+}}

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/rhel/6/riak-{{V.V.V}}-2.el6.x86_64.rpm
sudo rpm -Uvh riak-{{V.V.V}}-2.el6.x86_64.rpm
```

{{/1.2.0+}}


## 从源码安装

Riak 需要 [[Erlang|http://www.erlang.org/]] R15B01 的支持。*注意：暂时不要使用 Erlang R15B02 或 R15B03，因为这两个版本会导致 [riak-admin status 命令出错](https://github.com/basho/riak/issues/227)。*

如果还没有安装 Erlang，请参照“[[安装 Erlang]]”一文。不用担心，很简单！

编译源码需要安装以下包：

* gcc
* gcc-c++
* glibc-devel
* make

可以使用 yum 安装这些包：

```bash
sudo yum install gcc gcc-c++ glibc-devel make git
```

现在可以下载安装 Riak 了：

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}.tar.gz
tar zxvf riak-{{V.V.V}}.tar.gz
cd riak-{{V.V.V}}
make rel
```

一个新 Riak 版本会出现在 `rel/riak` 目录中。

## 然后呢？

请阅读下面的文章：

-   [[安装之后要做的事|安装之后]]：安装后检查 Riak 的状态
-   [[花五分钟安装]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
