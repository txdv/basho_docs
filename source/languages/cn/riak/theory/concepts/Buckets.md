---
title: Bucket
project: riak
version: 1.4.2+
document: appendix
audience: intermediate
keywords: [appendix, concepts]
---

bucket 存在的目的是定义一个虚拟的键空间，而且还能设定独立的非默认设置。bucket 有点类似关系型数据库中的表，或者文件系统中的文件夹。bucket 会继承默认设置，经过修改的设置会广播到整个环。

## 设置

每个 bucket 都可以设置一些属性，覆盖默认值。

### n_val

*整数*（默认值： `3`）。设定对象在集群中存储的副本数量。参见“[[副本]]”一文。

### allow_mult

*布尔值*（默认值：`false`）。设定是否创建兄弟数据。参见“[[兄弟数据|向量时钟#Siblings]]”一文。

### last_write_wins

*布尔值*（默认值：`false`）。设定在出现冲突时，是否使用对象的向量时钟以时间标记这次独一无二的写入操作。参见“[[解决冲突|概念#Conflict-resolution]]”一文。

### r, pr, w, dw, pw, rw

`all`、`quorum`、`one`，或*整数*（默认值：`quorum`）。设定操作被认定为成功之前，读取或写入操作要收到多少个响应。参见“[[读取数据|概念#Reading-Data]]”和“[[写入及更新数据|概念#Writing and Updating Data]]”两篇文档。

### precommit

在写入一个对象之前要执行的 Erlang 或 JavaScript 函数列表。参见“[[Pre-Commit 钩子|使用 Commit 钩子#Pre-Commit-Hooks]]”一文。

### postcommit

在写入一个对象之后要执行的 Erlang 函数列表。参见“[[Post-Commit 钩子|使用 Commit 钩子#Post-Commit-Hooks]]”一文。

设置 bucket 属性的更详细介绍请阅读“[[设置文件|设置文件#default_bucket_props]]”、“[[通过 HTTP 设置 bucket 的属性]]”，以及针对所用客户端驱动的文档。

### backend

如果使用 `riak_kv_multi_backend`，指定具体要使用哪个后台。
