---
title: Inspecting a Node
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [operator, status, riaknostic]
---

检查 Riak 节点收集性能指标或为了发现潜在问题时，有很多工具可以使用，其中有些是 Riak 内建的，
有些是 Riak 社区开发的。

本文简单介绍了如何使用这些工具检查 Riak 节点。

## riak-admin status


`riak-admin status` 是 `riak-admin` 命令的子命令，每个 Riak 都有。`status` 命令可以
显示节点当前运行状态相关的数据。`riak-admin status` 命令的输出结果分类介绍如下。

注意，某些计数器至少需要 5 个事务（transaction）才能收集到统计数据。

### 一分钟

一分钟计数器是一系列数据收集点，描绘出过去一分钟某节点上特定操作执行的次数。

例如：

-   **node\_gets** 某节点前一分钟处理的 GET 请求数量，包括该节点上非本地虚拟节点处理的 GET 请求
-   **node\_gets\_total** 自节点启动以来处理的 GET 请求数量，包括该节点上非本地虚拟节点处理的 GET 请求
-   **node\_puts** 某节点前一分钟处理的 PUT 请求数量，包括该节点上非本地虚拟节点处理的 PUT 请求
-   **node\_puts\_total** 自节点启动以来处理的 PUT 请求数量，包括该节点上非本地虚拟节点处理的 PUT 请求
-   **vnode\_gets** 某节点中虚拟节点前一分钟处理的 GET 请求数量
-   **vnode\_gets\_total** 自节点启动以来本地虚拟节点处理的 GET 请求数量
-   **vnode\_puts** 某节点中虚拟节点前一分钟处理的 PUT 请求数量
-   **vnode\_puts\_total** 自节点启动以来本地虚拟节点处理的 PUT 请求数量
-   **riak_kv_vnodes_running**: 前一分钟某虚拟节点排队的键值对数量
-   **riak_kv_vnodeq_mean**: 前一分钟某虚拟节点排队的键值对数量均值
-   **riak_kv_vnodeq_median**: 前一分钟某虚拟节点排队的键值对数量中值
-   **riak_kv_vnodeq_max**: 前一分钟某虚拟节点排队的键值对数量最大值
-   **riak_kv_vnodeq_min**: 前一分钟某虚拟节点排队的键值对数量最小值
-   **read\_repairs** 某节点前一分钟处理的读取修复操作数量
-   **read\_repairs\_total**: 自节点启动以来节点处理的读取修复数量

### FSM\_Time

FSM\_Time 计数器表明遍历 GET 或 PUT FSM 代码所需的时间，单位为毫秒。由此可以看出节点的
一般健康状况。对应用程序来说，FSM\_Time 很好地说明了迟延时间。FSM\_Time 计数器可以显示
均值、中值、95 百分位值、100 百分位值（最大值）。这些也属于“一分钟”状态。

例如：

-   **node\_get\_fsm\_time\_mean**: 客户端发起 GET 请求到收到响应时间间隔的均值
-   **node\_get\_fsm\_time\_median**: 客户端发起 GET 请求到收到响应时间间隔的中值
-   **node\_get\_fsm\_time\_95**: 客户端发起 GET 请求到收到响应时间间隔的 95 百分位值
-   **node\_get\_fsm\_time\_99** 客户端发起 GET 请求到收到响应时间间隔的 99 百分位值
-   **node\_get\_fsm\_time\_100** 客户端发起 GET 请求到收到响应时间间隔的 100 百分位值
-   **node\_put\_fsm\_time\_mean**: 客户端发起 PUT 请求到收到响应时间间隔的均值
-   **node\_put\_fsm\_time\_median**: 客户端发起 PUT 请求到收到响应时间间隔的中值
-   **node\_put\_fsm\_time\_95**: 客户端发起 PUT 请求到收到响应时间间隔的 95 百分位值
-   **node\_put\_fsm\_time\_99**: 客户端发起 PUT 请求到收到响应时间间隔的 99 百分位值
-   **node\_put\_fsm\_time\_100**: 客户端发起 PUT 请求到收到响应时间间隔的 100 百分位值

### GET\_FSM\_Siblings

