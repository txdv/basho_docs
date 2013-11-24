---
title: 替换节点
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator]
---

有时基于各种原因，可能要替换 Riak 集群中的节点（这和[[恢复失效的节点]]可不一样）。替换节点时推荐按照下面的步骤操作。

1. 备份要替换的节点数据文件夹。本例中我们称这个节点为 **riak4**

```bash
sudo tar -czf riak_backup.tar.gz /var/lib/riak /etc/riak
```

2. 在想引入集群替换 **riak4** 的节点上下载并安装 Riak，我们把这个新节点叫做 **riak7**

3. 执行 `[[riak start|命令行工具#start]]` 命令启动 **riak7**

```bash
riak start
```

4. 把 **riak7** 和集群中某个现有节点合并，例如在 **riak7** 中执行 `[[riak-admin cluster join|riak-admin 命令#cluster]]` 命令，和 **riak0** 合并

```bash
riak-admin cluster join riak0
```

5. 执行 `[[riak-admin cluster replace|riak-admin 命令#cluster]]` 命令把 **riak4** 替换成 **riak7**

```bash
riak-admin cluster replace riak4 riak7
```

<div class=info>
<div class=title>单个节点</div>
如果只有一个节点，要先修改 <code>etc/vm.args</code> 文件，再删除数据文件夹中的环文件。<code>riak-admin cluster replace</code> 命令没有任何作用，因为节点没有加入集群。
</div>

6. 在 **riak7** 中执行 `[[riak-admin cluster plan|riak-admin 命令#cluster]]` 命令，审查替换计划：

```bash
riak-admin cluster plan
```

7. 如果计划符合要求，执行 `[[riak-admin cluster commit|riak-admin 命令#cluster]]` 命令提交变动：

```bash
riak-admin cluster commit
```

如果要放弃计划重新开始，请执行 `[[riak-admin cluster clear|riak-admin 命令#cluster]]` 命令：

```bash
riak-admin cluster clear
```

成功替换后，旧节点就从集群中删除了。替换节点后可以使用 `[[riak-admin ringready|riak-admin 命令#ringready]]` 和 `[[riak-admin member-status|riak-admin 命令#member-status]]` 命令查看环的准备状态。

<div class="info">
<div class="title">安置环</div>
你要确保在启动新节点和使用新 IP 地址安置好环之间的这段时间内，不会修改环。

如果 <code>riak-admin ringready</code> 命令的输出为 <strong>true</strong>，就证明环已经安置好了。
</div>
