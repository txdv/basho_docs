---
title: 通过 PBC 获取对象
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Object/Key Operations"
---

从 Riak 中获取对象。

## 请求

```bash
message RpbGetReq {
    required bytes bucket = 1;
    required bytes key = 2;
    optional uint32 r = 3;
    optional uint32 pr = 4;
    optional bool basic_quorum = 5;
    optional bool notfound_ok = 6;
    optional bytes if_modified = 7;
    optional bool head = 8;
    optional bool deletedvclock = 9;
}
```

可选的参数：

* **r** -（读取法定值） 获取对象时要得到多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|通过 PBC 设置 bucket 的属性]]）
* **pr** -（主读取法定值）获取对象时要得到多少个主节点副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|通过 PBC 设置 bucket 的属性]]）
* **basic_quorum** - 出现错误时是否要提前返回结果（例如，r=1，出现 2 个错误，如果 `basic_quorum=true`，就会返回错误）（[[默认值在 bucket 层面设定|通过 PBC 设置 bucket 的属性]]）
* **notfound_ok** - 是否把未找到认为是成功的读取（[[默认值在 bucket 层面设定|通过 PBC 设置 bucket 的属性]]）
* **if_modified** - 如果提供了向量时钟，设定这个参数后只有当向量时钟不匹配时才会返回结果
* **head** - 返回结果中不包含对象的值，不用获取大量的值就能读取元数据
* **deletedvclock** - 删除死数据的向量时钟

## 响应

```bash
message RpbGetResp {
    repeated RpbContent content = 1;
    optional bytes vclock = 2;
    optional bool unchanged = 3;
}
```

响应值：

* **content** - 对象的值和元数据。如果有兄弟数据的话就要多个条目。如果没有找到键，内容为空。
* **vclock** - 向量时钟必须包含在 *RpbPutReq* 中来处理兄弟数据
* **unchanged** - 如果 GET 请求中设定了 `if_modified`，而且对象没有改动，那么返回结果中的 `unchanged` 就会设为 `true`

`content` 中包含对象的值和所有的元数据。

```bash
// Content message included in get/put responses
message RpbContent {
    required bytes value = 1;
    optional bytes content_type = 2;     // the media type/format
    optional bytes charset = 3;
    optional bytes content_encoding = 4;
    optional bytes vtag = 5;
    repeated RpbLink links = 6;          // links to other resources
    optional uint32 last_mod = 7;
    optional uint32 last_mod_usecs = 8;
    repeated RpbPair usermeta = 9;       // user metadata stored with the object
    repeated RpbPair indexes = 10;
    optional bool deleted = 11;
}
```

每个对象中都可以包含用户定义的元数据（在 HTTP 接口中以 `X-Riak-Meta-\*` 的形式表示），以“键值对”的形式存在。（例如，`key=X-Riak-Meta-ACL
value=users:r,administrators:f` 可以让应用程序存储访问控制信息）

```bash
// Key/value pair - used for user metadata
message RpbPair {
    required bytes key = 1;
    optional bytes value = 2;
}
```

链接存储指向其他“bucket/键”组合的引用，可以在 MapReduce 中通过链接遍历访问。

```bash
// Link metadata
message RpbLink {
    optional bytes bucket = 1;
    optional bytes key = 2;
    optional bytes tag = 3;
}
```

<div class="note">
<div class="title">键不存在</div>
<p>注意，如果 Riak 中不存在查询的键，会返回不包含内容和向量时钟的 RpbGetResp 响应。客户端可以把这个响应转换成所用变成语言中对应未找到的表示方法，例如 Erlang 客户端可以返回 <code>{error, notfound}</code>。</p>
</div>

## 示例

请求：

```bash
Hex      00 00 00 07 09 0A 01 62 12 01 6B
Erlang <<0,0,0,7,9,10,1,98,18,1,107>>

RpbGetReq protoc decode:
bucket: "b"
key: "k"
```

响应：

```bash
Hex      00 00 00 4A 0A 0A 26 0A 02 76 32 2A 16 33 53 44
         6C 66 34 49 4E 4B 7A 38 68 4E 64 68 79 49 6D 4B
         49 72 75 38 BB D7 A2 DE 04 40 E0 B9 06 12 1F 6B
         CE 61 60 60 60 CC 60 CA 05 52 2C AC C2 5B 3F 65
         30 25 32 E5 B1 32 EC 56 B7 3D CA 97 05 00
Erlang <<0,0,0,74,10,10,38,10,2,118,50,42,22,51,83,68,108,102,52,73,78,75,122,
         56,104,78,100,104,121,73,109,75,73,114,117,56,187,215,162,222,4,64,
         224,185,6,18,31,107,206,97,96,96,96,204,96,202,5,82,44,172,194,91,63,
         101,48,37,50,229,177,50,236,86,183,61,202,151,5,0>>

RpbGetResp protoc decode:
content {
  value: "v2"
  vtag: "3SDlf4INKz8hNdhyImKIru"
  last_mod: 1271442363
  last_mod_usecs: 105696
}
vclock: "k316a```314`312005R,254302[?e0%23452612354V267=312227005000"
```
