---
title: Installing on SUSE
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, suse]
prev: "[[Installing on Solaris]]"
up:   "[[Installing and Upgrading]]"
next: "[[Installing on Windows Azure]]"
---

下面介绍的方法可以告诉你如何在 SuSE 上安装 Riak。

Riak 可以在下面的 x86/x86_64 SuSE 变种上安装，由社区提供支持：

* SLES11-SP1
* OpenSUSE 11.2
* OpenSUSE 11.3
* OpenSUSE 11.4

Riak 安装包以及所有的依赖库（包括 Erlang）可以在 OpenSUSE Build Service (http://build.opensuse.org) Zypper 仓库中获取。

（下面的命令默认使用 root 用户执行）

## 添加 Riak 在 Zypper 中的仓库

```bash
$ zypper ar http://download.opensuse.org/repositories/server:/database/$distro Riak
```

$distro 是下面其中一个值：

* SLE_11_SP1
* openSUSE_11.2
* openSUSE_11.3
* openSUSE_11.4

_注意：把仓库添加到系统后第一次使用时，或许会询问是否接受该仓库的 GPG 密钥。_

## 安装 Riak

```bash
$ zypper in riak
```

上述命令会自定下载所需的依赖库，如果系统中没安装 Erlang 的话也会下载 Erlang。

## （可选）启动 Riak 仓库的刷新功能获得更新

```bash
$ zypper mr -r Riak
```

## 然后呢？

现在 Riak 已经安装好了，请阅读下面的文章：

-   [[Post Installation Notes|Post Installation]]：安装后检查 Riak 的状态
-   [[Five Minute Install]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
