---
title: Vector Clocks
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [appendix, concepts]
---

## 概览

任何节点都能接收任何请求，而且每次请求不需要所有节点都参与，这样就必须有一种方法来追踪值的
哪个版本是当前版本，为此向量时钟应运而生了。

当值存入 Riak 时，会使用向量时钟标记，创建值的初始版本。更新时，会扩展向量时钟，稍后可以对比
两个版本的对象，然后决定：

 * 某对象是不是另一个对象的直接后代
 * 一组对象是不是共同祖先的后代
 * 最近继承时，对象是不是不相关的

使用这个技术，Riak 可以自动修复过时的数据，或者至少能让客户端有机会在应用程序中调整有分歧
的改动。

## 兄弟数据

如果 Riak 无法决定哪个是所存数据的唯一版本就会创建兄弟数据。
如果 bucket 的 `allow_mult` 属性为 `true`，那么在三种情况下会在单个对象中创建兄弟数据：

1. **并发写入** 如果客户端同时发起两个写入请求，向量时钟也一样，Riak 就无法决定要存入哪个
对象，这时会创建两个兄弟数据。并发写入可以发生在同一个节点中，也可以发生在多个节点中。

2. **陈旧的向量时钟** 客户端发起写入请求时使用了陈旧的向量时钟。如果客户端先读（获取当前的
向量时钟）后写就很少发生这种事。不过，如果在“读写”这两个操作中的写操作由另一个客户端发起也会
出现这种情况，客户端写入时使用的是旧的向量时钟，会创建一个兄弟数据。如果客户端习惯使用陈旧
的向量时钟发起写入请求，就会不断的创建兄弟数据。

3. **向量时钟丢失** 更新已存数据时没有指定向量时钟。很少发生的情况是，使用 `curl` 这种客
户端处理对象时没有设置 `X-Riak-Vclock` 报头。

Riak 之所以会创建兄弟数据，是因为无法在分布式系统中按时间排序事件，只能按因果关系排序。
如果 `allow_mult` 属性设为 `true`，Riak 就不会为你处理冲突，你必须选择一个兄弟数据，或者
自行替换对象。

兄弟数据示例：

```bash
# create a bucket with allow_mult true (if its not already)
$ curl -v -XPUT -H "Content-Type: application/json" -d '{"props":{"allow_mult":true}}' \
http://127.0.0.1:8098/riak/kitchen

# create an object we will create a sibling of
$ curl -v -X POST -H "Content-Type: application/json" -d '{"dishes":11}' \
http://127.0.0.1:8098/riak/kitchen/sink?returnbody=true

# the easiest way to create a sibling is update the object without
# providing a vector clock in the headers
$ curl -v -XPUT -H "Content-Type: application/json" -d '{"dishes":9}' \
http://127.0.0.1:8098/riak/kitchen/sink?returnbody=true
```

### V-Tags

现在你应该看过了 curl 命令得到的多个响应。请求有兄弟数据的对象有两种方法。可以使用下面的方法
取回一组兄弟数据：

```bash
$ curl http://127.0.0.1:8098/riak/kitchen/sink
```

得到的响应如下：

    Siblings:
    175xDv0I3UFCfGRC7K7U9z
    6zY2mUCFPEoL834vYCDmPe

你得到的数据可能不一样，但格式应该相同。

读取一个包含多个值的对象会收到 `300 Multiple Choices` 响应。上述命令得到的是一组兄弟数据
的 `vtag`，以纯文本表示。在对象中可以使用 `vtag` 引用单个兄弟数据。要获取单个兄弟数据，
可以把 `vtag` 参数添加到对象的地址后。例如：

```bash
$ curl http://127.0.0.1:8098/riak/kitchen/sink?vtag=175xDv0I3UFCfGRC7K7U9z
```

得到的结果是：

```javascript
{"dishes":9}
```

要想在一次请求中查看所有的兄弟数据，可以这么做：

```bash
$ curl http://127.0.0.1:8098/riak/kitchen/sink -H "Accept: multipart/mixed"
```

如果把 `Accept` 报头设为 `multipart/mixed`，一次请求就会返回所有的兄弟数据，在响应主体
中显示。

### 解决冲突

一旦单个值有多个表示时，就要决定要用哪个。在应用程序中，可以自动选择，也可以交由最终用户
决定。要想使用相应的值更新对象，就要提供当前的向量时钟。假设 `{"dishes":11}` 是正确的值，
更新值的过程如下：

```bash
# Read the object to get the vector clock
$ curl -v http://127.0.0.1:8098/riak/kitchen/sink
```

