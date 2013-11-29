---
title: 通过 HTTP 获取对象
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Object/Key Operations"
---

读取指定“bucket/键”组合对应的对象。

## 请求

```bash
GET /riak/bucket/key            # Old format
GET /buckets/bucket/keys/key    # New format
```

重要的报头：

* `Accept` - 如果 content-type 是 `multipart/mixed`，请求会返回对象的所有兄弟数据。示例参见下文。推荐阅读 RFC 2616 - [[Accept header definition|http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1]]。

可选的报头：

* `If-None-Match` 和 `If-Modified-Since` 分别检查对象的 `ETag` 和 `Last-Modified`，进行条件请求。如果这两个测试中有一个失败了（ETag 相同，或者对象在提供的时间戳之前没有改动），Riak 就会返回 `304 Not Modified` 响应。参见 RFC 2616 - [[304 Not Modified|http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.3.5]]。

可选的请求参数：

* `r` - （读取法定值）获取对象时要得到多少个副本（[[默认值在 bucket 层面设定|通过 HTTP 设置 bucket 的属性]]）
* `pr` - 执行读取操作时要有多少个主节点副本在线（[[默认值在 bucket 层面设定|通过 HTTP 设置 bucket 的属性]]）
* `basic_quorum` - 在某些失败情况下是否要提前返回失败响应（例如，r=1，出现 2 个错误，如果 `basic_quorum=true`，就会返回错误）（[[默认值在 bucket 层面设定|通过 HTTP 设置 bucket 的属性]]）
* `notfound_ok` - 是否把未找到认为是成功的读取（[[默认值在 bucket 层面设定|通过 HTTP 设置 bucket 的属性]]）
* `vtag` - 当访问对象的兄弟数据时，要获取哪个兄弟数据

