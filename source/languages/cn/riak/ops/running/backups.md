---
title: Backing up Riak
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [operator]
---

选择何种备份 Riak 的策略很大程度上取决于节点的后台设置。大多数情况下，
Riak 会遵从已经建立起来的备份方法。备份节点时，一定要备份属于所使用
后台的 `ring` 和 `data` 文件夹。

除了上面这两个文件夹之外，最好也备份设置文件夹，这样便于从失效
的节点恢复。

Riak 默认的 `data`、`ring` 和设置文件夹在所支持的操作系统中
存放位置如下：

**Debian 和 Ubuntu**

* Bitcask 数据：`/var/lib/riak/bitcask`
* LevelDB 数据:`/var/lib/riak/leveldb`
* 环数据:`/var/lib/riak/ring`
* 设置：`/etc/riak`

**Fedora 和 RHEL**

* Bitcask 数据：`/var/lib/riak/bitcask`
* LevelDB 数据：`/var/lib/riak/leveldb`
* 环数据：`/var/lib/riak/ring`
* 设置：`/etc/riak`

**FreeBSD**

* Bitcask 数据`/var/db/riak/bitcask`
* LevelDB 数据：`/var/db/riak/leveldb`
* 环数据：`/var/db/riak/ring`
* 设置：`/usr/local/etc/riak`

**OS X**

注意：在 OS X 上的路径相对于安装包解压后放置的文件夹。

* Bitcask 数据：`./data/bitcask`
* LevelDB 数据：`./data/leveldb`
* 环数据：`./data/riak/ring`
* 设置：`./etc`

**SmartOS**

* Bitcask 数据：`/var/db/riak/bitcask`
* LevelDB 数据：`/var/db/riak/leveldb`
* 环数据：`/var/db/riak/ring`
* 设置：`/opt/local/etc/riak`

**Solaris**

* Bitcask 数据：`/opt/riak/data/bitcask`
* LevelDB 数据：`/opt/riak/data/leveldb`
* 环数据：`/opt/riak/ring`
* 设置：`/opt/riak/etc`

