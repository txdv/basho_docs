---
title: 修复索引
project: riak
version: 1.4.2+
document: tutorial
toc: true
audience: advanced
keywords: [kv, 2i, troubleshooting]
---

Riak 二级索引（2i）目前没有任何形式的“反熵”（anti-entropy）功能（例如，读取修复）。而且，为了性能呢过和负载平衡，2i 会从一个随机的节点读取数据。也就是说，如果某个副本丢失了，就会导致结果的不一致性。

## 进行修复

如果副本丢失了，要进行修复。修复时会从环中的毗邻分区修复对象，进而修复索引。

修复的过程很高效，为所有 bucket 生成哈希范围，这样就能避免对每一个键进行 preflist 计算。只要有键的哈希值即可，这个范围由 bucket->rang 映射决定，然后检查键的哈希是否落在这个范围内。

下面的方法可以强制重新读取节点上每个分区中的所有键，因此可以重建索引。

1. 在安装了 Riak 的节点上执行下面的命令，打开 Riak 控制台：From a cluster node with Riak installed, attach to the Riak console:

    ```bash
    $ riak attach
    ```

    可能要再次回车才能看到终端提示符。

2. 获取该节点拥有的需要修复的分区列表

    ```erlang
    > {ok, Ring} = riak_core_ring_manager:get_my_ring().
    ```

    会看到很多输出，显示环记录信息。直接忽略这些输出即可。

3. 然后运行下面的代码获取分区列表。把 'dev1@127.0.0.1' 换成需要修复的节点名。

    ```erlang
    > Partitions = [P || {P, 'dev1@127.0.0.1'} <- riak_core_ring:all_owners(Ring)].
    ```

    _注意：上面的代码是 [Erlang 列表推导](http://www.erlang.org/doc/programming_examples/list_comprehensions.html)，遍历环中每一个 `{Partition, Node}` 元组，只取出和制定节点名一样的分区，存入一个列表中。_

4. 在所有分区上进行修复操作。一次全部执行会导致很多 `{shutdown,max_concurrency}` 提示，不过无需担心，这只是因为转移机制强制执行了一个比并发事务上限值更大的值。

    ```erlang
    > [riak_kv_vnode:repair(P) || P <- Partitions].
    ```
5. 操作完成后，按 `Ctrl-D` 退出控制台。不要运行 `q()`，这会停止正在运行的节点。注意，`Ctrl-D` 只是断开和控制台的连接，不会阻止代码的运行。

## 查看修复进度

上述修复过程可能很慢，如果再次连接控制台，可以运行 `repair_status` 函数。可以使用上面定义的 `Partitions` 变量，查看每个分区的状态。

```erlang
> [{P, riak_kv_vnode:repair_status(P)} || P <- Partitions].
```

完成后按 `Ctrl-D` 退出控制台。

## 终止修复

目前没有简单的方法可以终止单个修复操作，只能终止节点上进行的所有修复操作，即在修复的节点上执行 `riak_core_vnode_manager:kill_repairs(Reason)`。这意味着，你要打开节点的控制台，或者通过 `rpc` 模块进行远程调用。下面的例子说明如何在本地节点上终止所有的修复操作。

```erlang
> riak_core_vnode_manager:kill_repairs(killed_by_user).
```

日志条文会证明修复操作已经终止：

```
2012-08-10 10:14:50.529 [warning] <0.154.0>@riak_core_vnode_manager:handle_cast:395 Killing all repairs: killed_by_user
```

下面这个例子说明如何进行远程调用。

```erlang
> rpc:call('dev1@127.0.0.1', riak_core_vnode_manager, kill_repairs, [killed_by_user]).
```

完成后，按 `Ctrl-D` 退出控制台。

在所有权变更时禁止进行修复操作。因为所有权变更需要移动分区数据，所以最好这两个操作最好不要有任何交集。如果合并或删除节点，整个集群中的修复操作都会终止。

----

# 修复搜索索引

Riak 搜索索引目前没有任何形式的“反熵”（anti-entropy）功能（例如，读取修复）。而且，为了性能呢过和负载平衡，搜索会从一个随机的节点读取数据。也就是说，如果某个副本丢失了，就会导致结果的不一致性。

## 进行修复

如果副本丢失了，要进行修复。修复时会从环中的毗邻分区修复对象，进而修复索引。

修复的过程很高效，为所有 bucket 生成哈希范围，这样就能避免对每一个键进行 preflist 计算。只要有键的哈希值即可，这个范围由 bucket->rang 映射决定，然后检查键的哈希是否落在这个范围内。

下面的方法可以强制重新读取节点上每个分区中的所有键，因此可以重建索引。

1. 在安装了 Riak 的节点上执行下面的命令，打开 Riak 控制台：From a cluster node with Riak installed, attach to the Riak console:

    ```bash
    $ riak attach
    ```

    可能要再次回车才能看到终端提示符。

2. 获取该节点拥有的需要修复的分区列表

    ```erlang
    > {ok, Ring} = riak_core_ring_manager:get_my_ring().
    ```

    会看到很多输出，显示环记录信息。直接忽略这些输出即可。

3. 然后运行下面的代码获取分区列表。把 'dev1@127.0.0.1' 换成需要修复的节点名。

    ```erlang
    > Partitions = [P || {P, 'dev1@127.0.0.1'} <- riak_core_ring:all_owners(Ring)].
    ```

    _注意：上面的代码是 [Erlang 列表推导](http://www.erlang.org/doc/programming_examples/list_comprehensions.html)，遍历环中每一个 `{Partition, Node}` 元组，只取出和制定节点名一样的分区，存入一个列表中。_

4. 在所有分区上进行修复操作。一次全部执行会导致很多 `{shutdown,max_concurrency}` 提示，不过无需担心，这只是因为转移机制强制执行了一个比并发事务上限值更大的值。

    ```erlang
    > [riak_kv_vnode:repair(P) || P <- Partitions].
    ```
5. 操作完成后，按 `Ctrl-D` 退出控制台。不要运行 `q()`，这会停止正在运行的节点。注意，`Ctrl-D` 只是断开和控制台的连接，不会阻止代码的运行。

## 查看修复进度

上述修复过程可能很慢，如果再次连接控制台，可以运行 `repair_status` 函数。可以使用上面定义的 `Partitions` 变量，查看每个分区的状态。

```erlang
> [{P, riak_kv_vnode:repair_status(P)} || P <- Partitions].
```

完成后按 `Ctrl-D` 退出控制台。

## 终止修复

目前没有简单的方法可以终止单个修复操作，只能终止节点上进行的所有修复操作，即在修复的节点上执行 `riak_core_vnode_manager:kill_repairs(Reason)`。这意味着，你要打开节点的控制台，或者通过 `rpc` 模块进行远程调用。下面的例子说明如何在本地节点上终止所有的修复操作。

```erlang
> riak_core_vnode_manager:kill_repairs(killed_by_user).
```

日志条文会证明修复操作已经终止：

```
2012-08-10 10:14:50.529 [warning] <0.154.0>@riak_core_vnode_manager:handle_cast:395 Killing all repairs: killed_by_user
```

下面这个例子说明如何进行远程调用。

```erlang
> rpc:call('dev1@127.0.0.1', riak_core_vnode_manager, kill_repairs, [killed_by_user]).
```

完成后，按 `Ctrl-D` 退出控制台。

在所有权变更时禁止进行修复操作。因为所有权变更需要移动分区数据，所以最好这两个操作最好不要有任何交集。如果合并或删除节点，整个集群中的修复操作都会终止。
