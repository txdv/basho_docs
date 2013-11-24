---
title: Linux Performance Tuning
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator, performance, os]
---

这篇文档介绍了推荐在 Riak 集群中使用的性能调整方法，常见的错误和修正方法，以及评测。

Riak 重要的瓶颈是硬盘和网络 IO。Riak 使用的 IO 模式可以更好的处理硬盘上散布的小型二进制文件。可以通过下列方式减轻这种模式的负面影响：为多卷添加 RAID 支持，使用固态硬盘（SSD），如果应用程序不需要支持二级索引，还可以使用 Bitcask 作为存储后台。

不管使用那种方法，都要适当的做些评测和调整，这样才能获得性能提升。这篇文档就会告诉你如何做评测和调整。

<div class="info">
<div class="title">提示</div>
针对运行在 Amazon Web Services EC2 环境中的 Riak 集群进行性能调整的推荐做法，请阅读“[[AWS 性能调整]]”一文。
</div>

## 调整 Linux

Linux 可以调整成一个很好的服务器操作系统，也可以作为桌面系统使用。Linux 系统的很多组件，例如内核、网络和硬盘设置，都应做适当调整，这样才能作为生成环境的数据库服务器使用。

### 打开文件限制

Riak 及相关工具在常规操作时会消耗很多的文件句柄。为了性能的稳定，很有必要提升打开文件限制。详细方法请阅读“[[打开文件限制]]”一文。

###调整内核和网络

下列设置可以最小限度地提升 Riak 在 Linux 系统中的性能，应该添加到 `/etc/sysctl.conf` 文件：

<div class="note">
<div class="title">注意</div>
一般来说，应该把这些推荐的设置应该和系统的默认值比较一下，只有当测评结果显示网络是瓶颈时才应该修改。
</div>

```text
vm.swappiness = 0
net.ipv4.tcp_max_syn_backlog = 40000
net.core.somaxconn=4000
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_tw_reuse = 1
```

下面的设置是可选的，可以提升 10GB 网络的性能：

```text
net.core.rmem_default = 8388608
net.core.rmem_max = 8388608
net.core.wmem_default = 8388608
net.core.wmem_max = 8388608
net.core.netdev_max_backlog = 10000
```

<div class="info">
<div class="title">提示</div>
如果修改了这些设置，一定要做调试，因为这影响到所有网络操作。
</div>

### 交换空间

由于 Riak 严重依赖 IO 性能，交换空间的使用可能会导致整个服务器拒绝响应。请禁用交换空间，或者找到一种方法确保 Riak 进程页不被交换。

Basho 建议，如果 Riak 节点使用过多的 RAM 就要允许内核终止这个节点的运行。如果完全禁止了交换空间，如果无法分配更多的 RAM，Riak 会直接退出，在 `/var/log/riak` 文件夹中保存一个故障转储文件（名为 `erl_crash.dump`），用来查证信息（如果你是我们的客户，查找工作由 Basho 客户服务工程师进行）。

### 挂载和调度方法

