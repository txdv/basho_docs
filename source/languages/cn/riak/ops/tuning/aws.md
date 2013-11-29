---
title: AWS 性能调整
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator, performance, aws]
---

这篇文档介绍了一些推荐使用的性能和调整方面的最佳实践，可用于部署在 Amazon Web Services (AWS) Elastic Compute Cloud (EC2) 环境中的 Riak 集群。

<div class="info">
<div class="title">提示</div>
请一定要阅读“[[Linux 性能调整]]”，这篇文档更详细的介绍了提升性能和调整的一般方法，可用于所有的 Riak 集群。
</div>

## EC2 实例

EC2 实例是预先定义好的类型，封装了固定量的计算机资源，其中对 Riak 来说最重要的有：硬盘 IO，RAM、网络 IO 以及 CPU 内核。充分考虑这些资源后，Riak 用户反馈成功的几率大了，大很多。

Riak 集群节点最常使用的[实例类型](http://aws.amazon.com/ec2/instance-types/)是 `m1.large` 或 `m1.xlarge`。如果想使用 10GB 的以太网，EC2 实例的 Cluster Compute 类型可以选择 `cc1.4xlarge` 或 `cc2.8xlarge`。

Amazon 还提供了 High I/O Quadruple Extra Large 实例（`hi14xlarge`），使用固态硬盘（SSD），提供了很高的 IO 性能。

Amazon 还提供了使用 [Provisioned IOPS](http://aws.amazon.com/about-aws/whats-new/2012/07/31/announcing-provisioned-iops-for-amazon-ebs/)EBS 针对 EBS 优化的 EC2 实例，具有每秒 500MB 到 1000MB 之间的吞吐量。推荐在 Provisioned IOPS EBS 卷上使用。

Riak 主要的瓶颈是硬盘和网络 IO，这意味着在大多数情况下，标准的 EBS 会出现很长的迟延和 IO 等待时间。Riak 的 IO 模型适合处理硬盘上散布的小型二进制文件，然而 EBS 却最适合批量读取和写入。这一模型的负面影响可以通过以下方式减弱：在多卷上实现 RAID，使用 Provisioned IOPS，如果应用程序不需要使用二级索引，还可以使用 Bitcask 作为存储后台。

不管使用那种方法，为了达到期望的性能，都要做评测和调整工作。

<div class="info">
<div class="title">提示</div>
大多数成功在 AWS 上部署集群的案例都是用了比物理节点数量更多的 EC2 实例，
以此来抵消分享的虚拟资源引起的性能变动。在规划集群大小时，要使用比物理
服务器更多的 EC2 实例。
</div>

## 操作系统

### 挂载和调度方法

在 EBS 卷上，应该使用 **deadline** 调度方法。例如要查看设备 xvdf 上使用的调度方法，可以执行下面的命令：

```bash
cat /sys/block/xvdf/queue/scheduler
```

要把调度方法设为 deadline，请执行下面的命令：

```bash
echo deadline > /sys/block/xvdf/queue/scheduler
```

关于硬盘调度方法的详细内容，请阅读 [[Linux 性能调整]]和[[打开文件限制]]。

### 错误查证

如果遇到问题，要尽量多的收集信息。请查看监控系统、备份日志和设置文件，以及操作系统的日志文件，例如 `dmesg` 和 syslog。确保 Riak 集群中其他节点还在正常运行，没有因为其他问题（例如 AWS 服务耗尽）导致影响扩大。尝试使用掌握的信息找到导致问题的原因。如果是授权的 Riak 企业版用户，问题是由 Riak 导致的，而且还没有头绪，可以到 Basho 客户服务帮助网站上发起工单，或者拨打 24*7 急救热线。

收集了所需数据后再联系 Basho 客户服务部门，我们的客户服务工程师（CES）会要求你提供日志文件、设置文件和其他信息。

## 数据丢失

很多问题不会导致数据丢失，或者丢失情况不严重，无需干预即可自动修复。一个节点的资源用完了不会导致数据丢失，因为每个键的副本在集群中的其他地方都有。如果检测到节点下线了，集群中的其他节点会临时担起责任，等到节点重新上线后会把更新后的数据传输过去（称为“提示移交”）。

更多的数据丢失和硬件失效有关（对 AWS 而言，是服务失败或实例终止）。如果数据丢失了，有很多方法可以恢复。

1.  从备份恢复。每日做一次 Riak 节点备份是很有用的。根据节点失效的时间，备份中的数据可能已经过期，不过仍然可以用来部分恢复 EBS 卷丢失的数据。如果使用 RAID，还可以重建阵列。
2.  从多个集群中的副本恢复。如果在两个或多个集群中存在副本，丢失的数据就可以通过副本流和整体同步恢复。整体同步还可以使用 riak-repl 命令手动触发。
3.  使用集群内部的修复功能恢复。Riak 1.2 以上的版本提供了“修复”功能，可以从副本恢复丢失的分区。目前，这种方式必须在 Riak 终端里手动调用，而且应该在 Basho CSE 的指导下操作。

数据恢复后就可以进行常规操作了。如果多个节点完全丢失了数据，强烈建议你咨询 Basho。

## 评测

使用像 [Basho Bench](https://github.com/basho/basho_bench) 这样的工具，可以生成负载，构建几乎兼容的有效数据负载，和 Riak 集群直接通信，来模拟应用程序的操作。

测评是决定适当的 EC2 类型的关键所在，强烈推荐一定要做。关于 Riak 集群测评的更多信息请阅读 [[Basho Bench]] 一文。

除了运行 basho bench 之外，还建议使用你自己的测试进行负载测试，确保 M/R 查询、链接、link-walking、全文搜索查询和索引查询的负载在可接受的范围内。

## 模拟升级，扩放和失败的情况

除了简单的性能测试之外，还要测试集群不在稳态时的性能削减。模拟实时负载时，可以模拟如下的状态：

1.  正常的停止一个或多个节点，一段时间后在重启（模拟 rolling-upgrade）
2.  在集群中添加两个或更多节点
3.  删除集群中的一些节点（完成第 2 步后）
4.  强制终止 Riak `beam.smp` 进程（例如使用 `kill -9`），然后再重启
5.  重启一个节点
6.  强制终止并销毁一个节点实例，然后从备份中创建一个新实例
7.  通过网络（也可以是防火墙）从集群中分出一个或多个节点，然后恢复到原始设置

## 内存耗尽

有时，如果可用的 RAM 用完了，Riak 就会终止运行。这种情况随不会导致数据丢失，但却表明集群需要扩容了。如果一个 Riak 节点耗尽了，集群的可用容量也很少，其他节点可能也很危险，这时一定要仔细监控。

把 EC2 实例换成一个拥有更大 RAM 的类型或许可以临时解决这个问题，但内存耗尽（OOM）表明集群资源供应不充足。

软件的错误（内存泄漏）也会可能会导致 OOM，我们建议 Riak 企业版用户遇到这种问题时联系 Basho 客户服务部门。

## 处理 IP 地址

在 VPC 上没有充足资源供应的 EC2 实例，重启后会修改以下参数。

* 内网 IP 地址
* 公网 IP 地址
* 内网 DNS
* 外网 DNS

Riak 要绑定一个 IP 地址，并通过这个地址和其他节点通讯，所以节点如果要重新上线，必须执行特定的管理命令。具体来说，必行执行下面的步骤。

* 执行 `riak stop` 命令，停止要重命名的节点
* 在集群的其他节点中执行 `riak-admin down 'old nodename'` 命令把上述节点标记为“下线”
* 在 vm.args 文件中重命名节点
* 删除环数据文件夹
* 执行 `riak start` 命令启动该节点
* 现在这个节点是个单例，可以执行 `riak-admin member-status` 命令查看
* 执行 `riak-admin cluster join 'cluster nodename'` 命令把这个节点加入集群
* 执行 `riak-admin cluster force-replace <old nodename> <new nodename>` 命令替换原来的实例
* 执行 `riak-admin cluster plan` 命令计划这次改动
* 执行 `riak-admin cluster commit` 命令提交这次改动

为了避免麻烦，可以把 Riak 部署到 [VPC](http://aws.amazon.com/vpc/) 上。VPC 上的实例重启后内网 IP 不会改变。而且还有以下好处。

* 可定义多级访问控制列表（Load balancers / Individual servers / VPC Groups）
* 不会为网络中任意的通讯打开 Riak 实例。只有子网中的节点才能联络 Riak。
* 私有节点如需连接网络，可以通过 NAT 实例进行。
* Amazon VPC 是[免费](http://aws.amazon.com/vpc/pricing/)的

设置 VPC 时可能会遇到其他问题，请查看对应的[解决方法](http://deepakbala.me/2013/02/08/deploying-riak-on-ec2/)。

## 选择存储类型

EC2 实例支持暂时和 EBS 存储。riak-users 邮件列表上有[很多文章](http://riak-users.197444.n3.nabble.com/EC2-and-RIAK-td2754409.html)讨论了不同存储的优缺点。这些文章可以引导你选择适合的存储。

## 参考资源

* [[Linux 性能调整]]
* [[失效和恢复]]
* [[文件系统调整]]
* [Basho 客户服务平台](https://help.basho.com)
