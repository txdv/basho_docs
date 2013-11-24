---
title: 通过 HTTP 进行链接遍历
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Query Operations"
---

链接遍历根据附属在对象上的链接从指定的“bucket/键”组合开始查找并返回对象。链接遍历是特殊的 [[MapReduce 查询|使用 MapReduce]]，如果直接使用 MapReduce 要复杂的多。关于链接的更多内容请阅读“[[链接]]” 一文。

## 请求

```bash
GET /riak/bucket/key/[bucket],[tag],[keep]            # 旧格式
GET /buckets/bucket/keys/key/[bucket],[tag],[keep]    # 新格式
```

<div class="info">
<div class="title">链接过滤器</div>
<p>请求 URL 中的链接过滤器包含三部分，以逗号分隔：</p>

<ul>
<li>Bucket - 限制链接指向的对象所在的 bucket</li>
<li>Tag - 设置链接指向的对象的“riaktag”</li>
<li>Keep - 0 或 1，是否返回这一步的结果</li>
</ul>

<p>这三部分都可以使用 <code>_</code>（下划线），即任何值都是合法的。多步链接变量可以直接在 URL 后面加上路径片段，以斜线分隔。链接遍历的最后一步会返回查询的结果。</p>
</div>

## 响应

正常的状态码：

* `200 OK`

常见的错误码：

* `400 Bad Request` - 如果请求 URL 的格式不正确
* `404 Not Found` - 如果遍历的初始对象不存在

重要的报头：

* `Content-Type` - 都是 `multipart/mixed`，还指定了边界

<div class="note">
<div class="title">理解响应主体</div>
<p>响应主体的类型都是 <code>multipart/mixed</code>，每个片段代表链接遍历查询中的一步。每一步的结果也会使用 <code>multipart/mixed</code> 格式编码，每个片段代表找到的一个对象。如果没找到对象，或者这一步的 `keep` 设为 `0`，那么就不会有对应这一步的片段。各步结果中的对象都有 <code>Location</code> 报头，用来识别所属的 bucket 和对应的键。其实，可以直接把每个对象片段看成是[[获取单个对象|通过 HTTP 获取对象]]得到的完整响应，只是没有状态码而已。</p>
</div>

## 示例

```bash
$ curl -v http://127.0.0.1:8098/riak/test/doc3/test,_,1/_,next,1
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test/doc3/test,_,1/_,next,1 HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Expires: Wed, 10 Mar 2010 20:24:49 GMT
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: multipart/mixed; boundary=JZi8W8pB0Z3nO3odw11GUB4LQCN
< Content-Length: 970
<

--JZi8W8pB0Z3nO3odw11GUB4LQCN
Content-Type: multipart/mixed; boundary=OjZ8Km9J5vbsmxtcn1p48J91cJP

--OjZ8Km9J5vbsmxtcn1p48J91cJP
X-Riak-Vclock: a85hYGDgymDKBVIszMk55zKYEhnzWBlKIniO8kGF2TyvHYIKf0cIszUnMTBzHYVKbIhEUl+VK4spDFTPxhHzFyqhEoVQz7wkSAGLMGuz6FSocFIUijE3pt7HlGBhnqejARXmq0QyZnnxE6jwVJBwFgA=
Location: /riak/test/doc
Content-Type: application/json
Link: </riak/test>; rel="up", </riak/test/doc2>; riaktag="next"
Etag: 3pvmY35coyWPxh8mh4uBQC
Last-Modified: Wed, 10 Mar 2010 20:14:13 GMT

{"riak":"CAP"}
--OjZ8Km9J5vbsmxtcn1p48J91cJP--

--JZi8W8pB0Z3nO3odw11GUB4LQCN
Content-Type: multipart/mixed; boundary=RJKFlAs9PrdBNfd74HANycvbA8C

--RJKFlAs9PrdBNfd74HANycvbA8C
X-Riak-Vclock: a85hYGBgzGDKBVIsbLvm1WYwJTLmsTLcjeE5ypcFAA==
Location: /riak/test/doc2
Content-Type: application/json
Link: </riak/test>; rel="up"
Etag: 6dQBm9oYA1mxRSH0e96l5W
Last-Modified: Wed, 10 Mar 2010 18:11:41 GMT

{"foo":"bar"}
--RJKFlAs9PrdBNfd74HANycvbA8C--

--JZi8W8pB0Z3nO3odw11GUB4LQCN--
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```
