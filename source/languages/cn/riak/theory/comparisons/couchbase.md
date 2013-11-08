---
title: Riak Compared to Couchbase
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, couchbase]
---

本文旨在简略客观的从技术角度对比 Riak 和 Couchbase（例如 Couchbase Server）。
对比时使用的 Couchbase 版本是 2.0，使用的 Riak 版本是 1.2.x。如果你觉得比较的
结果不准确，请[修正](https://github.com/basho/basho_docs/issues/new)，
或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 基于 Apache 2.0 协议；Couchbase 有两个免费版本：开源的 Couchbase 基于 Apache 2.0 协议；Couchbase Server Community Edition（免费版）基于一个[社区认同的协议](http://www.couchbase.com/agreement/community)发布
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。Couchbase 由 Erlang 和 C/C++ 开发。

<div class="note">
    <div class="title">Couchbase vs CouchDB</div>
    注意，Couchbase 和 CouchDB 是两个不同的数据库项目。CouchDB 是文档数据库，支持副本、MapReduce 和 HTTP API。Couchbase 后端使用 CouchDB，在其上又包装了一些高级功能，例如缓存，其设计目的是在集群中使用。
</div>

<div class="note">
    <div class="title">Couchbase 2.0</div>
    在编写本文时，Couchbase 2.0 还处在开发者预览阶段，因此比较的结果可能和最终发布版有所不同。<i>读者要格外小心。</i>
</div>

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 Couchbase 的特性和性能。为了保证这个
表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 Couchbase 的在线文档。

<table>
    <tr>
        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">Couchbase</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|Concepts#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>Couchbase 是基于 JSON 的文档数据库。和其他文档数据库一样，记录存储在 bucket 中，记录之间没有内在联系。记录必须小于 20MB。
            <ul>
                <li>[[应该如何存储对象？|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-developing-bestpractices-objectstorage-how.html]]</li>
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
        <td>Couchbase 2.0 所存的数据基本上都在内存中，使用 CouchDB 的衍生项目和“couchstore”这个 C 语言库（以前的版本使用 SQLite 作为存储引擎）可以异步永持久存储数据。
            <ul>
            <li>[[持久存储|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-architecture-persistencedesign.html]]</li>
            <li>[[Couchbase 文件格式|https://github.com/couchbaselabs/couchstore/wiki/Format]]</li>
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
        <td>Couchbase 通过二进制 memcached 协议提供了对多种编程语言访问数据的支持。Couchbase 还提供了 REST API，用于监控和管理集群（不过不会用来直接管理所存的数据）。
            <ul>
                <li>[[客户端接口|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-introduction-architecture-clientinterface.html]]</li>
                <li>[[客户端代码库|http://www.couchbase.com/develop]]</li>
                <li>[[管理 REST API|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-admin-restapi.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>查询类型和查询能力</td>
        <td>There are currently four ways to query data in Riak
            <ul>
                <li>主键操作（GET, PUT, DELETE, UPDATE）</li>
                <li>[[MapReduce|Using MapReduce]]</li>
                <li>[[使用二级索引|Using Secondary Indexes]]</li>
                <li>[[使用搜索|Using Search]]</li>
            </ul>
        </td>
        <td>Couchbase 也提供了四种查询方式
            <ul>
                <li>[[ID 查找|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-developing-bestpractices-multiget.html]]</li>
                <li>[[MapReduce 视图|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-views-basics.html]]</li>
                <li>[[UnQL|http://www.couchbase.com/press-releases/unql-query-language]]</li>
            </ul>
            使用插件的话也可以支持 Hadoop。处理的过程中数据会流入 Hadoop 分布式文件系统（Hadoop Distributed File System，HDFS），或 Hive 中。
            <ul>
                <li>[[Hadoop 连接器|http://www.couchbase.com/develop/connectors/hadoop]]</li>
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

        <td>在同一个数据中心内，Couchbase 是强一致性的，如果遇到故障会在集群的其他节点上创建副本。多个数据中心之间的副本沿袭 CouchDB 的最终一致性副本机制。

            通过 CouchDB，在内部会为文档创建修订版本（存储在以“_rev”为后缀的值中）。不过，如果执行了文件压缩操作，之前的修订版本就会被删除，这样数据也就不可靠了。

            <ul>
                <li>[[Couchbase 的架构|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-architecture.html]]</li>
                <li>[[内部版本字段|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-views-datastore-fields.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>

        <td>Couchbase 声称在每个条目的层面上符合 ACID 原则，但不支持可以同时进行多个操作的事务（transaction）。Couchbase 客户端连接到一个服务器列表（或通过代理），其键是在节点之间共享的。Couchbase 继承了 memcached 的默认连接限制（也是推荐值），即 10k。

            <ul>
                <li>[[事务和并发性|http://www.couchbase.com/forums/thread/transaction-and-concurency]]</li>
                <li>[[集群设计|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-architecture-clusterdesign.html]]</li>
                <li>[[客户端代理|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-deployment-standaloneproxy.html]]</li>
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
        <td>Couchbase 支持两种类型的副本。在同个数据中心内，Couchbase 使用 membase 式的副本，遇到网络隔断会立即实现一致性。在多个数据中心之间，Couchbase 使用 master 到 master 副本。

            <ul>
                <li>[[CouchDB 副本|http://wiki.apache.org/couchdb/Replication]]</li>
                <li>[[Memcache Tap|http://code.google.com/p/memcached/wiki/Tap]]</li>
                <li>[[CouchDB, Couchbase, Membase|http://www.infoq.com/news/2012/05/couchdb-vs-couchbase-membase]]</li>
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
        <td>Couchbase 通过自动分片（auto-sharding）弹性地扩放。可以在管理界面增加或删除节点。

            <ul>
            <li>[[重新平衡|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-admin-tasks-addremove.html]]</li>
            <li>[[使用自动分片克隆增长|http://www.couchbase.com/couchbase-server/features#clone_to_grow]]</li>
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
        <td>Couchbase 2.0 支持在多个数据中心之间创建副本（XDCR）。

            <ul>
                <li>[[稳定 Couchbase Server 2.0|http://blog.couchbase.com/stabilizing-couchbase-server-2-dot-0]]</li>
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
        <td>Couchbase 提供了网页版监控和管理控制台。
            <ul>
                <li>[[网页版管理控制台|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-admin-web-console.html]]</li>
                <li>[[监控 Couchbase|http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-monitoring.html]]</li>
            </ul>
        </td>
    </tr>
</table>
