---
title: 选择后台
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: intermediate
keywords: [backends, planning]
next: "[[Bitcask]]"
interest: false
---

Riak KV 的一个显著特性是可插入式的存储后台。这样就可以根据特殊测操作需求选择合适的底层存储引擎。例如，如果需要最大限度的吞吐量外加永久性数据存储和有限的密钥空间，Bitcask 是不错的选择。而如果需要存储数量巨大的键，LevelDB 是更好地选择。

Riak 支持以下后台：

* [[Bitcask]]
* [[LevelDB]]
* [[Memory]]
* [[Multi]]

Riak 也支持自定义存储后台。详细信息请阅读[[后台 API]]。