更多信息请看下面的[[手动请求兄弟数据|通过 HTTP 获取对象#Manually-requesting-siblings]]示例。

## 响应

正常的响应码：

* `200 OK`
* `300 Multiple Choices`
* `304 Not Modified`（条件请求时）

常见的错误码：

* `400 Bad Request` - 例如 r 值不可用（> N）
* `404 Not Found` - 无法在足够多的分区上找到对象
* `503 Service Unavailable` - 请求超时

重要的响应报头：

* `Content-Type` - 媒介类型/格式
* `X-Riak-Vclock` - 对象的向量时钟
* `X-Riak-Meta-*` - 存储对象时用户定义的元数据
* `ETag` - 对象的实体标签，用于条件 GET 请求和基于验证的缓存
* `Last-Modified` - 对象上一次改动的时间戳，使用 HTTP 日期时间格式
* `Link` - 用户和系统定义的指向其他资源的链接。参见“[[链接]]”一文

响应的主体是对象的内容，如果对象有兄弟数据，还包含兄弟数据。

<div class="note">
<div class="title">兄弟数据</div>

<p>如果 bucket 的 `allow_mult` 属性设为 `true`，则可以并发更新，生成兄弟对象，即很多值通过向量时钟相互关联。应用程序要负责处理对象版本冲突。</p>

<p>如果对象有多个兄弟数据，会返回 `300 Multiple Choices` 响应。如果 `Accept` 报头倾向于选择 `multipart/mixed` 类型的数据，所有的兄弟数据都会返回。否则，会以纯文本格式列出一组 vtags。请求中可以指定 `vtag` 参数查询单个兄弟数据。更多信息请参照下面的[[手动请求兄弟数据|通过 HTTP 获取对象#Manually-requesting-siblings]]示例。</p>

<p>要解决冲突，可以把解决好的版本使用响应中的 `X-Riak-Vclock` 存储。</p>
</div>

## 简单示例

```bash
$ curl -v http://127.0.0.1:8098/riak/test/doc2
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test/doc2 HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< X-Riak-Vclock: a85hYGBgzGDKBVIsbLvm1WYwJTLmsTLcjeE5ypcFAA==
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Link: </riak/test>; rel="up"
< Last-Modified: Wed, 10 Mar 2010 18:11:41 GMT
< ETag: 6dQBm9oYA1mxRSH0e96l5W
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 13
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
{"foo":"bar"}
```

## 兄弟数据示例

<a id="Manually-requesting-siblings"></a>
### 手动请求兄弟数据

```bash
$ curl -v http://127.0.0.1:8098/riak/test/doc
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test/doc HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 300 Multiple Choices
< X-Riak-Vclock: a85hYGDgyGDKBVIszMk55zKYEhnzWBlKIniO8kGF2TyvHYIKf0cIszUnMTBzHYVKbIhEUl+VK4spDFTPxhHzFyqhEoVQz7wkSAGLMGuz6FSocFIUijE3pt5HlsgCAA==
< Vary: Accept, Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: text/plain
< Content-Length: 102
<
Siblings:
16vic4eU9ny46o4KPiDz1f
4v5xOg4bVwUYZdMkqf0d6I
6nr5tDTmhxnwuAFJDd2s6G
6zRSZFUJlHXZ15o9CG0BYl
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0

$ curl -v http://127.0.0.1:8098/riak/test/doc?vtag=16vic4eU9ny46o4KPiDz1f
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test/doc?vtag=16vic4eU9ny46o4KPiDz1f HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< X-Riak-Vclock: a85hYGDgyGDKBVIszMk55zKYEhnzWBlKIniO8kGF2TyvHYIKf0cIszUnMTBzHYVKbIhEUl+VK4spDFTPxhHzFyqhEoVQz7wkSAGLMGuz6FSocFIUijE3pt5HlsgCAA==
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Link: </riak/test>; rel="up"
< Last-Modified: Wed, 10 Mar 2010 18:01:06 GMT
< ETag: 16vic4eU9ny46o4KPiDz1f
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/x-www-form-urlencoded
< Content-Length: 13
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
{"bar":"baz"}
```

### 一次请求获取所有兄弟数据

```bash
$ curl -v http://127.0.0.1:8098/riak/test/doc -H "Accept: multipart/mixed"
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test/doc HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: multipart/mixed
>
< HTTP/1.1 300 Multiple Choices
< X-Riak-Vclock: a85hYGDgyGDKBVIszMk55zKYEhnzWBlKIniO8kGF2TyvHYIKf0cIszUnMTBzHYVKbIhEUl+VK4spDFTPxhHzFyqhEoVQz7wkSAGLMGuz6FSocFIUijE3pt5HlsgCAA==
< Vary: Accept, Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: multipart/mixed; boundary=YinLMzyUR9feB17okMytgKsylvh
< Content-Length: 766
<

--YinLMzyUR9feB17okMytgKsylvh
Content-Type: application/x-www-form-urlencoded
Link: </riak/test>; rel="up"
Etag: 16vic4eU9ny46o4KPiDz1f
Last-Modified: Wed, 10 Mar 2010 18:01:06 GMT

{"bar":"baz"}
--YinLMzyUR9feB17okMytgKsylvh
Content-Type: application/json
Link: </riak/test>; rel="up"
Etag: 4v5xOg4bVwUYZdMkqf0d6I
Last-Modified: Wed, 10 Mar 2010 18:00:04 GMT

{"bar":"baz"}
--YinLMzyUR9feB17okMytgKsylvh
Content-Type: application/json
Link: </riak/test>; rel="up"
Etag: 6nr5tDTmhxnwuAFJDd2s6G
Last-Modified: Wed, 10 Mar 2010 17:58:08 GMT

{"bar":"baz"}
--YinLMzyUR9feB17okMytgKsylvh
Content-Type: application/json
Link: </riak/test>; rel="up"
Etag: 6zRSZFUJlHXZ15o9CG0BYl
Last-Modified: Wed, 10 Mar 2010 17:55:03 GMT

{"foo":"bar"}
--YinLMzyUR9feB17okMytgKsylvh--
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```
