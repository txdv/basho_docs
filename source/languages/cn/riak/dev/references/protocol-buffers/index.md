---
title: PBC API
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, protocol-buffer]
index: true
---

本文简略介绍了可以使用 Riak 的  Protocol Buffers 客户端（PBC）进行的操作，也可以作为开发客户端的参考。

## 协议

Riak 会在 TCP 端口（默认为 8087）上监听进入的连接。一旦建立连接，客户端就可以通过这个连接发送请求。

每个操作包含一个请求消息和一个或多个响应消息。所有的消息都使用相同的方式编码：

* 网络排序的 32 位长度的消息码 + Protocol Buffer 消息
* 标识 Protocol Buffer 消息的 8 位消息码
* N 字节长编码后的 Protocol Buffer 消息

### 示例

```bash
00 00 00 07 09 0A 01 62 12 01 6B
|----Len---|MC|----Message-----|

Len = 0x07
Message Code (MC) = 0x09 = RpbGetReq
RpbGetReq Message = 0x0A 0x01 0x62 0x12 0x01 0x6B

Decoded Message:
bucket: "b"
key: "k"
```

### 消息码

<table>
<tr><td>0</td><td>RpbErrorResp</td></tr>
<tr><td>1</td><td>RpbPingReq</td></tr>
<tr><td>2</td><td>RpbPingResp</td></tr>
<tr><td>3</td><td>RpbGetClientIdReq</td></tr>
<tr><td>4</td><td>RpbGetClientIdResp</td></tr>
<tr><td>5</td><td>RpbSetClientIdReq</td></tr>
<tr><td>6</td><td>RpbSetClientIdResp</td></tr>
<tr><td>7</td><td>RpbGetServerInfoReq</td></tr>
<tr><td>8</td><td>RpbGetServerInfoResp</td></tr>
<tr><td>9</td><td>RpbGetReq</td></tr>
<tr><td>10</td><td>RpbGetResp</td></tr>
<tr><td>11</td><td>RpbPutReq</td></tr>
<tr><td>12</td><td>RpbPutResp</td></tr>
<tr><td>13</td><td>RpbDelReq</td></tr>
<tr><td>14</td><td>RpbDelResp</td></tr>
<tr><td>15</td><td>RpbListBucketsReq</td></tr>
<tr><td>16</td><td>RpbListBucketsResp</td></tr>
<tr><td>17</td><td>RpbListKeysReq</td></tr>
<tr><td>18</td><td>RpbListKeysResp</td></tr>
<tr><td>19</td><td>RpbGetBucketReq</td></tr>
<tr><td>20</td><td>RpbGetBucketResp</td></tr>
<tr><td>21</td><td>RpbSetBucketReq</td></tr>
<tr><td>22</td><td>RpbSetBucketResp</td></tr>
<tr><td>23</td><td>RpbMapRedReq</td></tr>
<tr><td>24</td><td>RpbMapRedResp</td></tr>
<tr><td>25</td><td>RpbIndexReq <i>（1.2+ 中新添加）</i></td></tr>
<tr><td>26</td><td>RpbIndexResp <i>（1.2+ 中新添加）</i></td></tr>
<tr><td>27</td><td>RpbSearchQueryReq <i>（1.2+ 中新添加）</i></td></tr>
<tr><td>28</td><td>RbpSearchQueryResp <i>（1.2+ 中新添加）</i></td></tr>
</table>


<div class="info">
<div class="title">消息定义</div>
<p>所有的 Protocol Buffer 消息都可以在 [[riak.proto|https://github.com/basho/riak_pb/blob/master/src/riak.proto]] 和其他 RiakPB 项目的 .proto 文件中找到。</p>
</div>

### 错误响应

如果服务器处理请求的过程中发生了错误，不会返回请求期望得到的响应（例如，RbpGetReq 期望得到的响应是 RbpGetResp），而会返回 RpbErrorResp 消息。错误消息中包含错误消息和错误码。

```bash
message RpbErrorResp {
    required bytes errmsg = 1;
    required uint32 errcode = 2;
}
```

响应值：

* **errmsg** - 描述错误的文本
* **errcode** - 数字代码。目前只定义了 RIAKC_ERR_GENERAL=1

## Bucket 相关操作

* [[通过 PBC 列出 bucket]]
* [[通过 PBC 列出键]]
* [[通过 PBC 获取 bucket 的属性]]
* [[通过 PBC 设置 bucket 的属性]]

## 对象/键相关操作

* [[通过 PBC 获取对象]]
* [[通过 PBC 存储对象]]
* [[通过 PBC 删除对象]]

## 查询

* [[通过 PBC 执行 MapReduce 查询]]
* [[通过 PBC 执行二级索引查询]]
* [[通过 PCB 执行 Riak Search 查询]]

## 服务器相关操作

* [[PBC Ping]]
* [[通过 PBC 获取客户端 ID]]
* [[通过 PBC 设置客户端 ID]]
* [[通过 PBC 获取服务器信息]]
