---
title: Memory
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: intermediate
keywords: [backends, planning, memory]
prev: "[[LevelDB]]"
up:   "[[选择后台]]"
next: "[[Multi]]"
interest: false
---

## 概览

“内存”存储后台使用保存在内存中的表存储所有数据。这些数据永远不会存储硬盘会其他存储设备。“内存”存储后台特别适测试 Riak 集群，或者在生产环境中存储少量的事务状态。

<div class="note">
<div class="title">“内存”后台替代了“缓存”后台</div>
<p>“内存”后台的目的是替代 Riak 1.0 之前版本中的“缓存”后台，这个后台已经废弃不要了。“内存”后台的设置和“缓存”后台一样，可以设置成类似“缓存”后台的表现。</p>
</div>

## 安装

Riak 中包含了“内存”后台，所以无需额外安装。

## 启用 设置

要启用“内存”后台，请编辑各 Riak 节点的 [[app.config|设置文件#app-config]] 文件，在 `riak_kv` 区中指定使用“内存”后台，如下所示：

```erlang
{riak_kv, [
           %% Storage_backend specifies the Erlang module defining the storage
           %% mechanism that will be used on this node.
           % {storage_backend, riak_kv_bitcask_backend},
           {storage_backend, riak_kv_memory_backend},

```

注意，如果直接把原有设置去掉，或者像上面这样把原来的设置注释掉，使用原先的后台存储的数据还在文件系统中，但无法再使用 Riak 访问了，除非切换到原来的后台。

如果需要使用多个后台，请参照 [[Multi 后台的文档|Multi]]。

如果要修改“内存”后台的默认设置，可以在各节点的 [[app.config|设置文件#app-config]] 文件中的 `riak_kv` 区中添加 `memory_backend` 子区，加入下面的设置。

### 最大内存

每个虚拟节点可以使用的最大内存，单位为 MB。各物理节点上的每个虚拟内存都要使用一个“内存”后台实例。请使用 [[LevelDB cache_size|LevelDB#Cache-Size]] 中推荐的设置来决定这个值。

```erlang
{riak_kv, [
          %% Storage_backend specifies the Erlang module defining the storage
          %% mechanism that will be used on this node.
          % {storage_backend, riak_kv_bitcask_backend},
          {storage_backend, riak_kv_memory_backend},
          {memory_backend, [
              ...,
                  {max_memory, 4096}, %% 4GB in megabytes
              ...
          ]}
```

### TTL

对象的保鲜时间，单位为秒。

```erlang
{memory_backend, [
        ...,
            {ttl, 86400}, %% 1 Day in seconds
        ...
]}
```

<div class="note">
<div class="title">动态修改 ttl</div>
<p>目前没有办法动态修改每个 bucket 的 ttl。目前可用的方法是在 "riak_kv_multi_backend" 中定义多个 "riak_kv_memory_backends"，分别设定不同的值。详情请阅读 [[Multi 后台|Multi]]的文档。</p>
</div>

## 实现细节

“内存”后台内部使用 Erlang 的 `ets` 表管理数据。
