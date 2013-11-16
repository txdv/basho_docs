---
title: Session Storage
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

## 简单用例

Riak 开发之初是为了存储大量会话。存储会话是 Riak 比较擅长的工作，因为它就是一个键值对存储系统。用户的会话 ID 一般都存在 cookie 中，或者在查询时才能知道具体的 ID，Riak 能为这些查询提供较低的迟延。Riak 对数据的 content-type 无限制，因此对存储的值也没有什么限制，因此会话数据可以使用很多方法编码，无需管理员修改数据库模式。

## 复杂用例

Riak 还有一些其他功能可以存储更复杂的会话数据。Bitcask 存储后台支持自动把键标记为过期，这样应用程序就无需实现把会话标记为过期的功能。Riak 的 MapReduce 还可以对会话数据进行分析，例如统计活跃用户平均数量等。如果会话数据可以使用不同的键取出（UUID 或 Email 地址），使用二级索引会简单的多。

## 社区使用示例

<table class="links">
    <tr>
        <td><a href="https://player.vimeo.com/video/42744689" target="_blank" title="Kiip 如何扩放 Riak">
           <img src="http://b.vimeocdn.com/ts/296/624/296624215_960.jpg"/>
         </a></td>
        <td><a href="https://player.vimeo.com/video/42744689" target="_blank" title="Kiip 如何扩放 Riak">Kiip 如何扩放 Riak</a>
        <br>
        这个演讲视频在 2012 年 5 月的旧金山 Riak 聚会上录制，来自 Kiip 的 Armon Dadgar 和 Mitchell Hashimoto 介绍了为什么以及如何在生产环境中使用 Riak，以及 Kiip 的实现方式。他们首先转用 Riak 的就是会话系统。这份演讲的幻灯片可以在<a href="http://basho.com/blog/technical/2012/05/25/Scaling-Riak-At-Kiip/" class="riak" target="_blank">这篇文章</a>中获取。
        </td>
    </tr>
</table>
