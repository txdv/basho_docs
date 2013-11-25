---
title: riak-admin 命令
project: riak
version: 1.4.2+
document: reference
toc: true
audience: beginner
keywords: [command-line, riak-admin]
---

# riak-admin

`riak-admin` 用来处理和节点运行状态无关的操作，包括节点的成员，备份和基本状态。大多数命令都要求节点处于运行状态。对大多数子命令来说，节点必须处于运行状态。

```
Usage: riak-admin { cluster | join | leave | backup | restore | test |
                    reip | js-reload | erl-reload | wait-for-service |
                    ringready | transfers | force-remove | down |
                    cluster-info | member-status | ring-status | vnode-status |
                    diag | status | transfer-limit | top }
```

## cluster

从 Riak 1.2 开始，Riak 为集群提供了分步管理方式，先把变动暂存，然后审查，最后再提交。

使用这种方式可以把多个变动放在一起，例如一次添加多个节点，或者添加一些节点删除一些节点。

这种新方式可以提供一系列暂存的变动如何影响集群的详细信息，可以列出未来的环所有权，以及要实现这些变动需要进行的转移次数。

下面的命令把变动暂存在集群的成员中。这些命令不会立即产生效果。变动暂存后必须提交才能生效。

## cluster join

把 &lt;node&gt; 和集群中的节点合并。

```bash
riak-admin cluster join <node>
```

## cluster leave

把节点中的数据分区移交出去，从集群中删除并停止运行。

```bash
riak-admin cluster leave
```

把 &lt;node&gt; 中的数据分区移交出去，从集群中删除并停止运行。

```bash
riak-admin cluster leave <node>
```

## cluster force-remove

不移交数据分区，直接把 &lt;node&gt; 从集群中删除。这个命令适用于损坏无法恢复的节点，使用时要小心。

```bash
riak-admin cluster force-remove <node>
```

## cluster replace

把 &lt;node1&gt; 中的所有数据分区转移到  &lt;node2&gt;，然后把  &lt;node1&gt; 从集群中删除并停止运行。

```bash
riak-admin cluster replace <node1> <node2>
```

## cluster force-replace

不移交数据，直接把 &lt;node1&gt; 的所有分区转移到 &lt;node2&gt;，然后把 &lt;node1&gt; 从集群中删除。

```bash
riak-admin cluster force-replace <node1> <node2>
```

### 暂存命令

下列命令用来暂存变动。

#### cluster plan

显示目前暂存的变动。

```bash
riak-admin cluster plan
```

#### cluster clear

清除目前暂存的集群变动。

```bash
riak-admin cluster clear
```

#### cluster commit

提交目前暂存的集群变动。在提交之前，必须先执行 `riak-admin cluster plan` 命令审查变动。

```bash
riak-admin cluster commit
```

## join

