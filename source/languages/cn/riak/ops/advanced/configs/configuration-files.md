---
title: Configuration Files
project: riak
version: 1.4.2+
document: reference
toc: true
audience: intermediate
keywords: [operator]
---

Riak 有两个设置文件，如果是从源码安装的，保存在 `etc/`，如果是使用安装包安装的，
保存在 `/etc/riak`。这两个文件是 `app.config` 和 `vm.args`。

`app.config` 文件设置节点的各个属性，例如要使用哪种后台存储数据。`vm.args` 文件用来
向 Erlang 节点传递参数，例如 Erlang 节点的名字或 cookie。

## app.config

Riak 和相应的 Erlang 程序使用 Riak 节点中 `etc` 目录下的 `app.config` 设置。

```erlang
[
    {riak_core, [
        {ring_state_dir, "data/ring"}
        %% More riak_core settings...
            ]},
    {riak_kv, [
        {storage_backend, riak_kv_bitcask_backend},
        %% More riak_kv settings...
            ]},
    %% Other application configurations...
].
```

<div class="note">
注意，行前的 `%%` 代表注释。
</div>

{{#1.2.0+}}

### riak_api 设置

*   **pb_ip**
    Protocol Buffers 接口绑定的 IP 地址，默认为 `"127.0.0.1"`

    如果没设置，不会启动 PBC 接口。{{#1.3.0+}}IP 地址可以使用字符串，
    或者使用数字组成的元组（4个元素表示 IPv4，8 个数字表示 IPv6）。例如：

    ```erlang
    %% binds to specific IPv4 interface
    {pb_ip, {10,1,1,56}}

    %% binds to all IPv6 interfaces
    {pb_ip, "::0"}

    %% binds to a specific IPv6 interface
    {pb_ip, {65152,0,0,0,64030,57343,65250,15801}}
    ```
    {{/1.3.0+}}

*   **pb_port**
    Protocol Buffers 接口绑定的端口（默认为 `8087`）

*   **pb_backlog**
    同时发起的 Protocol Buffers 连接最大数。如果设置了，必须是大于等于 0 的整数。
    如果预计使用的连接数比默认同时初始化的要多，请相应地设置一个较大值。
    应该适当调整这个值，满足预计的同时连接数，或者如果正在经受连接重置。
    （默认值为 `5`）

*   **disable_pb_nagle**
    在 Protocol Buffers 连接中禁用 Nagle 算法（也叫 TCP slow-start）。
    这和设置 socket 的 TCP_NODELAY 选项效果一样。
    （默认为 {{#1.3.0+}}`false`{{/1.3.0+}}{{#1.3.0-}}`true`{{/1.3.0-}}）
{{/1.2.0+}}

### riak_core 设置

*   **choose_claim_fun**
    `{Module, Function}` 从传入的环中声明虚拟节点，返回处理后的环

*   **cluster_name**
    集群的名字。目前这个设置没有实际作用，不过可在大型架构中标识不同的集群。

*   **default_bucket_props**
    这些属性用于没有定义属性的 bucket（如在 HTTP API 中所述）。
    可用来设置 bucket 默认的行为：

    ```erlang
    {default_bucket_props, [
        {n_val,3},
        {allow_mult,false},
        {last_write_wins,false},
        {precommit, []},
        {postcommit, []},
        {chash_keyfun, {riak_core_util, chash_std_keyfun}},
        {linkfun, {modfun, riak_kv_wm_link_walker, mapreduce_linkfun}}
        ]}
    ```

    * n_val - 保存的副本数。*注意：详细讨论参见 [[CAP Controls]] 一文。*
    * 读、写和删除请求的法定值。可选值包括数字（例如，`{r, 2}`），以及下面列出的值：<br />
      `quorum`： 大多数副本要响应，等同于 `n_val / 2 + 1`<br />
      `all`： 所有副本都要响应
        * r - 读请求的法定值（成功的 GET 请求必须返回结果的 Riak 节点数）默认值：`quorum`
        * pr - 主读取请求的法定值（成功的 GET 请求必须返回结果的 Riak 主节点（非备用节点）数）默认值：`0` *注意：关于主节点的说明请阅读[[Eventual Consistency]] 一文*
        * w - 写请求的法定值（必须接受 PUT 请求的 Riak 节点数）默认值：`quorum`
        * dw - 持续写请求的法定值（接受从存储后台发出的写请求的 Riak 节点数）默认值：`quorum`
        * pw - 主写入请求的法定值（必须接受 PUT 请求的 Riak 主节点（非备用节点）数）默认值：`0`
        * rw - 删除请求的法定值。默认值：`quorum`
    * allow_mult - 是否允许兄弟数据。*注意：关于兄弟数据的解决方法请阅读 [[Vector Clocks]] 一文*
    * precommit - 全局 [[pre-commit 钩子|Using Commit Hooks#Pre-Commit-Hooks]] 函数，可在 Javascript 或 Erlang 中使用
    * postcommit - 全局 [[post-commit 钩子|Using Commit Hooks#Post-Commit-Hooks]] 函数。只能在 Erlang 中使用

*   **delayed_start**
    启动 riak_core 之前等待一段时间，单位为毫秒。默认值：`unset`

*   **disable_http_nagle**
    设为 `true` 时，会对 HTTP 流量禁用 Nagle 缓冲算法，等同于
    设置 HTTP socket 的 TCP_NODELAY 选项。默认值为 `false`。
    如果持续遇到最小迟延值是 20 毫秒的倍数，设为 `true` 或许可以减少迟延。

*   **gossip_interval**
    集群中的节点多久广播一次环的状态，单位为毫秒。默认值：`60000`

*   **handoff_concurrency**
    每个物理节点上允许同时进行移交操作的虚拟节点数量。默认值：`2`

*   **handoff_port**
    移交监听的 TCP 端口号。默认值：`8099`

*   **handoff_ip**
    移交绑定的 IP 地址。默认值：`"0.0.0.0"`
    {{#1.3.0+}}IP 地址可以使用字符串形式，或者元素为数字的元组形式
    （4 个元素表示 IPv4，8 个元素表示 IPv6）。示例请参照上面的 `pb_ip` 设置。 {{/1.3.0+}}

*   **http**
    Riak 的 HTTP 接口监听的 IP 地址和端口列表。默认值：`{"127.0.0.1", 8091 }`

    *如果不设定这个设置，Riak 的 HTTP 接口不会启用。*

*   **http_logdir**
    重新制定默认的访问日志存放路径。
    启用访问路径的方法请参照 `webmachine_logger_module` 设置。

*   **https**
    Riak 的 HTTPS 接口监听的 IP 地址和端口列表。默认不启用。

    *如果不设定这个设置，Riak 的 HTTPS 接口不会启用。*

*   **legacy_vnode_routing**
    （布尔值）是否兼容旧版本

*   **platform_data_dir**
    后台存储数据的基文件夹。默认值：`./data`

*   **ring_state_dir**
    硬盘上存储环状态的文件夹。默认值：`data/ring`

    Riak 的环状态存储在各个节点的硬盘上，这样就可以随时重启节点，在终结之前知道在集群中
    的位置，而不用立即访问集群中的其他节点。

*   **ring_creation_size**
    哈希空间要分成多少个分区。默认值：`64`

    默认情况下，各 Riak 节点的分区数量等于 ring_creation_size/集群中的节点数。
    一般来说都会把 ring_creation_size 的值设成节点数量的好几倍
    （例如，对于有 4 个节点的集群，分成 64-256 个分区）。这样就有足够的容量扩充集群，
    不用担心没有足够的分区。这个值应该是 2 的幂数。（64，128，256 等）

    {{#1.4.0-}}
    <div class="info">
    <div class="title">环的大小提示</div>
    `ring_creation_size` 应该在集群启动之前设置，而且设置好后就不要改动。
    </div>
    {{/1.4.0-}}

*   **ssl**
    重新设置默认的 SSL 密匙和证书。默认值：`etc/cert.pem`，`etc/key.pem`

*   **target_n_val**
    要使用的最大 n_val。这个值影响分区在集群中的分布，以及 preflist 的计算方式，可以确保
    数据不会多次存放在同一个物理节点中。很少需要改动这个值。

    假设 ring_creation_size 的值是 2 的幂数，target_n_val 的理想值要大于或等于
    任何 bucket n_val 的最大值，还要能被环的数量（ring_creation_size）整除。
    默认值是 4。为了有效避免热点，集群的大小（物理节点的数量）必须大于会等于 target_n_val。

*   **vnode_management_timer**
    默认情况下，Riak 每隔 10 秒钟会检查主分区是否需要转移。
    这个时间间隔可以通过这个设置修改，单位为毫秒。{{1.1.2+}}

*   **wants_claim_fun**

    返回布尔值的 {Module, Function}，如果为 `true`，表示这个节点想要更多的虚拟节点

*   **enable_health_checks**
    `true` 或 `false`。
    如果为 `true`，表示要启用所有的健康检查。{{1.3.0+}}

*   **stat_cache_ttl**
    {{#1.2.0-1.3.1}}缓存中状态的生存值期（TTL），单位为秒。如果请求缓存中的状态，
    但是超过了 TTL，则会重新生成状态。默认值：`1`。{{/1.2.0-1.3.1}}
    {{#1.3.2+}}状态缓存更新的间隔时间，单位为秒。默认值：`1`。
    所有的 Riak 状态都从这个缓存中读取。这个设置控制缓存更新的周期。 {{/1.3.2+}}

### riak_kv 设置

*   **anti_entropy**
    启用反熵子系统和可选的调试信息

    `{anti_entropy, {on|off, []}},`

    `{anti_entropy, {on|off, [debug]}},`

*   **anti_entropy_build_limit**
    限制 AAE 构建哈希树的速度。构建分区的哈希树要完整扫描整个分区中的数据。
    一旦构建开始，就会一直持续到限制时间才停止。
    该设置的格式是 `{number-of-builds, per-timespan-in-milliseconds}`。

    `{anti_entropy_build_limit, {1, 3600000}},`

*   **anti_entropy_expire**
    设置哈希树构建好后多久过期。定期让哈希树过期可以确保硬盘上的哈希树
    和 k/v 后台种存储的数据保持一致。同时还有助于 Riak 识别悄无声息的硬盘故障和位衰减。
    不过，常规的 AAE 操作不需要过期时间，而且为了性能，也应该不定期的过期。
    这个设置的单位是毫秒，默认值为一周。

    `{anti_entropy_expire, 604800000},`

*   **anti_entropy_concurrency**
    限制 AAE 交换/构建操作的并发数。

    `{anti_entropy_concurrency, 2},`

*   **anti_entropy_tick**
    设定 AAE 管理程序隔多久去找事做（例如，构建树，把数设为过期，进行交换等）。
    默认值为 15 秒。设置更小的值可以提高副本在集群中同步的速度。、
    不建议提升这个设置值。

    `{anti_entropy_tick, 15000},`

*   **anti_entropy_data_dir**
    AAE 哈希树存放的文件夹。

    `{anti_entropy_data_dir, "./data/anti_entropy"},`

*   **anti_entropy_leveldb_opts**
    AAE 为 LevelDB 生成硬盘上的哈希树所用的选项。

    `{anti_entropy_leveldb_opts, [{write_buffer_size, 4194304}, {max_open_files, 20}]},`

*   **add_paths**
    添加到 Erlang 代码路径中的一系列路径。

    如果执行 MapReduce 查询时允许 Riak 使用外部的模块，就可以使用这个设置。

*   **delete_mode**
    设置在 Riak 把对象标记为删除状态到对象真的被删除这段时间内系统应该作何反应。
    有三种模式可选：`delay`（单位为毫秒），`immediate` 和 `keep`。
    默认设置为延迟 3 秒。
    如果设为 `immediate`，在收到删除请求时就会立即移出墓碑。
    如果设为 `keep`，则禁止移除全部的墓碑。

*   **mapred_name**
    通过 HTTP 开放给 MapReduce 的 URL 地址基。默认为 `mapred`。

*   **mapred_queue_dir**
    文件夹的路径，用来存放暂时队列中等待执行的 mao 任务。
    只有在 mapred_system 设为 legacy 时才可用。默认值：`data/mrqueue`。{{1.3.0+}}

*   **mapred_system**
    设置要使用 MapReduce 哪个版本：设为 `'pipe'`，会使用 riak_pipe；
    设为 `'legacy'`，会使用 luke。{{1.3.0+}}

*   **map_js_vm_count**
    启动多少个 JavaScript VM 处理 map 步骤。默认值：`8`。

*   **reduce_js_vm_count**
    启动多少个 JavaScript VM 处理 reduce 步骤。默认值：`6`。

*   **hook_js_vm_count**
    启动多少个 JavaScript VM 处理 pre-commit 钩子。默认值：`2`。

*   **mapper_batch_size**
    一次请求中 mapper 获取的条目数量。对于非 MapReduce 请求而言，较大的值会影响读/写性能。
    只有当 mapred_system 为 legacy 时才可用。默认值：`5`。{{1.3.0+}}

*   **js_max_vm_mem**
    分配给每个 JavaScript VM 的最大内存，单位为 MB。默认值：`8`。

*   **js_thread_stack**
    分配给 JavaScript VM 的最大线程堆栈空间，单位为 MB。默认值：`16`。

*   **map_cache_size**
    MapReduce 缓存中存放的对象数量。
    如果缓存空间用完，或者修改了对象的 bucket/key 组合，就不会考虑这个设置了。
    只有当 mapred_system 设为 legacy 时才可用。默认值：`10000`。{{1.3.0+}}

*   **js_source_dir**
    从哪里加载用户定义的 JavaScript 函数。默认不设定。

*   **http_url_encoding**
    在 REST API 中 Riak 如何编码 bucket、键和链接。
    如果设为 `on`，Riak 会解码所有 URL 和报头中的编码。
    否则，Riak 使用兼容模式，只解码链接中的字符，而不管 bucket 和键。
    后续的发布版本中会删除兼容模式。
    默认值：`off`。

*   **vnode_vclocks**
    如果设为 `true`，使用基于虚拟节点的向量时钟，而不是客户端 ID。
    这个设置可以显著地减少向量时钟的数量。
    只有当集群中的所有节点都升级到 Riak 1.0，才可以设为 `true`。
    默认值：`false`。

*   **legacy_keylisting**
    是否兼容 Riak 0.14 之前版本的 bucket 和键列表。
    一旦滚动升级到 Riak 1.0+，就必须设为 `false`，这样可以提升 bucket 和键列表的性能。
    默认值：`true`。

*   **pb_ip**
    Protocol Buffers 接口绑定的 IP 地址。默认值：`"127.0.0.1"`

    如果不设置，不会启用 PBC 接口。{{1.2.0-}}

*   **pb_port**
    Protocol Buffers 接口绑定的端口号。默认值：`8087`。{{1.2.0-}}

*   **pb_backlog**
    等待执行的连接的最大值。
    如果设置，必须大于等于 0。
    如果同时初始化时需要很多连接，请把值设的大一点。
    默认值：`5`。 {{1.2.0-}}

*   **raw_name**
    Riak 开放的 HTTP 接口的 URL 地址基。默认值：`riak`。

    默认情况下数据的地址是 `/riak/Bucket/Key`。
    例如，如果把这个设置改为 "bar"，那么数据的地址会变成 `/bar/Bucket/Key`。

*   **riak_kv_stat**
    如果设为 `true`，则启用统计信息聚合工具（`/stats` 地址和 `riak-admin status` 命令）。
    默认值：`true`。

*   **stats_urlpath**
    统计信息聚合工具使用的 URL 地址基。默认值：`stats`。

*   **storage_backend**
    Riak 使用的存储后台模块名。默认值：`riak_kv_bitcask_backend`。

    如果不设定，Riak 会拒绝启动。
    可用的后台模块有：

    * `riak_kv_bitcask_backend` - 数据存储在 Bitcask 中。更多设置信息请阅读 Bitcask 的设置页面。
    * `riak_kv_eleveldb_backend` - 数据存储在 LevelDB 中。更多设置信息请阅读 LevelDB 的设置页面。
    * `riak_kv_memory_backend` - 具有过期时间的 LRU 缓存后台。更多设置信息请阅读“内存后台”的设置页面。
    * `riak_kv_multi_backend` - 不同的 bucket 使用不同的后台。更多设置信息请阅读 Multi 设置页面。

*   **riak_search**
    Riak 搜索功能现在在 `app.config` 中启用。
    如果要使用，请在 Riak Search Config 区将其设为 `true`。

*   **vnode_mr_timeout**
    map 函数允许在虚拟节点上执行多长时间才超时，然后再到下一个虚拟节点上尝试，单位为毫秒。默认值：`1000`。

*   **vnode_mailbox_limit**
    `{EnableThreshold, DisableThreshold}` - 设置 riak_kv 健康检查监控消息队列的
    允许长度。如果 KV 虚拟节点的消息队列长度达到了 `DisableThreshold`，该节点会
    关闭 `riak_kv` 服务，知道队列长度降到 `EnableThreshold` 以下，才会
    重启 `riak_kv` 服务。{{1.3.0+}}

*   **secondary_index_timeout**
    二级索引查询的超时时长。默认值是 `0`，表示不设超时。{{1.4.1+}}

### webmachine_logger_module

如果要启用访问日志就要设置这个值。

`{webmachine, [{webmachine_logger_module, webmachine_logger}]}`

<div class="info">
<div class="title">提示</div>
访问日志的硬盘 IO 消耗会影响一部分性能，而你可能并不想损耗。所以，默认情况下，Riak 不生成访问日志。
</div>

### riak_search 设置

*   **enabled**
    启用搜索功能。默认值：`false`。

*   **max_search_results**
    报错之前要累计多少个结果。默认值：`100000`。

```erlang
%% Riak Search Config
{riak_search, [
    %% To enable Search functionality set this 'true'.
    {enabled, false}
    ]},
```

### lager

Lager 是 Riak 使用的日志引擎，从 Riak 1.0 起使用。其设计目标是要
比 Erlang 的 error_logger 更稳定，还要能和常用的日志工具良好兼容。

*   **handlers**
    允许选择的日志处理程序使用不同的选项。

    * lager_console_backend - 日志显示到控制台中，使用指定的日志等级
    * lager_file_backend - 日志写入一系列指定的文件中，每个文件都有自己的等级

*   **crash_log**
    要不要生成宕机日志，如果要，那么保存在哪里。默认为不生成。

*   **crash_log_size**
    宕机日志文件大小的最大值。默认值：`65536`

*   **error_logger_redirect**
    要不要把 sasl error_logger 消息转到 Lager 中。默认值：`true`。

Lager 的默认设置如下：

```erlang
{lager, [
    {handlers, [
        {lager_console_backend, info},
            {lager_file_backend, [
                {"/opt/riak/log/error.log", error},
                {"/opt/riak/log/console.log", info}
                ]}
                ]},.
                {crash_log, "{{platform_log_dir}}/crash.log"},
                {crash_log_size, 65536},
                {error_logger_redirect, true}
                ]},
```

## vm.args

运行着 Riak 的 Erlang 节点，其参数在 `etc` 文件夹下得 `vm.args` 文件中设置。如果不需要
调整性能，大多数的设置之间使用默认值即可。

现在感兴趣的设置是 `-name` 和 `-setcookie`。这个两个值设定了 Erlang 节点的名字，
以及 Erlang 节点之间的通信。

这个文件对格式的要求不严格：前面没有 `#` 符号的行会联接起来传递给 `erl` 命令。

关于这些设置更详细的说明请阅读 Erlang 文档中对 erl Erlang 虚拟机的说明。

Riak CS 和企业版可能会使用不同的设置，请以各自的 `vm.args` 文件为准。

#### -name

Erlang 节点的名字。默认值：`riak@127.0.0.1`

默认值只对本地运行的 Riak 有效，如果在分布式环境（多个节点）中使用，
“@”符号后面的部分就要改成节点所在电脑的 IP 地址。

如果正确设置了 DNS，可以使用节点名的简短形式（例如，`riak`），即 `riak@Host.Domain`。

#### -setcookie

Erlang 节点的 cookie。默认值：`riak`

Erlang 节点根据之前共用的 cookie 来确认是否有权访问其他节点。
集群中的所有节点应该使用同一个 cookie 值，但一定要唯一，不易猜到，避免未授权的访问。

#### -heart

启用“heart”节点监控。默认值：`disabled`

如果节点宕机了，启用“heart”后，会自动重启节点。不过，“heart”对太专注重启节点，甚至到了
无法自已的地步。只有当你确定需要宕机自动重启功能时才启用“heart”。

#### +K

启用内核轮询。默认值：`true`

#### +A

异步线程池中的线程数。默认值：`64`

#### -pa

把指定的文件夹添加到代码搜索路径的前面，
和 [`code:add_pathsa/1`](http://www.erlang.org/doc/man/code.html#add_pathsa-1) 类似。
如果要添加很多文件夹，而且这些文件夹都有共同的父文件夹，
那么可以通过 `ERL_LIBS` 环境变量指定这个父文件夹。

#### -env

为 Erlang 设置主机环境变量。

#### -smp

启用 Erlang 对 SMP 的支持。默认值：`enable`

#### +zdbbl

设置节点之间出站消息的缓冲大小。默认情况下，这个设置是注释掉的，因为其设定值和
可用的系统内存，对象的一般大小和数据库的流量有很大关系。如果没有在 `vm.args` 中设置，
其值为 `1024`，注释掉的值是 `32768`。

内存很多而且浏览负载很重的系统可以考虑提升这个值。负载不是那么大，但存储的对象比较大时，
或许希望降低这个值。决定最佳值（以及调整其他参数）时强烈建议使用 [[Basho Bench]]。

#### +P

设置 Erlang 进程的数量限制。Riak 1.4.x 支持的 Erlang，限制都很小，
所以通过这个设置提升限制值就尤为重要。默认值：`256000`

**注意：**如果你担心这个值为什么这么大，请记住，Erlang 进程和系统进程不是一回事。
所有这些进程都仅仅存在于一个系统进程中，即 Erlang beam。

#### +sfwi

如果使用[打了补丁的 Erlang VM](https://gist.github.com/evanmcc/a599f4c6374338ed672e)
（例如从 Basho 下载的 Erlang VM），这个设置可以设定监督线程检查运行队列是否工作的时间间隔，
单位为毫秒。默认值：`500`

#### +W

设置要怎么对待发送到 Erlang `error_logger` 的警告消息，作为错误、警告还是提示。
默认值是 `w`，即作为警告。

#### -env ERL_LIBS

想代码搜索路径添加文件夹的另一种方法。详情参见上面的 `-pa`。

#### -env ERL_MAX_PORTS

ports/sockets 并发最大值。默认值：`64000`

**注意：**和进程一样，Erlang 的端口和系统端口类似，但不一样。

#### -env ERL_FULLSWEEP_AFTER

多久运行一次垃圾回收程序。默认值：`0`

#### -env ERL_CRASH_DUMP

宕机转储的位置。默认值：`./log/erl_crash.dump`

## 在 Rebar 中重用设置

如果经常重新编译 Riak，可以编辑 `rel/files` 文件夹中的 `vm.args` 和 `app.config` 文件。
使用 `make rel` 或 `rebar generate` 命令编译新版本时，每次都会用到这两个文件。
生成新版本之前要先删除旧版本。针对各版本的设置
（`rel/riak/etc/vm.args`，`rel/riak/etc/app.config` 等）在该版本被删除时也一并删除了。
