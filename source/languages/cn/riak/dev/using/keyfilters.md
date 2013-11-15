---
title: Using Key Filters
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, mapreduce, keyfilters]
---

键过滤器可以对 [[MapReduce|Using MapReduce]] 的输入数据进行预处理，只检查键而无需加载对象。如果键中包含特定的信息就可以使用键过滤器在查询时进行预先分析。

## 理解键过滤器

键过滤器可以看成一系列[[转换操作|Using Key Filters#Transform-functions]]和[[判定操作|Using Key Filters#Predicate-functions]]，尝试对列键操作生成的键进行匹配。满足判定函数的键会提供给 MapReduce 查询，就行手动提供输入数据一样。

下面举例说明。加入我们把客户的发票存储在“invoices”这个 bucket 中，有一个键由客户名称和日期组成，下面是几个键示例：

<notextile><pre>basho-20101215
google-20110103
yahoo-20090613</pre></notextile>

对于这样的键，我们可以使用键过滤器进行一些查询：

* 查找某个客户的所有发票
* 查找某段时间内的所有发票
* 查找客户名中包含“solutions”的发票
* 查找6月3日发送的发票

具体的查询方法参见下面的[[示例|Using Key Filters#Example-query-solutions]]

把键过滤到只保留我们关心的信息之后，使用常规的 MapReduce 作业就可以进一步过滤、转换、提取并聚合我们需要的数据了。

## 键过滤器的结构

键过滤器会修改 MapReduce 查询的输入数据。

如果以 JSON 格式提交查询，JSON 对象中要包含两个元素：bucket 和 key_filters。所有的过滤器，包括不接受参数的过滤器，都要以数组的形式指定。如下例所示：

```javascript
{
  "inputs":{
     "bucket":"invoices",
     "key_filters":[["ends_with", "0603"]]
  }
  // ... rest of mapreduce job
}
```

如果从本地 Erlang 客户端或 Protocol Buffers 客户端提交查询，输入数据就是包含两个元素的元组，第一个元素是 bucket 名，第二个元素是过滤器列表。和 JSON 格式一样，这里的过滤器也要以列表的形式指定，包括不接受参数的过滤器。过滤器的名字使用二进制格式。

```erlang
riakc_pb_socket:mapred(Pid, {<<"invoices">>, [[<<"ends_with">>,<<"0603">>]]}, Query).
```

## 键过滤器函数

Riak 键过滤器有两种函数：转换和判定。

转换过滤器函数对键进行处理，把键转换成一种可以被[[判定函数|Key Filters Reference#Predicate-functions]]处理的格式。每个函数的描述文本都使用 JSON 格式。

判定过滤器函数对输入进行测试，返回 `true` 或 `false`。鉴于此，判定函数应该在一系列键过滤器的最后，而且经常放在[[转换函数|Key Filters Reference#Transform-functions]]之后。

键过滤器函数的详细列表可以在“[[键过滤器参考手册Key Filters Reference]]”中查看。

## 查询方法示例

查找某个客户的所有发票：

```javascript
{
  "inputs":{
     "bucket":"invoices"
     "key_filters":[["tokenize", "-", 1],["eq", "basho"]]
   },
   // ...
}
```

查找某段时间内的所有发票：

```javascript
{
  "inputs":{
     "bucket":"invoices"
     "key_filters":[["tokenize", "-", 2],
                    ["between", "20100101", "20101231"]]
   },
   // ...
}
```

查找客户名中包含“solutions”的发票：

```javascript
{
  "inputs":{
     "bucket":"invoices"
     "key_filters":[["tokenize", "-", 1],
                    ["to_lower"],
                    ["matches", "solutions"]]
   },
   // ...
}
```

查找6月3日发送的发票：

```javascript
{
  "inputs":{
     "bucket":"invoices"
     "key_filters":[["ends_with", "0603"]]
   },
   // ...
}
```
