---
title: 统计和监控
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [operator, troubleshooting]
---

## Riak 统计

Riak 为当前操作的状态提供了数据，包含数量统计和柱状图。这些统计数据可以通过 HTTP API 的 `[[/stats|HTTP 状态]]` 端点获取，或者通过 `[[riak-admin status|检查节点#riak-admin-status]]` 命令获取。

本文介绍了经常被监视和手机的统计数据，以及客户和社区在 Riak 集群环境中成功使用的用来监视和收集统计数据的各种方法。Riak 各项统计信息的详细内容请阅读“[[检查节点]]”。

### 数量统计

Riak 为 GET 请求，PUT 请求和读取修复等常规操作提供了数量统计。默认情况下，会统计前一分钟内的操作数量，或者节点整个运行周期内的操作数量。

#### GET 和 PUT 请求

节点和虚拟节点（vnode）都能进行 GET/PUT 数量统计。这些统计数据经常用来做趋势分析和容量规划等。

指标               | 说明           |
-------------------| ------------- |
`node_gets`        | 某节点前一分钟处理的 GET 请求数量，包括该节点上非本地虚拟节点处理的 GET 请求 |
`node_gets_total`  | 自节点启动以来处理的 GET 请求数量，包括该节点上非本地虚拟节点处理的 GET 请求 |
`node_puts`        | 某节点前一分钟处理的 PUT 请求数量，包括该节点上非本地虚拟节点处理的 PUT 请求 |
`node_puts_total`  | 自节点启动以来处理的 PUT 请求数量，包括该节点上非本地虚拟节点处理的 PUT 请求 |
`vnode_gets`       | 某节点中虚拟节点前一分钟处理的 GET 请求数量                               |
`vnode_gets_total` | 自节点启动以来本地虚拟节点处理的 GET 请求数量                             |
`vnode_puts_total` | 自节点启动以来本地虚拟节点处理的 PUT 请求数量                             |

#### 读取修复

读取修复数量统计一般是为了监视和收集反常的峰值，能指示出问题所在。

指标                 | 说明                             |
---------------------|---------------------------------|
`read_repairs`       | 某节点前一分钟处理的读取修复操作数量 |
`read_repairs_total` | 自节点启动以来节点处理的读取修复数量 |

#### 协调重定向

节点协调重定向操作的数量统计自节点启动开始起得总量。

指标                 | 说明                                         |
---------------------|---------------------------------------------|
`coord_redirs_total` | 自节点启动以来处理的重定向到其他节点的操作数量    |

### 统计

Riak 为很多操作提供了统计数据。默认情况下，Riak会在一个 60 秒宽度的窗口中显示均值，中值，95 百分位值，99百分位值和 100 百分位值。

#### 有限状态机时间

Riak 提供了有限状态机（FSM）时间的数量统计（`node_get_fsm_time_*` 和 `node_put_fsm_time_*`），衡量了遍历 GET 或 PUT FSM 代码所需的时间，单位为毫秒。通过这一数据可以看出节点的一般健康状况。

#### GET FSM 对象大小

GET FSM 对象大小（`node_get_fsm_objsize_*`）衡量了流经该节点 GET FSM 的对象大小。对象的大小是该对象 bucket 名、键、序列化向量时钟、值和每个兄弟数据的序列化元数据长度之和。

#### GET FSM 兄弟数据

GET FSM 兄弟数据（`node_get_fsm_siblings_*`）会生成一个柱状图（在一个 60 秒的窗口内），显示该节点处理 GET 请求时处理的兄弟数据数量。

## 图表显示的 Riak 指标

