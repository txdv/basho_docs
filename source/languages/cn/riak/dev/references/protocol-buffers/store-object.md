---
title: PBC Store Object
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
group_by: "Object/Key Operations"
---

在指定的“bucket/键”上存储对象。存储对象有两种方式：使用指定的键，或者由 Riak 分配键。

#### 请求

```bash
message RpbPutReq {
    required bytes bucket = 1;
    optional bytes key = 2;
    optional bytes vclock = 3;
    required RpbContent content = 4;
    optional uint32 w = 5;
    optional uint32 dw = 6;
    optional bool return_body = 7;
    optional uint32 pw = 8;
    optional bool if_not_modified = 9;
    optional bool if_none_match = 10;
    optional bool return_head = 11;%
}
```

必须指定的参数：

* **bucket** - 要存储到哪个 bucket
* **content** - 对象的新值或者修改后的值，使用相同的 RpbContent 消息，RpbGetResp 返回的数据包含元数据

可选的参数：

* **key** - 要创建或更新的键。如果未指定，服务器会生成一个
* **vclock** - 前面的 RpbGetResp 消息提供的向量时钟。如果这是一个新键，或者故意想创建兄弟数据，就不提供这个参数
* **w** - （写入法定值）返回成功响应之前应该接受到多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **dw** - 返回成功响应之前要向持久性存储中写入多少个副本。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **return_body** - 是否返回存储对象的内容。默认为 `false`，不返回
* **pw** - 写入时要有多少个主节点在线。可选值有 `'one'`（4294967295-1），`'quorum'`（4294967295-2），`'all'`（4294967295-3），`'default'`（4294967295-4）和任何小于等于 N 的整数（[[默认值在 bucket 层面设定|PBC API#Set Bucket Properties]]）
* **if_not_modified** - 只有当提供的对象向量时钟和数据库中的向量时钟匹配时才更新值
* **if_none_match** - 只有当“bucket/键”组合不存在时才存储对象
* **return_head** - 和 *return_body" 类似，不过对象的值为空，避免返回大量的值

#### 响应

```bash
message RpbPutResp {
    repeated RpbContent contents = 1;
    optional bytes vclock = 2;        // the opaque vector clock for the object
    optional bytes key = 3;           // the key generated, if any
}
```

如果 PUT 请求的 `return_body` 参数设为 `true`，请求完成后返回的 RpbPutResp 会包含刚保存的对象。只有当服务器为对象生成键时，才会返回 `key`。是否返回 `key` 和 `return_body` 无关。如果没有设定 `return_body` 而且没有生成键，PUT 请求的响应为空。


<div class="note"><p>注意，响应中可能包含兄弟数据，和 RpbGetResp 类似。</p></div>

#### 示例

请求：

```bash
Hex      00 00 00 1C 0B 0A 01 62 12 01 6B 22 0F 0A 0D 7B
         22 66 6F 6F 22 3A 22 62 61 72 22 7D 28 02 38 01
Erlang <<0,0,0,28,11,10,1,98,18,1,107,34,15,10,13,123,34,102,111,111,34,58,34,
         98,97,114,34,125,40,2,56,1>>

RpbPutReq protoc decode:
bucket: "b"
key: "k"
content {
  value: "{"foo":"bar"}"
}
w: 2
return_body: true
```

响应：

```bash
Hex      00 00 00 62 0C 0A 31 0A 0D 7B 22 66 6F 6F 22 3A
         22 62 61 72 22 7D 2A 16 31 63 61 79 6B 4F 44 39
         36 69 4E 41 68 6F 6D 79 65 56 6A 4F 59 43 38 AF
         B0 A3 DE 04 40 90 E7 18 12 2C 6B CE 61 60 60 60
         CA 60 CA 05 52 2C 2C E9 0C 86 19 4C 89 8C 79 AC
         0C 5A 21 B6 47 F9 20 C2 6C CD 49 AC 0D 77 7C A0
         12 FA 20 89 2C 00
Erlang <<0,0,0,98,12,10,49,10,13,123,34,102,111,111,34,58,34,98,97,114,34,125,
         42,22,49,99,97,121,107,79,68,57,54,105,78,65,104,111,109,121,101,86,
         106,79,89,67,56,175,176,163,222,4,64,144,231,24,18,44,107,206,97,96,
         96,96,202,96,202,5,82,44,44,233,12,134,25,76,137,140,121,172,12,90,33,
         182,71,249,32,194,108,205,73,172,13,119,124,160,18,250,32,137,44,0>>

RpbPutResp protoc decode:
contents {
  value: "{"foo":"bar"}"
  vtag: "1caykOD96iNAhomyeVjOYC"
  last_mod: 1271453743
  last_mod_usecs: 406416
}
vclock: "k316a```312`312005R,,351014206031L211214y254014Z!266G371
302l315I254rw|240022372 211,000"
```
