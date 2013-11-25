---
title: Riak 和 HBase 比较
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, hbase]
---

本文旨在简略客观的从技术角度对比 Riak 和 HBase。对比时使用的 HBase 版本是 0.94.x，使用的 Riak 版本是 1.2.x。如果你觉得比较的结果不准确，请[修正](https://github.com/basho/basho_docs/issues/new)，或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 和 HBase 都基于 Apache 2.0 协议
* Riak 基于 Amazon 的 Dynamo 论文；HBase 基于 Google 的 BigTable
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。HBase 全部使用 Java 开发

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 HBase 的特性和性能。为了保证这个表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 HBase 的在线文档。

<table>
    <tr>
        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">HBase</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|概念#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>HBase 的数据存储在预先定义好的列族格式中（每组数据有个键，还有任意数量的属性，每个属性都可以单独做版本控制）。HBase 中的数据是有序的，而且很稀疏，以列族分组（不像关系型数据库中是以行分组的）。在 HBase 中分组也叫做“表”。
            <ul>
                <li>[[HBase 数据模型|http://hbase.apache.org/book/datamodel.html]]</li>
                <li>[[支持的数据类型|http://hbase.apache.org/book/supported.datatypes.html]]</li>
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
        <td>HBase 使用的存储系统是 Hadoop 分布式文件系统（Hadoop Distributed File System，HDFS）。数据存储在 MemStores 和 StoreFiles 中，然后再流入硬盘（通过 HFiles 实现，这种格式基于 BigTable 的 SSTable）。实现的过程一般使用内置的由 JVM 管理的 IO 文件流。
            <ul>
             <li>[[HDFS|http://en.wikipedia.org/wiki/Apache_Hadoop#Hadoop_Distributed_File_System]]</li>
             <li>[[Hadoop 使用 HDFS|http://hbase.apache.org/book/arch.hdfs.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>数据访问和 API</td>
        <td>除了原始的 Erlang 接口，Riak 还提供了两种接口：
			<ul>
				<li>[[HTTP|HTTP API]]</li>
				<li>[[Protocol Buffers|PBC API]]</li>
			</ul>
			Riak 客户端代码库封装了这些 API，支持很多编程语言。
			<ul>
				<li>[[客户端代码库]]</li>
                <li>[[社区项目]]</li>
			</ul>
		</td>
        <td>HBase 基本上是通过运行在 JVM（Java，Jython，Groovy 等）中的代码进行通讯的。HBase 也支持其他协议，REST 和 Thrift（支持多种编程语言的数据服务格式）。
            <ul>
                <li>[[Java 接口|http://hbase.apache.org/book/architecture.html]]</li>
                <li>[[REST|http://wiki.apache.org/hadoop/Hbase/Stargate]]</li>
                <li>[[Thrift|http://thrift.apache.org/]]</li>
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
        <td>HBase 由两种查询方式：扫描整个有序键列表查找值（过滤值，或者使用二级索引），或者使用 Hadoop 执行 MapReduce 查询。
            <ul>
                <li>[[扫描|http://hbase.apache.org/book/client.filter.html]]</li>
                <li>[[MapReduce|http://hbase.apache.org/book/mapreduce.html]]</li>
                <li>[[二级索引|http://hbase.apache.org/book/secondary.indexes.html]]</li>
            </ul>
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
        <td>HBase 的读写时强一致的。数据可能会在整个地区中被自动分片，修改数据后就会自动重新分发。

            列族可以包含不限数量的版本，以及可选的 TTL。
            <ul>
                <li>[[一致性架构|http://hbase.apache.org/book/architecture.html#arch.overview.nosql]]</li>
                <li>[[Time to Live|http://hbase.apache.org/book/ttl.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>
        <td>HBase 能保证写入的原子性，并会锁定每个行。最近 HBase 还加入了多操作和多行的本地事务（不过无法混合使用读、写这两个操作）。
            <ul>
                <li>[[一致性保证|http://hbase.apache.org/acid-semantics.html]]</li>
                <li>[[http://hadoop-hbase.blogspot.com/2012/03/acid-in-hbase.html]]</li>
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
                <td>HBase 支持在集群内和集群间创建副本。集群内的副本由 HDFS 处理，底层的数据文件副本由 Hadoop 设置。集群间由最终一致性主从推送副本，或者由最近新加的主主推送和周期推送（各节点既可以作为主节点也可以作为从节点）。
        <ul>
        <li>[[副本|http://hbase.apache.org/replication.html]]</li>
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
        <td>HBase 根据线路和地区分片，自动分离并重新分发不断增多的数据。某个地区的数据损坏了，需要进行复原操作。HBase 的扩放需要开发者或 DBA 干预。
            <ul>
                <li>[[地区|http://hbase.apache.org/book/regions.arch.html]]</li>
                <li>[[节点管理|http://hbase.apache.org/book/node.management.html]]</li>
                <li>[[HBase 架构|http://hbase.apache.org/book/architecture.html]]</li>
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
        <td>HBase 根据线路和地区分片，因此可以在多个数据中心之间创建副本。
            <ul>
              <li>[[节点管理|http://hbase.apache.org/replication.html]]</li>
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
        <td>HBase 中有很多由社区开发的图形化工具和命令行管理控制台。
            <ul>
                <li>[[管理控制台工具|http://hbase.apache.org/book/ops_mgt.html#tools]]</li>
                <li>[[Eclipse 开发插件|http://wiki.apache.org/hadoop/Hbase/EclipseEnvironment]]</li>
                <li>[[HBase 管理器|http://sourceforge.net/projects/hbasemanagergui/]]</li>
                <li>[[GUI 管理|https://github.com/zaharije/hbase-gui-admin]]</li>
            </ul>
        </td>
    </tr>
</table>
