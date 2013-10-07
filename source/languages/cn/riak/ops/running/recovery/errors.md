---
title: Common Errors
project: riak
version: 1.4.2+
document: reference
toc: true
audience: advanced
keywords: [errors]
interest: []
body_id: errors
---

本文并没有列出在使用 Riak 时可能遇到的错误，而是尽量列出最常见的错误，
并给出非关键错误的说明，在日志文件中可能会见到。

查找错误所在是个体力活，有时错误是由一系列其他错误导致的。

## 错误和消息

本文列出的表格没有说明错误消息会写入哪个日志文件。根据你所做的日志设置，有些可能更常见
（例如，日志等级为 debug），有些只会输出到控制台（例如，执行了 `riak console` 命令）。

你还可以在 `app.config` 文件的 `lager` 区设置 `lager_default_formatter`，调整
日志消息的格式。如果你做了修改，看到的消息和本文显示的会有所不同。

本文的组织方式有利于查看日志消息的某个部分，因为整个日志条目太笨重了。例如，下面的消息：

```
12:34:27.999 [error] gen_server riak_core_capability terminated with reason:\
no function clause matching orddict:fetch('riak@192.168.2.81', []) line 72
```

开头是日期（`12:34:27.999`），后面跟着日志的等级（`[error]`），然后是由 `lager` 设置
控制格式的一段消息（如下面的 Lager 表格中所示：*gen_server `Mod` terminated with reason: `Reason`*）

### Lager 格式

Riak 使用的主要日志机制基于 Lager 项目，最好了解一下常见的消息格式。大多数格式中，导致
问题的原因都用变量表示，例如对应 `Mod` 的 `Reason`（意思是说 Erlang 模块往往是问题所在）。

Riak 不会吧收到的所有错误消息都转换成人类可读的句子。不过，输出的错误是个对象。

上面的错误消息示例对应到下表第一个消息，Erlang `Mod` 的值是 **riak_core_capability**，
原因是个 Erlang 错误：**no function clause matching orddict:fetch('riak@192.168.2.81', []) line 72**。

错误 | 消息
------|--------
 | gen_server `Mod` terminated with reason: `Reason`
 | gen_fsm `Mod` in state `State` terminated with reason: `Reason`
 | gen_event `ID` installed in `Mod` terminated with reason: `Reason`
badarg | bad argument in call to `Mod1` in `Mod2`
badarith | bad arithmetic expression in `Mod`
badarity | fun called with wrong arity of `Ar1` instead of `Ar2` in `Mod`
badmatch | no match of right hand value `Val` in `Mod`
bad_return | bad return value `Value` from `Mod`
bad_return_value | bad return value: `Val` in `Mod`
badrecord | bad record `Record` in `Mod`
case_clause | no case clause matching `Val` in `Mod`
emfile | maximum number of file descriptors exhausted, check ulimit -n
function_clause | no function clause matching `Mod`
'function not exported' | call to undefined function `Func` from `Mod` |
if_clause | no true branch found while evaluating if expression in `Mod`
noproc | no such process or port in call to `Mod`
{system_limit, {erlang, open_port}} | maximum number of ports exceeded
{system_limit, {erlang, spawn}} | maximum number of processes exceeded
{system_limit, {erlang, spawn_opt}} | maximum number of processes exceeded
{system_limit, {erlang, list_to_atom}} | tried to create an atom larger than 255, or maximum atom count exceeded
{system_limit, {ets, new}} | maximum number of Erlang Term Storage (ETS) tables exceeded
try_clause | no try clause matching `Val` in `Mod`
undef | call to undefined function `Mod`

### 错误 Atom

Erlang 是一种“happy path/fail fast”风格的语言，最常见的错误日志字符串之一
会包含 `{error,{badmatch`。这个字符串是 Erlang 使用的方式，用来告诉你赋给了不期望的值，
因此可以用在很多消息前面。在下面这个例子中，`{error,{badmatch` 放在了 `insufficient_vnodes_available` 错误前面。
这个例子来自本文后面的 riak_kv 表格。

