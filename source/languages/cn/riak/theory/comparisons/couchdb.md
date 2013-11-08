---
title: Riak Compared to CouchDB
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, couchdb]
---

本文旨在简略客观的从技术角度对比 Riak 和 CouchDB。对比时使用的 CouchDB 版
本是 1.2.x，使用的 Riak 版本是 1.2.x。如果你觉得比较的结果不准确，
请[修正](https://github.com/basho/basho_docs/issues/new)，
或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 和 CouchDB 都基于 Apache 2.0 协议
* Riak 大部分都是使用 Erlang 开发的，还有少部分 C。CouchDB 全部是由 Erlang 开发的。

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 CouchDB 的特性和性能。为了保证这个
表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 CouchDB 的在线文档。

<table>
    <tr>

        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">CouchDB</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|Concepts#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>CouchDB 的数据格式是 JSON，存储在文档中（其中的记录无内在联系），然后以“database”这个命名空间分组。
            <ul>
                <li>[[文档 API|http://wiki.apache.org/couchdb/HTTP_Document_API]]</li>
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
        <td>CouchDB 通过“只能添加到最后”的文件把数据存到硬盘。随着文件数量的增多，需要不时进行压缩。
            <ul>
                <li>[[索引和文件|http://guide.couchdb.org/draft/btree.html]]</li>
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
        <td>CouchDB 提供有 HTTP API，可以用来访问数据，也可做数据库管理。
            <ul>
                <li>[[文档 API|http://wiki.apache.org/couchdb/HTTP_Document_API]]</li>
                <li>[[视图 API|http://wiki.apache.org/couchdb/HTTP_view_API]]</a></li>
                <li>[[DB API|http://wiki.apache.org/couchdb/HTTP_database_API]]</a></li>
            </ul>

            CouchDB 社区开发了很多客户端代码库。
            <ul>
              <li>[[客户端代码库|http://wiki.apache.org/couchdb/Related_Projects/#Libraries]]</li>
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
        <td>CouchDB 一般是直接通过 ID 查找进行查询的，也可以创建 MapReduce 视图生成可查询的索引用来查询，或者计算其他属性。除此之外，ChangesAPI 还可以按照最后修改时间的顺序列出文档。还要很多社区开发的插件，扩展了 CouchDB 的查询能力，例如全文搜索插件 CouchDB-Lucene。
            <ul>
                <li>[[视图|http://wiki.apache.org/couchdb/HTTP_view_API]]</li>
                <li>[[变更提醒|http://guide.couchdb.org/draft/notifications.html]]</li>
                <li>[[Lucene 插件|https://github.com/rnewson/couchdb-lucene/]]</li>
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

        <td>CouchDB 会为新版本的文档在不同的节点中创建副本，让其变成一个最终一致性的系统。CouchDB 使用“多版本并发控制”（Multi-Version Concurrency Control，MVCC）机制避免在写入时锁定数据库文件。数据冲突由应用程序在写入时解决。压缩只能附加到最后的数据库文件时，较旧版本的文档可能会丢失。
            <ul>
              <li>[[最终一致性|http://guide.couchdb.org/draft/consistency.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>
        <td>因为 CouchDB 的值只能附加到文件最后，单独的实例是无法被锁定的。在分布式系统中，如果没有之前的版本数，无法更新具有相似键的文档，而且冲突必须在写入之前手动解决。
            <ul>
                <li>[[不锁定|http://guide.couchdb.org/draft/consistency.html#locking]]</li>
                <li>[[冲突管理|http://guide.couchdb.org/draft/conflicts.html]]</li>
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
        <td>CouchDB 增量式地为文档的变化在不同的节点中创建副本。可以创建“主-主”副本，或者“主-从”副本。副本可以通过副本过滤器管良好控。
            <ul>
                <li>[[副本|http://wiki.apache.org/couchdb/Replication]]</li>
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
        <td>CouchDB 默认关注的是“主-主”副本（使用 MVCC 帮助解决冲突）。有一些项目可以用来管理 CouchDB 集群，例如 BigCouch（也基于 Apache 2.0 协议），可以把值分布到多个节点中。
            <ul>
                <li>[[BigCouch|http://bigcouch.cloudant.com/]]</li>
                <li>[[Sharding（维基百科）|http://en.wikipedia.org/wiki/Sharding]]</li>
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
        <td>适当设置后，CouchDB 可以运行在多个数据中心上。鲁棒意识需要第三方解决方案，或者自行开发副本过滤器。
            <ul>
                <li>[[过滤副本|http://wiki.apache.org/couchdb/Replication#Filtered_Replication]]</li>
                <li>[[裂脑|http://guide.couchdb.org/draft/conflicts.html#brain]]</li>
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
        <td>CouchDB 提供了图形化界面，叫做 Futon。
            <ul>
                <li>[[欢迎使用 Futon|http://guide.couchdb.org/draft/tour.html#welcome]]</li>
            </ul>
        </td>
    </tr>
</table>
