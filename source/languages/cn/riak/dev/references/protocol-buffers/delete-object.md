---
title: PBC Delete Object
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Object/Key Operations"
---

删除指定“bucket/键”组合对应的对象。

## 请求

```bash
message RpbDelReq {
    required bytes bucket = 1;
    required bytes key = 2;
    optional uint32 rw = 3;
    optional bytes vclock = 4;
    optional uint32 r = 5;
    optional uint32 w = 6;
    optional uint32 pr = 7;
    optional uint32 pw = 8;
    optional uint32 dw = 9;
}
```

可选的参数：

* **rw** - 返回成功响应之前要删除多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **vclock** - 前面的 RpbGetResp 消息提供的向量时钟。避免删除上一次 GET 请求修改的对象
* **r** -（读取法定值） 获取对象时要得到多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **w** -（写入法定值）返回成功响应之前应该接受到多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **pr** -（主读取法定值）获取对象时要得到多少个主节点副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **pw** - 写入时要有多少个主节点在线。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **dw** - 返回成功响应之前要向持久性存储中写入多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）

## 响应

只会返回消息码。

## 示例

请求：

```bash
Hex      00 00 00 12 0D 0A 0A 6E 6F 74 61 62 75 63 6B 65
         74 12 01 6B 18 01
Erlang <<0,0,0,18,13,10,10,110,111,116,97,98,117,99,107,101,116,18,1,107,24,1>>

RpbDelReq protoc decode:
bucket: "notabucket"
key: "k"
rw: 1
```
响应：

```bash
Hex      00 00 00 01 0E
Erlang <<0,0,0,1,14>>

RpbDelResp - only message code defined
```
