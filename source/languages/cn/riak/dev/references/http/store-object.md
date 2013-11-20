---
title: HTTP Store Object
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Object/Key Operations"
---

在指定的“bucket/键”组合中存储对象。存储对象有两种方式：使用自己指定的键，或者使用由 Riak 分配的键。

## 请求

```bash
POST /riak/bucket               # Riak-defined key, old format
POST /buckets/bucket/keys       # Riak-defined key, new format
PUT /riak/bucket/key            # User-defined key, old format
PUT /buckets/bucket/keys/key    # User-defined key, new format
```

为了兼容老的客户端，当使用指定的键存储对象时，也可以使用 `POST` 请求。

重要的报头：

* `Content-Type` - 必须为存储的对象指定，其值是取出时希望得到的类型
* `X-Riak-Vclock` - 如果对象已经存在，读取对象时附加其上的向量时钟
* `X-Riak-Meta-*` - 其他要附加在存储对象上的元数据报头
* `X-Riak-Index-*` - 该对象的索引应该放在哪个索引条目下。更多信息参加“[[通过 HTTP 执行二级索引查询|HTTP Secondary Indexes]]”一文
* `Link` - 用户和系统定义的链接。更多信息参加“[[链接|Links]]”一文

可选的报头（只能在 `PUT` 请求中使用）：

* `If-None-Match`、`If-Match`、`If-Modified-Since` 和 `If-Unmodified-Since` 会和对象的 `ETag` 和 `Last-Modified` 比较，触发条件请求。这几个报头可以避免覆盖修改后的对象。如果比较失败，会收到 `412 Precondition Failed` 响应。但不能避免并发写入，如果请求在同一时间发出，多个请求的条件比较可能会返回 `true`。

可选的请求参数：

* `w` - （写入法定值）返回成功响应之前要写入多少个副本（默认值在 bucket 层面设置）
* `dw` - （持久写入法定值）返回成功响应之前要向持久性存储中写入多少个副本（默认值在 bucket 层面设置）
* `pw` - 写入时要有多少个主副本在线（默认值在 bucket 层面设置）
* `returnbody=[true|false]` - 是否返回保存的对象内容

*<ins>请求必须包含主体。</ins>*

## 响应

正常的状态码：

* `201 Created`（未指定键）
* `200 OK`
* `204 No Content`
* `300 Multiple Choices`

常见的错误码：

* `400 Bad Request` - 例如，r、w 和 dw 参数的值不合法（> N）
* `412 Precondition Failed` - 任何一个条件请求报头匹配失败（见上）

重要的报头：

* `Location` - 指向新创建对象的相对 URL 地址（不指定键存储对象时）

如果 `returnbody=true`，[[通过 HTTP 获取对象|HTTP-Fetch-Object]]时得到的响应报头都可能会出现。例如，如果有兄弟数据，或者作为某项操作的一部分，可能会返回 `300 Multiple Choices`，响应可以按照类似方式处理。

## 示例：不指定键存储对象

```bash
$ curl -v -d 'this is a test' -H "Content-Type: text/plain" http://127.0.0.1:8098/riak/test
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> POST /riak/test HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
> Content-Type: text/plain
> Content-Length: 14
>
< HTTP/1.1 201 Created
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Location: /riak/test/bzPygTesROPtGGVUKfyvp2RR49
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 0
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```

## 示例：指定键存储对象

```bash
$ curl -v -XPUT -d '{"bar":"baz"}' -H "Content-Type: application/json" -H "X-Riak-Vclock: a85hYGBgzGDKBVIszMk55zKYEhnzWBlKIniO8mUBAA==" http://127.0.0.1:8098/riak/test/doc?returnbody=true
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> PUT /riak/test/doc?returnbody=true HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
> Content-Type: application/json
> X-Riak-Vclock: a85hYGBgzGDKBVIszMk55zKYEhnzWBlKIniO8mUBAA==
> Content-Length: 13
>
< HTTP/1.1 200 OK
< X-Riak-Vclock: a85hYGBgymDKBVIszMk55zKYEhnzWBlKIniO8kGF2TyvHYIKfwcJZwEA
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Link: </riak/test>; rel="up"
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 13
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
{"bar":"baz"}
```
