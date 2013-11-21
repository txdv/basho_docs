---
title: PBC List Keys
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Bucket Operations"
---

列出 bucket 中的所有键。这个请求使用流处理，每个请求有多个响应。

<div class="note">
<div class="title">不要在生产环境中使用</div>
<p>这个操作会遍历集群中所有的键，不应该在生产环境中使用。</p>
</div>

## 请求

```bash
message RpbListKeysReq {
    required bytes bucket = 1;
}
```

可选的参数：

* **bucket** - 键所在的 bucket

## 响应


```bash
message RpbListKeysResp {
    repeated bytes keys = 1;
    optional bool done = 2;
}
```

响应值：

* **keys** - bucket 中的键
* **done** - 在最后一个响应中为 `true`

## 示例

请求：

```bash
Hex      00 00 00 0B 11 0A 08 6C 69 73 74 6B 65 79 73
Erlang <<0,0,0,11,17,10,8,108,105,115,116,107,101,121,115>>

RpbListKeysReq protoc decode:
bucket: "listkeys"
```

响应 1：

```bash
Hex      00 00 00 04 12 0A 01 34
Erlang <<0,0,0,4,18,10,1,52>>

RpbListKeysResp protoc decode:
keys: "4"
```

响应 2：

```bash
Hex      00 00 00 08 12 0A 02 31 30 0A 01 33
Erlang <<0,0,0,8,18,10,2,49,48,10,1,51>>

RpbListKeysResp protoc decode:
keys: "10"
keys: "3"
```

响应 3：

```bash
Hex      00 00 00 03 12 10 01
Erlang <<0,0,0,3,18,16,1>>

RpbListKeysResp protoc decode:
done: true
```
