---
title: 提供广告服务
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

## 简单用例

Riak 的一个常见用法是存储广告内容，为不同的 Web 和移动设备用户以低迟延提供广告服务。广告的内容（图片或文本）可以使用唯一键存储，也可以使用 Riak 自动生成的键。为了便于取出数据，键经常是基于联盟 ID 的。

## 复杂用例

对于广告业来说，选择和调整数据库时优先考虑的是如何快速为众多用户和平台提供广告服务。Riak 的 CAP 控制是可调整的，能够提供快速读取性能。把 r 值设为 1，只要能返回一个副本读取操作就是成功的，这比把 r 值设成和副本数相等时的读取迟延要低。这对主要提供读取广告的服务来说是个不错的优势。

## 社区使用示例

<table class="links">
  <tr>
    <td><a href="http://player.vimeo.com/video/49775483" target="_blank" title="Riak at OpenX"><img src="http://b.vimeocdn.com/ts/343/417/343417336_960.jpg"/></a>
    </td>
    <td><a href="http://player.vimeo.com/video/49775483" target="_blank" title="Riak at OpenX">OpenX 是如何使用 Riak 的</a>
    <br>
    OpenX 是一家位于洛杉矶的公司，今年提供了 4 万亿次广告服务。在这个演讲中，OpenX 的工程师 Anthony Molinaro 深入介绍了他们使用的架构，如何构建系统，以及为什么在使用像 CouchDB 和 Cassandra 这类数据库之后转向使用 Riak 和 Riak Core 来存储数据。
    </td>
  </tr>
</table>
