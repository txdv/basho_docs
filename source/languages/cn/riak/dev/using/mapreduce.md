---
title: 使用 MapReduce
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, mapreduce]
---

## 简介

MapReduce（M/R）这个技术可以把作业分配到整个分布式系统，充分利用分布式系统的并行处理功能，还能减少网络带宽用量，因为 M/R 是把计算发送到数据上，而不是把巨量数据加载到客户端。开发者可以使用 MapReduce 通过标签过滤文档、统计文档中的字数，或者把链接提取到相关数据中。

在 Raik 中，MapReduce 是一种不使用键进行查询的方法。MapReduce 作业可以通过 HTTP API 或 Protocol Buffers API 提交。**Riak 中的 MapReduce 是用来进行批量处理的，而不是进行实时查询的。**

## 特性

* Map 步骤使用本地数据并行执行
* Reduce 步骤在提交查询作业的节点上并行执行
* 支持 Javascript MapReduce 查询
* 支持 Erlang MapReduce 查询

## 什么时候使用 MapReduce

* 知道要使用 MapReduce 处理的是哪些数据（“bucket/键”组合）
* 真的要返回对象，而不只是键，与使用[[Riak Search|使用 Riak Search]]和[[二级索引|使用二级索引]]一样
* 查询数据时需要极大的灵活性。MapReduce 能让你充分掌握对象，并根据需求选择需要的值。

## 什么时候不要使用 MapReduce

* 要查询整个 bucket 的数据时。MapReduce 会使用一组键列表，使用集群的很多资源
* 想要尽量预测迟延时

## MapReduce 是如何工作的

MapReduce 框架帮助开发者把查询分成多步，把数据集合分成多个片段，然后在不同的物理主机上运行这些“步骤/片段”组合。

MapReduce 查询分成两步：

* **Map**：收集数据阶段。在 Map 步骤中，大型数据片段会被分成更小的片段，然后在各片段上运算。
* **Reduce**：数据校对或处理阶段。Reduce 步骤把 Map 步骤中的多个结果汇总到一个最终输出里（_这一步是可选的_）

![MapReduce Diagram](/images/MapReduce-diagram.png)

Riak 的 MapReduce 查询有两部分组成：

* 输入列表
* 步骤列表

输入列表的元素是“bucket/键”组合。步骤列表的元素是 Map 函数、Reduce 函数或 Link 函数的相关信息。

客户端向 Riak 发起请求，接受请求的节点负责协调 MapReduce 作业。MapReduce 作业中包含很多步骤，Map 或 Reduce。Map 步骤中有一个函数和一组传入函数的对象，以 bucket 分组。协调查询的节点使用输入列表找到对象，函数则在这些对象上做运算。

Map 函数执行完毕后，结果会返回给负责协调的节点。负责协调的几点会把结果组成一个列表，再传给在同一个节点上运行的 Reduce 步骤（假设下一个步骤是 Reduce）。

## 示例

在这个例子中，我们要创建四个对象，都包含文本“pizza”，然后使用 Javascript MapReduce 查询统计“pizza”出现的次数。

### 存入数据的命令

```bash
curl -XPUT http://localhost:8098/buckets/training/keys/foo -H 'Content-Type: text/plain' -d 'pizza data goes here'
curl -XPUT http://localhost:8098/buckets/training/keys/bar -H 'Content-Type: text/plain' -d 'pizza pizza pizza pizza'
curl -XPUT http://localhost:8098/buckets/training/keys/baz -H 'Content-Type: text/plain' -d 'nothing to see here'
curl -XPUT http://localhost:8098/buckets/training/keys/bam -H 'Content-Type: text/plain' -d 'pizza pizza pizza'
```

### MapReduce 查询脚本

```javascript
curl -XPOST http://localhost:8098/mapred \
  -H 'Content-Type: application/json' \
  -d '{
    "inputs":"training",
    "query":[{"map":{"language":"javascript",
    "source":"function(riakObject) {
      var val = riakObject.values[0].data.match(/pizza/g);
      return [[riakObject.key, (val ? val.length : 0 )]];
    }"}}]}'
```

### 输出

输出的结果中包含各对象的键，以及“pizza”在其中出现的次数，如下所示：

```text
[["foo",1],["baz",0],["bar",4],["bam",3]]
```

### 小结

我们在 `training` 这个 bucket 中执行 Javascript MapReduce 查询，输入各 `riakObject`（Javascript 中表示键值对的方式），搜索“pizza”这个单词。`val` 是搜索的结果，包含零个或多个匹配正则表达式的结果。然后返回 `riakObject` 的键和匹配的数量。

<!-- ## NEED TO ADD
* Errors
* Tombstones
 -->

## 扩展阅读

* [[MapReduce 高级用法]]：详细说明了 Riak 是如何实现 MapReduce 的，以及不同的查询方法，示例和设置
* [[使用键过滤器]]：使用键查询整个 bucket，预处理 MapReduce 的输入数据
