---
title: Basic Configuration
project: riak
version: 1.4.2+
document: tutorial
toc: true
audience: beginner
keywords: [operators, building, configuration]
---

这篇文档介绍了架构新集群时经常修改的选项，强烈推荐你在把集群部署到生产环境之前阅读内容更详细的 [[Configuration Files]] 文档。

本文讲到的所有设置都在各节点的 `app.config` 文件中，设置在节点重启后才能生效。

在合并组成集群之前，建议你把本文介绍的所有设置都做了。设置好 `app.config` 后，请阅读 [[Basic Cluster Setup]]，完成集群的架构。

要想知道节点是否属于集群，可以使用 [[riak-admin member-status|riak-admin Command Line#member-status]] 命令。

## 环的大小

Riak 中环的大小是构成集群的数据分区的数量。这个数会影响集群的稳定性和性能，而且**必须在集群开始接收数据之前设置好**。

如果环的太大，硬盘 的 IO 就会受到各服务器上同时运行的过量数据库造成的负面影响。

如果环太小，服务器上其他的资源（主要指 CPU 和 RAM）就得不到充分利用。

如何正确设置环的大小，请阅读 [[Planning for a Riak System]] 和 [[Scaling and Operating Riak Best Practices]]。

修改环大小的步骤取决于集群中的服务器（节点）是否已经合并了。

### 集群已经启用

如果集群已经启用了，在修改环大小时需要保护数据，可以把数据迁移到另一个集群，或者联系 Basho 讨论进行动态环大小修改操作的方法。

### 集群已合并，但无需保护数据

1. 去掉 `ring_creation_size` 参数的注释（去掉前面的 `%`），位于每个节点 `app.config` 文件的 `riak_core` 区，然后设置合适的值
2. 停掉所有节点
3. 删掉各节点的环数据文件（该文件的位置请查看 [[Backing up Riak]]）
4. 启动所有节点
5. 重新把各节点加入集群（详情请阅读 [[Adding and Removing Nodes|Adding and Removing Nodes#Add-a-Node-to-an-Existing-Cluster]]，或者读完本文，然后完成 [[Basic Cluster Setup]] 中的设置）

### 新服务器，还没合并成集群

1. 去掉 `ring_creation_size` 参数的注释（去掉前面的 `%`），位于每个节点 `app.config` 文件的 `riak_core` 区，然后设置合适的值
2. 停掉所有节点
3. 删掉各节点的环数据文件（该文件的位置请查看 [[Backing up Riak]]）
4. 读完本文，然后完成 [[Basic Cluster Setup]] 中的设置

### 查看环的大小

使用 `riak-admin` 命令可以查看环的大小：

    $ sudo /usr/sbin/riak-admin status | egrep ring
    ring_members : ['riak@10.160.13.252']
    ring_num_partitions : 8
    ring_ownership : <<"[{'riak@10.160.13.252',8}]">>
    ring_creation_size : 8

如果 `ring_num_partitions` 和 `ring_creation_size` 的值不一致，就说明 `ring_creation_size` 的值修改的太晚了，设置新值时某个步骤漏掉了。

注意，Riak 不允许两个环大小不一样的节点合并到集群中。

## 后台

最难决定的就是选择合适的后台了。所选的后台会严重影响 Riak 的性能和功能。

可选的后台参见 [[Choosing a Backend]]，文中列出了针对各种后台设置文档的链接。

和修改环的大小一样，变更后台也可能会丢失所有数据，所以在操作之前无比要用足够的时间计算、测评各种后台。

如果还是有疑问，请使用 [[Multi]] 后台，以便提供后期可扩展性。

如果真的要变更默认的后台（一般是 [[Bitcask]]），请确保修改了所有节点的设置。虽然可以，但节点之间使用不同的后台可不明智，这样做会限制后台功能的效力。

## 默认的 bucket 属性

bucket 的属性对性能和行为特性也很重要。

针对各 bucket 的属性可以动态修改，属性的默认值在 `app.config` 文件的 `riak_core` 区中设定。

下面是 bucket 默认设置的示例（如果没有设定这些设置，Riak 会自动为我们设置）。

```
{default_bucket_props, [
    {n_val,3},
    {r,quorum},
    {w,quorum},
    {allow_mult,false},
    {last_write_wins,false},
    ]}
```

简要说明一下这个设置：副本数为 3，必须收到 3 个副本中的 2 个才能把读或写操作视为成功的，不在应用程序中输出有冲突的值。

`r` 和 `w` 值在每次请求中都可以重设，`n_val` 很少需要修改，但选择一个适当的 `allow_mult` 值对一个稳健的应用程序来说就很重要了。

关于这些设置的详细介绍，请阅读 [[Eventual Consistency]] 和 [[Replication]]，以及 Basho 博客中的“Understanding Riak's Configurable Behaviors”系列文章：
[[第一部分|http://basho.com/understanding-riaks-configurable-behaviors-part-1/]],
[[第二部分|http://basho.com/riaks-config-behaviors-part-2/]],
[[第三部分|http://basho.com/riaks-config-behaviors-part-3/]],
[[第四部分|http://basho.com/riaks-config-behaviors-part-4/]] 和
[[后记|http://basho.com/riaks-config-behaviors-epilogue/]]。

如果修改了 `app.config` 文件中 bucket 的默认属性，而且也重启了节点，但现有的 bucket **不会** 受到直接影响。不过可以使用 [[HTTP Reset Bucket Properties]] 中介绍的方法强制使用新的默认值。

## 系统调校

在进行评测（[[benchmarking|Basho Bench]]）和部署集群之前，请阅读下面的文档。

* [[Open Files Limit]]
* [[File System Tuning]]
* [[Linux Performance Tuning]]
* [[AWS Performance Tuning]]
* [[Configuration Files]]

## 把节点合并起来

集群搭建的过程参见 [[Basic Cluster Setup]] 一文。