指标                          | 说明                                                |
------------------------------| -------------------------------------------------- |
`node_get_fsm_objsize_mean`   | 某节点前一分钟流经 GET\_FSM 的对象大小均值             |
`node_get_fsm_objsize_median` | 某节点前一分钟流经 GET\_FSM 的对象大小中值             |
`node_get_fsm_objsize_95`     | 某节点前一分钟流经 GET\_FSM 的对象大小 95 百分位值      |
`node_get_fsm_objsize_100`    | 某节点前一分钟流经 GET\_FSM 的对象大小 100 百分位值     |
`node_get_fsm_time_mean`      | 客户端发起 GET 请求到收到响应时间间隔的均值              |
`node_get_fsm_time_median`    | 客户端发起 GET 请求到收到响应时间间隔的中值              |
`node_get_fsm_time_95`        | 客户端发起 GET 请求到收到响应时间间隔的 95 百分位值      |
`node_get_fsm_time_100`       | 客户端发起 GET 请求到收到响应时间间隔的 100 百分位值     |
`node_put_fsm_time_mean`      | 客户端发起 PUT 请求到收到响应时间间隔的均值              |
`node_put_fsm_time_median`    | 客户端发起 PUT 请求到收到响应时间间隔的中值              |
`node_put_fsm_time_95`        | 客户端发起 PUT 请求到收到响应时间间隔的 95 百分位值       |
`node_put_fsm_time_100`       | 客户端发起 PUT 请求到收到响应时间间隔的 100 百分位值      |
`node_get_fsm_siblings_mean`  | 某节点前一分钟所有 GET 操作处理的兄弟数据数量均值         |
`node_get_fsm_siblings_median`| 某节点前一分钟所有 GET 操作处理的兄弟数据数量中值         |
`node_get_fsm_siblings_95`    | 某节点前一分钟所有 GET 操作处理的兄弟数据数量 95 百分位值 |
`node_get_fsm_siblings_100`   | 某节点前一分钟所有 GET 操作处理的兄弟数据数量 100 百分位值 |
`memory_processes_used`       | Erlang 进程使用的内存总量                              |
`read_repairs`                | 某节点前一分钟处理的读取修复操作数量                      |
`read_repairs_total`          | 自节点启动以来处理的读取修复操作数量                      |
`sys_process_count`           | Erlang 进程的数量                                      |
`coord_redirs_total`          | 自节点启动以来处理的重定向到其他节点的操作数量             |
`pbc_connect`                 | 某节点前一分钟新建立的 Protocol Buffer 连接数量          |
`pbc_active`                  | 当前处理激活状态的 Protocol Buffer 连接数量              |


## 图表显示的系统指标

指标                   |
---------------------- |
可用的硬盘空间           |
IO 等待时间             |
读取操作                |
写入操作                |
网络吞吐量              |
平均负载                |


## 统计和监控工具

统计数据和记录数据有很多开源、自托管和基于服务的解决方案，可以在 Riak 集群中进行监视、报警和趋势分析。有些解决方法提供了针对 Riak 的模块和插件。

下面列出的是客户和社区成员在监视 Riak 集群操作状态时证实可用的解决方案。商业和托管的服务也与社区开发和开源项目一并列出。

### 社区和开源工具

#### Riaknostic