存储数据时，Riak 会大量使用硬盘的 IO。所以在挂载用来存储 Riak 数据的卷时，一定要使用  **noatime** 旗标，意思是读取数据时不要修改文件系统的 [inodes](http://en.wikipedia.org/wiki/Inode)。可以使用下面的命令临时设定这个旗标：

```bash
mount -o remount,noatime <riak_data_volume>
```

请把上述命令中的 &lt;riak_data_volume&gt; 换成你用来存储 Riak 数据的卷。如想永久设置，可以在 `/etc/fstab` 中设定。

Linux 上默认的硬盘 IO 调度方法是“完全公平队列”（completely fairqueuing，`cfq`），被设计用来处理桌面应用。Basho 推荐在存储 Riak 数据的卷上使用 `noop` 或 `deadline` 调度方法，这样可以更好的利用服务器。

例如，如果要查看设备 **sda** 所用的调度方法，可以使用下面的命令：

```bash
cat /sys/block/sda/queue/scheduler
```

要把调度方法设为 deadline，可以使用下面的方法：

```bash
echo deadline > /sys/block/sda/queue/scheduler
```

### 文件系统

为了系统的稳定性和可恢复性，Basho 推荐使用高级的日志文件系统，例如 ZFS 和 XFS。不过，在无法使用 ZFS 或 XFS 的系统中也可以使用 ext3 和 ext4。

<div class="note">
<div class="title">注意</div>
Basho <strong>不推荐</strong>现在就在生产环境中使用 <a href="http://zfsonlinux.org/">ZFS On Linux</a> 项目。
</div>

ext4 文件系统默认包含了两个选项用来增进集成度，但会降低性能。因为 Riak 的集成度是通过多个节点保存相同数据实现的，为了提升 IO 性能，可以修改一下这两个选项。使用 ext4 文件系统时，我们建议做以下设置：`barrier=0`，`data=writeback` 。

`noatime` 设置应该加入 `/etc/fstab` 文件，这样即使服务器重启设置依然存在。

## 集群规模

集群中包含 5 个或 5 个以上节点可以获得最好的性能，还能适时添加新节点。Riak 的扩放性是随着节点的数量增多成线性增长的，所以用户会发现更大的起群能提供更好的性能、可靠性和吞吐量。部署小型的集群违反了 Riak 的容错机制：为了满足可用性而默认设定的副本数量（3 个），在小型集群中可能无法实现。

集群中节点的数量越少，各节点的工作量就越多。如果有 3 个节点，需要提供 3 个副本，那么所有的节点都要响应请求。如果有 5 个节点，只有 60% 的节点需要响应。注意，集群中推荐包含的节点数量没有考虑所选实例的大小，因为大量节点的损耗还要由系统的其他部分评估。

### 分区（vnode）

和集群规模有直接关系的是集群中分区的数量，这个值在搭建集群时永久设定，而且必须是 2 的幂数（64，128，256 等）。每个分区中保存的键值对数量几乎相等（数据均匀的分布在集群中），而且还会保存特定范围内键的副本。

如果分区太少，就限制了集群增长肯能达到的最大规模，而且还会限制 IO 的并发数，因为分区负责很大一部分的键区间。如果分区太多，单个节点因过多的状态转换而超载，还会争夺 IO 资源。

Basho 建议集群中的每个节点使用 8 -64 个分区。例如，如果集群中有 5 个节点，那么就应该有 256 或 512 个分区。如果有 512 个分区，有 5 个节点的集群就可以在被换掉之前顺利的增长到包含 64 个节点。

详细信息请阅读“[[集群容量规划]]”一文。

## Riak 设置和调整

Riak 的设置都很明智，但针对特定的部署还是要做些修改。最为重要的是，集群中分区的数量一定要在启动节点之前设好。

在 `/etc/riak/app.config` 文件的 riak_core 区设置 ring_creation_size：

    {riak_core, [
       {ring_creation_size, 512},
       %% ...
       ]}

如果使用 LevelDB 作为存储后台（管理自己的 IO 线程池），Riak 默认线程池中的异步线程数可以在 `/etc/riak/vm.args` 文件中减少：

```text
+A 16
```

Riak 设置的更多信息，可以在[[设置文件]]的文档中查看。

<div class="info">
<div class="title">提示</div>
关于 Riak 设置的疑问还可以发到 <a href="http://help.basho.com/">Riak 客户服务帮助网站</a>上。
</div>

## 负载平衡设置

我们建议在应用程序和 Riak 之间放置一个负载平衡工具，例如 [HAProxy](http://haproxy.1wt.eu/)。

下面是一个 HAProxy 设置示例，设定值都经过测试：

```text
listen riak 0.0.0.0:8087
    balance    leastconn
    mode       tcp
    option     tcplog
    option     contstats
    option     tcpka
    option     srvtcpka
    server riak-1 192.168.1.1:8087 check weight 1 maxconn 1024
    server riak-2 192.168.1.2:8087 check weight 1 maxconn 1024
    server riak-3 192.168.1.3:8087 check weight 1 maxconn 1024
    server riak-4 192.168.1.4:8087 check weight 1 maxconn 1024
    server riak-5 192.168.1.5:8087 check weight 1 maxconn 1024
```

上述设置可能要根据连接、服务器和客户端超时等做调整。如果可能，请使用  kernel-splicing 功能（默认的）连接客户端和 Riak 节点，以便得到最佳性能。

## Riak 扩放

有两种方法可以扩放 Riak：纵向（改进硬件）和横向（添加更多节点）。这两种方法都可以提升性能和容量，但适用的情况不同。在使用这两种方法是，[[riak-admin cluster command|riak-admin 命令#cluster]] 可以给你提供帮助。

如果要修改集群进行纵向或横向扩放，请遵循以下步骤：

1.  分别使用 `riak-admin cluster [join|leave|replace]` 命令添加、删除或替换节点
2.  使用 `riak-admin cluster plan` 命令查看集群转换计划。确保该计划符合你的期待，即合并或删除正确的节点，环的所有权移交给了正确的节点
3.  执行 `riak-admin cluster commit` 命令确认修改，或者执行 `riak-admin cluster clear` 命令终止修改
4.  使用 `riak-admin member-status` 和 `riak-admin ring-status` 命令监视转换过程

### 纵向扩放

纵向扩放，即增加节点/服务器的容量，把节点的容量增多了，但没有减轻集群中现有节点的总体负载。也就是说，扩容后的节点处理负载的能力提升了，但负载量没变。进行纵向扩放的情况有，提升 IPOS，提升 CPU/RAM 容量和硬盘容量。

如果扩容的节点可以使用相同的 IP 地址和数据进行初始化，就无需修改 Riak。如果资源无法在新节点中使用，请在合并新节点后执行 `riak-admin cluster replace <oldnode> <newnode>` 命令。命令中的两个节点名可以从 member-status 命令的输出或者 `/etc/riak/vm.args` 文件中查看。

### 横向扩放

横向扩放，机增加集群中节点的数量，通过更大范围的键区间，为客户端连接提供更多的端点，减轻乐睿各节点的负担。也就是说，各节点的容量不变，但负载减少了。进行横向扩放的情况有，提升 IO 并发量，减少现有节点的负载，以及提升硬盘容量。

进行横向扩放，新节点必须使用 [[riak-admin cluster join command|riak-admin 命令#cluster]] 命令加入集群。如果添加的节点不止一个，应该一次性添加所有的节点，而不是一次添加一个。也就是说，在所有新节点的进行待加入状态之前，不要提交计划。这样做可以减少网络中传输的数据量（所有权移交）。如果不这么做，相同的数据可能会被多次移动。

### 反向横向扩放

如果 Riak 集群未被充分使用，或者遇到了季节性用量减少，可以在要删除的节点上执行 `riak-admin leave` 命令进行反向扩放。安全起见，我们建议一次删除一个节点，同时要监控其他节点的负载、容量和性能。

## 警告

集群成员的变动要小心谨慎。在新成员间重新分发数据需要一定的硬盘和网络资源，要花费一段时间；调整所有权转移的操作也要一定的时间。同样的，移交的频率也会受到 Riak 默认设置的限制，因为要避免影响正常操作。这个限制可以临时调整，如要更大的移交吞吐量，或者更低的影响，可以使用 [[riak-admin transfer-limit command|riak-admin 命令#transfer-limit]]。

由于错误和维护而不可使用的节点不应该从节点中删除。要维护节点，可以把这个节点标记为下线，或者停止这个节点上的 Riak，但不要从集群中删除这个节点。

如果遇到问题，请阅读”[[失效和恢复]]“一文获取更多信息。

## 评测

使用像 [Basho Bench](https://github.com/basho/basho_bench) 这样的工具，可以生成负载，构建几乎兼容的有效数据负载，和 Riak 集群直接通信，来模拟应用程序的操作。

测评是决定适当的集群节点资源的关键所在，强烈推荐一定要做。关于 Riak 集群测评的更多信息请阅读 [[Basho Bench]]。

除了简单的性能测试之外，还要测试集群不在稳态时的性能削减。模拟实时负载时，可以模拟如下的状态：

1.  正常的停止一个或多个节点，一段时间后在重启（模拟 rolling-upgrade）
2.  在集群中添加两个或更多节点
3.  删除集群中的一些节点（完成第 2 步后）
4.  强制终止 Riak `beam.smp` 进程（例如使用 `kill -9`），然后再重启
5.  重启一个节点
6.  强制终止并销毁一个节点实例，然后从备份中创建一个新实例
7.  通过网络（也可以是防火墙）从集群中分出一个或多个节点，然后恢复到原始设置

## 参考资源

* [[AWS 性能调整]]
* [Why Your Riak Cluster Should Have At Least Five Nodes](http://basho.com/blog/technical/2012/04/27/Why-Your-Riak-Cluster-Should-Have-At-Least-Five-Nodes/)
* [[失效和恢复]]
* [[设置文件]]
* [erl - The Erlang Emulator](http://www.erlang.org/doc/man/erl.html#id154078)
* [Basho 帮助平台](http://help.basho.com/)
* [[命令行工具]]
* [Basho Bench](https://github.com/basho/basho_bench)
* [[Basho Bench]]
