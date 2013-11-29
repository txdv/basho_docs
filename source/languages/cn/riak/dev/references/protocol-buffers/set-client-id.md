---
title: 通过 PBC 设置客户端 ID
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Server Operations"
---

设定当前连接的客户端 ID。ID 的设定可以使用代码库，只要能生成唯一的标识符即可。客户端 ID 可以减缓向量时钟增多的趋势。

<div class="note">
<div class="title">Riak 1.0 中的客户端 ID</div>
<p>所有发送到 Riak 1.0 及以下版本的请求，如果没有设定 <code>vnode_vclocks</code>，必须要设定客户端 ID，其值可以使用随机的字符串，只要能唯一标识客户端即可。客户端 ID 在[[向量时钟]]中用来跟踪对象变动。</p>
</div>

## 请求

```bash
message RpbSetClientIdReq {
    required bytes client_id = 1; // Client id to use for this connection
}
```

## 响应

只会返回 RpbSetClientIdResp 消息码。

## 示例

请求：

```bash
Hex      00 00 00 07 05 0A 04 01 65 01 B6
Erlang <<0,0,0,7,5,10,4,1,101,1,182>>

RpbSetClientIdReq protoc decode:
client_id: "001e001266"
```

响应：

```bash
Hex      00 00 00 01 06
Erlang <<0,0,0,1,6>>

RpbSetClientIdResp - only message code defined
```
