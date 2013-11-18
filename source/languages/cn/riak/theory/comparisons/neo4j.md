---
title: Riak Compared to Neo4j
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, neo4j]
---

本文旨在简略客观的从技术角度对比 Riak 和 Neo4j。

## 总体差异

Riak 和 Neo4j 的目的是保存不同的数据类型：

* Riak 是文档数据库，存储键值对，设计的目的是保存半结构化文档，或者不同大小的对象。
* Neo4j 是图形数据库，用来存储和遍历一系列相关信息（例如社会化网络）

大多数情况下，应用程序的需求可以清晰的表明应该使用键值对存储还是使用图形数据库。而且大多数情况下，都可以二者结合使用。像 Facebook 这种应用程序，可以把用户的个人资料、文章和图片存储在文档数据库中，而把朋友网络和关系存储在图形数据库中。

## 扩放性

Riak 可以弹性扩放，能很容易的从一个节点增加到 100 个节点。集群中增加新节点后，Riak 能自动重新分发数据，让集群中的每个服务器都分到相同比例的负载。类似的，如果减小集群规模，Riak 也会重新分配数据，把被删除的节点中的数据均匀的分给剩余的节点。

[[向 Riak 集群添加节点|Basic Configuration]]

Neo4j 设计的初衷则是运行在一个机器上，没有内建扩放到多个机器的功能。但这并不是说就无法运行在多个机器上，而是说应用程序中要有分片功能，而且要有能力果断划分数据，这可是很有挑战的，因为图形数据库一般都是存储随机连接的网络数据。如果无法果断分片数据，而是把数据复制到多个机器上，那么分片功能就要足够只能来协调 Neo4j 事务，因为 Neo4j 事务是绑定到单个机器上的。

_[[http://lists.neo4j.org/pipermail/user/2009-January/000997.html]]_
_[[http://en.wikipedia.org/wiki/Six_degrees_of_separation]]_

## 数据模型

Riak 可以存储半结构化文档或任意大小的对象。Riak 擅长存储用户资料、图片、.mp3 文件、订单或网站的会话信息。

[[Riak 的数据存储|Concepts#DataStorage]]

Neo4j 则使用节点、关系（一条线连接各节点）和属性存储数据。节点和关系上可以附属一系列属性。属性只能是 Java 语言的主要数据类型（int，byte，float 等）、字符串或者由主要类型和字符串组成的数组。关系是有类型的，可以这样表述关系：“PersonA KNOWS PersonB”，“PersonA IS_RELATED_TO PersonC”。

[[http://api.neo4j.org/current/org/neo4j/graphdb/PropertyContainer.html]]

## 写入时的冲突

如果两个进程试图使用不同的信息更新同一个数据，Riak 能通过向量时钟检测到。在分布式环境中，这种情况比想象中发生的次数要多：客户端可能会更新对象的缓存版本，或者网络隔断导致了客户端写入延时。这两种情况 Riak 都能检测到，然后通过向量始终决定要执行哪次更新操作，或者让客户端决定要使用哪个版本的数据。（可以想象一下两个用户同时编辑一个维基页面的情况。）

[[向量时钟|Vector Clocks]]

而 Neo4j 则和传统的 RDBMS 类似，支持可设置的 ACID 事务。客户端可以在隔离环境中更新图形的一部分，在提交事务之前这些改动对外是不可见的。如果多个事务修改同一份数据，Neo4j 内核会尝试同步这些变动。如果事务的相关性可能导致死锁，Neo4j 会检测到并抛出相应的异常。

* [[http://docs.neo4j.org/chunked/milestone/transactions.html]]

Riak 使用的方式可以确保数据库始终是可以写入的，而且写入操作一定能成功，即便是在网络隔断或者硬件失效的情况下，只要客户端能连接到集群中至少一个节点。不过，这样客户端读取数据时就要多做些工作来解决冲突，或者直接使用对象的最新版本（这是默认设置）。

Neo4j 使用的方法可以在第一时间避免产生冲突。这样客户端在写入数据时就要做些额外工作来检测和重试失败的事务，而且如前所述，事务只能修改单个机器上的数据。

## 查询

在 Riak 中可以使用一种简单的键值对模型获取数据。而且，Riak 支持链接和基于 JavaScript 的 Map/Reduce 查询：

链接可以在数据之间创建轻量级的指针，例如从 projects 指向 milestones，再指向 tasks，然后使用简单的客户端 API 命令沿着这个链读取数据。（在一定情况下，链接可以代替轻量级的图形数据库，只要链接的数量保持在很低的水平上，也就几十个，而不是几千个。）

基于 JavaScript 的 MapReduce 可以定义多个 map 和 reduce 步骤，连同一系列起始键传给 Riak 集群。Riak 像一个小型 Hadoop，实时执行 MapReduce 操作，并返回结果。所有数据处理过程都并行发生在所有机器上，在数据片段上运行的所有操作都运行在保存该数据的机器上。

* [[Riak 中的 MapReduce|Using MapReduce]]

Neo4j 则擅长查询网络信息。还是以 Facebook 为例，图形数据库可以缩短查找朋友的所有朋友所用的时间。在关系型数据库中，如果查询是从某行开始，递归联结到数以千计的行，那么就应该使用图形数据库。

在查询和遍历之前，Neo4j 要求必须提供一个起始节点。起始节点可以是上一次遍历得到的结果，也可以使用 Neo4j 生成的节点 ID 获取。如果使用后一种方法，应用程序就要把节点 ID 映射到实际值上，例如用户名。为了实现映射，Neo4j 目前和 Lucene 紧密集成，支持触及 Neo4j 和 Lucene 的 ACID 事务。除了 Lucene，任何与 JTA 兼容的 XA 资源都可以运用在 Neo4j 事务中。

* [[Neo4j 手册|http://docs.neo4j.org/]]
* [[http://highscalability.com/neo4j-graph-database-kicks-buttox]]