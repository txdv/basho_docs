---
title: 通过 PBC 执行二级索引查询
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Query Operations"
---

获取符合二级索引查询条件的键。

## 请求

```bash
message RpbIndexReq {
    enum IndexQueryType {
        eq = 0;
        range = 1;
    }
    required bytes bucket = 1;
    required bytes index = 2;
    required IndexQueryType qtype = 3;
    optional bytes key = 4;
    optional bytes range_min = 5;
    optional bytes range_max = 6;
    optional bool return_terms = 7;
    optional bool stream = 8;
    optional uint32 max_results = 9;
    optional bytes continuation = 10;
}
```

必须提供的参数：

* **bucket** - 要查询索引所在的 bucket
* **index** - 要使用的索引名
* **qtype** - IndexQueryType，0（等于）或者 1（范围）

索引查询有两种查询方式：

* **eq** - 精确匹配指定的 `key`
* **range** - l落在一个范围内（`range_min` 和 `range_max` 之间）

分页：

* **max_results** - 返回结果的数量
* **continuation** - 在分页响应中结合 `max_results` 使用，请求下一页的结果

可选的参数：

* **key** - 要精确匹配的键。只在 `qtype` 设为 0 时使用
* **range_min** - 范围查询的下限。只在 `qtype` 设为 1 时使用
* **range_max** - 范围查询的上限。只在 `qtype` 设为 1 时使用
* **return_terms** - 在响应中包含匹配的索引值（只用于范围查询）
* **stream** - 用流的方式返回响应，而不是等到收集了 `max_results` 指定的数量或者完整的结果后再返回

## 响应

二级索引查询的返回结果是一系列重复的 0 或者符合查询条件的键。

```bash
message RpbIndexResp {
    repeated bytes keys = 1;
    repeated RpbPair results = 2;
    optional bytes continuation = 3;
    optional bool done = 4;
}
```

响应值：

* **keys** - 符合索引请求查询条件的一系列键
* **results** - 如果范围查询指定了 `return_terms`，返回匹配的索引值
* **continuation** - 用于分页的响应
* **done** - 用于使用流的方式返回结果：当前的流处理已经结束（已经达到了 `max_results` 指定的数量，或者后续没有结果了）

## 示例

请求：

我们在“farm”这个 bucket 中使用“animal_bin”索引精确查询匹配“chicken”的键。

```bash
RpbIndexReq protoc decode:
bucket: "farm"
index: "animal_bin"
qtype: 0
key: "chicken"

Hex     00 00 00 1E 19 0A 04 66 61 72 6D 12 0A 61 6E 69
        6D 61 6C 5F 62 69 6E 18 00 22 07 63 68 69 63 6B 65 6E
Erlang  <<0,0,0,30,25,10,10,4,102,97,114,109,18,10,97,110,105,
          109,97,108,95,98,105,110,24,0,34,7,99,104,105,99,107,
          101,110>>
```

响应：

```bash
Hex     00 00 00 0F 1A 0A 03 68 65 6E 0A 07 72 6F 6F 73 74 65 72
Erlang  <<0,0,0,15,26,10,3,104,101,110,10,7,114,111,111,115,116,101,114>>

RpbIndexResp protoc decode:
keys: "hen"
keys: "rooster"
```
