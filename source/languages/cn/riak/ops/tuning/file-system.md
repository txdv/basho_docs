---
title: 文件系统调整
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator, os]
---

本文介绍了部署 Riak 时建议使用的 IO 调度方法设置。

IO 调度或硬盘调度是一个总括术语，用来说明操作系统如何排序读取和写入操作。

IO 调度方法有很多种。常用的有：

* Anticipatory
* 完全公平队列（CFQ），2006 年以后 Linux 使用的默认方法
* Deadline
* FIFO
* NOOP

CFQ 虽然是常规调度方法，但不能提供数据库在生产环境中所需的吞吐量。对 Riak 来说，如果使用 HBA 进行 iSCST 部署，或者使用基于 RAID 的硬件，最好的选择是 NOOP。如果使用 SSD 存储设备，最好使用 Deadline 方法。

系统和工作量的配合有很多种，请查看所用操作系统的文档，查看可以使用的 IO 调度方法，以及必须要实现的方法。
