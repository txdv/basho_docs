---
title: HTTP Status
project: riak
version: 1.4.2+
document: api
toc: true
audience: advanced
keywords: [api, http]
group_by: "Server Operations"
---

报告所请求节点的性能和设置。要想激活这个请求 URL，必须在 app.config 文件中设置 `{riak_kv_stat,true}`。这个请求的效果和使用 [[riak-admin status|Command-Line Tools#status]] 命令得到的结果一样。

## 请求

```bash
GET /stats
```

重要的报头：

* `Accept` - 响应主体应该使用 `application/json` 还是 `text/plain` 格式

## 响应

正常的状态码：

* `200 OK`

常见的错误码：

* `404 Not Found` - `riak_kv_stat` 未启用

重要的报头：

* `Content-Type` - `application/json` 或 `text/plain`（加入换行的 JSON 格式）

## 示例

```bash
$ curl -v http://127.0.0.1:8098/stats -H "Accept: text/plain"
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /stats HTTP/1.1
> User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
> Host: 127.0.0.1:8098
> Accept: text/plain
>
< HTTP/1.1 200 OK
< Vary: Accept, Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (participate in the frantic)
< Date: Fri, 30 Sep 2011 15:24:35 GMT
< Content-Type: text/plain
< Content-Length: 2102
<
{
    "vnode_gets": 0,
    "vnode_puts": 0,
    "read_repairs": 0,
    "vnode_gets_total": 0,
    "vnode_puts_total": 0,
    "node_gets": 0,
    "node_gets_total": 0,
    "node_get_fsm_time_mean": "undefined",
    "node_get_fsm_time_median": "undefined",
    "node_get_fsm_time_95": "undefined",
    "node_get_fsm_time_99": "undefined",
    "node_get_fsm_time_100": "undefined",
    "node_puts": 0,
    "node_puts_total": 0,
    "node_put_fsm_time_mean": "undefined",
    "node_put_fsm_time_median": "undefined",
    "node_put_fsm_time_95": "undefined",
    "node_put_fsm_time_99": "undefined",
    "node_put_fsm_time_100": "undefined",
    "read_repairs_total": 0,
    "cpu_nprocs": 84,
    "cpu_avg1": 251,
    "cpu_avg5": 174,
    "cpu_avg15": 110,
    "mem_total": 7946684000.0,
    "mem_allocated": 4340880000.0,
    "nodename": "riak@127.0.0.1",
    "connected_nodes": [

    ],
    "sys_driver_version": "1.5",
    "sys_global_heaps_size": 0,
    "sys_heap_type": "private",
    "sys_logical_processors": 2,
    "sys_otp_release": "R13B04",
    "sys_process_count": 189,
    "sys_smp_support": true,
    "sys_system_version": "Erlang R13B04 (erts-5.7.5) [[source]] [[64-bit]] [[smp:2:2]] [[rq:2]] [[async-threads:5]] [[hipe]] [[kernel-poll:true]]",
    "sys_system_architecture": "i386-apple-darwin10.3.0",
    "sys_threads_enabled": true,
    "sys_thread_pool_size": 5,
    "sys_wordsize": 8,
    "ring_members": [
        "riak@127.0.0.1"
    ],
    "ring_num_partitions": 64,
    "ring_ownership": "[{'riak@127.0.0.1',64}]",
    "ring_creation_size": 64,
    "storage_backend": "riak_kv_bitcask_backend",
    "pbc_connects_total": 0,
    "pbc_connects": 0,
    "pbc_active": 0,
    "riak_kv_version": "0.11.0",
    "riak_core_version": "0.11.0",
    "bitcask_version": "1.0.1",
    "luke_version": "0.1",
    "webmachine_version": "1.7.1",
    "mochiweb_version": "1.7.1",
    "erlang_js_version": "0.4",
    "runtime_tools_version": "1.8.3",
    "crypto_version": "1.6.4",
    "os_mon_version": "2.2.5",
    "sasl_version": "2.1.9",
    "stdlib_version": "1.16.5",
    "kernel_version": "2.13.5"
}
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```

## 返回结果说明

对 `/stats` 的请求会返回很多设置和性能细节。详细说明如下。

## CPU 和内存

CPU 统计信息直接取自 Erlang 的 cpu\_sup 模块，其文档是 [[ErlDocs: cpu_sup|http://erldocs.com/R14B04/os_mon/cpu_sup.html]]。

* `cpu_nprocs`：操作系统的进程数量
* `cpu_avg1`：前一分钟活跃的进程平均数（等于 top(1) 命令的结果除以 256）
* `cpu_avg5`：前五分钟活跃的进程平均数（等于 top(1) 命令的结果除以 256）
* `cpu_avg15`：前十五分钟活跃的进程平均数（等于 top(1) 命令的结果除以 256）

内存的统计信息直接取自 Erlang 虚拟机，其文档是 [[ErlDocs: Memory|http://erldocs.com/R14B04/erts/erlang.html?i=0&search=erlang:memory#memory/0]]。

* `memory_total`：分配的内存总量（进程使用量和系统使用量之和）
* `memory_processes`：为 Erlang 进程分配的内存量
* `memory_processes_used`：Erlang 进程使用的内存量
* `memory_system`：不直接和 Erlang 进程有关的内存分配量
* `memory_atom`：当前为原子存储分配的内存量
* `memory_atom_used`：当前原子存储使用的内存量
* `memory_binary`：二进制文件使用的内存量
* `memory_code`：为 Erlang 代码分配的内存量
* `memory_ets`：为 Erlang 关键字（Erlang Term Storage）存储分配的内存量
* `mem_total`：系统可用的内存总量
* `mem_allocated`：为当前代码分配的内存量

## 节点，集群和系统

* `nodename`：生成这个状态信息的节点名
* `connected_nodes`：列出连接到这个节点上的节点
* `read_repairs`：上一分钟该节点协调处理的读取修复数量
* `read_repairs_total`：该节点启动以来负责协调处理的读取修复数量
* `coord_redirs_total`：该节点启动以来协调时转发的请求次数
* `ring_members`：列出属于该环成员的节点
* `ring_num_partitions`：环上分区的数量
* `ring_ownership`：列出环中的所有节点，以及相应地分区管理关系
* `ring_creation_size`：该节点负责的分区数量
* `ignored_gossip_total`：该节点启动以来忽略的广播消息数量
* `handoff_timeouts`：该节点遇到的移交超时次数
* `precommit_fail`：pre-commit 钩子失败的次数
* `postcommit_fail`：post-commit 钩子失败的次数
* `sys_driver_version`：运行时系统所用的 Erlang 驱动版本号，以字符串形式表示
* `sys_global_heaps_size`：当前共享的全局堆大小
* `sys_heap_type`：在用的堆大小（包括私有堆，共享堆和混合堆），以字符串形式表示
* `sys_logical_processors`：系统中可用的逻辑处理器数量
* `sys_otp_release`：该节点上使用的 Erlang OTP 发布版本号
* `sys_process_count`：该节点上运行的进程数量
* `sys_smp_support`：布尔值，表示“对称多处理”（symmetric multi-processing, SMP）技术是否可用
* `sys_system_version`：详细的 Erlang 版本信息
* `sys_system_architecture`：节点的操作系统和硬件架构
* `sys_threads_enabled`：布尔值，表示是否启用了线程
* `sys_thread_pool_size`：异步线程池中的线程数
* `sys_wordsize`：Erlang 关键词的数量，以字节为单位，例如，在 32 位系统中结果是 4，在 64 为系统中结果是 8
* `storage_backend`：使用的存储后台名称
* `pbc_connects_total`：自节点启动以来的 Protocol Buffers 连接数
* `pbc_connects`：前一分钟内的 Protocol Buffers 连接数
* `pbc_active`：活跃的 Protocol Buffers 连接数
* `ssl_version`：使用的 SSL 版本
* `public_key_version`：使用的公匙版本
* `runtime_tools_version`：使用的运行时工具版本
* `basho_stats_version`：使用的 Basho 状态程序版本
* `riak_search_version`：使用的 Riak Search 版本
* `riak_kv_version`：使用的 Riak KV 版本
* `bitcask_version`：使用的 Bitcask 后台版本
* `luke_version`：使用的 Luke 版本
* `erlang_js_version`：使用的 Erlang JS 版本
* `mochiweb_version`：使用的 MochiWeb 版本
* `inets_version`：使用的 Inets 程序版本
* `riak_pipe_version`：使用的 Riak Pipe 版本
* `merge_index_version`：使用的 Merge Index 版本
* `cluster_info_version`：使用的 Cluster Information 版本
* `basho_metrics_version`：使用的 Basho Metrics 版本
* `riak_control_version`：使用的 Riak Control 版本
* `riak_core_version`：使用的 Riak Core 版本
* `lager_version`：使用的 Lager 版本
* `riak_sysmon_version`：使用的 Riak System Monitor 版本
* `webmachine_version`：使用的 Webmachine 版本
* `crypto_version`：使用的 Cryptography 版本
* `os_mon_version`：使用的 Operating System Monitor 版本
* `sasl_version`：使用的 SASL 程序版本
* `stdlib_version`：使用的标准库版本
* `kernel_version`: 使用的 kernel 版本

### 节点和虚拟节点计数器

* `vnode_gets`：前一分钟运行在该节点上的虚拟节点负责协调处理的 GET 请求数量
* `vnode_puts`：前一分钟运行在该节点上的虚拟节点负责协调处理的 PUT 请求数量
* `vnode_gets_total`：自节点启动以来，运行在该节点上的虚拟节点负责协调处理的 GET 请求数量
* `vnode_puts_total`：自节点启动以来，运行在该节点上的虚拟节点负责协调处理的 PUT 请求数量
* `node_gets`：前一分钟运行在该节点上的虚拟节点负责协调的本地和非本地 GET 请求数量
* `node_puts`：前一分钟运行在该节点上的虚拟节点负责协调的本地和非本地 PUT 请求数量
* `node_gets_total`：自节点启动以来，运行在该节点上的虚拟节点负责协调的本地和非本地 GET 请求数量
* `node_puts_total`: 自节点启动以来，运行在该节点上的虚拟节点负责协调的本地和非本地 PUT 请求数量

### 微秒级计时器

* `node_get_fsm_time_mean`：节点收到 GET 请求和做出相应相距时间的平均值
* `node_get_fsm_time_median`：节点收到 GET 请求和做出相应相距时间的中值
* `node_get_fsm_time_95`：节点收到 GET 请求和做出相应相距时间的 95 百分位值
* `node_get_fsm_time_99`：节点收到 GET 请求和做出相应相距时间的 99 百分位值
* `node_get_fsm_time_100`：节点收到 GET 请求和做出相应相距时间的 100 百分位值
* `node_put_fsm_time_mean`：节点收到 PUT 请求和做出相应相距时间的平均值
* `node_put_fsm_time_median`：节点收到 PUT 请求和做出相应相距时间的中值
* `node_put_fsm_time_95`：节点收到 PUT 请求和做出相应相距时间的 95 百分位值
* `node_put_fsm_time_99`：节点收到 PUT 请求和做出相应相距时间的 99 百分位值
* `node_put_fsm_time_100`：节点收到 PUT 请求和做出相应相距时间的 100 百分位值

### 对象，索引和兄弟数据指标

* `node_get_fsm_objsize_mean`：该节点前一分钟处理的对象大小平均值
* `node_get_fsm_objsize_median`：该节点前一分钟处理的对象大小中值
* `node_get_fsm_objsize_95`：该节点前一分钟处理的对象大小的 95 百分位值
* `node_get_fsm_objsize_99`：该节点前一分钟处理的对象大小的 99 百分位值
* `node_get_fsm_objsize_100`：该节点前一分钟处理的对象大小的 100 百分位值
* `vnode_index_reads`：前一分钟虚拟节点读取索引操作的次数
* `vnode_index_writes`：前一分钟虚拟节点写入索引操作的次数
* `vnode_index_deletes`：前一分钟虚拟节点删除索引操作的次数
* `vnode_index_reads_total`：自节点启动以来，虚拟节点读取索引操作的次数
* `vnode_index_writes_total`：自节点启动以来，虚拟节点写入索引操作的次数
* `vnode_index_deletes_total`：自节点启动以来，虚拟节点删除索引操作的次数
* `node_get_fsm_siblings_mean`：该节点前一分钟在所有 GET 请求中出现兄弟数据的次数平均值
* `node_get_fsm_siblings_median`：该节点前一分钟在所有 GET 请求中出现兄弟数据的次数中值
* `node_get_fsm_siblings_95`：该节点前一分钟在所有 GET 请求中出现兄弟数据的次数 95 百分位值
* `node_get_fsm_siblings_99`：该节点前一分钟在所有 GET 请求中出现兄弟数据的次数 99 百分位值
* `node_get_fsm_siblings_100`：该节点前一分钟在所有 GET 请求中出现兄弟数据的次数 100 百分位值

{{#1.2.0+}}

### Pipeline 指标

下面出自 riak_pipe 的指标在执行 MapReduce 查询时产生。

* `pipeline_active`：前一分钟活跃的 Pipeline 数量
* `pipeline_create_count`：自节点启动以来创建的 Pipeline 总数
* `pipeline_create_error_count`：自节点启动以来，创建 Pipeline 时发生的错误次数
* `pipeline_create_one`：前一分钟创建的 Pipeline 数量
* `pipeline_create_error_one`：前一分钟创建 Pipeline 时发生错误的次数

{{/1.2.0+}}
