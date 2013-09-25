---
title: Installing on SmartOS
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, smartos]
prev: "[[Installing on FreeBSD]]"
up:   "[[Installing and Upgrading]]"
next: "[[Installing on Solaris]]"
download:
  key: smartos
  name: "SmartOS"
---

下面介绍的安装方法适用于 Riak 1.2，在 SmartOS <strong>joyent_20120614T184600Z</strong> 上测试可行。文中介绍创建 Riak 节点的方法使用的是 SmartOS 的 root 用户。

## 打开文件限制

在安装之前，请确认系统的打开文件限制至少为 **4096**。请查看当前的限制：

```bash
ulimit -a
```

要想*只为当前的会话*临时提升限制，请使用下面的命令：

```bash
ulimit -n 65536
```

要想永久性提升限制，系统重启后也有效，请把下面的代码加入 `/etc/system`：

```text
set rlim_fd_max=65536
```

{{#1.3.0+}}

## 选择版本

SmartOS 虽然很强大，但在执行某些简单任务时却很困难（例如查看系统的版本）。SmartOS 正确地版本由 Global Zone 的快照版本和 Guest Zone 中的 pkgsrc 版本构成。这里提供一种决定使用哪个 Riak 安装包的方法。

Riak 真正关心的是 SmartOS VM 使用的数据集（dataset）。数据集来自 Joyent，使用 `dsadm` 命令可以查看，例如：

```
fdea06b0-3f24-11e2-ac50-0b645575ce9d smartos 2012-12-05 sdc:sdc:base64:1.8.4
f4c23828-7981-11e1-912f-8b6d67c68076 smartos 2012-03-29 sdc:sdc:smartos64:1.6.1
```

我们要找的是包名中的 `1.6` 和 `1.8`。这种方法虽然不完美，不过一旦知道了 SmartOS VM 所用的数据集，就知道使用哪个安装包了。

对于 Joyent Cloud 用户，如果不知道使用的是哪种数据集，可以在 Guest Zone 中输入下面的命令：

```
cat /opt/local/etc/pkgin/repositories.conf
```

* 如果返回 `http://pkgsrc.joyent.com/sdc6/2012Q2/x86_64/All` 或任何 *2012Q2* 相关的结果，就要下载 `1.8` 对应的安装包；
* 如果返回 `http://pkgsrc.joyent.com/sdc6/2011Q4/x86_64/All` 或任何 *2011* 相关的结果，就要下载 `1.6` 对应的安装包。

{{/1.3.0+}}

## 下载安装

下载针对 SmartOS 特定版本的 Riak 安装包{{#1.3.0}}*（我们安装的是针对 SmartOS 1.6 的 Riak，要安装针对 1.8 的 Riak，直接把下载地址中的 `1.6` 换成 `1.8` 即可）*{{/1.3.0}}：

{{#1.2.1-}}

```bash
curl -o /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/smartos/11/riak-{{V.V.V}}-SmartOS-i386.tgz
```

然后安装：

```
pkg_add /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz
```

{{/1.2.1-}}
{{#1.2.1}}

```bash
curl -o /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/smartos/11/riak-{{V.V.V}}-SmartOS-i386.tgz
```

然后安装：

```
pkg_add /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz
```

{{/1.2.1}}
{{#1.3.0}}

```bash
curl -o /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/smartos/1.6/riak-{{V.V.V}}-SmartOS-i386.tgz
```

然后安装：

```
pkg_add /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz
```

{{/1.3.0}}
{{#1.3.1+}}

```bash
curl -o /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz http://s3.amazonaws.com/downloads.basho.com/riak/{{V.V}}/{{V.V.V}}/smartos/1.8/riak-{{V.V.V}}-SmartOS-i386.tgz
```

然后安装：

```
pkg_add /tmp/riak-{{V.V.V}}-SmartOS-i386.tgz
```

{{/1.3.1+}}

安装完成后，启用 Riak 和 Erlang Port Mapper Daemon（epmd）服务：

```bash
svcadm -v enable -r riak
```

启用服务后，确保其在线：

```
svcs -a | grep -E 'epmd|riak'
```

上述命令的输出应该和下面的结果类似：

```text
online    17:17:16 svc:/network/epmd:default
online    17:17:16 svc:/application/riak:default
```

确保服务为 **online** 状态后，来 Ping 一下 Riak：

```bash
riak ping
```

Ping 的结果如果是 `pong`，说明节点已经创建，且可以连通；如果结果是 `pang`，说明节点已经创建，但有问题。如果节点没有创建，而且不可连通，会显示 *not responding to pings* 错误。

如果返回结果表明 Riak 成功运行了，就证明成功的在 SmartOS 上安装并设置了 Riak 服务。

## 然后呢？

现在 Riak 已经安装好了，请阅读下面的文章：

-   [[Post Installation Notes|Post Installation]]：安装后检查 Riak 的状态
-   [[Five Minute Install]]：介绍如何从一个节点开始，变的比 Google 的节点还多！
