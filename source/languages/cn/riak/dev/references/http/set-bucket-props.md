---
title: HTTP Set Bucket Properties
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Bucket Operations"
---

设置 bucket 的属性，例如 "n_val" 和 "allow_mult"。

## 请求

```bash
PUT /riak/bucket                # Old format
PUT /buckets/bucket/props       # New format
```

重要的报头：

* `Content-Type` - `application/json`

请求主体是 JSON 对象，且只有一个元素 `props`。不需要修改的属性可以不指定新值。

可以设置的属性：

* `n_val`（大于 0 的整数） - bucket 中对象的副本数
* `allow_mult`（`true` 或 `false`） - 是否允许创建兄弟数据（并发更新）
* `last_write_wins`（`true` 或 `false`） -写入数据时是否忽略对象的历史版本（向量时钟）
* `precommit` - [[precommit 钩子|Using Commit Hooks]]
* `postcommit` - [[postcommit 钩子|Using Commit Hooks]]
* `r, w, dw, rw` - bucket 中键操作的法定值
可选的值有：
  * `"all"` - 所有节点都要响应
  * `"quorum"` - (n_val/2) + 1 个节点必须响应。*这是默认值*
  * `"one"` - 等同于设为 1
  * *其他整数* - 必须小于或等于 n_val
* `backend` - 使用 `riak_kv_multi_backend` 时，该 bucket 具体要使用哪个后台

bucket 中还有其他属性，但一般不会修改。

<div class="note">
<div class="title">属性的类型</div>
<p>确保属性的值要使用正确的类型。如果需要使用整数或布尔值，但却指定了字符串，会在日志中看到奇快的错误，例如 <code>"{badarith,[{riak_kv_util,normalize_rw_value,2},]}"</code>。</p>
</div>

## 响应

正常的状态码：

* `204 No Content`

常见的错误码：

* `400 Bad Request` - 提交的 JSON 格式不正确
* `415 Unsupported Media Type` - 请求的 Content-Type 没有设成 `application/json`

如果操作成功，响应主体中不会有任何内容。

## 示例

```bash
$ curl -v -XPUT -H "Content-Type: application/json" -d '{"props":{"n_val":5}}'
http://127.0.0.1:8098/riak/test
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> PUT /riak/test HTTP/1.1
> User-Agent: curl/7.19.4 (universal-apple-darwin10.0) libcurl/7.19.4
OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: */*
> Content-Type: application/json
> Content-Length: 21
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
