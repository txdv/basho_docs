---
title: PBC Get Client ID
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Server Operations"
---

获取当前连接的客户端 ID。客户端 ID 用来解决冲突，系统中的每个客户端都应该指定一个 ID。建立 socket 连接时会为客户端随机分配一个 ID，而且后续还可以[[修改|PBC Set Client ID]]。

<div class="note">
<div class="title">Riak 1.0 中的客户端 ID</div>
<p>所有发送到 Riak 1.0 及以下版本的请求，如果没有设定 <code>vnode_vclocks</code>，必须要设定客户端 ID，其值可以使用随机的字符串，只要能唯一标识客户端即可。客户端 ID 在[[向量时钟|Vector Clocks]]中用来跟踪对象变动。</p>
</div>

## 请求

只有 RpbGetClientIdReq 消息码。没有定义请求消息。

## 响应

```bash
// Get ClientId Request - no message defined, just send RpbGetClientIdReq
message code
message RpbGetClientIdResp {
    required bytes client_id = 1; // Client id in use for this connection
}
```

## 示例

请求：

```bash
Hex     00 00 00 01 03
Erlang  <<0,0,0,1,3>>
```

响应：

```bash
Hex     00 00 00 07 04 0A 04 01 65 01 B5
Erlang <<0,0,0,7,4,10,4,1,101,1,181>>

RpbGetClientIdResp protoc decode:
client_id: "001e001265"
```
