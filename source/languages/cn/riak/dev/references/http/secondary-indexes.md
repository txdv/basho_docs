---
title: HTTP Secondary Indexes
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Query Operations"
---

[[二级索引|Using Secondary Indexes]] 可以使用“字段/值”组合为 Riak 对象加上一个或多个标签。对象会使用这些“字段/值”组合建立索引，应用程序可以查询这些索引取回符合条件的键列表。

## 请求

### 精确匹配

```bash
GET /buckets/mybucket/index/myindex_bin/value
```

### 范围查询

```
GET /buckets/mybucket/index/myindex_bin/start/end
```

{{#1.4.0+}}
#### 通过关键字进行范围查询

要得到范围内的索引值，需要指定 `return_terms=true`。

```
GET /buckets/mybucket/index/myindex_bin/start/end?return_terms=true
```
{{/1.4.0+}}


{{#1.4.0+}}
### 分页

要想对结果进行分页，需要指定 `max_results` 参数。分页会限制返回的结果数量，并为下一个请求提供 `continuation` 值。

```
GET /buckets/mybucket/index/myindex_bin/start/end?return_terms=true&max_results=500
GET /buckets/mybucket/index/myindex_bin/start/end?return_terms=true&max_results=500&continuation=g2gCbQAAAAdyaXBqYWtlbQAAABIzNDkyMjA2ODcwNTcxMjk0NzM=
```
{{/1.4.0+}}


{{#1.4.0+}}
### 流处理
```
GET /buckets/mybucket/index/myindex_bin/start/end?stream=true
```
{{/1.4.0+}}

## 响应

正常的状态码：

+ `200 OK`

常见的错误码：

+ `400 Bad Request` - 如果索引名或索引值不合法
+ `500 Internal Server Error` - 如果 Map 函数或者 Reduce 函数运行的过程中出现错误，或者系统不支持索引
+ `503 Service Unavailable` - 作业完成前请求超时

## 示例

```bash
$ curl -v http://localhost:8098/buckets/mybucket/index/field1_bin/val1
* About to connect() to localhost port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to localhost (127.0.0.1) port 8098 (#0)
> GET /buckets/mybucket/index/field1_bin/val1 HTTP/1.1
> User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8r zlib/1.2.3
> Host: localhost:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 19
<
* Connection #0 to host localhost left intact
* Closing connection #0
{"keys":["mykey1"]}%
```
