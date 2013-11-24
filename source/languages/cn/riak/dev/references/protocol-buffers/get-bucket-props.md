---
title: 通过 PBC 获取 bucket 的属性
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Bucket Operations"
---

读取 bucket 属性。

## 请求

```bash
message RpbGetBucketReq {
    required bytes bucket = 1;
}
```

必须提供的参数：

* **bucket** - 要读取属性的 bucket

## 响应

```bash
message RpbGetBucketResp {
    required RpbBucketProps props = 1;
}
// Bucket properties
message RpbBucketProps {
    optional uint32 n_val = 1;
    optional bool allow_mult = 2;
}
```

响应值：

* **n_val** - 该 bucket 的当前 n_val
* **allow_mult** - 如果冲突要返回给客户端，把 `allow_mult` 设为 `true`

## 示例

请求：

```bash
Hex      00 00 00 0B 13 0A 08 6D 79 62 75 63 6B 65 74
Erlang <<0,0,0,11,19,10,8,109,121,98,117,99,107,101,116>>

RpbGetBucketReq protoc decode:
bucket: "mybucket"
```

响应：

```bash
Hex      00 00 00 07 14 0A 04 08 05 10 01
Erlang <<0,0,0,7,20,10,4,8,5,16,1>>

RpbGetBucketResp protoc decode:
props {
  n_val: 5
  allow_mult: true
}

```