GET\_FSM\_Sibling 表明在 GET 请求中节点中兄弟数据的数量。这也是“一分钟”状态。

例如：

-   **node\_get\_fsm\_siblings\_mean**: 某节点前一分钟所有 GET 操作处理的兄弟数据数量均值
-   **node\_get\_fsm\_siblings\_median**: 某节点前一分钟所有 GET 操作处理的兄弟数据数量中值
-   **node\_get\_fsm\_siblings\_95**: 某节点前一分钟所有 GET 操作处理的兄弟数据数量 95 百分位值
-   **node\_get\_fsm\_siblings\_99**: 某节点前一分钟所有 GET 操作处理的兄弟数据数量 99 百分位值
-   **node\_get\_fsm\_siblings\_100**: 某节点前一分钟所有 GET 操作处理的兄弟数据数量 100 百分位值
    minute

### GET\_FSM\_Objsize

GET\_FSM\_Objsize 是流经某节点 GET\_FSM 的对象大小。对象的大小是该对象 bucket 名、键、
序列化向量时钟、值和每个兄弟数据的序列化元数据长度之和。
GET\_FSM\_Objsize 和 GET\_FSM\_Siblings 之间的联系很紧密。这些也是“一分钟”状态。

例如：

-   **node\_get\_fsm\_objsize\_mean**: 某节点前一分钟流经 GET\_FSM 的对象大小均值
-   **node\_get\_fsm\_objsize\_median**: M某节点前一分钟流经 GET\_FSM 的对象大小中值
-   **node\_get\_fsm\_objsize\_95**: 某节点前一分钟流经 GET\_FSM 的对象大小 95 百分位值
-   **node\_get\_fsm\_objsize\_99**: 某节点前一分钟流经 GET\_FSM 的对象大小 99 百分位值
-   **node\_get\_fsm\_objsize\_100** 某节点前一分钟流经 GET\_FSM 的对象大小 100 百分位值

### 总数

一分钟计数器是一系列数据收集点，描绘自节点启动以来特定操作执行的次数。

例如：

-   **vnode\_gets\_total**: 自节点启动以来本地虚拟节点处理的 GET 请求数量
-   **vnode\_puts\_total**: 自节点启动以来本地虚拟节点处理的 PUT 请求数量
-   **riak_kv_vnodeq_total**: 自虚拟节点启动以来排队的键值对数量
-   **node\_gets\_total**: 自节点启动以来处理的 GET 请求数量，包括该节点上非本地虚拟节点处理的 GET 请求
-   **node\_puts\_total**: 自节点启动以来处理的 PUT 请求数量，包括该节点上非本地虚拟节点处理的 PUT 请求
-   **read\_repairs\_total**: 自节点启动以来节点处理的读取修复数量
-   **coord\_redirs\_total**: 自节点启动以来处理的重定向到其他节点的操作数量

### CPU 和内存

