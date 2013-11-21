---
title: PBC Set Bucket Properties
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Bucket Operations"
---

设置 bucket 的属性。

<div class="note">
<p>PBC 接口目前没有完全支持所有的 bucket 属性，现在只能设置 <code>allow_mult</code> 和 <code>n_val</code>;。其他的属性要通过 [[HTTP API|HTTP Set Bucket Properties]] 设置。</p>
</div>

## 请求

```bash
message RpbSetBucketReq {
    required bytes bucket = 1;
    required RpbBucketProps props = 2;
}
// Bucket properties
message RpbBucketProps {
    optional uint32 n_val = 1;
    optional bool allow_mult = 2;
}
```

必须提供的参数：

* **bucket** - 要设置属性的 bucket
* **props** - 要修改的属性
* **n_val** - bucket 当前的 n_val
* **allow_mult** - 如果要把冲突返回给客户端，就把 `allow_mult` 设为 `true`

## 响应

只返回消息码。

## 示例

把“friends”这个 bucket 的 `allow_mult` 设为 `true`。

请求：

```bash
Hex      00 00 00 0E 15 0A 07 66 72 69 65 6E 64 73 12 02
         10 01
Erlang <<0,0,0,14,21,10,7,102,114,105,101,110,100,115,18,2,16,1>>

RpbSetBucketReq protoc decode:
bucket: "friends"
props {
  allow_mult: true
}
```

响应：

```bash
Hex      00 00 00 01 16
Erlang <<0,0,0,1,22>>

RpbSetBucketResp - only message code defined
```
