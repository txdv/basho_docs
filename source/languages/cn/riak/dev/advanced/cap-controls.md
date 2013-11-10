---
title: CAP Controls
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [developers, cap]
interest: [
"[[Installing and Upgrading]]",
"[[Concepts]]",
"[[Planning for a Riak System]]",
"[[Cluster Capacity Planning]]",
"[[Use Cases]]"
]
---

本文我们要介绍 Riak 是如何把数据分发到整个集群的，以及如何调整一致性和可用性等级。调整的过程因应用程序而已，这也是 Riak 区别于其他同类产品的特性之一。

本文末尾有一个视频，简单介绍了如何调整副本等级以满足程序和业务需求。不过在观看这个视频之前，请先大致阅读下面的内容。

## N，R 和 W 简介

Riak 把 CAP 交由开发者控制，可以在 bucket 层级上调整要存储多少副本，我们需要做的是设置 N，R 和 W 这三个值。

Riak 设计的指导理论是 Dr. Eric Brewer 的 CAP 定理。CAP 定理为分布式系统定义了三个特性：一致性（C），可用性（A），分区容忍性（P）。该定理指出，任意时刻只能依赖三个特性中的两个特性。

Riak 选择关注 CAP 中的 A 和 P。这中选择使 Riak 加入了最终一致性阵营。不过最终一致性的窗口是以毫秒来衡量的，已经能满足多数应用程序的需求。

### N 值和副本

Riak 中存储的所有数据都会根据 bucket 的 N 值在一定数量的节点上创建副本。Riak 默认设置的 n 值是 3，所以会在 3 个不同的节点中创建副本。为了能真正创建 3 个副本，集群中至少要有 3 个物理节点。（可以使用本地节点做演示。）

要想修改 bucket 的 N 值，可以向 bucket 发起 PUT 请求。如果包含 3 个节点的集群还在运行，请试一下下面的命令：

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/another_bucket \
  -H "Content-Type: application/json" \
  -d '{"props":{"n_val":2}}'
```

这个命令会把名为“another_bucket”的 bucket 的 n_val 改为 2，即该 bucket 中的数据会在两个分区中创建副本。

<div class="note">
	<div class="title">修改 N 值时的注意事项</div>
	<code>n_val</code> 必须大于 0，且要小于或等于集群中节点的数量，这样才能充分发挥副本的作用。我们建议创建 bucket 后不要修改 n_val，这么做可能会导致读取失败，因为新写入的值可能没有在相应的分区中创建副本。
</div>

### R 值和读取失败容忍

使用上面的命令，我们把 bucket 的 n_val 改为了 2。

Riak 允许客户端在直接读取时指定 R 值，这个值指明，如果这次读取操作是成功的，必须有多少节点返回结果。这样，即便节点下线出现延迟，也能保证读取的可用性。

例如，在下面这个 HTTP 请求中，r 值被设为 1：

```bash
http://127.0.0.1:8091/riak/images/1.png?r=1
```

只要集群中存有至少一个副本，就会返回数据。

### W 值和写入失败容忍

Riak 还允许客户端更新数据时指定 W 值，这个值表明，如果这次更新操作是成功的，必须有多少节点成功响应。这样，即便节点下线或出现延迟，也能保证写入的可用性。

在下面这个 PUT 请求中，W 值被设为 3。

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/docs/story.txt?w=3 \
  -H "Content-type: text/plain" \
  --data-binary @story.txt
```

### 符号名

Riak 0.12 为 R 和 W 值提供了符号名，用起来更方便，也易于理解。这些符号名是：

* *all* - 所有节点都要应答。等价于把 R 或 W 设为和 N 值一样
* *one* - 等价于把 R 或 W 值设为 1
* *quorum* - 大多数节点要做出应答，即半数加一个。对于默认的 N 值 3，结果就是 2
* *default* - 把 R 或 W 设为各 bucket 的一致性属性值，可以是上述 3 个中的任何一个，或者是一个整数

如果不指定 R 和 W 值，就等同于将其设为“default”。

## N，R 和 W 实操

下面是一个视频，介绍了 N、R 和 W 值是如何影响包含 3 个节点的 Riak 集群的：

<div style="display:none" class="iframe-video" id="http://player.vimeo.com/video/11172656"></div>

<p><a href="http://vimeo.com/11172656">调整 Riak 的 CAP</a>，<a href="http://vimeo.com/bashotech">Basho Technologies</a> 制作，存放在 <a href="http://vimeo.com">Vimeo</a> 上。</p>