在长长的输出中会包含 `X-Riak-Vclock` 报头，其值可能和下面的不一样，但样子差不多：

    < X-Riak-Vclock: a85hYGBgzmDKBVIsTFUPPmcwJTLmsTIcmsJ1nA8qzK7HcQwqfB0hzNacxCYWcA1ZIgsA

一旦得到了向量时钟就可以使用正确的值更新了。

```bash
$ curl -v -XPUT -H "Content-Type: application/json" -d '{"dishes":11}' \
-H "X-Riak-Vclock: a85hYGBgzmDKBVIsTFUPPmcwJTLmsTIcmsJ1nA8qzK7HcQwqfB0hzNacxCYWcA1ZIgsA=" \
http://127.0.0.1:8098/riak/kitchen/sink?returnbody=true
```

<div class="note">
<div class="title">并行解决冲突</div>
注意，如果试着自动解决冲突，很有可能会发生两个客户端同时解决，又产生新冲突的情况。为了避免
问题发生，最好限制解决冲突的程序数量，一旦超过这个值这次冲突解决就会失败。
</div>

### 兄弟数据激增

如果对象急速生成兄弟数据而不进行调解，那么兄弟数据量就会激增。这回导致种种问题。如果节点
中存有巨型对象，读取这个对象时会导致整个节点崩溃。其他的问题有，因创建对象副本导致的集群
迟延增加，以及耗尽内存。

### 向量时钟激增

除了兄弟数据激增之外，如果较短时间内频繁更新对象还会导致向量时钟激增。避免过度频繁更新对象
的同时，还可以调整 Riak 的向量时钟修剪程序，防止向量时钟快速增长。

### last_write_wins 是如何影响冲突解决的？

从表面上看，把 `allow_mult` 设为 `false`（默认值）和
把 `last_write_wins` 设为 `true` 的结果一样，但还是有点细微差别的。

按照上面的方式设定这两个值后客户端都只会收到一个值，但 `allow_mult=false` 还是会使用向量
时钟解决冲突，而 `last_write_wins=true` 会根据时间戳来找到数据的最新版本。更深入来说，
`allow_mult=false` 还是允许创建兄弟数据（由于并发写入或网络隔断），
而 `last_write_wins=true` 会直接使用新值覆盖原值。

如果不介意有兄弟数据产生，`allow_mult=false` 引起的意外情况是最少的，你会得到最新的数据，
系统会优雅的处理网络隔断。如果需要经常（快速）重写键，而且新值和旧值没有多大关系，
`last_write_wins` 能提供更好地性能。使用 `last_write_wins` 的情况包括，缓存，会话存储，
直插入值（不更新）。

<div class="note">
如果同时定义了 <code>allow_mult=true</code> 和 <code>last_write_wins=true</code> 这
两个 bucket 属性，是没有效果的，而且不应该这么做。
</div>

## 向量时钟修剪

Riak 会定期修剪向量时钟，避免过度增长。修剪程序受以下四个 bucket 设置控制：

 * `small_vclock`
 * `big_vclock`
 * `young_vclock`
 * `old_vclock`

`small_vclock` 和 `big_vclock` 参数表示向量时钟列表的长度。如果小于 `small_vclock` 不会
修剪，如果大于 `big_vclock` 就会修剪。

![Vclock Pruning](/images/vclock-pruning.png)


`young_vclock` 和 `old_vclock` 参数表示各向量时钟附属的时间戳。如果向量时钟列表的长度
在 `small_vclock` 和 `big_vclock` 之间，就会检查每个向量时钟的寿命。
如果小于 `young_vclock` 不会修剪，如果大于 `old_vclock` 就会修剪。

## 客户端和虚拟节点管理向量时钟

在 Riak 1.0 之前，所有的 PUT 请求都要提交一个客户端 ID。协调 PUT 请求以及增加相关向量时钟
这两个工作由接受请求的虚拟节点完成。如果没有提交客户端 ID，系统会随机生成一个，用来增加向量
时钟。这种方式会由表现不好的客户端导致向量时钟不受限制的增长。

从 Riak 1.0 开始，向量时钟（默认）直接由虚拟节点使用内部的计数器和标识符管理。这样可以限制
向量时钟的增长，但写入操作的迟延会多一些。

## 更多信息

关于向量时钟的其他背景资料：

* [[维基百科对向量时钟的介绍|http://en.wikipedia.org/wiki/Vector_clock]]
* [[为什么说向量时钟很简单|http://blog.basho.com/2010/01/29/why-vector-clocks-are-easy/]]
* [[为什么说向量时钟很难|http://blog.basho.com/2010/04/05/why-vector-clocks-are-hard/]]
* Riak 使用的向量时钟基于 [[Leslie Lamport 的开发|http://portal.acm.org/citation.cfm?id=359563]]