```
2012-01-13 02:30:37.015 [error] <0.116.0> webmachine error: path="/riak/contexts"\
{error,{error,{badmatch,{error,insufficient_vnodes_available}},\
[{riak_kv_wm_keylist,produce_bucket_body,2},{webmachine_resource,resource_call,3},\
{webmachine_resour,resource_call,1},{webmachine_decision_core,decision,1},\
{webmachine_decision_core,handle_request,2},\
{webmachine_mochiweb,loop,1},{mochiweb_http,headers,5}]}}
```

## Erlang 错误

一旦 Riak 集群部署到生产环境就很难出错，不过很多初次接触 Riak 或 Erlang 的用户偶尔会在
初次安装时遇到错误。这些错误往往和 Erlang 本身无关，而是由于网络、权限或设置导致的。

错误    | 说明 | 解决办法
---------|-------------|-------
{error,duplicate_name} | 试图启动一个新 Erlang 节点，但同名的节点已经在运行了 | 可能是试图用相同的 `vm.args` `-name` 值在同一台电脑中启动多个节点。或者是因为节点已经运行了，可以查看 beam.smp。或者 epmd 认为 Riak 已经运行了，请查看或者终止 epmd
{error,econnrefused} | 远程 Erlang 节点拒绝连接 | 请确保集群已经上线，而且其中的节点可以相互通信。参照[脚注 1](/ops/running/recovery/errors/#f1)
{error,ehostunreach} | 无法连接到远程节点 | 请确保节点之间可以相互通信。参照[脚注 1](/ops/running/recovery/errors/#f1)
{error,eacces} | 无法写入指定文件 | 请确保 Riak beam 进程有权限写入 `app.config` 中的所有 `*_dir` 文件夹，例如 `ring_state_dir`、`platform_data_dir` 等
{error,enoent} | 缺少文件或文件夹 | 确保 `app.config` 中的所有 `*_dir` 都存在，例如 `ring_state_dir`、`platform_data_dir` 等
{error,erofs} | 试图写入一个只读文件系统的文件或文件夹 | 只在可读写的文件夹系统上使用 Riak
system_memory_high_watermark | 经常预示了 EST 表过大 | 检查你是否使用了一个合适的后台（如果键数量很多要使用 LevelDB），以及虚拟节点数量是否合理 （每个节点有十几个，而不是几百个）
temp_alloc | Erlang 试图分配内存 | 经常和“Cannot allocate X bytes of memory”错误有关，这意味着创建的对象太大了，或者是 RAM 容量不够用了。每个节点建议使用的 RAM 大小为 4GB

## Riak 错误和消息

很多 KV 错误都有规定的消息。针对这些情况，我们交由 Riak 来说明正确地做法。
例如，如果输入不合法，`map/reduce` `parse_input` 会显示如下错误：

<blockquote>Inputs must be a binary bucket, a tuple of bucket and key-filters, a list of target tuples, or a search, index, or modfun tuple: INPUT</blockquote>

其他的常见错误代码经常都由 Erlang atom 标记
（经常包含在 `{error,{badmatch,...}}` 元组中，如前一节所述）。下面的表格列出了常见的
错误代码以及相应的日志消息（如果有的话）。

### Riak Core

Riak Core 是 KV 的底层实现。下面列出的错误都是由这个框架导致的，可能会在
使用 KV，搜索功能或任何其他的核心实现时遇到。

错误    | 消息 | 说明 | 解决方法
---------|---------|-------------|-------
behavior | | 试图执行一个未知的行为 | 确保在 `app.config` 中选择了试图使用的行为，例如设置 LevelDB 使用 2i
already_leaving | *Node is already in the process of leaving the cluster.* | 把一个已经下线的节点标记为下线 | 没必要重复执行 `leave` 命令
already_replacement |  | 该节点已经在替换操作列表中 | 不能替换同一个节点两次
{different_owners, N1, N2} |  | 两个节点列出不同的分区所有者，意味着环还没准备好 | 环准备好就没事了
different_ring_sizes |  | 要合并的环和集群中现有的环大小不一样 | 不要把已经加入集群的节点再次加入集群
insufficient_vnodes_available |  | 创建查询覆盖计划时，没有足够可用的虚拟节点 | 查看 `riak-admin ring-status`，确保所有的节点都健康，而且已经连接
invalid_replacement |  | 节点正在前一个操作中进行合并，在合并完成之前无法进行替换操作 | 等待节点完成合并
invalid_ring_state_dir | *Ring state directory `RingDir` does not exist, and could not be created: `Reason`* | 环文件夹不存在，而且无法在指定位置创建新文件夹 | 确保 Erlang 进程可以写入 ring_state_dir，而且有权限创建这个文件夹
is_claimant |  | 节点无法处理删除自己的请求 | 要在另一个节点中删除、替换节点
is_up |  | 节点应该是下线的，但却处于上线状态 | 把节点标记为下线，就应该处于下线状态
legacy |  | 试图在一个过时的环上暂存计划 | 暂存功能只能在 Riak 1.2.0+ 中使用
max_concurrency | *Handoff receiver for partition `Partition` exited abnormally after processing `Count` objects: `Reason`* | 不允许移交进程数超过 `riak_core` `handoff_concurrency` 设置（默认为 2） | 如果出现这个问题时终止了虚拟节点，那么就和 LevelDB 的压缩有关，会阻止写入，这时还会显示 `Waiting....` 或 `Compacting`
{nodes_down, Down} |  | 所有节点必须都在线才能检查 |
not_member |  | 这个节点不是环的成员 | 如果不是环的成员，则无法离开、删除或下线节点
not_reachable |  | 不能合并无法连接的节点 | 检查网络连接，以及 Erlang cookie 设置 `vm.args` `-setcookie`
{not_registered, App} |  | 试图使用未注册的进程 | 确保 `app.config` 的设置选择了要使用的程序 `{riak_kv_stat, true}`
not_single_node |  | 没有合并的对象 | 至少要有两个节点才能合并
nothing_planned |  | 不能提交没有变动的计划 | 提交之前确保至少修改了一个环
only_member |  | 这个节点是环的唯一节点 | 如果节点是换的唯一节点，则无法离开、删除或下线
ring_not_ready |  | 环还没准备好，不能执行命令 | 环准备好之后才能计划对环的修改
self_join |  | 不能和自己合并 | 和其他节点合并才能组成合法的集群
timeout | *`Type` transfer of `Module` from `SrcNode` `SrcPartition` to `TargetNode` `TargetPartition` failed because of TCP recv timeout* |  | 确保 `app.config` 中设置的端口没有被系统或其他程序占用
unable_to_get_join_ring |  | 合并时无法连接到集群的环 | 有可能环已经损坏
{unknown_capability, Capability} |  | 试图使用不支持的功能 | 确保 `app.config` 设置中选择了要使用的功能
vnode_exiting | *`Mod` failed to store handoff obj: `Err`* |  | 虚拟节点无法移交数据，因为移交状态被删除了
vnode_shutdown |  |  虚拟节点的 worker 池关闭了 | 关闭的原因有很多，请查看日志消息
 | *Bucket validation failed `Detail`* |  | 只能设置 bucket 有的属性
 | *set_recv_data called for non-existing receiver* | 移交数据时无法连接到接收方 | 确保接收方仍然在线，而且正在运行
 | *An `Dir` handoff of partition `M` was terminated because the vnode died* | 移交停止了，因为虚拟节点处于下线状态，发送发一定是被终止运行了 | 移交过程中如果虚拟节点下线了就会看到这个消息。其他可能的原因请查看日志分析
 | *status_update for non-existing handoff `Target`* | 无法获取不存在的移交 `Target` 模块状态 | 预料之中的消息。查看日志分析原因
 | *SSL handoff config error: property `FailProp`: `BadMat`.* | 可能是接收方拒绝了发送发的移交请求 | 确保 SSL 和证书设置正确
 | *Failure processing SSL handoff config `Props`:`X`:`Y`* |  | 确保 SSL 和证书设置正确
 | *`Type` transfer of `Module` from `SrcNode` `SrcPartition` to `TargetNode` `TargetPartition` failed because of `Reason`* | 节点无法移交数据 | 确保集群在线，而且节点直接可以互相通讯。参照[脚注 1](/ops/running/recovery/errors/#f1)
 | *Failed to start application: `App`* | 无法加载想使用的应用程序 | 这和 Erlang 应用程序有关，基本不关 Riak 的事。应用程序基于某些原因无法加载，可能是缺少内建代码库。请查看其他日志消息寻找线索
 | *Failed to read ring file: `Reason`* | 说明为什么启动时无法读取环文件 | 给出的原因解释了这个问题，例如 `eacces`，意思是 Erlang 进程没有权限读
 | *Failed to load ring file: `Reason`* | 说明为什么启动时无法加载环文件 | 给出的原因解释了这个问题，例如 `enoent`，意思是无法找到要加载的文件
 | *ring_trans: invalid return value: `Other`* | 在节点之间转移坏数据时收到了一个不合法的值 | 经常是因为环损坏了，或者转移发送方以外退出了
 | *Error while running bucket fixup module `Fixup` from application `App` on bucket `BucketName`: `Reason`* |  | 导致修复错误的原因有很多，请阅读相关的错误信息
 | *Crash while running bucket fixup module `Fixup` from application App on bucket `BucketName` : `What`:`Why`* |  | 导致修复错误的原因有很多，请阅读相关的错误信息
 | *`Index` `Mod` worker pool crashed `Reason`* |  | 导致 worker 池损坏的原因有很多，请阅读相关的错误信息
 | *Received xfer_complete for non-existing repair: `ModPartition`* | 不合常规的修复消息 | 没什么可做的，节点一般不会收到 xfer_complete 状态

### Riak KV

Riak KV 是实现键值对的模块，一般都可说成 Riak。这个模块包含了 Riak 的大部分代码，因此也是经常会出错的地方。

错误    | 消息 | 说明 | 解决方法
---------|---------|-------------|-------
all_nodes_down |  | 没有可用的节点 | 查看 `riak-admin member-status` 命令的输出，确保所有期望使用的节点其状态是 `valid`
{bad_qterm, QueryTerm} |  | MapReduce 的查询语句不对 | 修正 MapReduce 查询语句
{coord_handoff_failed, Reason} | *Unable to forward put for `Key` to `CoordNode` - `Reason`* | 虚拟节点无法通讯 | 确保协调的虚拟节点没有下线。确保集群在线，而且节点之间可以相互通讯。参照[脚注 1](/ops/running/recovery/errors/#f1)
{could_not_reach_node, Node} |  | 无法访问 Erlang 进程 | 检查网络设置；确保远程节点正在运行，而且可以连接；确保所有节点的 Erlang cookie 设置（`vm.args` `-setcookie`）都一样。参照[脚注 1](/ops/running/recovery/errors/#f1)
{deleted, Vclock} |  | 值和当前的向量时钟都已经删除了 | Riak 最终会清理这个值
{dw_val_violation, DW} |  | 和 `w_val_violation` 错误一样，但关注持续写入操作 | 设置一个合法的持续写入值
{field_parsing_failed, {Field, Value}} | *Could not parse field `Field`, value `Value`.* | 无法解析索引字段 | 对大多数情况下是无法解析 _int 字段。例如，下面这个查询就是不合法的：invalid /buckets/X/index/Y_int/BADVAL，因为 BADVAL 应该是个整数
{hook_crashed, {Mod, Fun, Class, Exception}} | *Problem invoking pre-commit hook* | 由于某些操作失败导致 precommit 过程中止了 | 修正 precommit 函数的代码，根据消息和堆栈追溯查错
{indexes_not_supported, Mod} |  | 所用后台不支持索引（目前只有 LevelDB 支持 2i） | 在 `app.config` 设定使用 LevelDB
{insufficient_vnodes, NumVnodes, need, R} |  | R 的值设的比虚拟节点总数多 | 设定一个合适的 R 值。或者是因为太多的节点下线了。或者因为太多的节点损坏或者网络隔断导致无法连接。执行 `riak-admin ring-status` 命令，确保所有节点都可用
{invalid_hook_def, HookDef} | *Invalid post-commit hook definition `Def`* | 没有找到 Erlang 模块、方法，或者 JavaScript 函数名 | 使用正确地设置定义钩子
{invalid_inputdef, InputDef} |  | 运行 MapReduce 时，输入没定义好 | 修正输入设置；把 mapred_system 设置从 legacy 改为 pipe
invalid_message | | 未知事件发送到了模块 | 确保所有节点上使用的 Riak（特别是 poolboy）版本差不多
{invalid_range, Args} |  | 索引请求范围的开始值大于结束值 | 修正查询
{invalid_return, {Mod, Fun, Result}} | *Problem invoking pre-commit hook `Mod`:`Fun`, invalid return `Result`* | precommit 函数在指定 `Result` 时返回的结果不合法 | 确保 precommit 函数返回一个合法值
invalid_storage_backend | *storage_backend `Backend` is non-loadable.* | 启动 Riak 时选用了一个不合法的后台 | 在 `app.config` 中设定一个合法的后台（例如，{storage_backend, riak_kv_bitcask_backend}）
key_too_large |  | 键的长度大于 65536 字节 | 使用一个小一点儿的键
local_put_failed |  | 本地节点上的 PUT 操作失败 | 这个问题和 LevelDB 有关，因为限制了内存使用，而且无法写入硬盘。如果这个问题重复多次出现，请重启 Riak 节点，强制重新分配内存
{n_val_violation, N} |  | (W > N) 或 (DW > N) 或 (PW > N) 或 (R > N) 或 (PR > N) | W 或 R 的值都不能大于 N
{nodes_not_synchronized, Members} |  | 环的所有成员还没同步 | 如果节点之间没有同步，备份会失败
{not_supported, mapred_index, FlowPid} |  | MapReduce 的索引查询只支持 Pipe | 把 mapred_system 设置从 legacy 改为 pipe
notfound |  | 没有找到值 | 值被删除了，或者还没存储，或者会被建立副本
{pr_val_unsatisfied, PR, Primaries} |  | 和 `r_val_unsatisfied` 错误一样，但只计算 `Primary` 节点的回应 | 太多的主节点下线了，或者 `PR` 的值设的太大
{pr_val_violation, R} |  | 和 `r_val_violation` 错误一样，但只关注 `Primary` 的读取 | 设置一个合理的 `PR` 值
precommit_fail | *Pre-commit hook `Mod`:`Fun` failed with reason `Reason`* | 因为 `Reason` 导致 precommit 函数失败了 | 修正 precommit 函数的代码
{pw_val_unsatisfied, PR, Primaries} | | 和 `w_val_unsatisfied` 错误一样，但只计算 `Primary` 节点的回应 | 太多的主节点下线了，或者 `PR` 的值设的太大
{pw_val_violation, PW} |  | 和 `w_val_violation` 错误一昂，但关注 `Primary` 的写入 | 设置一个合理的 `PR` 值
{r_val_unsatisfied, R, Replies} |  | 没有足够的节点回应，无法满足 `R` 值，只收到了 `Replies` 个回应 | 太多的节点下线了，或者 `R` 的值设的太大
{r_val_violation, R} |  | 设定的 `R` 值不是数字，而且不合法（`one`, `all`, `quorum`） | 设置一个合理合法的 `R` 值
receiver_down |  | 远端进程无法响应请求 | 可能在调用 listkeys 时发生
{rw_val_violation, RW} |  | 设定的 `RW` 值不是数字，而且不合法（`one`, `all`, `quorum`） | 设置一个合理合法的 `RW` 值
{siblings_not_allowed, Object} | *Siblings not allowed: `Object`* | 索引钩子不接受兄弟数据 | 把 bucket 的 `allow_mult` 属性设为 `false`
timeout |  | 指定动作回应时间太长 | 确保集群在线，而且节点之间可以相互通讯。(参照[脚注 1](/ops/running/recovery/errors/#f1))或者检查是否设置了合理的 `ulimit` 值。注意 listkeys 命令很容易超时，不应该在生产环境中使用
{too_few_arguments, Args} |  | 索引查询至少需要一个参数 | 修正查询的格式
{too_many_arguments, Args} |  | 搜索查询被太多的参数破坏了 | 修正查询的格式
too_many_fails |  | 写入操作失败太多，无法满足 `W` 或 `DW` 值 | 试着再次写入。或者确保节点和网络的状况良好。或者设置小一点儿的 `W` 或 `DW` 值
too_many_results | | 要返回的值太多了 | 这是防护性错误。修改查询返回少一点结果，或者修改 `app.config` 中的 `max_search_results` 设置（默认为 100,000）
{unknown_field_type, Field} | *Unknown field type for field: `Field`.* | 未知的索引字段扩展（名字以下划线开头） | 合法的字段只有 _int 和 _bin
{w_val_unsatisfied, RepliesW, RepliesDW, W, DW} | | 响应的节点太少，无法满足 `W` 或 `DW` 值，只得到了 `Replies*` 个响应 | 下线的节点太多，或者 `W` 或 `DW` 的值设的太大
{w_val_violation, W} |  | 设定的 `W` 值不是数字，而且不合法（`one`,``all`, `quorum`) | 设置一个合法的 `W` 值
 | *Invalid equality query `SKey`* | 索引相等性查询必须使用二进制值 | 进行 2i 相等性查询时传入相等的值
 | *Invalid range query: `Min` -> `Max`* | 范围查询的上下限值都要指定，而且必须是二进制 | 进行 2i 范围查询时必须指定上下限两个值
 | *Failed to start `Mod` `Reason`:`Reason`* | 由于原因 `Reason`，Riak KV 无法启动 | 无法启动的原因有很多，请阅读给出的原因寻找解决办法

### 后台错误

以下错误是由于服务器导致的。后台对容量较低或者损坏的硬盘或内存，内部代码，节点之间的设置差异等相当敏感。相反地，网络问题很少会影响到后台。

错误    | 消息 | 说明 | 解决方法
---------|---------|-------------|-------
data_root_not_set | | 和 `data_root_unset` 错误一样 | 在设置文件中设定 `data_root` 文件夹
data_root_unset | *Failed to create bitcask dir: data_root is not set* | 必须设定 `data_root` 文件夹 | 在 `bitcask` 区中设置 `data_root`，这个文件夹是保存 Bitcask 数据的根目录
{invalid_config_setting, multi_backend, list_expected} | | 设置 `multi_backend` 时，要放在一个列表中 | 把 `multi_backend` 设置放在一个列表中
{invalid_config_setting, multi_backend, list_is_empty} | | 设置 `multi_backend` 时，要指定一个值 | `multi_backend` 设置中至少要包含一个后台
{invalid_config_setting, multi_backend_default, backend_not_found} | | | 设置 `multi_backend_config_unset` 时必须选择一个合法的后台类型
multi_backend_config_unset | | 没有设置 `multi_backend` | `multi_backend` 设置中至少要包含一个后台
not_loaded | | 内建驱动未加载 | 确保驱动存在（.dll 或 .so 文件）
{riak_kv_multi_backend, undefined_backend, BackendName} | | bucket 使用的后台不合法 | 使用 bucket 之前，在 lib/`project`/priv 中定义一个合法的后台，其中 `project` 大多数情况下是 leveldb
reset_disabled | | 试图在生产环境中重设内存后台 | 不要在生产环境中执行这个操作

### JavaScript

有些错误和 JavaScript pre-commit 函数、map/reduce 函数，或管理 JavaScript VM 的
进程池有关。如果不适用 JavaScript 就不会遇到这些问题；如果遇到了，
请把 `*js_vm*` 设置高一点，或者只是某些问题的副作用，例如资源紧张。

错误    | 消息 | 说明 | 解决方法
---------|---------|-------------|-------
no_vms | *JS call failed: All VMs are busy.* | 所有 JavaScript VM 都在使用中 | 等一会儿在运行；提高 `app.config` 设置中 JavaScript VM 相关设置的值（`map_js_vm_count`、`reduce_js_vm_count` 或 `hook_js_vm_count`）
bad_utf8_character_code | *Error JSON encoding arguments: `Args`* | UTF-8 字符的编码不正确 | JavaScript 代码和参数只使用正确地 UTF-8 字符
bad_json | | Bad JSON formatting | 在 JavaScript 命令参数中只使用正确的 JSON 格式
 | *Invalid bucket properties: `Details`* | 如果属性不合法，则无法列出 bucket 的全部属性 | 修正 bucket 的属性
{load_error, "Failed to load spidermonkey_drv.so"} | | JavaScript 驱动损坏，或者丢失 | 在 OS X 中应该使用 `llvm-gcc` 编译，而不是 `gcc`

### MapReduce

这些错误实在使用 Riak 的 MapReduce 时可能遇到的，不过用的是以前的 MapReduce 还是 Pipe。
如果从不使用 MapReduce，则不会遇到这些问题。

错误    | 消息 | 说明 | 解决方法
---------|---------|-------------|-------
bad_mapper_props_no_keys | | 默认情况下，至少应该找到一个属性 *Riak 1.3+ 中未用到* | 设置 mapper 属性，或者干脆不用
bad_mapred_inputs | | 发送给 MapReduce 一个错误值 *Riak 1.3+ 中未用到* | 使用 Erlang 客户端接口时，确保所有的 MapReduce 和搜索查询都是正确的二进制
bad_fetch | | 没有取回一个期望得到的本地查询 *Riak 1.3+ 中未用到* | 要先把 javascript MapReduce 查询作为 Riak 值使用，必须先存储才能执行查询
{bad_filter, `Filter`} | | 使用了一个非法的 keyfilter | 确保 MapReduce keyfilter 是正确的
{dead_mapper, `Stacktrace`, `MapperData`} | | 某个事物从 mapper 得到的回应已经存在 *Riak 1.3+ 中未用到* | 检查被卡住的 Erlang 进程；如果使用旧的 MapReduce，确保设置了 `map_cache_size`（这两个解决方法都要重启节点）
{inputs, Reason} | *An error occurred parsing the "inputs" field.* | MapReduce 请求的输入字段不合法 | 修正 MapReduce 字段
{invalid_json, Message} | *The POST body was not valid JSON. The error from the parser was: `Message`* | 在 MapReduce 中进行 POST 请求要使用正确的 JSON 格式 | 使用正确的 MapReduce 请求格式
javascript_reduce_timeout | | JavaScript reduce 函数用时过长 | 如果对象数量很多，JavaScript 函数可能会成为瓶颈。减少传入以及从 reduce 函数 返回的值数量，或者用 Erlang 重写这个函数
missing_field | *The post body was missing the "inputs" or "query" field.* | 必须制定输入字段或查询字段 | 进行 MapReduce POST 请求时至少指定一个字段
{error,notfound} | | 在 mapping 阶段用来代替 RiakObject | 自定义的 Erlang map 函数应该要能处理这种类型的值
not_json | *The POST body was not a JSON object.* | 进行 MapReduce POST 请求时必须使用正确的 JSON 格式 | 使用正确的 MapReduce 请求格式
{no_candidate_nodes, exhausted_prefist, `Stacktrace`, `MapperData`} | | 某些 map phase workers 终止运行了 | 或许某个长时间运行的任务超时了，请升级到 Pipe
{'query', Reason} | *An error occurred parsing the "query" field.* | MapReduce 请求的查询字段不合法 | 修正 MapReduce 查询
{unhandled_entry, Other} | *Unhandled entry: `Other`* | reduce_identity 函数未用到 | 如果不适用 reduce_identity，就别设置 reduce phase
{unknown_content_type, ContentType} | | MapReduce 查询的内容不正确 | 只接受 `application/json` 和 `application/x-erlang-binary`
 | *Phase `Fitting`: `Reason`* | 使用 Pipe MapReduce 时，如果制定了错误的参数，或设置错误，一般都会看到这个消息 | 可能是由不正确的 map 或 reduce 导致的。最近发现，如果 JavaScript 函数没有正确处理顽固的对象，也会看到这个消息
 | *riak_kv_w_reduce requires a function as argument, not a `Type`* | reduce 需要一个函数对象，而不是其他类型 | 不可能发生
 
## 特殊的消息

虽然可以通过上面几个表格找到很多错误，但也有一些不常见，而且很难理解的消息，但却知道原因和解决方法。

 消息 | 解决方法
---------|-----------
gen_server riak_core_capability terminated with reason: no function clause matching orddict:fetch('`Node`', []) | 节点发生了变动而没有通知环，修改了 IP 或者 `vm.args` `-name`。 执行 `riak-admin cluster replace` 命令，或者删除过时的 `rm -rf /var/lib/riak/ring/*` 文件，然后重新合并组成集群
gen_server <`PID`> terminated with reason: no function clause matching riak_core_pb:encode(`Args`) line 40 | 确保不同的节点没有使用不同的设置（例如，一个节点的 mem 后台设置了 ttl mem，而另一节点没有）
monitor `busy_dist_port` `Pid` [...{almost_current_function,...] | 这个消息的意思是，分布式 Erlang 缓冲用完了。尝试把 `vm.args` 中的 zdbbl 设的高一点，例如 `+zdbbl 16384`。或者确认一下网络不慢。喝着确认没有为大的值创建兄弟数据。如果带宽很大却阻塞了，请把 RTO_min 设为 0 毫秒（或 1 毫秒）
<`PID`>@riak_core_sysmon___handler:handle_event:89 Monitor got {suppressed,port_events,1} | 可以把 `+swt very_low` 添加到`vm.args`
(in LevelDB LOG files) Compaction error | 停止节点，在 LevelDB 分区上进行修复。参照[脚注 2](/ops/running/recovery/errors/#f2)
enif_send: env==NULL on non-SMP VM/usr/lib/riak/lib/os_mon-2.2.9/priv/bin/memsup: Erlang has closed. | Riak 的 Erlang VM 支持 SMP，如果 Riak 运行在一个不支持 SMP 的系统上，就会出现类似错误。这个消息经常出现在只用一个 CPU 核心的虚拟环境中。
exit with reason bad return value: {error,eaddrinuse} in context start_error | 这个错误可能是因为要使用的 IP 地址已经绑定到其他进程上了。使用操作系统提供的 `netstat`、`ps` 和 `lsof` 工具找到导致这个问题的根本原因。检查是否存在过期的 `beam.smp` 进程。
exited with reason: eaddrnotavail in gen_server:init_it/6 line 320 | 这个问题可能是应为 Riak 无法绑定到设置中指定的 IP 地址。这时，应该检查 `app.config` 中的 HTTP 和 Protocol Buffers 地址，确保所用的端口不在特殊的 1-1024 这个范围内，因为用户 `riak` 无权使用这些端口
gen_server riak_core_capability terminated with reason: no function clause matching orddict:fetch('riak@192.168.2.2', []) line 72 | 这个问题可能是因为只修改了 `vm.args` 中的 `-name` 值，而没有使用 `riak-admin cluster replace` 命令
** Configuration error: [FRAMEWORK-MIB]: missing context.conf file => generating a default file | 这个问题经常出现在没有设置 SNMP 就启动了 Riak 企业版
RPC to 'node@example.com' failed: {'EXIT', {badarg, [{ets,lookup, [schema_table,<<"search-example">>], []} {riak_search_config,get_schema,1, [{file,"src/riak_search_config.erl"}, {line,69}]} ...| 这个问题可能是由于没有在节点的 `app.config` 启用就使用了搜索功能。请阅读 [[Configuration Files]] 一文，查看如何启用 Riak 搜索。

### 脚注

1. <a name="f1"></a>确认节点之间的通讯
  - 执行 `riak-admin member-status` 命令，确保集群是可用的
  - 执行 `riak-admin ring-status` 命令，确保环和虚拟节点直接可以正常通讯
  - 确保电脑没有防火墙，或者任何能阻碍和远程节点通信的而设置
  - 远程集群中的节点 `vm.args` `-setcookie` 设置必须一样
  - 节点合并后一定不能修改 `vm.args` `-name` 的值（除非使用 `riak-admin cluster replace` 命令）

2. <a name="f2"></a>进行 LevelDB 压缩
  1. 运行 `find . -name "LOG" -exec grep -l 'Compaction error' {} \;` *（如果得到一个压缩错误还好，多了的话就说明硬件或操作系统有问题）*
  2. 停止该节点：`riak stop`
  3. 启动 Erlang 会话（不要启动 Riak，我们只要用 Erlang）
  4. 在 Erlang 控制台中执行下面的命令，打开 LevelDB 数据库

        ```erlang
        [application:set_env(eleveldb, Var, Val) || {Var, Val} <-
        [{max_open_files, 2000},
        {block_size, 1048576},
        {cache_size, 20*1024*1024*1024},
        {sync, false},
        {data_root, "/var/db/riak/leveldb"}]].
        ```
  5. 在没有损坏的 LevelDB 数据库（通过 `find . -name "LOG" -exec` | `grep -l 'Compaction error' {} \;` 命令查找）中执行下面的命令，要指定正确的虚拟内存数量

        ```erlang
        eleveldb:repair("/var/db/riak/leveldb/442446784738847563128068650529343492278651453440", []).
        ```
  6. 上述操作成功完成后，重启节点：`riak start`
  7. 查看 /var/log/riak 和 LevelDB 虚拟节点中的日志文件，确认操作是否成功
