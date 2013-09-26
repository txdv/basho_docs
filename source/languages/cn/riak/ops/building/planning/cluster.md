---
title: Cluster Capacity Planning
project: riak
version: 1.4.2+
document: appendix
toc: true
keywords: [planning, cluster]
---

这篇文档很短，介绍规划 Riak 集群时要考虑的方方面面。具体的使用情况和环境变量肯定要看你的规划，这篇文档会帮助你正确地规划、搭建合用的 Riak 集群。

## RAM

在规划 Riak 集群时，[RAM](http://en.wikipedia.org/wiki/Random-access_memory) 是最重要的考虑因素。RAM 可以把数据存储在离用户更近的内存中，也是运行复杂 MapReduce 查询的先决条件，还能缓存数据减少请求迟延。

### Bitcask 及其内存需求

选择使用的存储后台直接影响着 RAM 用量。Riak 支持可插入式存储后台，默认使用 Bitcask，这也是生产环境推荐使用的后台。为什么呢？因为开发 Bitcask 的目的是为了：

* 减少请求迟延
* 大吞吐量
* 不影响性能的处理大于 RAM 的数据

不过 Bitcask 最主要的要求是要把整个“keydir”放在内存中。“keydir”是个哈希表，把一个 Bitcask（“一个 Bitcask”是指每个 Bitcask 后台中存储的所有文件）中的 bucket+key 映射到一个大小固定的结构上，这个结构表示了这个 bucket+key 所对应存储在硬盘上的文件，及其偏移和大小。

如果你想更深入的了解 keydir 是什么，其中包含的内容，更详细的了解 Bitcask，请访问[这个地址](http://blog.basho.com/2010/04/27/hello-bitcask/)和[这份文件](http://downloads.basho.com/papers/bitcask-intro.pdf)。（建议你一定要阅读）

如果算出的 RAM 用量超出了硬件资源（也就是说无力承担能使用 Bitcask 的 RAM），建议你使用 LevelDB。

规划使用 Bitcask 作为后台的集群，更详细的内容请阅读 [[Bitcask Capacity Planning]]。

### LevelDB

如果无法提供能使用 Bitcask 的 RAM 容量，Basho 推荐你使用 LevelDB 做后台。LevelDB 不需要太大的 RAM，给它能提供的最大内存量就能得到很好地性能。


<div class="info">
详细内容请阅读 [[LevelDB]]。
</div>

## 硬盘

现在你知道要用多大的 RAM 了，接下来要考虑硬盘容量了。硬盘容量的需求更容易计算，可以归纳成下面的公式：

<div class="info">
预计存储的对象总量 * 对象的平均大小 * n_val
</div>

例如：

* 存储 50,000,000 个对象
* 对象的平均大小为 2KB（2,048 字节）
* 使用默认的 n_val，3

那么你大概需要 **286GB** 的硬盘来存储整个集群的数据。

（在 Basho，我们相信数据库应该很耐用。考虑到这一点，开发时，我们要求 Riak 在能够写入硬盘的同时，把响应时间保持在用户的期待值之下。所以这个计算公式假设所有的数据都保存在硬盘上。）

把电脑设置成可以提供数据库服务的设备时的很多考虑点都可以应用在设置 Riak 节点上。挂载硬盘时不记录访问时间，以及把 OS 和 Riak 数据放在不同的硬盘可以更进一步提升性能。详细内容请阅读 [[System Planning|Planning for a Riak System]]。

## 读写性能分析

读写的比例，以及键访问的分布，会影响到集群的设置和架构。如果更多的是写操作，就不需要太多的缓存 RAM；而且如果只是经常访问某个特定区域中的键，例如[帕累托分布](http://en.wikipedia.org/wiki/Pareto_distribution)，就无需使用太多的 RAM 缓存这些键。

## 节点的数量

集群中节点的数量取决于数据复制的次数（参阅 [[Replicated|Replication]]）。为了保证集群总是能处理读写请求，Basho 推荐把副本数 N 设为 3。集群中包含 3 个或 4 个节点都可以（调整节点数量的方法参见 [Five Minute Install]]）。不过，在生产环境中部署时，我们建议最少要有 5 个节点，因为数量很小就违背了系统的容错功能。而且，在少于 5 个节点的集群中，响应请求的节点比例会很高（75-100%），集群中过度的负载可能会降低性能。关于这个推荐设置的详细信息请阅读[这篇博文](http://basho.com/blog/technical/2012/04/27/Why-Your-Riak-Cluster-Should-Have-At-Least-Five-Nodes/)。

## 环的大小和分区数量

环的大小是组成 Riak 集群的分区数量。这个数量在集群启动之前设置，在 app.config 文件的 [[ring_creation_size|Configuration Files#app-config]] 参数下面。

Riak 集群的默认分区数是 64，这个数字对小型的集群足够了，如果你计划扩建集群就要选择一个更大的数字。环的大小必须是 2 的幂数。每个节点的推荐分区数量是 10，每个节点分配的分区数量可以用分区的数量除以节点的数量得到。
{{#<1.4.0}}
**现在，你选择的环的大小在集群整个生命周期内都会保持不变，所以考虑增长需求是很重要的。**{{/<1.4.0}}

对于大多数中型 Riak 集群（8-16 个节点），128、256、512 个分区都是不错的选择，可以递增或递减集群。如果你无法确定要使用多少个分区，可以在 [Riak 邮件列表](http://lists.basho.com/mailman/listinfo/riak-users_lists.basho.com)中询问。

## 其他因素

Riak 是位集群环境而生的，这可以弥补网络隔断导致的问题，但却增加了系统的负担。而且，在缺少低迟延的 IO 访问的虚拟环境中运行可以大幅度的降低性能。把 Riak 集群部署到生产环境之前，建议你完全理解所用环境的功能，这样才能知道集群如何应对长时间负载。这么做可以帮助你为后续的增长设定集群的大小，获取最优性能。

Basho 推荐你使用 [[Basho Bench]] 测评集群的性能。

### 带宽

Riak 使用 Erlang 内建的分发能力提供了对数据的可靠访问性。Riak 集群可以部署到很多网络拓扑结构，不过建议尽量减少节点之间的迟延。高延迟带来的是次优性能。不建议把一个 Riak 集群部署到两个数据中心。如果你需要这种功能，Basho 提供了数据中心之间的复制选项，可以在多个不同地理位置的数据中心间同步数据。

* [更详细的了解 Riak Enterprise](http://basho.com/products/riak-overview/).

### IO

一般来说，Riak 最大的瓶颈是可用的 IO 量，特别是写操作很多的情况。在这一点上，Riak 和其他数据库很像，在选择硬盘时一定要考虑到 IO 问题。因为 Riak 是集群式的，而且数据存储在多个物理节点中，你应该考虑放弃使用传统的 RAID 创建冗余，把目光转向降低迟延，例如使用 SATA 驱动或 SSD。

## 进一步阅读

* [[System Planning|Planning for a Riak System]]
* [[Basho Bench]]
