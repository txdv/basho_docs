---
title: Riak Glossary
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [appendix, concepts]
---

下面列出了一些术语，以及在 Riak 中的含义，还附带了一些链接指向详细的文档。

你还可以阅读“[[概念|Concepts]]”一文大致了解这些术语。

## Active Anti-Entropy (AAE)

一个一直运行的后台程序，比较并修复有分歧、丢失或损坏的副本。[[读取修复|Replication#Read-Repair]]
只在读取数据时触发，而 AAE 可以保证存储在 Riak 中全部数据的完整性。这个功能特别适合用于
存有“冰封数据”（很长时间不会被读取的数据，可能是几年）的集群。AAE 不像 `repair` 命令，
无需人工干预，会自动执行，而且从 Riak 1.3 开始默认启用。

* [[副本|Replication#Active-Anti-Entropy-AAE-]]

## Basho Bench

Basho Bench 是一个评测工具，用来进行准确且可重复的性能测试和压力测试，可以生成性能图表。

* [[Basho Bench]]
* [[GitHub 残酷|http://github.com/basho/basho_bench/]]

## Bucket

bucket 是存储在 Riak 中的数据的容器和键空间，可以为其设置很多属性（例如副本的数量，N 值）。
bucket 可以通过 URL 地址访问，例如 `/riak/bucket`。

* [[Buckets]]
* [[HTTP Bucket 操作|HTTP API#Bucket-Operations]]

## 集群

Riak 集群是一个 160 位整数空间，被分成大小相等的分区。Riak 环中的每个虚拟节点负责一个分区。

* [[集群|Clusters]]

## 一致性哈希

当哈希树数据结构再平衡时（增加或删除节点），一致性哈希可以限制重排键。Riak 使用一致性哈希
组织数据存储和副本。Riak 环中负责存储对象的虚拟节点决定了要使用一致性哈希技术。

* [[集群|Clusters]]
* [[维基百科：一致性哈希|http://en.wikipedia.org/wiki/Consistent_hashing]]

## 广播

Riak 使用“gossip 协议”在集群中分享和传播环状态及 bucket 的属性。只要节点在环中负责的区域
变化了，就会通过这个协议选择变动。每个节点还会定期向随机选择的其他节点发送自己的环状态，防止
有节点错过了之前的更新。

* [[集群|Clusters]]
* [[添加和删除节点|Adding and Removing Nodes#The-Node-Join-Process]]

## 提示移交

提议移交用来处理 Riak 集群中的节点失效，让临近的节点临时替代失效的节点存储数据。当失效的
节点重新加入集群后，临近节点中存储的数据会移交回来。

提示移交确保了 Riak 数据库的可用性。即便几点失效了，Riak 仍能继续处理请求，就像节点还在
时一样。

* [[恢复失效的节点|Recovering a Failed Node]]

## 键

键是对象的唯一标示符，作用域是 bucket。

* [[键和对象|Keys and Objects]]
* [[开发基础|The Basics]]

## Lager

[[Lager|https://github.com/basho/lager]] 是一个 Erlang/OTP 框架，是 Riak 默认的
日志程序。

## 链接

链接是附属在对象上的元数据。链接让建立对象之间的关联变得简单，只需在存储对象时添加
一个 `Link` 报头。

* [[链接|Links]]

## MapReduce

Riak 中的 MapReduce 可以让开发者对存储的键值对数据执行更复杂的请求。

* [[使用 MapReduce|Using MapReduce]]
* [[MapReduce 高级技术|Advanced MapReduce]]

## 节点

节点代表物理服务器。节点上运行着一定数量的虚拟节点，每个虚拟节点负责环上的一个分区。

* [[集群|Clusters]]
* [[添加和删除节点|Adding and Removing Nodes]]

## 对象

对象就是存储的值。

* [[键和对象|Keys and Objects]]
* [[开发基础|The Basics]]

## 分区

分区是 Riak 集群被分成的一系列空间。Riak 中的每个虚拟节点负责一个分区。数据存储在一定数量
的分区中，这取决于设定的 *n_val* 值。存储到那个分区取决于键的一致性哈希。

* [[集群|Clusters]]
* [[最终一致性|Eventual Consistency]]
* [[集群容量规划|Cluster Capacity Planning#Ring-Size-Number-of-Partitions]]

## 法定值

在 Riak 中，法定值有两个意思：

* 在判定为成功的请求之前，必须回响的副本数量。具体的值可以在 bucket 属性中设置，也可以在
  每次请求中通过请求参数指定（R,W,DW,RW）
* 一个符号，代表上面的数值，等于 `n_val / 2 + 1`。使用默认设置时为 `2`。

* [[最终一致性|Eventual Consistency]]
* [[CAP 控制|CAP Controls]]
* [[理解 Riak 的可配置行为：第 2 部分|http://basho.com/riaks-config-behaviors-part-2/]]

## 读取修复

读取修复是 Riak 使用的一种反熵机制，当读取请求得到的是陈旧数据时，可以主动更新陈旧的副本。

* [[读取修正详解|Replication]]

## 副本

副本是存储在 Riak 中的数据复制品。成功的读和写所需的副本数可以在 Riak 中设置，设置时应该考虑
应用程序的一致性和可用性需求。

* [[最终一致性|Eventual Consistency]]
* [[理解 Riak 的可配置行为：第 2 部分|http://basho.com/riaks-config-behaviors-part-2/]]

## Riak Core

Riak Core 是一个模块化分布式系统框架，是 Riak 可扩放性架构的基础。

* [[Riak Core|https://github.com/basho/riak_core]]
* [[Where To Start With Riak Core|http://basho.com/where-to-start-with-riak-core/]]

## Riak KV

Riak KV 是 Riak 的键值对存储。

* [[Riak KV|https://github.com/basho/riak_kv]]

## Riak Pipe

Riak Pipe 是驱动 MapReduce 的进程。对其最好的描述是“Riak 的 Unix pipe”。

* [[Riak Pipe|https://github.com/basho/riak_pipe]]
* [[Riak Pipe - the New MapReduce Power|http://basho.com/riak-pipe-the-new-mapreduce-power/]]
* [[Riak Pipe - Riak's Distributed Processing Framework|http://vimeo.com/53910999]]

## Riak Search

Riak Search 是分布式、可扩放、容错、实时、全文搜索引擎，在 Riak Core 中实现，和 Riak KV 紧密结合。

* [[使用搜索|Using Search]]
* [[高级搜索|Advanced Search]]

## 环

Riak 环是一个 160 位整数空间。这个空间被平均分成多个分区，每个分区有一个虚拟节点管理，而
虚拟节点则运行在物理服务器节点上。

* [[集群|Clusters]]
* [[集群容量规划|Cluster Capacity Planning#Ring-Size-Number-of-Partitions]]

## 二级索引（2i）

开发者可以通过二级索引使用一个或多个值标记对象，然后可以使用这些值查询对象。

* [[使用二级索引|Using Secondary Indexes]]
* [[二级索引高级技术|Advanced Secondary Indexes]]
* [[修复索引|Repairing Indexes]]

## 值

简单来说，Riak 就是一个键值对数据库。在 Riak 中，值就是 BLOBS（大型二进制对象），使用唯一
的键识别，类型不限，不过使用 JSON 格式有很多好处。

* [[键和对象|Keys and Objects]]
* [[开发基础|The Basics]]

## 向量时钟

Riak 利用向量时钟（简称 vclock）处理版本控制。Riak 集群中的每个节点都能处理请求，而不用
所有节点都参与，跟踪当前值就要进行记录数据的版本。当值存入 Riak 时，会附带一个向量时钟，
作为数据的初始版本。更新数据时，客户端会提供要修改对象的向量时钟，通过扩展这个向量时钟体现出
数据被更新了。Riak 通过对比对象不同版本的向量时钟来决定数据的特定属性。

* [[向量时钟|Vector clocks]]

## 虚拟节点

虚拟节点负责环中的分区，还会协调针对这些分区的请求。虚拟节点运行在物理节点之上，每个物理节点
上运行的虚拟节点数量取决于虚拟节点总数和集群中运行的物理节点数量。Riak 会在所有运行着的物理
节点上平均分配虚拟节点。

* [[集群|Clusters]]
