---
title: PBC Search
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Query Operations"
---

发送 Riak Search 请求，取回一组文档，以及一些状态信息。

## 请求

```bash
message RpbSearchQueryReq {
  required bytes  q      =  1;
  required bytes  index  =  2;
  optional uint32 rows   =  3;
  optional uint32 start  =  4;
  optional bytes  sort   =  5;
  optional bytes  filter =  6;
  optional bytes  df     =  7;
  optional bytes  op     =  8;
  repeated bytes  fl     =  9;
  optional bytes  presort = 10;
}
```

必须提供的参数：

* **q** - 要查询索引所在的 bucket
* **index** - 要查询的索引名

可选的参数：

* **rows** - 返回行数的最大值
* **start** - 偏移值。返回值之前要跳过的键数量
* **sort** - 搜索结果的排序方式
* **filter** - 使用行间字段指定的搜素过滤器
* **df** - 覆盖模式文件中设置的 `default_field`
* **op** - "and" 或 "or"，覆盖模式文件中设置的 `default_op`
* **fl** -返回字段的数量限制
* **presort** - 预排序（键 / 得分）

## 响应

Riak Search 查询的结果会是一系列重复的 0 或者 RpbSearchDocs。RpbSearchDocs 本身是由 0 和符合查询参数的键值对（RpbPair)）组成的。而且还会返回最大的搜素得分和结果的数量。

```bash
// RbpPair is a generic key/value pair datatype used for other message types
message RpbPair {
  required bytes key = 1;
  optional bytes value = 2;
}
message RpbSearchDoc {
  repeated RpbPair fields = 1;
}
message RpbSearchQueryResp {
  repeated RpbSearchDoc docs      = 1;
  optional float        max_score = 2;
  optional uint32       num_found = 3;
}
```

响应值：

* **docs** - 符合查询条件的一组文档
* **max_score** - 最大得分
* **num_found** - 符合查询条件的结果总数

## 示例

请求：

下面这个例子查询以字符串“pig”开头的动物名，我们只想得到前 100 个结果，而且按照 `name` 字段排序。

```bash
RpbSearchQueryReq protoc decode:
q: "pig*"
index: "animals"
rows: 100
start: 0
sort: "name"

Hex     00 00 00 1A 1B 0A 04 70 69 67 2A 12 07 61 6E
        69 6D 61 6C 73 18 64 20 00 2A 04 6E 61 6D 65
Erlang  <<0,0,0,26,27,10,4,112,105,103,42,18,7,97,110,
          105,109,97,108,115,24,100,32,0,42,4,110,97,
          109,101>>
```

响应：

```bash
Hex     00 00 00 36 1B 0A 1D 0A 0D 0A 06 61 6E 69 6D
        61 6C 12 03 70 69 67 0A 0C 0A 04 6E 61 6D 65
        12 04 66 72 65 64 0A 12 0A 10 0A 06 61 6E 69
        6D 61 6C 12 06 70 69 67 65 6F 6E 18 02
Erlang  <<0,0,0,54,27,10,29,10,13,10,6,97,110,105,109,
          97,108,18,3,112,105,103,10,12,10,4,110,97,
          109,101,18,4,102,114,101,100,10,18,10,16,10,
          6,97,110,105,109,97,108,18,6,112,105,103,
          101,111,110,24,2>>

RpbSearchQueryResp protoc decode:
docs {
  fields {
    key: "animal"
    value: "pig"
  }
  fields {
    key: "name"
    value: "fred"
  }
}
docs {
  fields {
    key: "animal"
    value: "pigeon"
  }
}
num_found: 2
```
