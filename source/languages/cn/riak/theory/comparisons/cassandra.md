---
title: Riak Compared to Cassandra
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, cassandra]
---

本文旨在简略客观的从技术角度对比 Riak 和 Cassandra。对比时使用的 Cassandra 版
本是 1.2.x，使用的 Riak 版本是 1.2.x。如果你觉得比较的结果不准确，
请[修正](https://github.com/basho/basho_docs/issues/new)，
或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 和 Cassandra 都是基于 Apache 2.0 协议发布的数据库，而且都基于 Amazon Dynamo。
* Riak 忠实的实现了 Dynamo，在此基础上增加了一些功能，例如链接，MapReduce，索引，全文搜索。Cassandra 有点脱离 Dynamo，没有实现向量时钟，把基于分区的一致性哈希转到了键范围上，不过也添加了一些功能，例如保序分区函数和范围查询。
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。Cassandra 全部是由 Java 开发的。

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 Cassandra 的特性和性能。为了保证这个
表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 Cassandra 的在线文档。

<table>
    <tr>
        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">Cassandra</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|Concepts#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>Cassandra 的数据模型类似于列存储，包含键空间、列族（Column Families）和其他参数。
            <ul>
              <li>[[Cassandra 的数据模型|http://www.datastax.com/docs/0.7/data_model/index]] </li>
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
        <td>Cassandra 写入数据的过程是这样的，先写入一个提交日志，然后写入内存中的“内存表”（memtable），然后批量永久写入“有序字符串表”（sorted string table，SST）。
            <ul>
                <li><a href="http://wiki.apache.org/cassandra/ArchitectureCommitLog">提交日志</a></li>
                <li><a href="http://wiki.apache.org/cassandra/MemtableSSTable">内存表</a></li>
                <li><a href="http://wiki.apache.org/cassandra/ArchitectureSSTable">SSTable 概述</a></li>
                <li><a href="http://www.datastax.com/docs/1.1/dml/about_writes">关于写入</a></li>
                <li><a href="http://www.datastax.com/docs/1.1/dml/about_reads">关于读取</a></li>
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
                <li>[[客户端代码库|Client Libraries]]</li>
                <li>[[社区项目|Community Projects]] </li>
            </ul>
        </td>
        <td>Cassandra 提供了很多访问方式，包括 Thrift API，CQL (Cassandra Query Language) 和 CLI。
            <ul>
              <li><a href="http://www.datastax.com/docs/1.1/dml/about_clients">Cassandra 客户端 API</a></li>
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
        <td>Cassandra 提供了多种查询数据的方法：
            <ul>
                <li><a href="http://www.datastax.com/docs/0.7/data_model/keyspaces">键空间</a></li>
                <li><a href="http://www.datastax.com/docs/0.7/data_model/cfs_as_indexes">列族操作</a></li>
                <li><a href="http://www.datastax.com/docs/1.0/dml/using_cql">CQL</a></li>
                <li><a href="http://www.datastax.com/docs/0.7/data_model/secondary_indexes">二级索引</a></li>
                <li><a href="http://wiki.apache.org/cassandra/HadoopSupport#ClusterConfig">Hadoop 支持</a></li>
            <ul>
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
        <td>读取数据时，Cassandra 使用列族层的时间戳找出最新的值。Cassandra 没有内置数据版本功能。
            <ul>
              <li>[[关于读取的一致性|http://www.datastax.com/docs/1.1/dml/data_consistency#about-read-consistency]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>
        <td>Cassandra 中的所有节点地位都是相等的。从客户端发出的读取或写入请求可以到达集群中的任何一个节点。客户端和节点建立连接后发起读取或写入请求，该节点就充当这次操作的协调员。
            <ul>
                <li>[[关于客户端请求|http://www.datastax.com/docs/1.0/cluster_architecture/about_client_requests]]
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
        <td>在 Cassandra 中，选定分区函数后开始创建副本。分区函数包括 Random Partitioner（存储数据也要依靠一致性哈希），以及很多 Ordered Partitioner。在底层，物理节点分配了一个权标，用来决定节点在环中的位置，以及所负责的数据范围。
            <ul>
                <li>[[副本|http://www.datastax.com/docs/1.0/cluster_architecture/replication]]</li>
            </ul>

            和 Riak 一样，Cassandra 也允许开发者在每次请求中通过不同的 API 设置一致性和可用性参数。

            <ul>
                <li><a href="http://www.datastax.com/docs/1.1/dml/data_consistency#tunable-consistency">可调整的一致性</a>
            </ul>

        </td>
    </tr>
    <tr>
        <td>扩放</td>
        <td>Riak 允许用户弹性的提升和减小集群的大小，而且最终在每个设备上做到负载平衡。Riak 中没有特殊的节点，或者具有特殊角色的节点。也就是说，所有节点都是无主的。如果增加了物理设备，集群会通过环状态广播得知这一变化。一旦成为环成员后，就会赋给相同比例的分区，然后负责这些分区中的数据。删除设备就是上述过程的反操作。Riak 还提供了一套完整的命令行工具，让节点操作更简单直观。

            <ul>
                <li>[[添加和删除节点|Adding and Removing Nodes]]</li>
                <li>[[命令行工具|Command Line Tools]]</li>
            </ul>
        </td>
        <td>Cassandra 允许动态添加新节点，不过要手动计算节点的权标（可以交由 Cassandra 计算）。增加容量时建议扩充两倍的集群容量。如果无法做到，可以添加一些节点（要重新计算现有节点的权标），或者一次添加一个节点，留白初始权标，这么做“或许不会得到完美的均等环，但可以减少热区”。
            <ul>
              <li>[[扩容现有集群|http://www.datastax.com/docs/1.1/operations/cluster_management#adding-capacity-to-an-existing-cluster]]</li>
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

        <td>通过设置一些参数，可以让 Cassandra 支持在多个数据中心部署节点。
            <ul>
              <li>[[多数据中心|http://www.datastax.com/docs/1.1/initialize/cluster_init_multi_dc]]</li>
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
        <td>Datastax 开发了 DataStax OpsCenter 这是一个图形化用户界面，可以监控和管理 Cassandra 集群。DataStax OpsCenter 有免费版本，可以在生产环境中使用；也有付费版本，提供更多功能。
            <ul>
                <li>[[DataStax OpsCenter|http://www.datastax.com/products/opscenter]]</li>
            </ul>
        </td>
    </tr>
</table>
