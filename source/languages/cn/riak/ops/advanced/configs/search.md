---
title: Riak Search Settings
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [search]
---

## 启用 Riak 搜索功能

{{#1.2.0}}
<div class="info">
<div class="title">Riak 搜索 1.2.0 版本中的严重问题</div>
在 [merge_index 中有个问题](https://github.com/basho/merge_index/pull/24)可以终止
数据移交。如果遇到这个问题，移交会无限制失败，集群就会卡住。这种情况可能是
由 merge_index 数据损坏造成的，但具体圆圆还要根据用户日志分析。这个问题在 1.2.1 中已修正。
</div>
{{/1.2.0}}

Riak 搜索功能可在 [[app.config|Configuration-Files#app.config]] 文件中开启。
只需把下面的设置改为 `true` 即可。

```erlang
%% Riak Search Config
{riak_search, [
               %% To enable Search functionality set this 'true'.
               {enabled, false}
              ]},
```

集群中所有节点都要做这个设置，而且必须重启节点才能生效。
（可以使用 [[Riaknostic|http://riaknostic.basho.com/]] 查看是不是全部节点都启用了搜索功能。）

设置好后，[[Riak 启动|Installing and Upgrading]]后就会自动启动 Riak 搜索。

## 默认端口

默认情况下，Riak 搜索使用下面的端口：

* `8098` - Solr 接口
* `8099` - Riak 移交
* `8087` - Protocol Buffers 接口

切记做好必要的安全措施，防止对外界暴露这些端口。

## Merge Index 设置

这些设置在 `app.config` 文件的 `merge_index` 区之中：

* `data_root` - 设置数据文件写入的地址，相对于 Riak 搜索的根目录
* `buffer_rollover_size` - 缓冲被传输到分段（segment）并写入硬盘之前，可用的内存最大值。较大的值可以加速索引，但更消耗内存。
* `buffer_delayed_write_size` - 预写日志写入硬盘之前可使用的字节数
* `buffer_delayed_write_ms` - 预写日志写入硬盘的时间间隔
* `max_compact_segments` - 压缩的最大分段数量。较小的值可以加速压缩过程，每个分区中分配的文件数可以更均匀，而且同一组数据可以被压缩多次
* `segment_query_read_ahead_size` - 获取查询结果时，文件预读缓冲的大小，单位为字节，
* `segment_compact_read_ahead_size` - 读取分段进行压缩时，文件预读缓冲的大小，单位为字节
* `segment_file_buffer_size` - 写入文件句柄之前，批量处理的分段大小，单位为字节。应该设的比 segment_delayed_write_size 小或一样，否则
segment_delayed_write_size 就没效果了
* `segment_delayed_write_size` - 延迟写缓冲的大小，单位为字节。一旦超过了这个值，压缩缓冲就会写入硬盘
* `segment_delayed_write_ms` - 压缩时数据写入文件的时间间隔
* `segment_full_read_size` - 为了提高性能（增加了 RAM 的用量），压缩时低于这个值的分段文件会读入内存。这个设置和 *max_compact_segments* 直接影响了压缩时可以使用的最大 RAM 值
* `segment_block_size` - 分段计算偏置和查询信息时使用的块大小。设定较小的值可以提升查询性能，不过却会增加 RAM 和硬盘使用量
* `segment_values_staging_size` - 在压缩并加入输出缓冲之前，内存中可以保存对象的最大值
* `segment_values_compression_threshold` - 拥有较多数量的值时使用压缩才更有效，这个值就是设定在压缩前必须有多少个值
* `segment_values_compression_level` - 压缩时使用的 压缩等级
