---
title: 概念
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [appendix, concepts]
---

本文概览了 Riak 中用到的概念、技术选择以及实现细节。

## Riak 是什么

简单来说，Riak 是分布式可扩放的开源键值对存储系统。我们会说 Riak 是可以用于生产环境中最强大的开源分布式数据库。Riak 可以提前计划扩放方案，而且扩放起来很简单，后续开发也大大简化，用户可以快速的为应用程序创建原型，做测试及部署。

## 简介及历史

Riak 使用的技术基于 [[Basho Technologies|http://basho.com]] 公司之前为 Salesforce 开发的自动化业务。数据存储技术本身要比运行其上的应用程序更有趣，所以 Basho 决定围绕 Riak 开展商业运作。

Riak 受到 Dr. Eric Brewer 的 [[CAP 理论|http://en.wikipedia.org/wiki/CAP_theorem]]和 Amazon 的 Dynamo 的大量启发。Riak 的核心团队成员大都来自 Akamai，这让 Riak 更关注操作简便性和系统的容错功能。

## Riak API

编写 Riak 的团队还开发了一个 Erlang  REST 框架 [Webmachine](http://webmachine.basho.com)，所以 Riak 也使用了 [[REST API|HTTP API]]，作为从 Riak 中获取数据的两种方法之一。存储数据使用 HTTP 的 PUT 或 POST 请求，获取数据使用 HTTP 的 GET 请求。存储数据要提交到预先定义好的 URL，默认为 `/riak`。

除了 HTTP API 之外，Riak 还提供了功能完整的 [[Protocol Buffers API|PBC-API]]。这是一种简单的协议，基于 Google 的同名开源项目。

## 客户端代码库

Basho 和 Riak 社区开发了很多客户端代码库，用来连接 Riak。

目前，Basho 官方[[提供支持的客户端代码库|客户端代码库]]有 Ruby、Java、Erlang、Python、PHP 和 C/C++。

Riak 社区开发了针对其他语言及框架的客户端代码库，例如 Node.js、Go、Groovy、Haskell 等。

## bucket，键和值

[[Bucket]] 和[[键|键和对象]] 是在 Riak 中租出数据的唯一方式。数据通过“bucket/键”组合来存储和识别。每个键都对应一个唯一的值，类型不限。

## 集群

Riak 集群的核心是一个 160 位的整数空间，其被分成大小相等的分区。

物理服务器（在集群中叫做“节点”）上运行着一定数量的虚拟节点（简称“vnode”）。每个虚拟节点都会声明拥有环上的一个分区。运行的虚拟节点数取决于集群中物理节点的数量。

有个规则是，集群中的各节点负责环的 1/(物理节点总数)。要想知道各节点上的虚拟节点数量，可以计算 (分区总数)/(节点总数) 的值。例如，一个环上有 32 个分区，由 4 个物理节点组成，那么大概每个节点上有 8 个虚拟节点。如下图所示。

![Riak Ring](/images/riak-ring.png)

节点可以动态的添加到集群中，也可以动态的从集群中删除，节点变动后 Riak 会重新分发数据。

Riak 骨子里就是为分布式环境设计的。核心的操作，例如读写数据，执行 map/reduce 任务，在节点很多的集群中会变得更快。

### 无主控节点

Riak 集群中的所有节点的地位都是相同的。各节点都可以独自响应客户端的请求。这种特性可能是由于 Riak 使用了一致性哈希在集群中分发数据。

### 存储 implications

Riak 会把 bucket 的信息通过 [[gossip 协议|Riak 词汇表#Gossiping]] 广播到整个集群。一般来说，在 Riak 集群中存储大量的 bucket 是没有问题的，但在实际使用时，有两个潜在的限制，控制了 Riak 能处理的最大 bucket 数。

首先，没使用标准属性的 bucket 会要求 Riak 广播更多的数据。这些多出来的数据会把整个过程变慢，降低了性能。其次，有些后台会把各 bucket 存储为独立的实体。这会导致节点耗尽资源，例如文件句柄。这个限制不会影响到性能，但会引起其他的对 bucket 数量的限制。

## 副本

[[副本]] 是 Riak 结构的核心概念。Riak 通过 N 值控制存储的副本数量。每个节点都可以设置默认的 N 值，也可以在每个 bucket 中重设。Riak 对象会继承父级 bucket 的 N 值。同一集群中的所有节点应该使用相同的 N 值。

下图说明了 N 值为 3（默认值）时的情况。存储一个数据时，Riak 会将其存入环上的 3 个不同的分区。

![Riak Data Distribution](/images/riak-data-distribution.png)

Riak 使用一种称为“提示移交”的技术来弥补因节点失效带来的损失。临近的节点会担起责任，替代失效的节点，让集群正常运行。这算得上是一种自愈能力。

## 读，写，更新数据

如果客户端知道 bucket 和键，就可以通过 API 直接获取 Riak 中存储的对象。这是从 Riak 中获取数据最简单的方式。

### R 值

客户端请求时可以指定一个 R 值，设置必须收到这么多 Riak 节点的响应，才能判定这次读请求是成功的。这样即便有节点下线了或响应延迟了，Riak 仍能继续提供读取数据的能力。

### 读取失败容错

N 减去 R 得到的值就是 Riak 集群在无法提供读能力之前容许出现的节点下线和延迟数量。例如，一个集群有 8 个节点，N 值为 8，R 值为 1，那么在完全无法提供读能力之前，最多容许有 7 个节点下线。

### 链接遍历

Riak 还可以通过存储在对象中的链接获取对象。可以在一次请求中使用链接遍历获取一系列相关的对象。

### 向量时钟

每次更新 Riak 对象时都会记录一个[[向量时钟]]。向量时钟可以决定因果顺序，还能识别分布系统中的数据冲突。

### 解决冲突

Riak 中有两种方法可以解决更新 Riak 对象时出现的冲突。Riak 可以让最后一次更新取胜，或者返回数据的两个版本。这样客户端就可以自行处理有冲突的数据了。

### W 值

更新时客户端可以指定一个 W 值，设置必须收到这么多 Riak 节点的响应，才能判定这次更新操作是成功的。这样即便有节点下线或响应延迟了，Riak 仍能继续提供写入数据的能力。

### 写入失败容错

N 减去 R 得到的值就是 Riak 集群在无法提供写能力之前容许出现的节点下线和延迟数量。例如，一个集群有 8 个节点，N 值为 8，W 值为 2，那么在完全无法提供写能力之前，最多容许有 6 个节点下线。

## 本地硬盘存储以及可插入式后台

Riak 使用[[后台 API]]和存储子系统交互。使用这种 API，Riak 可以支持多种后台，更近所需进行选择。目前支持的后台请参看“[[选择后台]]”一文。最常用的两种后台时 Bitcask 和 LevelDB。

从 Riak 0.12 开始，[[Bitcask]] 是默认的后台。Bitcask 是一个简单却强大的本地键值对存储系统，是一种低迟延、高吞吐量的存储后台。

<div class="info">
<div class="title">Bitcask 的更多信息</div>

* [[Hello, Bitcask（来自 Basho 的博客）|http://blog.basho.com/2010/04/27/hello-bitcask/]]
* [[Bitcask 架构概述（PDF）|http://downloads.basho.com/papers/bitcask-intro.pdf]]

</div>

[[LevelDB]] 是 Google 开发的一个开源代码库，提供了有别于 Bitcak 的特性。如果要使用 Riak 的[[二级索引|使用二级索引]]功能，就必须使用 LevelDB。

## MapReduce

Riak 中的 [[MapReduce|使用 MapReduce]] 可以实时并行的使用整个集群的硬件资源处理数据。MapReduce 作业使用 JSON 格式表述，包含很多嵌套的 Hash，说明了输入、阶段和超时值。单个作业可以包含任意数量的 Map 和 Reduce 阶段。因此，Riak 中的 MapReduce 可以认为是一种实时的“mini-Hadoop”。作业通过 HTTP 提交，返回的结果时 JSON 格式的字符串。（Riak 也提供了 Protocol Buffers 接口。）

## 二级索引

Riak 1.0 添加了对[[二级索引|使用二级索引]]的支持。开发者可以利用这个功能使用一个或多个“字段/值”组合给 Riak 中存储的值打标签。对象则通过这些“字段/值”组合进行索引，应用程序可以查询这些索引取回一系列匹配的键。

索引基于对象，没有模式（schema）。索引在写入对象时创建。要修改对象的索引，直接写入有不同索引值的对象即可。

索引是实时的，而且是原子的。查询的结构会在写入操作完成后立即显现，所有的索引都存在对象所在的分区，这样对象就可以和其索引同步。

索引可以通过 HTTP 接口或 Protocol Buffers 接口写入及查询。而且，索引结果可以直接插入 Map/Reduce 操作，近一步过滤和处理索引查询结果。

## Riak Search

[[Riak Search|使用 Riak Search]] 是一个分布式、易于扩放、失败容错、实时、全文搜索引擎，在 Riak Core 中实现，和 Riak KV 紧密的结合。

通过 Riak Search 可以通过对象的值查找并取回 Riak 对象。在 Riak KV bucket 中启用搜索集成后（安装搜索 pre-commit 钩子），该 bucket 中的所有对象都会被 Riak Search 无缝索引。

## 提交钩子

[[提交 Hooks|使用 Commit 钩子]] 在数据持久化存储之前或之后执行，可以大大增强应用程序的功能。提交钩子可以：

-   对象未修改时进行写入
-   修改对象
-   让更新操作失败，禁止修改对象

Post-commit 钩子在操作完成后执行，而且不应该修改 riak\_object。在 post-commit 中修改 riak\_object 可以导致诡异的回馈循环，无限的执行钩子，除非钩子函数编写的很小心，包含终止这种循环的代码。

[[Pre- 和 post-commit 钩子|使用 Commit 钩子]] 是针对各 bucket 的，存储在 bucket 的属性中。每次成功响应客户端时执行一次。

## 链接和链接遍历

[[链接]] 是一些元数据，在对象之间建立一种单向关联，可以表示类似对象关联这种松散的模型。
