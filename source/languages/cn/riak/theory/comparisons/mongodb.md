---
title: Riak 和 MongoDB 比较
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, mongodb]
---

本文旨在简略客观的从技术角度对比 Riak 和 MongoDB。对比时使用的 MongoDB 版本是 2.2.x，使用的 Riak 版本是 1.2.x。如果你觉得比较的结果不准确，请[修正](https://github.com/basho/basho_docs/issues/new)，或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 基于 Apache 2.0 协议；MongoDB 基于 AGPL 协议
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。MongoDB 使用 C++ 开发

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 MongoDB 的特性和性能。为了保证这个表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 MongoDB 的在线文档。

<table>
    <tr>
        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">MongoDB</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|概念#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>MongoDB 使用的数据格式是 BSON（binary equivalent to JSON），以文档（所含的记录内在无关联）的形式存储。MongoDB 中的文档可以保存所定义的任何 BSON 类型，而且以集合分组。
            <ul>
                <li>[[文档|http://www.mongodb.org/display/DOCS/Documents]]</li>
                <li>[[数据类型和约定|http://www.mongodb.org/display/DOCS/Data+Types+and+Conventions]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>存储模型</td>
        <td>Riak 的存储系统是模块化可扩展的，允许用户根据寻妖选择适合的后台。默认的后台是 Bitcask。
            <ul>
              <li>[[Riak 支持的存储后台|选择后台]]</li>
            </ul>

            用户还可以使用 Riak 提供的[[后台 API]]自行编写存储后台。
        </td>
        <td>MongoDB 默认的存储系统是 Memory-Mapped Storage Engine，所有的硬盘 IO 都是用内存映射文件。数据冲刷到硬盘和分页是由操作系统负责的。
            <ul>
             <li>[[缓存|http://www.mongodb.org/display/DOCS/Caching]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>数据访问和 API</td>
        <td>Riak（除了原始的 Erlang 接口）主要提供了两种接口：
            <ul>
                <li>[[HTTP|HTTP API]]</li>
                <li>[[Protocol Buffers|PBC API]]</li>
            </ul>
            Riak 客户端代码库封装了这些 API，支持很多编程语言。
            <ul>
                <li>[[客户端代码库]]</li>
                <li>[[社区项目]] </li>
            </ul>
        </td>
        <td>MongoDB 使用自定义基于套接字的 Wire Protocal 和 BSON 作为交换格式。
            <ul>
                <li><a href="http://www.mongodb.org/display/DOCS/Mongo+Wire+Protocol">Mongo Wire Protocol</a></li>
            </ul>
            10Gen 和 Mongo 社区开发了很多客户端代码库。
            <ul>
              <li>[[客户端代码库|http://www.mongodb.org/display/DOCS/Drivers]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>查询类型和查询能力</td>
        <td>目前在 Riak 中有四种查询数据的方式
            <ul>
                <li>主键操作（GET, PUT, DELETE, UPDATE）</li>
                <li>[[MapReduce|使用 MapReduce]]</li>
                <li>[[使用二级索引]]</li>
                <li>[[使用 Riak Search]]</li>
            </ul>
        </td>
        <td>MongoDB 的查询接口和关系型数据库很像，还包含可以从所存文档创建的二级索引。MongoDB 还支持对文档进行 MapReduce 查询和即席查询（ad-hoc query）。而且也支持 Hadoop。
            <ul>
                <li>[[查询|http://www.mongodb.org/display/DOCS/Querying]]</li>
                <li>[[索引|http://www.mongodb.org/display/DOCS/Indexes]]</li>
                <li>[[MapReduce|http://www.mongodb.org/display/DOCS/MapReduce]]</li>
                <li>[[MongoDB 的 Hadoop 适配器|https://github.com/mongodb/mongo-hadoop]]</li>
            <ul>
        </td>
    </tr>
    <tr>
        <td>数据版本和一致性</td>
        <td>Riak 使用向量时钟推导存储数据的因果关系和过期情况。使用向量时钟可以让客户端始终能向数据库写入数据，在读取时由应用程序或客户端代码来解决冲突。还可以设置向量时钟基于数据的大小和寿命存储副本。还可以完全禁用向量时钟，使用简单的基于时间戳的“最后一次写入获胜”机制。
            <ul>
              <li>[[向量时钟]]</li>
              <li>[[为什么向量始终很简单|http://basho.com/blog/technical/2010/01/29/why-vector-clocks-are-easy/]]</li>
              <li>[[为什么向量始终很难|http://basho.com/blog/technical/2010/04/05/why-vector-clocks-are-hard/]]</li>
            </ul>
        </td>
        <td>MongoDB 是强一致性的数据库。通过次级读操作可以实现最终一致性的读取。每个分片中某个时刻 MongoDB 集群（有自动分片和副本）中都有一个主服务器。
            <ul>
              <li>[[关于分布式一致性|http://blog.mongodb.org/post/475279604/on-distributed-consistency-part-1]]</li>
            </ul>
        </td>
    </tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>
        <td>MongoDB 的一致性依赖于锁定。从 2.2 开始，MongoDB 为所有操作提供了 DB Level Lock。
            <ul>
                <li>[[锁定|http://docs.mongodb.org/manual/administration/monitoring/#locks]]</li>
                <li>[[DB Level Locking|https://jira.mongodb.org/browse/SERVER-4328]]</li>
                <li>[[如何处理并发？|http://www.mongodb.org/display/DOCS/How+does+concurrency+work]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>副本</td>
        <td>Riak 的副本系统重度依赖 Dynamo 和 Dr. Eric Brewer 的 CAP 定理。Riak 使用一致性哈希创建副本，然后把 N 个副本分发到由任意数量物理设备组成的集群中。在底层，Riak 使用虚拟节点处理数据的分发和动态平衡，因此解耦了从物理资源分发出来的数据。
            <ul>
              <li>[[副本]]</li>
              <li>[[集群|概念#Clustering]]</li>
            </ul>
            Riak API 开放了可以调整的一致性和可用性参数，允许用户设置一个合适的水平。副本在 bucket 层面设置，要在第一次存储数据前设定好。后续的读写操作可以设置针对每次请求的参数。
            <ul>
                <li>[[读、写、更新数据|概念#Reading-Writing-and-Updating-Data]]</li>
            </ul>
        </td>
        <td>Mongo 使用副本集合管理副本，这是一种异步主从副本。传统的主从副本也可以使用，但不推荐。
            <ul>
            <li>[[副本|http://www.mongodb.org/display/DOCS/Replication]]</li>
            <li>[[副本集合|http://www.mongodb.org/display/DOCS/Replica+Sets]]</li>
            <li>[[主从|http://www.mongodb.org/display/DOCS/Master+Slave]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>扩放</td>
        <td>Riak 允许用户弹性的提升和减小集群的大小，而且最终在每个设备上做到负载平衡。Riak 中没有特殊的节点，或者具有特殊角色的节点。也就是说，所有节点都是无主的。如果增加了物理设备，集群会通过环状态广播得知这一变化。一旦成为环成员后，就会赋给相同比例的分区，然后负责这些分区中的数据。删除设备就是上述过程的反操作。Riak 还提供了一套完整的命令行工具，让节点操作更简单直观。
            <ul>
                <li>[[添加和删除节点]]</li>
                <li>[[命令行工具]]</li>
            </ul>
        </td>
        <td>Mongo 集群的增大依赖于分片，随着数据的增长，要选定一个服务器来存储数据片段。
            <ul>
                <li>[[MongoDB 中的分片|http://www.mongodb.org/display/DOCS/Sharding]]</li>
                <li>[[分片介绍|http://www.mongodb.org/display/DOCS/Sharding+Introduction]]</li>
                <li>[[分片（维基百科）|http://en.wikipedia.org/wiki/Sharding]]</li>
            </ul>
            减小集群可以从数据库中删除分片。
            <ul>
                <li>[[删除分片|http://docs.mongodb.org/manual/administration/sharding/#remove-a-shard-from-a-cluster]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>在多数据中心之间创建副本</td>
        <td>Riak 中有两种类型的副本。用户可以使用 Apache 2.0 数据库在一个集群中创建任意数量的副本（通常在 LAN 中的同一个数据中心）。如果要在多个数据中心之间创建副本（可以在 N 个数据中心中运行 Riak 集群），就要使用 Riak Enterprise，Basho 开发的 Raik 商业扩展。
            <ul>
                <li><a href="http://basho.com/products/riak-enterprise/">Riak Enterprise</a></li>
            <ul>
        </td>
        <td>MongoDB 设置后可以运行在多个数据中心上。
            <ul>
                <li><a href="http://www.mongodb.org/display/DOCS/Data+Center+Awareness">Datacenter Awareness</a></li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>图形化监控/管理控制台</td>
        <td>Riak 提供有 Riak Control，这是个开源图形化控制台，可以监控和管理 Riak 集群。
            <ul>
                <li>[[Riak Control]]</li>
                <li>[[介绍 Riak Control|http://basho.com/blog/technical/2012/02/22/Riak-Control/]]
            </ul>
        </td>
        <td>MongoDB 没有提供图形化监控和管理控制台。不过很多由社区项目开发了图形化监控和管理程序。
            <ul>
                <li>[[监控和诊断|http://www.mongodb.org/display/DOCS/Monitoring+and+Diagnostics]]</li>
                <li>[[管理界面|http://www.mongodb.org/display/DOCS/Admin+UIs]]</li>
            </ul>

            10Gen 提供有托管的监控服务。

            <ul>
                <li><a href="http://www.10gen.com/mongodb-monitoring-service">Mongo 监控服务</a></li>
            </ul>
     </td>
    </tr>
</table>
