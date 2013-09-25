---
title: Installing on Solaris
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, solaris]
prev: "[[Installing on SmartOS]]"
up:   "[[Installing and Upgrading]]"
next: "[[Installing on SUSE]]"
download:
  key: solaris
  name: "Solaris"
---

下面介绍的安装方法适用于 Riak 1.3.1，在 Solaris 10 i386 上测试可行。文中介绍创建 Riak 节点的方法使用的是 Solaris 的 root 用户。

<div class="note">在 Solaris 上安装 Riak 之前，请确保系统中安装了 <code>sudo</code>，因为为了能正确操作，Riak 需要 <code>sudo</code> 的支持。</div>

## 打开文件限制

在安装之前，请确认系统的打开文件限制至少为 **4096**，可以通过 *nofiles(descriptors)* 查看当前值。使用 `ulimit` 命令查看当前值：

```bash
ulimit -a
```

要想*只为当前的会话*临时提升限制，请使用下面的命令：

```bash
ulimit -n 65536
```

要想永久性提升限制，系统重启后也有效，请把下面的代码加入 `/etc/system`：

```
set rlim_fd_max=65536
set rlim_fd_cur=65536
```

注意，重启后上述设置才会生效。

## 下载安装

下载你想在 Solaris 10 上安装的 Riak 版本：

{{#1.4.0-}}

```bash
curl -o /tmp/BASHOriak-{{V.V.V}}-Solaris10-i386.pkg.gz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/solaris/10/BASHOriak-{{V.V.V}}-1-Solaris10-i386.pkg.gz
```
{{/1.4.0-}}
{{#1.4.0+}}

```bash
curl -o /tmp/BASHOriak-{{V.V.V}}-Solaris10-i386.pkg.gz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/solaris/10/BASHOriak-{{V.V.V}}-Solaris10-x86_64.pkg.gz
```
{{/1.4.0+}}

然后安装：

```bash
gunzip /tmp/BASHOriak-{{V.V.V}}-Solaris10-i386.pkg.gz
pkgadd /tmp/BASHOriak-{{V.V.V}}-Solaris10-i386.pkg
```

安装完后，请把 `/opt/riak/bin` 加入用户的加载路径 PATH 中。然后，可以启动 Riak 了：

```bash
riak start
```

最后，ping 一下 Riak 确保其已经在运行了：

```bash
riak ping
```

Ping 的结果如果是 `pong`，说明节点已经创建，且可以连通；如果结果是 `pang`，说明节点已经创建，但有问题。如果节点没有创建，而且不可连通，会显示 *not responding to pings* 错误。

如果返回结果表明 Riak 成功运行了，就证明成功的在 Solaris 10 上安装并设置了 Riak 服务。

## 然后呢？

现在 Riak 已经安装好了，请阅读下面的文章：

-   [[Post Installation Notes|Post Installation]]：安装后检查 Riak 的状态
-   [[Five Minute Install]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
