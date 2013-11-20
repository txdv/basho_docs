---
title: HTTP List Resources
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Server Operations"
---

列出 Riak 节点中可用的 HTTP 资源。客户端可以使用这个请求自动识别特定操作对应的资源地址。

标准的资源有：

* `riak_kv_wm_buckets` - [[Bucket 相关操作|HTTP API#Bucket-Operations]]
* `riak_kv_wm_index` - [[通过 HTTP 执行二级索引查询|HTTP Secondary Indexes]]
* `riak_kv_wm_link_walker` - [[通过 HTTP 进行链接遍历|HTTP Link Walking]]
* `riak_kv_wm_mapred` - [[通过 HTTP 执行 MapReduce 查询|HTTP MapReduce]]
* `riak_kv_wm_object`- [[对象/键相关操作|HTTP API#Object-Key-Operations]]
* `riak_kv_wm_ping` - [[HTTP Ping]]
* `riak_kv_wm_props` - [[通过 HTTP 设置 bucket 的属性|HTTP Set Bucket Properties]]
* `riak_kv_wm_stats` - [[HTTP 状态|HTTP Status]]

如果启用了 Riak Search，还会包含下面的资源：

* `riak_solr_searcher_wm` - [[通过 Solr 接口搜索|Using Search#Querying]]
* `riak_solr_indexer_wm` - [[通过 Solr 接口索引|Advanced Search#Indexing-using-the-Solr-Interface]]

{{#1.0.0-}}

如果启用了 Luwak，还会包含下面的资源：

* `luwak_wm_file` - [[Luwak 操作|HTTP API#Luwak Operations (Large Objects)]]

{{/1.0.0-}}

## 请求

```bash
GET /
```

报头：

* `Accept` - `application/json` 或 `text/html`

## 响应

正常的响应码：

* `200 OK`

重要的报头：

* `Link` - 所有资源都在响应主体中描述，但使用的是链接形式

## 示例

```bash
# Request JSON response
curl -i http://localhost:8098 -H "Accept: application/json"
HTTP/1.1 200 OK
Vary: Accept
Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
Link: </riak>; rel="riak_kv_wm_link_walker",</mapred>; rel="riak_kv_wm_mapred",</ping>; rel="riak_kv_wm_ping",</riak>; rel="riak_kv_wm_raw",</stats>; rel="riak_kv_wm_stats"
Date: Fri, 30 Sep 2011 15:24:35 GMT
Content-Type: application/json
Content-Length: 143

{"riak_kv_wm_link_walker":"/riak","riak_kv_wm_mapred":"/mapred","riak_kv_wm_ping":"/ping","riak_kv_wm_raw":"/riak","riak_kv_wm_stats":"/stats"}

# Request HTML response
curl -i http://localhost:8098 -H "Accept: text/html"
HTTP/1.1 200 OK
Vary: Accept
Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
Link: </riak>; rel="riak_kv_wm_link_walker",</mapred>; rel="riak_kv_wm_mapred",</ping>; rel="riak_kv_wm_ping",</riak>; rel="riak_kv_wm_raw",</stats>; rel="riak_kv_wm_stats"
Date: Fri, 30 Sep 2011 15:24:35 GMT
Content-Type: text/html
Content-Length: 267

<html><body><ul><li><a href="/riak">riak_kv_wm_link_walker</a></li><li><a href="/mapred">riak_kv_wm_mapred</a></li><li><a href="/ping">riak_kv_wm_ping</a></li><li><a href="/riak">riak_kv_wm_raw</a></li><li><a href="/stats">riak_kv_wm_stats</a></li></ul></body></html>
```
