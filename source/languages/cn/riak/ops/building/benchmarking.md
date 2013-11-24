---
title: Basho Bench
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: beginner
keywords: [operator, benchmark]
---

Basho Bench 是一个测评工具，用来进行精确且可重复的性能测试和压力测试，最终会输出性能图表。

Basho Bench 最开始由 Dave Smith (Dizzy) 开发，用来测评 Basho 的键值对数据库 Riak。它提供了一个可插入式驱动接口，基于这个接口 Basho Bench 已经得到扩展，可以测评很多项目。驱动使用 Erlang 开发，一般都会少于 200 行代码。

## 下载

basho_bench 的主仓库地址是 [http://github.com/basho/basho_bench/](http://github.com/basho/basho_bench/)。

## 文档


<div class="info">
<div class="title">关于文档的说明</div>

本文可用来代替 2011 年 2 月份以前 basho_bench 仓库中的 `docs/Documentation.org` 文档。
</div>


### basho_bench 是怎么工作的？

Basho Bench 启动时（basho_bench.erl），会读取设置文件（basho_bench_config.erl），新建一个文件夹用来保存结果，然后进行测试（basho_bench_app.erl/basho_bench_sup.erl）。

在测试阶段，Basho Bench 创建了：

-   一个**状态进程**（basho_bench_stats.erl）。这个进程会接受操作完成后的提醒，以及操作所用时间，然后把结果保存成一个柱状图。一定时间后，柱状图会被转换成 `summary.csv` 和针对某项操作的迟延 CSV 文件（例如，`put` 操作的迟延文件是 `put_latencies.csv`）。
-   n 个 **worker**，n 的值由 [[concurrent|Basho Bench#concurrent]] 设置设定（basho_bench_worker.erl）。worker 包裹了一个驱动模块，这个模块由 [[driver|Basho Bench#driver]] 设置设定。驱动是根据操作的分布情况随机调用的，由 [[operations|Basho Bench#operations]] 设置设定。驱动调用操作的比例是由 [[mode|Basho Bench#mode]] 设定的。

这些经常创建并初始化之后，Basho Bench 会向所有的 worker 进程发送运行命令，开始进行测试。每个 worker 初始化时都使用了相同的初始值，随机生成数字，确保生成的工作量以后可以再次生成。

测试时，worker 会重复调用 `driver:run/4`，传入接下来要进行的操作，生成键的函数，生成值的函数，以及驱动的最终状态。worker 进程会对操作计时，等操作完成后把结果传给状态进程。

只要测试运行的时间达到了设置文件中的指定值，所有 worker 和状态进程都会终止，测评也就结束了。测出的迟延和吞吐量保存在 `./tests/current/` 文件夹中。以前的测试结果保存在以时间戳命名的文件夹中，也就是 `./tests/YYYYMMDD-HHMMSS/` 这种形式。

## 安装

### 前提条件

-   必须先安装 Erlang。Erlang 的安装方法和版本要求参见“[[安装 Erlang]]”一文
-   如果想生成图表，必须先安装[统计语言 R](http://www.r-project.org/)（详情参见下面的“[[生成测评图表|Basho Bench#Generating-Benchmark-Graphs]]”一节)

### 从源码编译

Basho Bench 现在只有源码，要获取最新的代码，请克隆 basho_bench 的仓库：

```bash
git clone git://github.com/basho/basho_bench.git
cd basho_bench
make
```

## 用法

运行 basho_bench 命令：

```bash
./basho_bench myconfig.config
```

上述命令会把测试结果保存到 `tests/current/` 文件夹中。运行这个命令前要先创建设置文件。建议以 `examples` 文件夹中的某个文件为样本，然后根据下面“[[设置|Basho Bench#Configuration]]”一节的说明进行修改。

<a id="Generating-Benchmark-Graphs"></a>
## 生成测评图表

basho_bench 的结果可以生成图表，显示：

-   吞吐量 - 测试运行的时间段内每秒执行的操作数
-   99 百分位的迟延，某些操作可达到 99.9 百分位或者更高
-   迟延中值，迟延均值，以及某些操作的 95 百分位迟延

### 前提条件

要生成图表，必须安装统计语言 R。注意：如果需要，可以在运行 basho_bench 之外的另一台电脑上安装 R，相关数据会从加载测试的电脑（例如，使用 rsync）复制到生成和查看图表的电脑（例如一个桌面电脑）。

-   更多信息：[[http://www.r-project.org/]]
-   下载 R：[[http://cran.r-project.org/mirrors.html]]

请按照针对你所用平台的说明安装 R。

### 生成图表

要想为当前的测试结果生成图表，请运行：

```bash
make results
```

上述命令会生成 `tests/current/summary.png`。

也可以手动运行下面的命令：

```bash
priv/summary.r -i tests/current
```

## 设置

Basho Bench 提供了很多示例设置文件，都在 /examples/ 文件夹中。

### 全局设置

<a id="mode"></a>
#### mode

**mode** 控制 worker 使用新方法调用 `{driver:run/4}` 的频率。可选值有两个：

* `{max}` --- 每秒生成尽可能多得操作
* `{rate, N}` --- 每秒生成 N 个操作，N 的值是时间间隔的指数

注意，这个设置各驱动都是独立设定地。例如，使用 3 个并发 worker，**mode** 设为 `{rate, 5}`，basho_bench 每秒就会生成 15（=5*3）个操作。

```bash
% Run at max, i.e.: as quickly as possible
{mode, max}

% Run 15 operations per second per worker
{mode, {rate, 15}}
```

<a id="concurrent"></a>
#### concurrent

并发的 worker 进程数，默认为 3。这个设置决定了请求 API 的并发客户端数量。

```bash
% Run 10 concurrent processes
{concurrent, 10}
```

<a id="duration"></a>
#### duration

测试持续的时间，单位为分钟。默认为 5 分钟。

```bash
% Run the test for one hour
{duration, 60}
```

<a id="operations"></a>
#### operations

驱动要进行的操作，以及权重或者被执行的可能性。默认值为 `[{get,4},{put,4},{delete, 1}]`，也就是说，平均每 9 次操作中，`get` 会运行 4 次，`put` 会运行 4 次，`delete` 会运行 1 次。

```bash
% Run 80% gets, 20% puts
{operations, [{get, 4}, {put, 1}]}.
```
这一设置也是每个驱动分开设定的。并不是所有的驱动都会实现前面提到的 "get"/"put" 操作。具体实现的操作请阅读驱动的源码。假如要测试 HTTP 接口，相应的操作就是 get 和 update。

如果驱动不支持某个操作（这里以 asdfput 为例），会看到如下的错误：

```bash
DEBUG:Driver basho_bench_driver_null crashed: {function_clause,
                                          [{{{basho_bench_driver_null,run,
                                            [asdfput,
                                             #Fun<basho_bench_keygen.4.4674>,
                                             #Fun<basho_bench_valgen.0.1334>,
                                             undefined]}}},
                                           {{{basho_bench_worker,
                                            worker_next_op,1}}},
                                           {{{basho_bench_worker,
                                            max_worker_run_loop,1}}}]}
```

<a id="driver"></a>
#### driver

生成负载时 basho_bench 使用的驱动模块名。驱动可以之间在进程中调用代码（例如测试 DETS 的性能时），或者打开网络连接从远程系统加载数据（例如测试 Riak 服务器/集群时）。

可以使用的驱动如下：

-   `basho_bench_driver_http_raw` - 使用 Riak 的 HTTP 接口，对 Riak 服务器进行 get/update/insert 操作
-   `basho_bench_driver_riakc_pb` - 使用 Riak 的 Protocol Buffers 接口，对 Riak 服务器进行 get/put/update/delete 操作
-   `basho_bench_driver_riakclient` - 使用 Riak 的 Distributed Erlang 接口，对 Riak 服务器进行 get/put/update/delete 操作
-   `basho_bench_driver_bitcask` - 直接调用 Bitcask API
-   `basho_bench_driver_dets` - 直接调用 DETS API

调用 `driver:run/4` 方法时，驱动可能会返回下列的结果：

-   `{ok, NewState}` - 操作成功完成
-   `{error, Reason, NewState}` - 操作失败，但驱动可以继续运行（例如，可复原的错误）
-   `{stop, Reason}` - 操作失败，驱动无法继续运行
-   `{'EXIT', Reason}` - 操作失败，驱动挂机

#### code_paths

某些驱动必须加载额外的 Erlang 代码才能运行。这些代码的路径就由 **code_paths** 设置指定。

#### key_generator

生成键的函数。在 `basho_bench_keygen.erl` 中定义。可用的函数有：

-   `{sequential_int, MaxKey}` - 按 0..MaxKey 的顺序生成整数，然后终止系统。注意，该方法的每个实例都专属于一个 worker
-   `{partitioned_sequential_int, MaxKey}` - 和 `{sequential_int}` 一样，但在所有的 worker 进程中平均分配键的取值范围。这个函数常用于要预先加载大型数据的情况。
-   `{partitioned_sequential_int, StartKey, NumKeys}` - 和 `partitioned_sequential_int` 一样，但从 `StartKey` 开始，直到 `StartKey + NumKeys`
-   `{uniform_int, MaxKey}` - 从 0..MaxKey 范围内选择一个唯一值，所有值被选中的概率相等
-   `{pareto_int, MaxKey}` - 从帕累托分布中选择一个整数，所以所有键中的 20% 有 80% 的机会被选中。注意，当前实现的这个函数可能会生成大于 MaxKey 的值，这是由帕累托分布的数学性质导致的。
-   `{truncated_pareto_int, MaxKey}` - 和 `{pareto_int}` 一样，但不会生成比 MaxKey 大的值
-   `{function, Module, Function, Args}` - 指定一个外部函数用来生成键。调用这个函数时，worker 的 `Id` 会传入 `Args`。
-   `{int_to_bin, Generator}` - 接受上述任何一个以 `_int` 结尾的函数做参数，然后把生成的结果转换成 32 位二进制。需要二进制键的驱动就要用这个函数。
-   `{int_to_str, Generator}` - 接受上述任何一个以 `_int` 结尾的函数做参数，然后把生成的结果转换成字符串。需要字符串形式的键的驱动就要用这个函数。

默认用来生成键的函数是 `{uniform_int, 100000}`。

示例：

```bash
% Use a randomly selected integer between 1 and 10,000
{key_generator, {uniform_int, 10000}}.

% Use a randomly selected integer between 1 and 10,000, as binary.
{key_generator, {int_to_bin, {uniform_int, 10000}}}.

% Use a pareto distributed integer between 1 and 10,000; values < 2000
% will be returned 80% of the time.
{key_generator, {pareto_int, 10000}}.
```

#### value_generator

生成值的函数。在 `basho_bench_valgen.erl` 中定义。可用的函数有：

-   `{fixed_bin, Size}` - 生成随机的二进制对象，字节数由 Size 指定。生成的每个值长度一样，知识内容不同。
-   `{exponential_bin, MinSize, Mean}` - 生成随机的二进制对象，大小呈指数变化。大多数值的大小近似 MinSize + Mean 个字节，较大值会有长尾。
-   `{uniform_bin, MinSize, MaxSize}` - 生成随机的二进制对象，大小在 MinSize 和 MaxSize 之间等价分布。
-   `{function, Module, Function, Args}` - 指定一个外部函数用来生成值。调用这个函数时，worker 的 `Id` 会传入 `Args`。

默认使用的函数是 `{value_generator, {fixed_bin, 100}}`。

示例：

```bash
% Generate a fixed size random binary of 512 bytes
{value_generator, {fixed_bin, 512}}.

% Generate a random binary whose size is exponentially distributed
% starting at 1000 bytes and a mean of 2000 bytes
{value_generator, {exponential_bin, 1000, 2000}}.
```

#### rng_seed

要使用的初始随机值。这些值会显式注入，而不是在当前时间注入，这样测试就可以预测，重复执行。

默认值为 `{rng_seed, {42, 23, 12}}`。

```bash
% Seed to {12, 34, 56}
{rng_seed, {12, 34, 56}.
```

#### log_level

 **log_level**  决定 Basho Bench 要把哪些消息输出到终端并写入硬盘。

默认值是 **debug**。

可用的值有：

-   debug
-   info
-   warn
-   error

#### report_interval

状态进程隔多久要把柱状图写入硬盘，单位为秒。默认值为 10 秒。

#### test_dir

测试结果保存的文件夹。默认为 `tests/`。

### basho_bench_driver_riakclient Settings

这些设置针对 `basho_bench_driver_riakclient` 驱动。

#### riakclient_nodes

列出测试时要使用的 Riak 节点。

```bash
{riakclient_nodes, ['[riak1@127.0.0.1](mailto:riak1@127.0.0.1)',
'[riak2@127.0.0.1](mailto:riak2@127.0.0.1)']}.
```

#### riakclient_cookie

用来连接到 Riak 客户端的 Erlang cookie。默认值是 `'riak'`。

```bash
{riakclient_cookie, riak}.
```

#### riakclient_mynode

本地节点的名称。会传入 [net_kernel:start/1](http://erlang.org/doc/man/net_kernel.html)。

```bash
{riakclient_mynode,
['[basho_bench@127.0.0.1](mailto:basho_bench@127.0.0.1)', longnames]}.
```

#### riakclient_replies

这个值在 get 操作时代表 R 值，在 put 操作时代表 W 值。

```bash
% Expect 1 reply.
{riakclient_replies, 1}.
```

#### riakclient_bucket

读写操作使用的 Riak bucket。默认为 `<<"test">>`。

```bash
% Use the "bench" bucket.
{riakclient_bucket, &lt;&lt;"bench"&gt;&gt;}.
```

### 针对 basho_bench_driver_riakc_pb 驱动的设置

#### riakc_pb_ips

worker 要连接的 IP 地址。每个 worker 会选择一个随机的 IP。

默认值是 `{riakc_pb_ips, [{127,0,0,1}]}`。

```bash
% Connect to a cluster of 3 machines
{riakc_pb_ips, [{10,0,0,1},{10,0,0,2},{10,0,0,3}]}
```

#### riakc_pb_port

连接到 PBC 接口的端口号。

默认值为 `{riakc_pb_port, 8087}`。

#### riakc_pb_bucket

测试时使用的 bucket。

默认值是 `{riakc_pb_bucket, <<"test">>}`。

### 针对 basho_bench_driver_http_raw 驱动的设置

#### http_raw_ips

worker 要连接的 IP 地址。每个 worker 会循环的向各 IP 地址发起请求。

默认值为 `{http_raw_ips, ["127.0.0.1"]}`。

```bash
% Connect to a cluster of machines in the 10.x network
{http_raw_ips, ["10.0.0.1", "10.0.0.2", "10.0.0.3"]}.
```

#### http_raw_port

连接到 HTTP 服务器的默认端口。

默认值为 `{http_raw_port, 8098}`。

```bash
% Connect on port 8090
{http_raw_port, 8090}.
```

#### http_raw_path

连接 Riak 时使用的基路径，一般是 "/riak/<bucket>"。

默认值为 `{http_raw_path, "/riak/test"}`。

```bash
% Place test data in another_bucket
{http_raw_path, "/riak/another_bucket"}.
```

#### http_raw_params

添加到 URL 尾部的参数。这个值可用来设置所需的 r/w/dw/rw 参数。

默认值为 `{http_raw_params, ""}`。

```bash
% Set R=1, W=1 for testing a system with n_val set to 1
{http_raw_params, "?r=1&w=1"}.
```

#### http_raw_disconnect_frequency

多长时间（秒）或多少次操作后要强制中断 HTT 客户端（worker）和服务器之间的连接。

默认值为 `{http_raw_disconnect_frequency, infinity}`。（从不强制中断）

```bash
% Disconnect after 60 seconds
{http_raw_disconnect_frequency, 60}.

% Disconnect after 200 operations
{http_raw_disconnect_frequency, {ops, 200}}.
```

## 自定义驱动

自定义驱动必须提供下面的回调函数。

```erlang
% Create the worker
% ID is an integer
new(ID) -> {ok, State} or {error, Reason}.

% Run an operation
run(Op, KeyGen, ValueGen, State) -> {ok, NewState} or {error, Reason, NewState}.
```
详细信息请参照[现有的驱动](https://github.com/basho/basho_bench/tree/master/src)。