<div class="note">
<div class="title">弃用说明</title></div>
<p>从 Riak 1.2 开始，<tt>riak-admin join</tt> 弃用，换成了 [[riak-admin cluster join|riak-admin 命令#cluster-join]] 命令。不过，如果指定 <tt>-f</tt> 选项还可以继续使用 <tt>riak-admin join</tt> 命令。</p>
</div>

合并两个运行中的节点，组成集群。

* &lt;node&gt; 是要连接的另一个节点。

```bash
riak-admin join -f <node>
```

## leave

<div class="note">
<div class="title">弃用说明</title></div>
<p>从 Riak 1.2 开始，<tt>riak-admin leave</tt> 弃用，换成了 [[riak-admin cluster leave|riak-admin 命令#cluster-leave]] 命令。不过，如果指定 <tt>-f</tt> 选项还可以继续使用 <tt>riak-admin leave</tt> 命令。</p>
</div>

从所在集群中删除节点。执行这个命令后，要删除的节点中所有的副本都会移交到集群中的其他节点，然后才被完全删除。

```bash
riak-admin leave -f
```

## backup

把节点或整个集群中数据备份到一个文件中。

* &lt;node&gt; 是在其上执行备份操作的节点名字
* &lt;cookie&gt; 是用来连接到节点的 Erlang cookie 或共享密匙。[[默认设置|设置文件#\-setcookie]]为“riak”
* &lt;filename&gt; 是存储备份数据的文件。应该指定文件的完整路径
* [node|all] 指定要备份所在节点还是整个集群的数据

```bash
riak-admin backup <node> <cookie> <filename> [node|all]
```

## restore

从备份中恢复节点或集群。

* &lt;node&gt; 是在其上执行恢复操作的节点名字
* &lt;cookie&gt; 是用来连接到节点的 Erlang cookie 或共享密匙。[[vm.args|设置文件#vm.args]] 文件中的默认值是 “riak”
* &lt;filename&gt; 是存储备份数据的文件。应该指定文件的完整路径

```bash
riak-admin restore <node> <cookie> <filename>
```

## test

在节点中运行一系列 Riak 标准操作进行测试。

```
riak-admin test
```

## reip

_这个命令未来极有可能会删除。请使用 `riak-admin cluster replace`。_

这个命令的最用是重命名节点。在这个过程中会备份环的状态。**要想操作成功，节点一定不能处于运行状态。**

```bash
riak-admin reip <old nodename> <new nodename>
```

## js-reload

强制内嵌的 JavaScript 虚拟机重启。这个命令在部署新的自定义 [[MapReduce|使用 MapReduce]] 功能是很有用。（ _这个命令要在集群中所有节点上运行。_ ）

```bash
riak-admin js-reload
```

## services

列出节点上可用的服务。（例如 **riak_kv**）

```bash
riak-admin services
```

## wait-for-service

等待所关注的服务可用（一般是 _riak_kv_）。这个命令在集群负载未满时启动或重启节点时很有用。执行 `services` 命令可以查看节点上可用的服务。

```
riak-admin wait-for-service <service> <nodename>
```

## ringready

检查集群中所有节点是否都使用了同一个环状态。如果不相同，会显示“FALSE”。在集群成员变动后，检查环状态是否安置时很有用。

```bash
riak-admin ringready
```

## transfers

识别等待转移一个或多个分区的节点。这种情况一般发生在改变分区所有权（添加或删除节点）或还原节点后。

```bash
riak-admin transfers
```

## transfer-limit

修改 handoff_concurrency 限制值。

```bash
riak-admin transfer-limit <node> <limit>
```

## force-remove

<div class="note">
<div class="title">弃用说明</div>
<p>从 Riak 1.2 开始，<tt>riak-admin force-remove</tt> 弃用，换成了 [[riak-admin cluster force-remove|riak-admin 命令#cluster-force-remove]] 命令。不过，如果指定 <code>-f</code> 选项，还可以继续使用 <tt>riak-admin force-remove</tt> 命令。</p>
</div>

不移交副本，直接从集群中删除节点。这个命令很危险，适用于常规、安全的删除方法无法使用的情况，例如要删除的节点出现了硬件问题，无法恢复。使用这个命令会导致要删除的节点上所有数据都丢失，必须使用其他方法，例如[[读取修复|副本#Read-Repair]]，进行复原。只要可以，就建议使用 [[riak-admin leave|riak-admin 命令#leave]] 命令。

```bash
riak-admin force-remove -f <node>
```

## down

把节点标记为下线状态，这样在重新上线之前可以进行环转换操作。

```bash
riak-admin down <node>
```

## cluster-info

显示 Riak 集群的信息。这个命令会收集集群中所有节点或部分节点的信息，然后把结果输出到一个文本文件中。

这个命令会输出以下信息：

 * 当前时间和日期
 * VM 统计数据
 * erlang:memory() 概况
 * 前 50 个占用内存最多的进程
 * 注册的进程名字
 * 使用 regs() 注册的进程名字
 * 收件箱大小
 * 端口
 * 程序
 * 计时器状态
 * ETS 概况
 * 节点概况
 * net_kernel 概况
 * inet_db 概况
 * 警报概况
 * 全局概况
 * erlang:system_info() 概况
 * 加载的模块
 * Riak Core 设置文件
 * Riak Core 虚拟节点模块
 * Riak Core 环
 * Riak Core 最新的环文件
 * Riak Core 激活的分区
 * Riak KV 状态
 * Riak KV 环准备状态
 * Riak KV 转移

```bash
riak-admin cluster_info <output file> [<node list>]
```

示例：

```bash
# Output information from all nodes to /tmp/cluster_info.txt
riak-admin cluster_info /tmp/cluster_info.txt
```

```
# Output information from the current node
riak-admin cluster_info /tmp/cluster_info.txt local
```

```bash
# Output information from a subset of nodes
riak-admin cluster_info /tmp/cluster_info.txt riak@192.168.1.10
riak@192.168.1.11
```

## member-status

输出集群全部成员的当前状态。

```bash
riak-admin member-status
```

## ring-status

输出当前集群的状态，环准备状态，待进行的所有权移交，以及无法访问的节点列表。

```bash
riak-admin ring-status
```

## vnode-status

输出本地节点上所有虚拟节点的状态。

```bash
riak-admin vnode-status
```

{{#1.3.0+}}
## aae-status

这个命令会详细说明 Riak Active Anti Entropy（AAE）功能的操作。

```
riak-admin aae-status
```

这个命令会输出关于 AAE 键值对分区交换、构建熵树和由 AEE 导致的键修复等信息。

* **交换**
 * *Last* 列显示最近一次分区和兄弟副本交换的时间
 * *All* 显示分区和所有兄弟副本交换持续了多长时间

* **熵树**
 * *Built* 列显示指定分区的哈希树是什么时候创建的

* **键修复**
 * *Last* 列显示最近一次键交换时修复的键数量
 * *Mean* 列显示自上一次节点启动以来，所有键交换时修复的键数量均值
 * *Max* 列显示自上一次节点启动以来，所有键交换时修复的键数量最大值

<div class="info">
所有 AAE 状态信息都储存在内存中，节点重启后会重设。只有构建树的时间会永久保存（因为树本身就会永久保存）。
</div>

`aae-status` 命令更详细的说明可以阅读 [Riak 1.3 的发布说明](https://github.com/basho/riak/blob/1.3/RELEASE-NOTES.md#active-anti-entropy)。
{{/1.3.0+}}

## diag

诊断 &lt;node&gt;。{{#<1.3.0}}必须先安装 [riaknostic](http://riaknostic.basho.com/) 才能执行这个命令。{{/<1.3.0}}

```bash
riak-admin diag <check>
```

## status

显示状态信息，包括性能统计、系统健康信息和版本数字。必须在[[设置文件|设置文件#riak_kv_stat]]中启用才能使用这个命令。关于这个命令的输出，请阅读[[这篇文章|检查节点]]。

```bash
riak-admin status
```

{{#1.3.1+}}
## reformat-indexes

这个命令会在 Riak 1.3.1 之前版本中重建二级索引的整数索引，这样范围查询才能返回正确地结果。

```
riak-admin reformat-indexes [<concurrency>] [<batch size>] --downgrade
```

`concurrency` 选项的默认值是 *2* ，设定并发重建索引的分区数量。

`batch size` 选项设定同时进行的键操作数量，默认值为 *100* 。

这个命令可以在节点接受请求时执行，大多数情况下，选项的值都建议使用默认值。只有测试对集群性能的影响时才应该修改默认值。

命令完成后会把结果写到 `console.log` 中。

`--downgrade` 用来把节点所用 Riak 的版本降级 到 1.3.1 之前的版本。

更多信息请阅读 [Riak 1.3.1 的发布说明](https://github.com/basho/riak/blob/1.3/RELEASE-NOTES.md)。
{{/1.3.1+}}

## top

这个命令可以显示 Riak 中 Erlang 进程正在做什么，包括进程还原（CPU 利用率的指标之一），内存用量和消息队列的大小。

```bash
riak-admin top
```
