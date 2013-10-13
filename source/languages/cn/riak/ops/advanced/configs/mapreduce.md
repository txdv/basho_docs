---
title: Riak MapReduce Settings
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: advanced
keywords: [mapreduce]
---

## 配置 MapReduce

[[MapReduce|Using MapReduce]] \(M/R) 是一直启用的，
可以在 [[app.config|Configuration-Files#app-config]] 文件的 `riak_kv` 区中设置：

```erlang
{riak_kv, [
```

`mapred_name` 是向 Riak 提交 M/R 请求时使用的 URL 目录。
其默认值是 `mapred`，地址为 `http://localhost:8091/mapred`

```erlang
    {mapred_name, "mapred"},
```

{{#<1.3.0}}
`mapred_system` 设定要使用的 MapReduce 版本：

* 设为 `pipe` 时使用 [riak_pipe](https://github.com/basho/riak_pipe)
* 设为 `legacy` 时使用 [luke](https://github.com/basho/luke)

```erlang
    {mapred_system, pipe},
```
{{/<1.3.0}}

`mapred_2i_pipe` 设定 [[2i|Using Secondary Indexes]] MapReduce 输入队列
在 pipe 中并排（`true`），还是通过帮助进程连续处理（`flase` 或未定义）。

{{#1.1.0+}}
_**注意：** 从 Riak 1.0 滚动升级时要设为 `false` 或不定义。_
{{/1.1.0+}}

```erlang
    {mapred_2i_pipe, true},
```

{{#<1.3.0}}
`mapred_queue_dir` 设置一个文件夹，用来存储待执行的 map 任务的事务队列。

_只有当设置为 `{mapred_system, legacy}`，
使用 [luke](https://github.com/basho/luke) 时才可用。_

```erlang
    %% {mapred_queue_dir, "./data/mr_queue" },
```
{{/<1.3.0}}

下面这几行分别控制执行 map、reduce、pre 和 post commit 钩子函数时
要使用多少个 JavaScript 虚拟机。

这些设置只有编写 JavaScript M/R 任务时才有用。

```erlang
    {map_js_vm_count, 8 },
    {reduce_js_vm_count, 6 },
    {hook_js_vm_count, 2 },
```

{{#<1.3.0}}
`mapper_batch_size` 设置 mapper 在一条请求中获取的条目数量。
设的值很大的话会影响非 MapReduce 请求的读写性能。

_只有当设置为 `{mapred_system, legacy}`，
使用 [luke](https://github.com/basho/luke) 时才可用。_

```erlang
    %% {mapper_batch_size, 5},
```
{{/<1.3.0}}

`js_max_vm_mem` 设置为 Javascript VM 分配的最大内存量，单位为 MB。
如果不设置，则为 8MB。

这些设置只有编写 JavaScript M/R 任务时才有用。

```erlang
    {js_max_vm_mem, 8},
```

`js_thread_stack` 设置为 Javascript VM 分配的最大线程堆栈大小，单位为 MB。
如果不设置，则为 16MB。

_**注意：** 这里地堆栈和 C 线程堆栈不一样。_

```erlang
    {js_thread_stack, 16},
```

{{#<1.3.0}}
`map_cache_size` 设置在 MapReduce 缓存中存储的对象数量。
如果缓存空间用完，或者 bucket/key 更改了，相应的缓存就会被删除。

_只有当设置为 `{mapred_system, legacy}`，
使用 [luke](https://github.com/basho/luke) 时才可用。_

```erlang
    %% {map_cache_size, 10000},
```
{{/<1.3.0}}

`js_source_dir` 设置一个文件夹，里面保存的是 JavaScript 源码文件，
在 Riak 初始化 JavaScript VM 时使用。

```erlang
    %{js_source_dir, "/tmp/js_source"},
```

<!-- TODO: Pulled from MapReduce-Implementation.md -->

## 调整 Javascript 的设置

如果在 bucket 中加载很大的 JSON 对象，很有可能遇到下面的错误：

```javascript
 {"lineno":465,"message":"InternalError: script stack space quota is exhausted","source":"unknown"}
```

要解决这个问题，可以编辑 app.config 文件，增加分配给 JavaScript VM 堆栈的内存。
下面的设置会把堆栈的大小从 8MB 增加到 32 MB：

```erlang
{js_thread_stack, 8}
```

改成

```erlang
{js_thread_stack, 32},
```

除了增加分配给堆栈的内存大小之外，还可以增加堆阵的大小，即修改 `js_max_vm_mem` 设置，
其默认值为 8MB。如果在 reduce 阶段收集了大量结果就可以提升这个设置值。

## Riak 1.0 设置

Riak 1.0 是 MapReduce 支持 Riak Pipe 后发布的第一个版本。
默认情况下，Riak 集群会使用 Riak Pipe 提供 MapReduce 查询。升级到 Riak 1.0 的集群将
继续使用之前的 MapReduce 系统，除非把下面的设置加入每个
节点 `app.config` 文件的 `riak_kv` 区：

```erlang
%% Use Riak Pipe to power MapReduce queries
{mapred_system, pipe},
```

<div class="note">
警告：在集群中的每个节点都升级到 Riak 1.0 之前，千万别启用 Riak Pipe。
</div>

除了集群的速度和稳定性，选用哪种 MapReduce 不会对用户有太大影响。在 Riak 1.0 中，两种
系统使用的查询句法以及返回的结果都是一样的。如果遇到问题，可以切换会之前的系统，或者删除
上面添加的设置，或者按下面的方式修改：

```erlang
%% Use the legacy MapReduce system
{mapred_system, legacy},
```

## Reduce 阶段的设置

如果在 Riak 1.0 中使用 MapReduce 的 Riak Pipe 子系统，
可以通过下面的设置调整 reduce 阶段。

### Batch Size

默认情况下，如果收到 20 个新输入，Riak 就会执行 reduce 函数。如果 reduce 阶段要更高效，
或者输入数少一点，可以修改默认的设置，在 `riak_kv` 中加入下面的代码：

```erlang
%% Run reduce functions after 100 new inputs are received
{mapred_reduce_phase_batch_size, 100},
```

批量行为还可以针对每个请求设置，使用阶段规定的静态参数。通过 HTTP 指定阶段时，收到 150 个
新输入后执行该函数的 JSON 格式设置如下：

```javascript
{"reduce":
  {...language, etc. as usual...
   "arg":{"reduce_phase_batch_size":150}}}
```

在 Erlang 中，阶段参数还可以使用类似的 mochijson2 格式，或者使用更简单的 proplist 格式：

```erlang
{reduce, FunSpec, [{reduce_phase_batch_size, 150}], Keep}
```

如果 reduce 函数只要在收到所有输入后执行一次，请使用下面的参数：

```javascript
{"reduce":
  {...language, etc. as usual...
   "arg":{"reduce_phase_only_1":true}}}
```

类似地，在 Erlang 中可以这么设置：

```erlang
{reduce, FunSpec, [reduce_phase_only_1], Keep}
```

<div class="note">
警告：在 Riak 1.0.0 中有个系统问题，如果正在累计输入时进行数据移交，reduce 函数有可能比
设定值运行的次数多。这个问题在 1.0.1 中已经修正。
</div>

### Pre-Reduce

If your reduce functions can benefit from parallel execution, it is possible to request that the outputs of a preceding map phase be reduced local to the partition that produced them, before being sent, as usual, to the final aggregate reduce.

默认情况下，pre-reduce 是被禁用的。要为所有的 reduce 阶段启用这个功能，请把下面的设置加入 `riak_kv` 区：

```erlang
%% Always pre-reduce between map and reduce phases
{mapred_always_prereduce, true}
```

pre-reduce 功能还可以在单个阶段中启用或禁止，通过使用 Erlang 实现的 map 阶段的 API 设定。
要为 reduce 阶段后的 map 阶段启用 pre-reduce，传入一个 proplist 作为静态参数，包含下面
的设置：

```erlang
{map, FunSpec, [do_prereduce], Keep}
```

<div class="note">
警告：在 Riak 1.0.0 中有个已知问题，无法通过 HTTP 启用单个阶段的 pre-reduce 功能。
这个问题同样影响了 JavaScript 阶段。这时，请使用 app.config 中的全局设置。
这个问题在 1.0.1 中已修正。
</div>
