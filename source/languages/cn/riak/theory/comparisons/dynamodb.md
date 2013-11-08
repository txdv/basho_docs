---
title: Riak Compared to DynamoDB
project: riak
version: 1.4.2+
document: appendix
toc: true
index: true
keywords: [comparisons, dynamodb]
---

本文旨在简略客观的从技术角度对比 Riak 和 Amazon DynamoDB。对比时使用的 DynamoDB 版
本是 API Version 2011-12-05，使用的 Riak 版本是 1.3.x。如果你觉得比较的结果不准确，
请[修正](https://github.com/basho/basho_docs/issues/new)，
或者发邮件到 **docs@basho.com**。

## 总体比较

* Riak 是开源项目，基于 Apache 2.0 协议。DynamoDB 是一个完整的 NoSQL 数据库服务，由 Amazon 提供，是 Amazon Web Services 的一部分。
* 因为 DynamoDB 是一项数据库服务，因此很多实现细节（语言，架构等）无法得到证实。

## 特性/性能对比

下面的表格站在一定的高度上对比了 Riak 和 DynamoDB 的特性和性能。为了保证这个
表格能跟上快速开发的节奏，较低层面的细节都链接到了 Riak 和 DynamoDB 的在线文档。

<table>
    <tr>
        <th WIDTH="15%">特性/性能</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">DynamoDB</th>
    </tr>
    <tr>
        <td>数据模型</td>
        <td>Riak 把键值对存储在称为 bucket 的命名空间中。
            <ul>
              <li>[[Bucket，键和值|Concepts#Buckets-Keys-and-Values]] </li>
            </ul>
        </td>
        <td>DynamoDB 的数据模型包括表，条目和属性。一个数据库中包含多张表。一个表中有很多条目，每个条目又有很多属性。
            <ul>
              <li>[[DynamoDB 数据模型|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DataModel.html]]</li>
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
        <td>所有条目都存储在固态硬盘（SSD）中，而且会在一个[[地区|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]的多个[[可用区域|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]上创建副本。
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
        <td>DynamoDB 是一项 Web 服务，使用 HTTP 传输数据，使用 JSON 作为消息序列化格式。除此之外还可以使用封装了 DynamoDB API 调用的 AWS SDK。
            <ul>
              <li>[[DynamoDB API 参考文档|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/API.html]]</li>
        <li>[[在 DynamoDB 中使用 AWS SDK|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/UsingAWSSDK.html]]</li>
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
        <td>DynamoDB 提供了三种查询数据的方式：
            <ul>
              <li>主键操作（GET, PUT, DELETE, UPDATE）</li>
              <li>[[查询|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/queryingdynamodb.html]]</li>
              <li>[[扫描|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/scandynamodb.html]]</li>
              <li>[[本地二级索引|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.html]]</li>
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

        <td>DynamoDB 中的数据是最终一致性的，也就是说如果刚写入就读取，得到的有可能不是最新的数据。不过 DynamoDB 也提供了请求最新版本数据的选项。
            <ul>
              <li>[[读取数据和并发考量|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/APISummary.html]]</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>并发性</td>
        <td>在 Riak 中，集群中的任何一个节点都可以处理另一个节点的读取和写入操作。Riak 为写入和读取提供了较高的可用性，把重担都交给读取时的客户端。
        </td>
        <td>专用资源会分配给数据表以满足性能需求，而且数据会自动分发到多个服务器以满足请求能力。
            <ul>
                <li>[[读/写流量限制预设|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ProvisionedThroughputIntro.html]]
            </ul>
        读写流量的单位需求在创建表时设定。发起 GET、UPDATE 或 DELETE 请求时，会消耗这些流量。
        <ul>
          <li>[[流量单位计算|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithDDTables.html#CapacityUnitCalculations]]</li>
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
        <td>DynamoDB 会同步地在一个[[地区|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]中的多个[[可用区域|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]中创建数据副本，避免单个设备或其他设施损坏导致数据丢失。
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
        <td>DynamoDB 要求，在创建数据表时要制定读写流量限制，这个流量后续可以根据需求修改。这么做可以保留足够的硬件资源，适当的把数据分布到多个服务器上，以满足流量需求。
          <ul>
            <li>[[读/写流量限制预设|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ProvisionedThroughputIntro.html]]
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
        <td>DynamoDB 可以把实例分布到同一[[地区|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]的多个[[可用区域|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]中，但不能跨[[地区|http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html]]。可用区域不是地理分散的。
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
        <td>DynamoDB 集成了 [[CloudWatch|http://aws.amazon.com/cloudwatch/]]，可以监控很多指标。
            <ul>
                <li>[[监控 Amazon DynamoDB|http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/MonitoringDynamoDB.html]]</li>
            </ul>
     </td>
    </tr>
</table>
