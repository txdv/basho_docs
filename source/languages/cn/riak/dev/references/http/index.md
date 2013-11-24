---
title: HTTP API
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
index: true
---

Riak 提供了丰富完整的 HTTP 1.1 API。本文简单介绍了可以通过 HTTP 接口进行的操作，也可作为开发客户端的参考。所有的 URL 地址都基于默认的设置。所有的示例都使用 `curl` 和 Riak 交互。

<div class="note">
<div class="title">客户端 ID</div>

发送到 Riak 1.0 及以下版本的请求，如果没有启用 `vnode_vclocks`，请求中必须包含 `X-Riak-ClientId` 报头，使用任意的字符串唯一标识客户端，以便使用[[向量时钟]]跟踪对象的变动。

</div>

<div class="note">
<div class="title">URL 转义</div>
<p>Bucket、键和链接中都不能包含未转义的斜线。请使用 URL 转义代码库或者直接把斜线替换成 `%2F`。</p>
</div>

## Bucket 相关操作

Riak 中的 bucket 是个虚拟概念，作为一种命名空间，也可以使用有别于 bucket 默认设置的特定行为。例如，可以调整[[副本的数量|副本#Selecting-an-N-value-(n_val)]]，指定要使用的存储后台和 [[commit 钩子|使用 Commit 钩子]]。

<div class="info">
<div class="title">可以有多少个 bucket？</div>
<p>目前，bucket 基本上不会消耗资源，除非修改其属性。修改 bucket 属性后，要广播到整个集群，因此会增加网络传输量。因此，如果 bucket 使用默认属性，想用多少就用多少。</p>
</div>

<div class="note">
<div class="title">删除 Bucket</div>
<p>现在没有简单的方法可以删除整个 bucket。要删除 bucket 中的所有键，就得一个一个的删除。</P>
</div>

<a id="Bucket-Operations"></a>
## Bucket 相关操作

* [[通过 HTTP 列出 bucket]]
* [[通过 HTTP 列出键]]
* [[通过 HTTP 获取 bucket 的属性]]
* [[通过 HTTP 设置 bucket 的属性]]
* [[通过 HTTP 还原 bucket 的属性]] {{1.3.0+}}

<a id="Object-Key-Operations"></a>
## 对象/键相关操作

bucket、键、值和元数据在一起称为“Riak 对象”。下面的操作针对 Riak 中的单个对象。

* [[通过 HTTP 获取对象]]
* [[通过 HTTP 存储对象]]
* [[通过 HTTP 删除对象]]

{{#1.4.0+}}
## 数据类型

* [[HTTP 计数器]]

{{/1.4.0+}}

## 查询

* [[通过 HTTP 进行链接遍历]]
* [[通过 HTTP 执行 MapReduce 查询]]
* [[通过 HTTP 执行二级索引查询]]

## 服务器相关操作

* [[HTTP Ping]]
* [[HTTP 状态]]
* [[通过 HTTP 列出资源]]
