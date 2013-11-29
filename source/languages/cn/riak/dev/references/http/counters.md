---
title: HTTP 计数器
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Datatypes"
---

Riak 计数器是 CRDT 数据类型，最终会得到一个准确的值。基本无需人工干预，所有潜在的冲突 Riak 都会自动解决。

## 设置

只有 bucket 的 `allow_mult` 属性设为 `true` 时才能使用 Riak 计数器。

```
curl -XPUT localhost:8098/buckets/BUCKET/props \
  -H "Content-Type: application/json" \
  -d "{\"props\" : {\"allow_mult\": true}}"
```

如果没有做上述设置而尝试使用计数器，会得到如下消息：

```
Counters require bucket property 'allow_mult=true'
```

## 请求

要插入值请向 `/counters` 资源发送 POST 请求，把指定键对应的值修改为发送的数值。

```
POST /buckets/BUCKET/counters/KEY
```

获取当前的值，请向 `/counters` 发送 GET 请求

```
GET /buckets/BUCKET/counters/KEY
```

## 响应

常规的 POST/PUT（[[通过 HTTP 存储对象]]）和 GET（[[通过 HTTP 获取对象]]）请求的响应在这同样适用。

注意：计数器不支持二级索引，链接和自定义 HTTP 元数据。

## 示例

响应主体必须是一个整数（正数或负数）。

```
curl -XPOST http://localhost:8098/buckets/my_bucket/counters/my_key -d "1"

curl http://localhost:8098/buckets/my_bucket/counters/my_key
1

curl -XPOST http://localhost:8098/buckets/my_bucket/counters/my_key -d "100"

curl http://localhost:8098/buckets/my_bucket/counters/my_key
101

curl -XPOST http://localhost:8098/buckets/my_bucket/counters/my_key -d "-1"
100
```
