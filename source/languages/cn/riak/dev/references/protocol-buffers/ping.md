---
title: PBC Ping
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Server Operations"
---

检查服务器是否在线。

## 请求

只有 RpbPingReq 消息码。没有请求消息。

## Response

只有 RpbPingResp 消息码。没有响应消息。

## 示例

请求：

```bash
Hex    00 00 00 01 01
Erlang <<0,0,0,1,1>>
```

响应：

```bash
Hex    00 00 00 01 02
Erlang <<0,0,0,1,2>>
```