CPU 的统计数据直接从 Erlang 的 cpu\_sup 模块获取，详细说明请
阅读 [Erlang 文档](http://erldocs.com/R14B04/os_mon/cpu_sup.html)

-   **cpu\_nprocs**: 操作系统的进程数量
-   **cpu\_avg1**: 前一分钟运行的进程数均值（等价于 top(1) 命令的平均负载除以 256）
-   **cpu\_avg5**: 前五分钟运行的进程数均值（等价于 top(1) 命令的平均负载除以 256）
-   **cpu\_avg15**: 前十五分钟运行的进程数均值（等价于 top(1) 命令的平均负载除以 256）

内存使用统计数据直接从 Erlang 的虚拟机获取，详细说明请
阅读 [Erlang 文档](http://erldocs.com/R14B04/erts/erlang.html?i=0&search=erlang:memory#memory/0)。

-   **memory\_total**: 分配的内存总量（进程和系统之和）
-   **memory\_processes**: 为 Erlang 进程分配的内存总量
-   **memory\_processes\_used**: Erlang 进程使用的内存总量
-   **memory\_system**: 不是直接为 Erlang 进程分配的内存总量
-   **memory\_atom**: 为 Atom 存储分配的内存总量
-   **memory\_atom\_used**: Atom 存储使用的内存总量
-   **memory\_binary**: 二进制文件使用的内存总量
-   **memory\_code**: 为 Erlang 代码分配的内存总量
-   **memory\_ets**: 为 Erlang Term Storage 分配的内存总量
-   **mem\_total**: 系统中可用的内存总量
-   **mem\_allocated**: 为某节点分配的内存总量

### 其他信息

Riak 也会提供一些关于节点的其他信息。

例如：

-   **nodename** 用来标记自身的节点名字
-   **ring\_num\_partitions** 设定的环中分区的数量
-   **ring\_ownership**: 列出环中所有节点，以及所拥有的分区
-   **ring\_members**: 列出环中包含的节点
-   **rings_reconciled**: 最近进行的环核对操作次数
-   **rings_reconciled_total**: 自节点启动以来进行的环核对操作次数
-   **converge_delay_min**: 修改环后再次汇集所需的时间最小值，单位为毫秒
-   **converge_delay_max**: 修改环后再次汇集所需的时间最大值，单位为毫秒
-   **converge_delay_mean**: 修改环后再次汇集所需的时间均值，单位为毫秒
-   **converge_delay_last**: 上一次监控到的修改环后再次汇集所需的时间，单位为毫秒
-   **connected\_nodes** 某节点目前连接的节点列表
-   **gossip_received**: 自节点启动以来收到的广播信息总数
-   **ignored\_gossip\_total**: 自节点启动以来忽略的广播信息总数
-   **handoff\_timeouts**: 某节点移交操作超时的次数
-   **rejected_handoffs**: 某节点最近拒绝的所有权移交操作次数
-   **rebalance_delay_min**: 集群成员变动后重新计算分区分布所用的最少时间，单位为毫秒
-   **rebalance_delay_max**: 集群成员变动后重新计算分区分布所用的最多时间，单位为毫秒
-   **rebalance_delay_mean**: 集群成员变动后重新计算分区分布所用的平均时间，单位为毫秒
-   **rebalance_delay_last**: 上一次监控到的集群成员变动后重新计算分区分布所用时间，单位为毫秒
-   **coord\_redirs\_total**: 自节点启动以来处理的重定向到其他节点的操作数量
-   **precommit\_fail**: pre commit 钩子执行失败的次数
-   **postcommit\_fail**: post commit 钩子执行失败的次数
-   **sys\_driver\_version**: 运行时所在系统使用的 Erlang 驱动版本，以字符串的形式显示
-   **sys\_global\_heaps\_size**: 当前共享的全局堆（global heap）
-   **sys\_heap\_type**: 所用堆的类型，以字符串形式显示（结果为 private，shared，hybrid 之一）
-   **sys\_logical\_processors**: 系统上可用的逻辑处理器数量

{{#1.2.0+}}
### Pipeline 指标

下列 riak_pipe 的指标在 MapReduce 操作执行时产生。

- **pipeline_active**: 前 60 秒运行的 pipeline 数量
- **pipeline_create_count**: 自节点启动以来创建的 pipeline 总量
- **pipeline_create_error_count**: 自节点启动以来，创建 pipeline 时发生的错误次数
- **pipeline_create_error_one**: 前 60 秒创建 pipeline 时发生的错误次数
- **pipeline_create_one**: 前 60 秒创建的 pipeline 数量
{{/1.2.0+}}

### 应用程序和子系统的版本

构成 Riak 节点的 Erlang 应用程序和子系统所用的版本也可以通过 `riak-admin status` 命令查看。

-   **sys\_driver\_version**: 运行时所在系统使用的 Erlang 驱动版本，以字符串的形式显示
-   **sys\_otp\_release**: 某节点使用的 Erlang OTP 发行版本
-   **sys\_system\_version**: Erlang 版本的详细信息
-   **ssl\_version**: 所用的 SSL 版本
-   **public\_key\_version**: 所用公匙程序的版本
-   **runtime\_tools\_version**: 所用运行时工具的版本
-   **basho\_stats\_version**: 所有 Basho 状态程序的版本
-   **riak\_search\_version**: 所有 Riak 搜索程序的版本
-   **riak\_kv\_version**: 所用 Riak KV 程序的版本
-   **bitcask\_version**: 所用 Bitcask 后台的版本
-   **luke\_version**: 所用 Luke 程序的版本{{<1.3.0}}
-   **erlang\_js\_version**: 所用 Erlang JS 程序的版本
-   **mochiweb\_version**: 所用 MochiWeb 程序的版本
-   **inets\_version**: 所用 Inets 程序的版本
-   **riak\_pipe\_version**: 所用 Riak Pipe 程序的版本
-   **merge\_index\_version**: 所用 Merge Index 程序的版本
-   **cluster\_info\_version**: 所用 Cluster Information 程序的版本
-   **basho\_metrics\_version**: 所用 Basho Metrics 程序的版本
-   **riak\_control\_version**: 所用 Riak Control 程序的版本
-   **riak\_core\_version**: 所用 Riak Core 程序的版本
-   **lager\_version**: 所用 Large 程序的版本
-   **riak\_sysmon\_version**: 所用 Riak System Monitor 程序的版本
-   **webmachine\_version**: 所用 Webmachine 程序的版本
-   **crypto\_version**: 所用 Cryptography 程序的版本
-   **os\_mon\_version**: 所用 Operating System Monitor 程序的版本
-   **sasl\_version**: 所用 SASL 程序的版本
-   **stdlib\_version**: 所用 Standard Library 程序的版本
-   **kernel\_version**: 所用的内核版本

{{#1.2.0+}}
### Riak 搜索统计

下列的统计信息和 Riak 搜索消息队列有关。

- **riak_search_vnodeq_max**: 前一分钟 Riak 搜索系统收到的所有虚拟节点消息队列中未处理的消息数量最大值
- **riak_search_vnodeq_mean**: 前一分钟 Riak 搜索系统收到的所有虚拟节点消息队列中未处理的消息数量均值
- **riak_search_vnodeq_median**: 前一分钟 Riak 搜索系统收到的所有虚拟节点消息队列中未处理的消息数量均值
- **riak_search_vnodeq_min**: 前一分钟 Riak 搜索系统收到的所有虚拟节点消息队列中未处理的消息数量最小值
- **riak_search_vnodeq_total**: 自节点启动以来 Riak 搜索系统收到的所有虚拟节点消息队列中未处理的消息数量最大值
- **riak_search_vnodes_running**: 目前在 Riak 搜索系统中运行的虚拟节点数量

注意，在理想状态下，除了 `riak_search_vnodes_running`，其他信息的值可能很小（例如 0-10）。
如果值很大可能就是出问题了。
{{/1.2.0+}}

## Riaknostic

[Riaknostic](http://riaknostic.basho.com) 是一个小型的诊断工具，在节点中运行，
能发现常规问题，并给出解决方法。这些检查项目来源于 Basho 客户服务团队的经验，以及邮件列表、
IRC 和其他在线媒体上的公开讨论。

{{#1.3.0-}}
Riaknostic 是一个开源项目，由 Basho Technologies 和社区成员开发。其代码
可到 [GitHub 仓库](https://github.com/basho/riaknostic)获取。

Riaknostic 使用起来很简单，安装和使用说明可以到 Riaknostic 的网站查看。下载安装后，
Riaknostic 向 `riak-admin` 添加了 `diag` 子命令。

`riak-admin diag` 会输出节点的所有问题及推荐的解决方法。Riaknostic 特别适合用来诊查
设置相关的问题，节点或集群遇到问题时强烈建议先使用它来检查问题。
{{/1.3.0-}}

{{#1.3.0+}}
从 Riak 1.3 开始，Riaknostic 是默认安装的。

Riaknostic 包含在 Riak 中，可以使用 `riak-admin diag` 命令运行。Riaknostic 是一个开源项目，由 Basho Technologies 和社区成员开发。其代码
可到 [GitHub 仓库](https://github.com/basho/riaknostic)获取。
{{/1.3.0+}}

## 相关资源

-   [设置和管理：命令行工具：riak-admin](http://docs.basho.com/riak/1.2.0/references/riak-admin Command Line/)
-   [Riaknostic](http://riaknostic.basho.com/)
-   [[HTTP API status|HTTP Status]]
