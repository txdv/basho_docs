---
title: HTTP List Buckets
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Bucket Operations"
---

列出全部有效的 bucket（其中存有键）。

<div class="note">
<div class="title">不要在生产环境中操作</div>
<p>和列键操作类似，这个查询会遍历集群中存储的所有键，不应该在生产环境中操作。</p>
</div>

## 请求

```bash
GET /riak?buckets=true       # Old format
GET /buckets?buckets=true    # New format
```

必须提供的请求参数：

* **buckets=true** - 列出 bucket 请求必须指定

## 响应

正常的状态码：

* 200 OK

重要的报头：

* Content-Type - application/json

响应中的 JSON 对象只有一个元素：bucket，其值是一个 bucket 名字组成的数组。

## 示例

```bash
$ curl -i http://localhost:8098/riak?buckets=true
HTTP/1.1 200 OK
Vary: Accept-Encoding
Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
Link: </riak/files>; rel="contained"
Date: Fri, 30 Sep 2011 15:24:35 GMT
Content-Type: application/json
Content-Length: 21

{"buckets":["files"]}
```
