---
title: 使用示例
project: riak
version: 1.4.2+
document: cookbook
index: true
toc: false
audience: intermediate
keywords: [use-cases]
---

这里列出的数据模型示例并不一定适合于你的应用程序，其目的只是为了给出一些常见的解决方案，让你去思考如何实现 Riak 数据模型满足常见的程序功能。具体怎么实现要结合应用程序的需求，包括访问模式（例如分布式读写），不同操作之间的迟延差异，Riak Search 和二级索引等。这些文章只是为你做个引导。

## 简单的应用程序，追求较高的读写性能

*没有复杂的关联，只需要较高的读写性能*

* [[会话存储|Session Storage]]
* [[提供广告内容|Serving Advertisements]]
* [[日志数据|Log Data]]
* [[传感器数据|Sensor Data]]

## 内容管理和社会化程序

*需要实现一对多和多对多关联*

* [[用户账户|User Accounts]]
* [[用户设置|User Settings/Preferences]]
* [[用户事件和时间轴|User Subscriptions/Events/Timelines]]
* [[博客文章|Blog Posts, Articles and Other Content]]

<!--

## Common SQL Design Patterns

*Reproducing common SQL models/queries in Riak*

* [[Counting]]
* [[Conditional Summation]]

 -->