<div class="info">
由于 Riak 具有最终一致性特性，不同节点的备份可能稍微有点不一致。备份时，
某些节点上有的数据在其他节点上可能不存在。不过，这些不一致会在读取时
使用 [[read-repair|Replication#Read-Repair]] 系统纠正。
</div>

## 备份 Bitcask

BItcask 是对数结构的设计，其备份可以通过一些常用的方法完成。一些标准的工具，
例如 `cp`、`rsync` 和 `tar` 可以在任何系统中以安装的备份系统或方法中使用。

一个简单的计划任务（cron job）就可以在 Linux 系统中使用安装包安装的 Riak 中，
备份 Bitcask 的数据、环数据和 Riak 设置文件夹等，如下所示：

```bash
tar -czf /mnt/riak_backups/riak_data_`date +%Y%m%d_%H%M`.tar.gz \
  /var/lib/riak/bitcask /var/lib/riak/ring /etc/riak
```

关于这一后台更多的信息请阅读 [[Bitcask]]，

## 备份 LevelDB

目前，备份 LevelDB 的数据和日志需要节点处于**未运行**的状态。
Currently, LevelDB data and log backups require that the node
*not be running* when the backup is performed. This can present the challenge
of 这就要求备份程序能对等的执行节点关停和启动操作。除此之外，备份
使用 LevelDB 后台的节点和其他后台很类似。

一个简单的计划任务（cron job）就可以在 Linux 系统中使用安装包安装的 Riak 中，
备份 LevelDB 的数据、环数据和 Riak 设置文件夹等，如下所示：

备份一个使用 LevelDB 后台的节点，其基本步骤如下：

1. 停止节点
2. 备份相关数据，环和设置文件夹
3. 启动节点

<div class="info">
为了避免过长的停机时间，可以把 Riak 数据存储在支持快照的文件系统上，例如 ZFS。
备份的过程是，先停止节点，给数据文件夹做个快照，然后启动节点。以后你可以丢掉
并删除这个快照。
</div>

关于这一后台的更多信息请阅读  [[LevelDB]]。

## 恢复节点

恢复节点要使用的方法受很多因素影响，包括节点名称的变化和网络环境。

如果要使用一个新节点替换现有的节点（一般是完全限定域名或 IP 地址），
而且节点名相同，那么恢复节点的过程就很简单。


1. 在新节点上安装 Riak
2. 把旧节点的设置文件、数据文件夹和环文件夹恢复到新节点中
3. 启动新节点，执行 `riak ping` 和 `riak-admin status` 等检查节点状况的命令确认操作是否成功

{{#1.2.0-}}
如果修改了节点名称（即某节点 `vm.args` 设置文件夹中的 *-name* 参数和备份
要恢复到的节点不一致），在**启动各节点之前**需要执行 `riak-admin reip` 命令
更新所有节点。

注意，即使只修改了一个节点的名称，也要更新所有节点，这样改动才能生效。
在每个节点中，从备份中恢复数据文件夹和设置文件夹，在**启动节点之前**，
在修改了名字的节点中执行 `riak-admin reip` 命令。

例如，一个集群中有 5 个节点，原来的名字分别是 *riak1.example.com* 到 *riak5.example.com*，
现将其名字改为 *riak101.example.com* 到 *riak105.example.com*，
因此要在**每个停止的节点中**执行 `riak-admin reip` 命令，如下所示：

```bash
# run these commands on every node in the cluster while the node is stopped
riak-admin reip riak@riak1.example.com riak@riak101.example.com
riak-admin reip riak@riak2.example.com riak@riak102.example.com
riak-admin reip riak@riak3.example.com riak@riak103.example.com
riak-admin reip riak@riak4.example.com riak@riak104.example.com
riak-admin reip riak@riak5.example.com riak@riak105.example.com
```
{{/1.2.0-}}

{{#1.2.0+}}
如果修改了节点名称（即某节点 `vm.args` 设置文件夹中的 *-name* 参数和备份
要恢复到的节点不一致），那么还需要执行以下操作：

1. 执行 `[[riak-admin down <node>|riak-admin Command Line#down]]` 命令在集群中把原来的实例标记为下线
2. 执行 `[[riak-admin cluster join <node>|riak-admin Command Line#cluster-join]]` 命令把恢复后的节点加入集群
3. 执行 `[[riak-admin cluster force-replace <node1> <node2>|riak-admin Command Line#cluster-force-replace]]` 命令用重命名后的实例替换掉原来的实例
4. 执行 `riak-admin cluster plan` 命令计划这次变动
5. 执行 `riak-admin cluster commit` 命令提交这次变动

<div class="info">
关于 `riak-admin cluster` 命令的详细信息请阅读 [[cluster section of "Command Line Tools - riak-admin"|riak-admin Command Line#cluster]]。
</div>

例如，一个集群中有 5 个节点，原来的名字分别
是 *riak1.example.com* 到 *riak5.example.com*，
现在要把 *riak1.example.com* 恢复到 *riak6.example.com*，那么需要
在 *riak6.example.com* 中执行下面的命令：

```bash
# Join to any existing, cluster node
riak-admin cluster join riak@riak2.example.com
# Mark the old instance down
riak-admin down riak@riak1.example.com
# Force-replace the original instance with the new one
riak-admin cluster force-replace riak@riak1.example.com riak@riak6.example.com
# Display and review the cluster change plan
riak-admin cluster plan
# Commit the changes to the cluster.
riak-admin cluster commit
```
{{/1.2.0+}}

除了执行上述命令之外，还要把 `vm.args` 设置文件中的 *-name* 参数设为新的名字。
如果节点的 IP 地址改变了，请确保这一变化写入了 *app.config* 文件，
确保 HTTP 和 PB 接口绑定到正确的地址上。

如果节点的 IP 地址改变了，稳健的 DNS 设置可以简化恢复的过程，不过节点的名称
将使用主机名，而主机名是不变的。而且，如果 HTTP 和 PB 接口绑定到
所有的 IP 地址（0.0.0.0），那么就无需修改 *app.config* 文件。

强烈建议在用到 {{#1.2.0-}}`riak-admin reip`{{/1.2.0-}}{{#1.2.0+}}`riak-admin cluster force-replace`{{/1.2.0+}} 命令
的恢复操作时，一次只启动一个节点，然后验证每个启动的节点其名字是否正确。

首先要确保在 `vm.args` 设置文件中设定了正确的名字。然后，启动节点后，
执行 `riak attach` 命令链接到该节点。 或许需要输入 Erlang atom （`x.`），然后
回车，来获取终端。获取的终端应该包含正确的节点名字。按下 `^d`（control-d） 断开
和会话的连接。最后，执行 `riak-admin member_status` 命令列出所有节点，检测所列
节点的名字是否正确。
