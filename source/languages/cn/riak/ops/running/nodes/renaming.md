---
title: Renaming Nodes
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator]
---

在 Riak 1.2 之前，修改节点的 IP 地址要使用 `[[riak-admin reip|riak-admin Command Line#reip]]` 命令，
需要把整个集群停掉。

从 Riak 1.2 开始，这个命令被 `[[riak-admin cluster force-replace|riak-admin Command Line#cluster-force-replace]]` 命令
取代了，这个命令更安全，而且不需要把整个集群都停掉。

下面的例子介绍了如何使用 `riak-admin cluster force-replace`  命令修改节点的 IP 地址。

## 示例

对这个例子来说，Riak 集群中有 5 个节点，网络设置如下：

* `node1.localdomain` 上的 `riak@10.1.42.11`
  &rarr; IP 地址改为 192.168.17.11
* `node2.localdomain` 上的 `riak@10.1.42.12`
  &rarr; IP 地址改为 192.168.17.12
* `node3.localdomain` 上的 `riak@10.1.42.13`
  &rarr; IP 地址改为 192.168.17.13
* `node4.localdomain` 上的 `riak@10.1.42.14`
  &rarr; IP 地址改为 192.168.17.14
* `node5.localdomain` 上的 `riak@10.1.42.15`
  &rarr; IP 地址改为 192.168.17.15

上面的列表显示了 5 个节点的详细网络设置，包括 Erlang 的节点名字，节点的完全限定域名，以及
每个节点要换用的 IP 地址。

这个例子中的集群，现在使用的是 *10.1.42.* 内部子网。我们的目的是要把节点的 IP 地址
换到 *192.168.17.* 内部子网上，而且整个过程无需停机。

## 过程

整个修改过程分三步。每一步的详细操作如下所示。

1. [[停止要修改的节点|Renaming-Nodes#down]]
2. [[设置节点使用新地址|Renaming-Nodes#reconfigure]]
3. [[在每个节点中重复上面两步|Renaming-Nodes#repeat]]


<a id="down"></a>
### 停止节点

停止 `node1.localdomain` 上的节点：

```
riak stop
```

上述命令的输出如下：

```
Attempting to restart script through sudo -H -u riak
ok
```

**在 `node2.localdomain` 节点上**，把 `riak@10.1.42.11` 标记为下线：

```
riak-admin down riak@10.1.42.11
```

成功下线后会看到如下输出：

```
Attempting to restart script through sudo -H -u riak
Success: "riak@10.1.42.11" marked as down
```

这一步的作用是把 `riak@10.1.42.11` 节点下线，允许转义环状态。这里 `riak-admin down` 命令
是在 `node2.localdomain` 节点中执行的，其实可以在任一节点中执行。

<a id="reconfigure"></a>
### 设置节点使用新地址

按照下面的步骤操作，让 `node1.localdomain` 节点监听新的内网 IP *192.168.17.11*：

1. 编辑该节点的 `vm.args` 设置文件，把 `-name` 参数设置为：

        -name riak@192.168.17.11

2. 在 `app.config` 文件中把相应的 IP 地址改为 *192.168.17.11*，即 `pb_ip`、`http`、`https` 和 `cluster_mgr` 设置。

3. 重命名该节点的 `ring` 文件夹。该文件夹的位置可在 `app.config` 文件中查看。

4. 启动 `node1.localdomain` 上的节点

        riak start

5. 把该节点重新加入集群

        riak-admin cluster join riak@10.1.42.12

     上述命令成功后回看到如下输出：

        Attempting to restart script through sudo -H -u riak
        Success: staged join request for 'riak@192.168.17.11' to 'riak@10.1.42.12'

6. 执行 `riak-admin cluster force-replace` 命令，把所有权从 `riak@10.1.42.11` 改成 `riak@192.168.17.11`：

        riak-admin cluster force-replace riak@10.1.42.11 riak@192.168.17.11

     上述命令成功后会看到如下输出：

        Attempting to restart script through sudo -H -u riak
        Success: staged forced replacement of 'riak@10.1.42.11' with 'riak@192.168.17.11'

7. 执行 `riak-admin cluster plan` 命令审查计划：

        riak-admin cluster plan

     输出结果如下：

        Attempting to restart script through sudo -H -u riak
        =========================== Staged Changes ============================
        Action         Nodes(s)
        -----------------------------------------------------------------------
        join           'riak@192.168.17.11'
        force-replace  'riak@10.1.42.11' with 'riak@192.168.17.11'
        -----------------------------------------------------------------------

        WARNING: All of 'riak@10.1.42.11' replicas will be lost

        NOTE: Applying these changes will result in 1 cluster transition

        #######################################################################
                             After cluster transition 1/1
        #######################################################################

        ============================= Membership ==============================
        Status     Ring    Pending    Node
        -----------------------------------------------------------------------
        valid      20.3%      --      'riak@192.168.17.11'
        valid      20.3%      --      'riak@10.1.42.12'
        valid      20.3%      --      'riak@10.1.42.13'
        valid      20.3%      --      'riak@10.1.42.14'
        valid      18.8%      --      'riak@10.1.42.15'
        -----------------------------------------------------------------------
        Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0

        Partitions reassigned from cluster changes: 13
        13 reassigned from 'riak@10.1.42.11' to 'riak@192.168.17.11'

     注意：执行 `riak-admin force-replace` 命令，一定会看到这样的提醒信息：`WARNING: All of 'riak@10.1.42.11' replicas will be lost`。
     因为我们不会删除任何数据文件，而是使用同一个节点替换掉自己，只是换个名字而已，不会丢失任何数据。

8. 执行 `riak-admin cluster commit` 命令，提交变动：

        riak-admin cluster commit

     输出结果如下：

        Attempting to restart script through sudo -H -u riak
        Cluster changes committed

9. 检查节点在集群中是正常：

        riak-admin member-status

     输出如下：

        Attempting to restart script through sudo -H -u riak
        ============================= Membership ==============================
        Status     Ring    Pending    Node
        -----------------------------------------------------------------------
        valid      20.3%      --      'riak@192.168.17.11'
        valid      20.3%      --      'riak@10.1.42.12'
        valid      20.3%      --      'riak@10.1.42.13'
        valid      20.3%      --      'riak@10.1.42.14'
        valid      18.8%      --      'riak@10.1.42.15'
        -----------------------------------------------------------------------
        Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0

10. 执行 `riak-admin transfers` 命令监视提示移交，确保操作执行完整

11. 上述步骤完成后，删除重命名的 `ring` 文件夹

<a id="repeat"></a>
### 在每个节点中重复上面两步

在集群的每个节点中重复上面两步。

修改后续节点时，要把节点加入集群，调用 `riak-admin cluster join` 命令时，目标节点
使用  *riak@192.168.17.11*。

```
riak-admin cluster join riak@192.168.17.11
```

合并操作暂存成功后会看到以下输出：

```
Attempting to restart script through sudo -H -u riak
Success: staged join request for 'riak@192.168.17.12' to 'riak@192.168.17.11'
```
