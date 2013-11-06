---
title: Riak Compared to HBase
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, hbase]
---

本文旨在简略客观的从技术角度对比 Riak 和 HBase。对比时使用的 HBase 版
本是 0.94.x，使用的 Riak 版本是 1.2.x。如果你觉得比较的结果不准确，
请[修正](https://github.com/basho/basho_docs/issues/new)，
或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 和 HBase 都基于 Apache 2.0 协议
* Riak 基于 Amazon 的 Dynamo 论文；HBase 基于 Google 的 BigTable
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。HBase 全部使用 Java 开发

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 HBase 的特性和性能。为了保证这个
表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 HBase 的在线文档。

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
              <li>[[Bucket，键和值|Concepts#Buckets-Keys-and-Values]] </li>
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
              <li>[[Riak 支持的存储后台|Choosing a Backend]]</li>
            </ul>

            用户还可以使用 Riak 提供的[[后台 API|Backend API]]自行编写存储后台。
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
				<li>[[客户端代码库|Client Libraries]]</li>
                <li>[[社区项目|Community Projects]]</li>
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
                <li>[[MapReduce|Using MapReduce]]</li>
                <li>[[使用二级索引|Using Secondary Indexes]]</li>
                <li>[[使用搜索|Using Search]]</li>
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
              <li>[[向量时钟|Vector Clocks]]</li>
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
              <li>[[副本|Replication]]</li>
              <li>[[集群|Concepts#Clustering]]</li>
            </ul>
            Riak API 开放了可以调整的一致性和可用性参数，允许用户设置一个合适的水平。副本在 bucket 层面设置，要在第一次存储数据前设定好。后续的读写操作可以设置针对每次请求的参数。
            <ul>
                <li>[[读、写、更新数据|Concepts#Reading-Writing-and-Updating-Data]]</li>
            </ul>
        </td>
        <td>HBase supports in-cluster and between-cluster replication. In-cluster replication is handled by HDFS and replicates underlying data files according to Hadoop's settings. Between-cluster replicates by an eventually consistent master/slave push, or more recently added (experimental) master/master and cyclic (where each node plays the role of master and slave) replication.
        <ul>
        <li>[[Replication|http://hbase.apache.org/replication.html]]</li>
        </ul>
     </td>
    </tr>
    <tr>
        <td>Scaling Out and In</td>
        <td>Riak allows you to elastically grow and shrink your cluster while evenly balancing the load on each machine. No node in Riak is special or has any particular role. In other words, all nodes are masterless. When you add a physical machine to Riak, the cluster is made aware of its membership via gossiping of ring state. Once it's a member of the ring, it's assigned an equal percentage of the partitions and subsequently takes ownership of the data belonging to those partitions. The process for removing a machine is the inverse of this. Riak also ships with a comprehensive suite of command line tools to help make node operations simple and straightforward.
    <ul>
        <li>[[Adding and Removing Nodes]]</li>
        <li>[[Command Line Tools]]</li>
    </ul>
        </td>
        <td>HBase shards by way or regions, that automatically split and redistribute growing data. A crash on a region requires crash recovery. HBase can be made to scale in with some intervention on the part of the developer or DBA.
            <ul>
                <li>[[Regions|http://hbase.apache.org/book/regions.arch.html]]</li>
                <li>[[Node Management|http://hbase.apache.org/book/node.management.html]]</li>
                <li>[[HBase Architecture|http://hbase.apache.org/book/architecture.html]]</li>
            </ul>
    </td>
    </tr>
    <tr>
        <td>Multi-Datacenter Replication and Awareness</td>

        <td>Riak features two distinct types of replication. Users can replicate to any number of nodes in one cluster (which is usually contained within one datacenter over a LAN) using the Apache 2.0 licensed database. Riak Enterprise, Basho's commercial extension to Riak, is required for Multi-Datacenter deployments (meaning the ability to run active Riak clusters in N datacenters).
        <ul>
            <li><a href="http://basho.com/products/riak-enterprise/">Riak Enterprise</a></li>
        </ul>

        </td>
        <td>HBase shards by way of regions, that themselves may be replicated across multiple datacenters.
            <ul>
              <li>[[Node Management|http://hbase.apache.org/replication.html]]</li>
            </ul>
    </td>
    </tr>
    <tr>
        <td>Graphical Monitoring/Admin Console</td>
        <td>Riak ships with Riak Control, an open source graphical console for monitoring and managing Riak clusters.
            <ul>
                <li>[[Riak Control]]</li>
                <li>[[Introducing Riak Control|http://basho.com/blog/technical/2012/02/22/Riak-Control/]]
            </ul>
    </td>
        <td>HBase has a few community supported graphical tools, and a command-line admin console.
        <ul>
        <li>[[Admin Console Tools|http://hbase.apache.org/book/ops_mgt.html#tools]]</li>
        <li>[[Eclipse Dev Plugin|http://wiki.apache.org/hadoop/Hbase/EclipseEnvironment]]</li>
        <li>[[HBase Manager|http://sourceforge.net/projects/hbasemanagergui/]]</li>
        <li>[[GUI Admin|https://github.com/zaharije/hbase-gui-admin]]</li>
        </ul>
     </td>
    </tr>
</table>