[Riaknostic](http://riaknostic.basho.com) 是一个持续开发的诊断工具，在节点中运行，能发现常规问题，并给出解决方法。这些检查项目来源于 Basho 客户服务团队的经验，以及邮件列表、IRC 和其他在线媒体上的公开讨论。

Riaknostic 集成在 `riak-admin` 命令中，通过子命令 `diag` 调用。诊断和排错时最好先使用 Riaknostic。

#### Riak Control

[[Riak Control]] 由 Basho 开发，是一个 REST 架构的 Riak 集群管理界面。其开发目的是，便于快速查看集群健康状况，以及简单的管理节点。

Riak Control 目前没有提供监视和统计功能，只能快速查看集群健康状况、节点的状态，还能执行移交操作。

#### collectd

[collectd](http://collectd.org) 会收集并存储运行其上的系统的信息。然后这些统计信息会转换成图表，用来查看性能瓶颈，预测系统负载，以及分析趋势。

#### Ganglia

[Ganglia](http://ganglia.info) 是一个监视系统，特别针对大型、高性能的电脑群组，例如集群和网格。客户和社区成员反馈成功使用 Ganglia 监视了 Riak 集群。

有一个[针对 Riak 的模块](https://github.com/jnewland/gmond_python_modules/tree/master/riak/)，可以通过 Riak HTTP 的 `[[/stats|HTTP 状态]]` 端点收集统计数据。

#### Nagios

[Nagios](http://www.nagios.org) 是一个监控和报警系统，可以提供 Riak 集群中节点的状态信息，还能在某些特定事件发生时发出各种警报。Nagios 还有日志和事件报告功能，可以用来分析趋势和规划容量。

有很多[针对 Riak 的脚本](https://github.com/basho/riak_nagios)可以结合 Nagios 使用。

#### Riemann

[Riemann](http://aphyr.github.com/riemann/) 使用一种强大的流处理语言收集运行在 Riak 节点上的客户端事件，可以用来跟踪趋势，以及在事件发生时给出报告。统计信息从节点获取，然后交由类似 Graphite 的工具生成图表。

[Riemann Tools](https://github.com/aphyr/riemann.git) 可以把数据发送给 Riemann，采用模块化设计，可以读取 Riak 的统计数据。

#### OpenTSDB

[OpenTSDB](http://opentsdb.net) 是一个分布式可扩放的“时间序列数据库”（TSDB），能为不同的源存储、索引和服务指标。OpenTSDB 可以大规模的收集数据，然后飞速生成图表。

[tcollector 框架](https://github.com/stumbleupon/tcollector) 中提供了一个[支持 OpenTSDB 的 Riak 收集器](https://github.com/stumbleupon/tcollector/blob/master/collectors/0/riak.py)。

### 商业和托管的工具

下面列出的是客户和社区成员在监视 Riak 集群状态、收集 Riak 集群数据时证实可用的商业工具。

#### Circonus

[Circonus](http://circonus.com) 提供了组织级别的监视、趋势分析、报警、提醒和管理面板功能。可用来在 Riak 集群环境中进行趋势分析，帮助排错，以及容量规划。

<!--
Need more information on this one...
#### Scout
[Scout](https://scoutapp.com)
-->

#### Splunk

[Splunk](http://www.splunk.com) 可以下载，也可以作为服务使用。它提供的工具可以视觉化机器生成的数据，例如日志文件。它能连接到 Riak 的 HTTP 统计端点 `[[/stats|HTTP 状态]]`。


Splunk 可以收集 Riak 集群中所有节点的操作日志文件，包括操作系统和针对 Riak 的日志，以及 Riak 的统计数据。这些数据可以用来进行实时图表转换、搜索等其他视觉化操作，有助于问题排错和趋势分析。

## 总结

Riak 提供课很多重要的统计信息，可以使用各种开源和商业工具收集、监视、分析、转换成图表或报告。

如果你使用的解决方案没有列出来，而且你想将其加入这篇文档，请 fork 本文档，在适当的小结内添加你的方法，然后给 [RiaK 文档项目](https://github.com/basho/basho_docs)发送一个合并请求。

## 参考资源

* [[检查节点]]
* [Riaknostic](http://riaknostic.basho.com)
* [[Riak Control]]
* [collectd](http://collectd.org)
* [Ganglia](http://ganglia.info)
* [Nagios](http://www.nagios.org)
* [Riemann](http://aphyr.github.com/riemann/)
* [Riemann Github](https://github.com/aphyr/riemann)
* [OpenTSDB](http://opentsdb.net)
* [tcollector project](https://github.com/stumbleupon/tcollector)
* [tcollector Riak module](https://github.com/stumbleupon/tcollector/blob/master/collectors/0/riak.py)
* [Folsom Backed Stats Riak 1.2](http://basho.com/blog/technical/2012/07/02/folsom-backed-stats-riak-1-2/)
* [Circonus](http://circonus.com)
* [Splunk](http://www.splunk.com)
* [Riak 文档在 Github 上的仓库](https://github.com/basho/basho_docs)
