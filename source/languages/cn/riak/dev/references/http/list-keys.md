---
title: HTTP List Keys
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Bucket Operations"
---

列出 bucket 中的所有键。

<div class="note">
<div class="title">不要在生产环境中操作</div>

这个操作要遍历集群中的所有键，不应该在生产环境中操作。

</div>

## 请求

```bash
GET /riak/bucket?keys=true            # List all keys, old format
GET /buckets/bucket/keys?keys=true    # List all keys, new format
GET /riak/bucket?keys=stream          # Stream keys to the client, old format
GET /buckets/bucket/keys?keys=stream  # Stream keys to the client, new format
```

必须提供的请求参数：

* `keys` - 默认为 `false`。如果设为 `true`，一次请求会返回所有键。如果设为 `stream`，会对返回的键分段

可选的请求参数：

* `props` - 默认为 `true`，响应中也会返回 [[bucket 的属性|HTTP-Get-Bucket-Properties]]。设为 `false` 禁止返回 bucket 的属性

## 响应

正常的响应码：

* `200 OK`

重要的报头：

* `Content-Type` - `application/json`
* `Transfer-Encoding` - 如果请求参数 `keys` 设为 `stream`，则为 `chunked`

响应中的 JSON 对象最多包含两个元素：`"props"` 和 `"keys"`，根据请求参数的设置不同，包含的元素也会不同。如果 `keys=stream`，会返回很多个包含 `"keys"` 元素的分段 JSON 对象。

## 示例

```bash
$ curl -i http://localhost:8098/riak/jsconf?keys=true\&props=false
HTTP/1.1 200 OK
Vary: Accept-Encoding
Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
Link: </riak/jsconf/challenge.jpg>; riaktag="contained",
</riak/jsconf/puddi.png>; riaktag="contained", </riak/jsconf/basho.gif>;
riaktag="contained", </riak/jsconf/puddikid.jpg>; riaktag="contained",
</riak/jsconf/yay.png>; riaktag="contained", </riak/jsconf/thinking.png>;
riaktag="contained", </riak/jsconf/victory.gif>; riaktag="contained",
</riak/jsconf/slides>; riaktag="contained", </riak/jsconf/joyent.png>;
riaktag="contained", </riak/jsconf/seancribbs-small.jpg>; riaktag="contained",
</riak/jsconf/trollface.jpg>; riaktag="contained",
</riak/jsconf/riak_logo_animated1.gif>; riaktag="contained",
</riak/jsconf/victory.jpg>; riaktag="contained", </riak/jsconf/challenge.png>;
riaktag="contained", </riak/jsconf/team_cribbs.png>; riaktag="contained"
Date: Fri, 30 Sep 2011 15:24:35 GMT
Content-Type: application/json
Content-Length: 239

{"keys":["challenge.jpg","puddi.png","basho.gif","puddikid.jpg","yay.png","
thinking.png","victory.gif","slides","joyent.png","seancribbs-small.jpg","
trollface.jpg","riak_logo_animated1.gif","victory.jpg","challenge.png","
team_cribbs.png"]}
```
