---
title: 日志数据
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

## 简单用例

Riak 的一个常见用法是存储大量日志数据，使用 Map/Reduce 分析；或者作为日志数据的主存储，然后再使用从集群进行更强大的分析工作。对于这样需求，可以创建一个名为“logs”的 bucket，键使用唯一值，对应的值是日志文件。要存储不同系统的日志数据，可以分别为每个系统创建一个 bucket，把日志写入相应的 bucket。分析日志数据时，可以使用 MapReduce 计算数据记录的总量，或者使用 Riak Search 执行更复杂的文本查询。

## 复杂用例

如果要存储的日志数据量很大，需要经常向 Riak 写入数据，有些用户会使用一个 Riak 主集群存储日志，再把数据副本传送到从副本中，进行繁重的分析作业。从集群可以是 Riak 集群，或者使用其他解决方案，例如 Hadoop。向 Riak 写入和读取数据采用的模式和 MapReduce 作业获取数据采用的模式不一样，MapReduce 要遍历很多键，所以把写入操作和分析操作分担到两个集群可以有效提高性能、降低迟延。

## 社区使用示例

<table class="links">
  <tr>
    <td><a href="http://www.simonbuckle.com/2011/08/27/analyzing-apache-logs-with-riak/" target="_blank" title="Riak at OpenX"><img src="/images/simon-analyzing-logs.png"/></a>
    </td>
    <td>Simon Buckle 介绍<a href="http://www.simonbuckle.com/2011/08/27/analyzing-apache-logs-with-riak/" target="_blank">如何使用 Riak 分析 Apache 的日志</a>
    </td>
  </tr>
</table>
