---
title: 在 Mac OS X 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, osx]
prev: "[[在 RHEL 和 CentOS 中安装]]"
up:   "[[安装和升级]]"
next: "[[在 FreeBSD 中安装]]"
download:
  key: osx
  name: "Mac OS X"
---

下面介绍的步骤在 Mac OS X {{#1.4.0-}}10.5 和 10.6{{/1.4.0-}}{{#1.4.0+}}10.8{{/1.4.0+}} 上可用。可以从源码安装或者下载预先编译好的 tarball 压缩包。

## 安装方式

* 预先编译好的 tarball 压缩包
* Homebrew
* 源码

<div class="note">
<div class="title">OS X 上的 ulimit</div>

OS X 中文件的打开句柄数很小，因此即便是文件句柄使用量很小的后台程序，也可能将其耗尽。更改句柄数量限制的方法参见“[[打开文件限制]]”一文。
</div>

## 使用预先编译好的 tarball 压缩包安装

要想使用语言编译好的 tarball 压缩包安装 Riak，请运行针对相应平台的命令：

{{#1.2.0-}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V}}-osx-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

### 32 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}-osx-i386.tar.gz
tar xzvf riak-{{V.V.V}}-osx-i386.tar.gz
```

{{/1.2.0-}}
{{#1.2.0}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.4/riak-{{V.V.V}}-osx-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

### 32 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.4/riak-{{V.V.V}}-osx-i386.tar.gz
tar xzvf riak-{{V.V.V}}-osx-i386.tar.gz
```

{{/1.2.0}}
{{#1.2.1}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.4/riak-{{V.V.V}}-osx-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

### 32 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.4/riak-{{V.V.V}}-osx-i386.tar.gz
tar xzvf riak-{{V.V.V}}-osx-i386.tar.gz
```

{{/1.2.1}}
{{#1.3.0-1.3.2}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.6/riak-{{V.V.V}}-osx-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

### 32 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.6/riak-{{V.V.V}}-osx-i386.tar.gz
tar xzvf riak-{{V.V.V}}-osx-i386.tar.gz
```

{{/1.3.0-1.3.2}}
{{#1.3.2-1.3.9}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.8/riak-{{V.V.V}}-osx-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

### 32 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.8/riak-{{V.V.V}}-osx-i386.tar.gz
tar xzvf riak-{{V.V.V}}-osx-i386.tar.gz
```

{{/1.3.2-1.3.9}}
{{#1.4.0+}}

### 64 位

```bash
curl -O http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/osx/10.8/riak-{{V.V.V}}-OSX-x86_64.tar.gz
tar xzvf riak-{{V.V.V}}-osx-x86_64.tar.gz
```

{{/1.4.0+}}
After the release is untarred you will be able to cd into the riak directory and execute bin/riak start to start the Riak node.

## 使用 Homebrew 安装

<div class="note">Homebrew 中安装 Riak 的脚本是由社区维护的，因此可能不是针对最新版 Riak 的。安装时请确保脚本安装的是最新版（如果不是最新版，也不用害怕，自己修改就是了）。</div>

使用 Homebrew 安装很简单：

```bash
brew install riak
```

如果没有安装 Erlang，Homebrew 会自定为你安装。

<a id="Installing-From-Source"></a>
## 从源码安装

必须先安装 Mac 附带 CD 中的 Xcode 工具包（还可以从 [Apple 开发者网站](http://developer.apple.com/)上下载）。

<div class="note">Riak 不兼容 Clang。请确保默认的 C/C++ 编译器是 GCC。</div>

Riak 需要 [[Erlang|http://www.erlang.org/]] R15B01 的支持。*注意：暂时不要使用 Erlang R15B02 或 R15B03，因为这两个版本会导致 [riak-admin status 命令出错](https://github.com/basho/riak/issues/227)。*

如果还没有安装 Erlang，请参照“[[安装 Erlang]]”一文。不用担心，很简单！

然后，下载解压源码：

```bash
wget http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/riak-{{V.V.V}}.tar.gz
tar zxvf riak-{{V.V.V}}.tar.gz
cd riak-{{V.V.V}}
make rel
```

如果编译时遇到关于“incompatible architecture”的错误，请确认编译 Erlang 时使用的架构是否和系统一致。（Snow Leopard 及以上版本：64 位{{#1.4.0-}}，其他版本：32 位{{/1.4.0-}}）

## 然后呢？

请阅读下面的文章：

-   [[安装之后要做的事|安装之后]]：安装后检查 Riak 的状态
-   [[花五分钟安装]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
