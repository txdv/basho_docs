---
title: 通过 HTTP 获取 bucket 的属性
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Bucket Operations"
---

读取 bucket 属性。

## 请求

```bash
GET /riak/bucket                # Old format
GET /buckets/bucket/props       # New format
```

可选的请求参数（只对旧请求格式可用）：

* `props` - 是否返回 bucket 的属性（默认值是 `true`）
* `keys` - 是否返回 bucket 中存储的键（默认值是 `false`）参见[[HTTP 列键操作|通过 HTTP 列出键]]

## 响应

正常的响应码：

* `200 OK`

重要的报头：

* `Content-Type` - `application/json`

响应中的 JSON 对象中最多可以有两个元素：`"props"` 和 `"keys"`，根据请求参数的设定，对应的元素可能不会出现。默认情况下，只有 `"props"` 会出现。

可获取的 bucket 属性参见“[[通过 HTTP 设置 bucket 的属性]]”一文。

## 示例

```bash
$ curl -v http://127.0.0.1:8098/riak/test
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test HTTP/1.1
> User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7
OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: application/json
< Content-Length: 368
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
{"props":{"name":"test","n_val":3,"allow_mult":false,"last_write_wins":false,"
precommit":[],"postcommit":[],"chash_keyfun":{"mod":"riak_core_util","fun":"
chash_std_keyfun"},"linkfun":{"mod":"riak_kv_wm_link_walker","fun":"
mapreduce_linkfun"},"old_vclock":86400,"young_vclock":20,"big_vclock":50,"
small_vclock":10,"r":"quorum","w":"quorum","dw":"quorum","rw":"quorum"}}
```
