---
title: HTTP Delete Object
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Object/Key Operations"
---

删除指定“bucket/键”组合对应的对象。

## 请求

```
DELETE /riak/bucket/key           # Old format
DELETE /buckets/bucket/keys/key   # New format
```

可选的请求参数：

* `rw` - 删除操作中涉及到的两个请求（GET 和 PUT）使用的法定值（默认值在 bucket 层面设定）
* `r` - （读取法定值）获取对象时要得到多少个副本
* `pr` - （主读取法定值）和 `r` 类似，但读取的节点不能是回退节点
* `w` - （写入法定值）返回成功响应之前应该接受到多少个副本
* `dw` - （持久写入法定值）返回成功响应之前持久化存储要返回多少个副本
* `pw` - （主写入法定值）返回成功响应之前主节点要返回多少个副本

## 响应

<div class="note">
<div class="title">客户端 ID</div>
<p>发送到 Riak 1.0 及以下版本的请求，如果没有启用 `vnode_vclocks`，请求中必须包含 `X-Riak-ClientId` 报头，使用任意的字符串唯一标识客户端，以便使用[[向量时钟|Vector Clocks]]跟踪对象的变动。</p>
</div>

正常的响应码：

* `204 No Content`
* `404 Not Found`

常见的错误码：

* `400 Bad Request` - e.g. when rw parameter is invalid (> N)

`404` 是正常的响应码，因为 DELETE 操作是幂等的，没找到资源和资源被删除的效果是一样的。

## 示例

```bash
$ curl -v -X DELETE http://127.0.0.1:8098/riak/test/test2
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> DELETE /riak/test/test2 HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 204 No Content
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 0
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```
