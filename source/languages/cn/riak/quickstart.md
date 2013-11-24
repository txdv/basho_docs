---
title: 花五分钟安装
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, 2i]
---

让我们来再本地电脑上安装 Riak，然后再搭建一个包含 [5 个节点](http://basho.com/why-your-riak-cluster-should-have-at-least-five-nodes/)的集群。

## 安装 Riak

Basho 提供的 Riak 安装包（可以在[[下载]]页面获取）内嵌了 Erlang 运行时，不过本页的教程是通过源码安装的，所以如果还没安装 Erlang，请先[[安装 Erlang]]。从源码安装 Riak 需要 Erlang R15B01 的支持。

### 获取源码

下面列出的链接包含了针对各平台的说明，告诉你如何下载并从源码安装 Riak。

  * [[Debian 和 Ubuntu|Installing on Debian and Ubuntu#Installing-From-Source]]
  * [[RHEL 和 CentOS|Installing on RHEL and CentOS#Installing-From-Source]]
  * [[Mac OS X|Installing on Mac OS X#Installing-From-Source]]
  * [[FreeBSD|Installing on FreeBSD#Installing-From-Source]]
  * [[SUSE|Installing on SUSE]]
  * [[Windows Azure|Installing on Windows Azure]]
  * [[AWS Marketplace|Installing on AWS Marketplace]]
  * [[其他操作系统|从源码编译安装 Riak]]

### 编译 Riak

下载完毕后就可以编译了，先进入 *riak* 源码所在的目录，然后执行 `make all` 命令。

```bash
$ cd riak-{{V.V.V}}
$ make all
```

`make all` 命令会获取 Riak 的依赖库，所以无需手动下载了。编译可能要花一点时间。

## 创建 5 个节点

Riak 编译完后，我们要使用 [Rebar](https://github.com/basho/rebar)（Erlang 程序的打包和编译工具）创建 5 个运行在本地电脑上的 Riak 节点。未来，如果要把 Riak 部署到生产环境中，使用 Rebar 可以把实现编译好的 Riak 上传到服务器。现在我们只关注本地这 5 个节点。{{#1.3.0+}}节点的数量可以通过 `DEVNODES` 指定。{{/1.3.0+}}运行下面的命令来创建节点：

{{#1.3.0+}}

```bash
$ make devrel DEVNODES=5
```
{{/1.3.0+}}
{{#1.3.0-}}

```bash
$ make devrel
```
{{/1.3.0-}}

这个命令会创建 `dev` 文件夹，进入这个文件夹看看其中的内容：

```bash
$ cd dev; ls
```

结果应该是这样的：

```bash
dev1       dev2       dev3       dev4       dev5
```

每个以 `dev` 开头的文件夹都是一个包含完整 Riak 包得节点。接下来我们要启动各个节点。先启动 `dev1`：

```bash
$ dev1/bin/riak start
```

<div class="note">
<div class="title">ulimit 提示</div>

执行上述命令后会看到一个提示信息，告知需要增加文件句柄限制（ulimit）。各平台的具体做法说明请参照“[[打开文件限制]]”一文。

</div>

然后对 `dev2` 到 `dev5` 执行相同的命令：

```bash
$ dev2/bin/riak start
$ dev3/bin/riak start
$ dev4/bin/riak start
$ dev5/bin/riak start
```

### 查看运行中的节点

启动节点后，要测试一下，确保可用。我们只需查看进程列表，执行下面的命令：

```bash
$ ps aux | grep beam
```

上述命令会给出正在运行的 5 个节点的详细信息。

## 搭建集群

下一步要把这 5 个节点放在一起搭建成集群。这个过程可以在 Riak Admin 工具中进行。具体而言，我们需要把 `dev2`、`dev3`、`dev4` 和 `dev5` 并入 `dev1`：

```bash
$ dev2/bin/riak-admin cluster join dev1@127.0.0.1
$ dev3/bin/riak-admin cluster join dev1@127.0.0.1
$ dev4/bin/riak-admin cluster join dev1@127.0.0.1
$ dev5/bin/riak-admin cluster join dev1@127.0.0.1
```

为了保证上述合并操作生效，首先要查看 `plan` 命令：

```bash
$ dev1/bin/riak-admin cluster plan
```

上述命令会给出一个概要，说明计划做什么事，以及所有事做完后集群是什么样的：

```bash
=============================== Staged Changes ================================
Action         Nodes(s)
-------------------------------------------------------------------------------
join           'dev2@127.0.0.1'
join           'dev3@127.0.0.1'
join           'dev4@127.0.0.1'
join           'dev5@127.0.0.1'
-------------------------------------------------------------------------------


NOTE: Applying these changes will result in 1 cluster transition

###############################################################################
                         After cluster transition 1/1
###############################################################################

================================= Membership ==================================
Status     Ring    Pending    Node
-------------------------------------------------------------------------------
valid     100.0%     20.3%    'dev1@127.0.0.1'
valid       0.0%     20.3%    'dev2@127.0.0.1'
valid       0.0%     20.3%    'dev3@127.0.0.1'
valid       0.0%     20.3%    'dev4@127.0.0.1'
valid       0.0%     18.8%    'dev5@127.0.0.1'
-------------------------------------------------------------------------------
Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0

Transfers resulting from cluster changes: 51
  12 transfers from 'dev1@127.0.0.1' to 'dev5@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev4@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev3@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev2@127.0.0.1'
```

最后，执行这些批处理：

```bash
$ dev2/bin/riak-admin cluster commit
```

<div class="info">
<div class="title">关于 riak-admin</div>

riak-admin 是 Riak 的管理工具。除了启动、停止节点之外所有操作都应该使用这个工具，例如加入或剔除集群，备份数据，以及集群的常规操作。详细说明请阅读 “[[riak-admin 命令]]”一文。

</div>

## 测试集群

现在我们运行了一个包含 5 个节点的 Riak 集群。下面我们来确保一下一切都运行正常。有几种检查方式，一个简单的方法是执行 `member-status` 命令。

```bash
$ dev1/bin/riak-admin member-status
```

上述命令会给出集群的概况，以及每个节点中环的使用量。

```bash
================================= Membership ==================================
Status     Ring    Pending    Node
-------------------------------------------------------------------------------
valid      20.3%      --      'dev1@127.0.0.1'
valid      20.3%      --      'dev2@127.0.0.1'
valid      20.3%      --      'dev3@127.0.0.1'
valid      20.3%      --      'dev4@127.0.0.1'
valid      18.8%      --      'dev5@127.0.0.1'
-------------------------------------------------------------------------------
Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0
```

如果需要，可以在 Riak 集群中放一个文件，测试相关功能是否正常。假设我们要放一个图片，测试是否可以读取。首先，复制一个图片到目录中：

```bash
$ cp ~/image/location/image_name.jpg .
```

然后使用 curl 命令把图片放入（通过 PUT 请求） Riak 集群中（你要使用的端口可能不同，请查看 `etc/app.config` 找到正确地 `http` 端口）：

```
$ curl -XPUT http://127.0.0.1:10018/riak/images/1.jpg \
  -H "Content-type: image/jpeg" \
  --data-binary @image_name.jpg
```

然后你可以检查一下图片是否真的存入了 Riak 集群。过程很简单，复制存入图片时使用地址，在浏览器中打开即可。应该是可以看到图片的。

现在包含 5 个节点的 Riak 集群已经搭建好了。恭喜你！

<div class="note">
<div class="title">HTTP 接口的端口</div>

上面的设置把节点的 HTTP 端口指定为 `10018`、`10028`、`10038` 和 `10048`，分别对应 dev1、dev2、dev3、dev4 和 dev5。如果只有一个节点，默认监听的端口是 8089。如果使用了默认提供的使用其他语言编写的客户端一定要注意这一点。

</div>
