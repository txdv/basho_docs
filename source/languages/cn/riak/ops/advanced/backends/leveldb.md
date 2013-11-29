---
title: LevelDB
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: intermediate
keywords: [backends, planning, leveldb]
prev: "[[Bitcask]]"
up:   "[[选择后台]]"
next: "[[Memory]]"
interest: [
  "[[LevelDB 文档|http://leveldb.googlecode.com/svn/trunk/doc/index.html]]",
  "[[Cache Oblivious BTree|http://supertech.csail.mit.edu/cacheObliviousBTree.html]]",
  "[[LevelDB 测评|http://leveldb.googlecode.com/svn/trunk/doc/benchmark.html]]",
  "[[维基百科：LevelDB|http://en.wikipedia.org/wiki/LevelDB]]",
  "[[LSM 树|http://nosqlsummer.org/paper/lsm-tree]]",
  "[[Cache Conscious Indexing for Decision-Support in Main Memory|http://www.cs.columbia.edu/~library/TR-repository/reports/reports-1998/cucs-019-98.pdf]]"
]
---

## 概览

[eLevelDB](https://github.com/basho/eleveldb) 是一个 Erlang 应用程序，封装了 [LevelDB](http://code.google.com/p/leveldb/)。LevelDB 是个开源程序，把键值对存储在硬盘中，由 Google 的 Jeffrey Dean 和 Sanjay Ghemawat 开发。LevelDB 在键值对数据库领域算是新鲜人，但有很多优秀的特性，我们认为可以在 Riak 中使用。LevelDB 的存储架构相较于 Bitcask 而言，更像 [BigTable](http://en.wikipedia.org/wiki/BigTable) 的 memtable/sstable 模型。这样设计可以避开 Bitcask 对 RAM 的限制。

Riak 1.2 对 elevelDB 做了些修改，让用户可以在生产环境中调整大型数据存储的性能。

### 优点

  * 授权

    LevelDB 和 eLevelDB 分别基于[新的 BSD 协议](http://www.opensource.org/licenses/bsd-license.php)和 [Apache 2.0 协议](http://www.apache.org/licenses/LICENSE-2.0.html)发布。我们很感谢 Google 及 LevelDB 的开发者选择了一个完全符合“免费/自由开源软件”的协议，让每个人都能从这个创新的存储引擎中受益。

  * 数据压缩

    LevelDB 默认情况下会使用 Google Snappy 压缩数据。这么做会增加 CPU 的使用量，但能减少硬盘空间的占用。压缩特别适用于文本数据，例如纯文本、Base64、JSON 等。

### 缺点

  * 如果要搜索很多层级时，读取数据会很慢

    读取数据时 LevelDB 可能要做大量的硬盘搜索，每个层级搜索一次，如果数据库的 10% 能够存入内存，最后一个层级只需搜索一次，如果只有 1% 能存入内存，就需要两次搜索。

## 安装 eLevelDB

Riak 中包含了 eLevelDB，所以无需额外安装。不过，默认设置，Riak 使用 Bitcask 作为存储后台。要想换用 eLevelDB，请把 [[app.config|设置文件]] 文件中的 `storage_backend` 设置改为 `riak_kv_eleveldb_backend`。

```bash
{riak_kv, [
    {storage_backend, riak_kv_eleveldb_backend},
```

## 设置 eLevelDB

eLevelDB 默认的表现可以在 [[app.config|设置文件]] 文件的 `eleveldb` 区中修改。下面列出了可修改参数的详细信息。“[[参数规划|LevelDB#Key-Parameters]]”一节分步介绍了如何根据应用程序的需求设置合适的参数值。

[[app.config|设置文件]] 文件中 eLevelDB 的设置如下：

```erlang
 %% LevelDB Config
 {eleveldb, [
     %% Required. Set to your data storage directory
     {data_root, "/var/lib/riak/leveldb"},

     %% Memory usage per vnode

     %% Maximum number of files open at once per partition
     %% Default. You must calculate to adjust (see below)
     {max_open_files, 30},
     %% Default. You must calculate to adjust (see below)
     {cache_size, 8388608},

     %% Write performance, Write safety

     %% this is default, recommended
     {sync, false},
     %% this is default, recommended
     {write_buffer_size_min, 31457280},
     %% this is default, recommended
     {write_buffer_size_max, 62914560},

     %% Read performance

     %% Required, strongly recommended to be true
     {use_bloomfilter, true},
     %% Default. Recommended to be 4k
     {sst_block_size, 4096},
     %% Default. Recommended to be 16
     {block_restart_interval, 16},

     %% Database integrity

     %% Default. Strongly recommended to be true
     {verify_checksums, true},
     %% Default. Strongly recommended to be true
     {verify_compactions, true}
 ]},
```

### 每个虚拟节点的内存使用量

下面的选项可以调整每个虚拟节点的内存使用量。

#### 打开文件最大值

`max_open_files` 的值会乘于 4，得到一个容量值，单位为 MB，用来生成文件缓存。文件缓存根据某一时刻文件元数据的大小，存储的文件有多有少。`max_open_files` 设置针对单个虚拟节点，而不是整个服务器。详情参见“[[参数规划|LevelDB#Key-Parameters]]”一节。

只要服务器的资源允许，`max_open_files` 应该超过虚拟内存数据库文件夹中 `.sst` 表格文件的数量。相较于下面要介绍的 cache_size，为这个设置预留内存对随机读取操作更重要。

{{#1.4.0-}}
这个设置指定数据库可以打开文件的数量。如果数据库要处理的数据很多，就需要增加这个值（budget one open file per 2MB of working set divided by `ring_creation_size`）。

`max_open_files` 的最小值是 20，默认值也是 20。

```erlang
{eleveldb, [
    ...,
    {max_open_files, 20},
    ...
]}
```

<div class="note">
<div class="title">修改 max_open_files</div>
在 Riak 1.2 之前设定的 max_open_files 值，在 Riak 1.2 中要减少一半。（例如，如果在 Riak 1.1 中，max_open_files 的值为 250，那么在 Riak 1.2 中只需设成 125。）
</div>

{{/1.4.0-}}
{{#1.4.0+}}
`max_open_files` 的最小值是 30，默认值也是 30。

```erlang
{eleveldb, [
    ...,
    {max_open_files, 30},
    ...
]}
```
{{/1.4.0+}}

{{#1.4.0-1.5.0}}
<div class="note">
<div class="title">Riak 1.4 中的变化</div>
<p><code>max_open_files</code> 本来只是限制文件句柄的，但文件的元数据现在是考虑的重点。Basho 的较大型表格和 Google 最近添加的 Bloom 过滤器都让这种转换变得很重要。
</p>
</div>
{{/1.4.0-1.5.0}}

<div class="note">
<div class="title">检查系统的打开文件限制</div>
<p>因为这种存储引擎会用到很多的打开文件，所以最好查看并适当的设置系统的打开文件限制。如果见到包含 emfile 的错误，很有可能是因为超出了系统的打开文件限制，请阅读下面的“<a href="/tutorials/choosing-a-backend/LevelDB/#Tips-Tricks">提示和技巧</a>”一节查看如何修正这样的错误。</p>
</div>

<a id="Cache-Size"></a>
#### 缓存大小

`cache_size` 设定每个虚拟节点的块缓存大小。块缓存中保存着 leveldb 从 `.sst` 表文件中获取的最新数据块。每个块中都包含了一到两个完整的键值对。缓存可以加速对某一个键及相邻键的多次访问。

<div class="note">
<div class="title">Riak 1.2 中的问题</div>
<p>在 Riak 1.2 中有个问题，如果存储的值大于默认值 8,388,608，读取性能就会明显下降。这个问题在 Riak 1.3 中已经修正，而且还测试了大于 2GB 的数据，缓存性能良好。</p>
</div>

`cache_size` 决定了 LevelDB 可以在内存中缓存多少数据。内存中的缓存数据越多，LevelDB 的性能就越好。LevelDB 缓存离不开系统缓存和文件系统缓存，所以不要禁用或减少这两个缓存。如果使用 64 位的 Erlang VM，只要内存足够大，就可以放心的把 `cache_size` 设为 2GB 以上。和 Bitcask 不一样，LevelDB 把键和值放在块缓存中，这样就可以管理比可用内存还大的键空间。eLevelDB 为集群中的每个分区创建独立的 LevelDB 实例，所以每个分区的缓存也是分开的。

我们建议把这个值设为可用 RAM 的 20%-30%（可用量要去掉其他服务占用的 RAM，包括文件系统缓存消耗的物理内存）。

例如，一个集群有 64 个分区，运行在 4 个物理节点上，每个节点有 16GB 的 RAM。理想情况下，所以节点都运行着，那么缓存的大小最好设成可用 RAM 的一半（8GB）除以每个介绍上运行的虚拟节点数（64/4 = 16），即每个虚拟节点 536870912 字节（512MB）。

理想情况下：

      (可用的 RAM / 2) * (1024 ^ 3)
    -------------------------------- = 缓存大小
            (分区数 / 节点数)

但现实是，有些节点会失效。如果物理节点失效了，集群中会发生什么事呢？这个节点上的 16 个虚拟节点现在由其他 3 个正常运行的节点管理。那么，现在每个节点要处理近 22 个虚拟节点。为了设置合理的缓存大小，总缓存量不再是 16 * 512MB = 8GB，而是 22 * 512MB = 11GB。可用的内存无法负担起这么大的缓存了。这是就要加入一些余量。

实际情况下：

      (可用的 RAM / 2) * (1024 ^ 3)
    -------------------------------- = 缓存大小
          (分区数 / (节点数 - F))

    F = 可能回影响缓存的内存使用量的节点数

如果在影响缓存的内存使用量之前，允许有 1 个物理内存失效，F = 1，那么现在可用内存的一半（仍是 8G）就要除以 (64/(4-1)) = 21.3333（约等于 22），得到的值是 390451572，即 372MB。现在，每个物理节点在达到 50% 的内存使用量之前，可以缓存 22 的虚拟节点的数据。如果再有一个节点失效了，集群能察觉到。

你可能会问，“为什么只能用可用内存的一半？”因为物理 RAM 的另一半要用于操作系统、Erlang VM 以及文件系统的缓存（Linux 中的缓冲池）。文件系统缓存可以大大加速对集群的访问（读和写）时间。使用这个缓冲的另一个原因是不会把分页存储器写入硬盘中。虚拟内存可以避免因内存用完引起的失效，但是从硬盘中读取分页存储器或把分页存储器写入硬盘的代价是很大的，会严重影响集群的整体性能。

默认值：8MB

```erlang
{eleveldb, [
    ...,
    {cache_size, 8388608}, %% 8MB default cache size per-partition
    ...
]}
```

### 写入的性能/写操作的安全性

下面的设置可以调整写入的性能和写操作的安全性。调整的基本原则是，要想更快的写入性能（例如，更多的缓冲），其安全性就更低（崩溃时丢失的数据越多）。

#### 同步

{{#1.4.0+}}
`sync` 设置键值对在恢复日志中的存储方式。只有当 Riak 程序崩溃或服务器停电时才会用到。这个设置的最初目的是为了保证在回响写入成功前，每个新的键值对都会写入物理硬盘。对现在的服务器来说，在服务器程序和物理内存之间有很多层级的数据缓存。这个设置只能影响其中一个层级。

如果设为 `true`，写入操作会变慢，不无法保证数据会写入物理设备。数据极有可能从操作系统的换成移到了硬盘控制器中。如果服务器没电了，硬盘控制器就无法保证能把数据写入硬盘。如果设为 `false`，写入操作会快一点，Riak 程序崩溃时的恢复能力取决于操作系统的内存映射 IO，但无法处理服务器停电的情况。
{{/1.4.0+}}
{{#1.4.0-}}
如果设为 `true`，在写操作被认定为成功之前，数据会从操作系统的缓冲缓存中移出。写入操作虽然变慢了，但更持久。

如果设为 `false`，而且电脑损坏了，很对最近写入的数据可能会丢失。注意，如果只是进程崩溃了（例如，电脑没有重启），即便设为 `false`，也不会丢失写入的数据。

也就是说，`sync` 设为 `false` 时，对数据库写入操作来说，其处理方式和 `write()` 系统调用一样。`sync` 设为 `true` 时，其处理方式和 `write()` 外加 `fsync()` 系统调用一样。

另外一个需要考虑的情况是，在把数据写入磁盘之前，硬盘本身会缓存写入的数据（提前写缓存），并作出响应。这个过程的安全性取决于在停电之前硬盘是否有足够的店里保存其存储在内存中的数据。如果数据的持久性很重要，那么就要在驱动中禁用这个功能，或者提供后备电池，并且为停电制定一个合理的关机流程。
{{/1.4.0-}}

默认值：`false`

```erlang
{eleveldb, [
    ...,
    {sync, false},  %% do not write()/fsync() every time
    ...
]}
```

<div id="Write-Buffer-Size"></div>
#### 写缓冲大小

各虚拟节点会先把新键值对保存在基于内存的写缓冲里。写缓冲和前面提到的 `sync` 是并行的。考虑到性能，Riak 创建虚拟节点时会分配一个随机的写缓冲大小。这个随机值介于 `write_buffer_size_min` 和 `write_buffer_size_max` 之间。

如果在 [[app.config|设置文件]] 文件中没有设定，eLevelDB 使用的 `write_buffer_size_min` 默认值是 31,457,280 字节（30MB），`write_buffer_size_max` 的默认值是 62,914,560 字节（60MB）。此时，缓冲的平均大小是 47,185,920 字节（45MB）。

LevelDB 其他方面的调整也会使用这两个默认值。不管这些值变大还是变小，都可能会降低写操作的吞吐总量。

```erlang
{eleveldb, [
    ...,
    {write_buffer_size_min, 31457280},  %% 30 MB in bytes
    {write_buffer_size_max, 62914560},  %% 60 MB in bytes
    ...
]}
```

如果想修改写缓冲的大小，要修改 `write_buffer_size_min` 和 `write_buffer_size_max` 的话，`write_buffer_size_min` 的值必须至少为 30MB，而且大概是 `write_buffer_size_max` 的一半。

如果想把所有的写缓冲大小设的一样，可以使用 `write_buffer_size`。这个值会覆盖 `write_buffer_size_min` 和 `write_buffer_size_max`。不过不推荐这么做。

较大的写缓冲可以提升性能，特别是在负载较大时。同一时间，内存中最多只能保存两个写缓冲，所以你可能想适当的调整这个设置以控制内存的使用量。

### 读取的性能

下面的设置可以用来调整读取操作的性能。

`block_size` 和 `block_restart_interval` 控制 LevelDB 如何组织各 `.sst` 表文件中的键空间。其默认值是经过研究后决定的，也是推荐使用的值。

#### Bloom 过滤器

每个数据库 `.sst` 表文件都可以包含一个可选的 Bloom 过滤器，可以大大减少那些注定无法找到所请求键的请求。`bloom_filter` 一般会增加 `.sst` 表文件的大小，大概多 2%。必须在 app.config 文件中设为 `true` 才有效。

默认值：`true`

```erlang
{eleveldb, [
    ...,
    {use_bloomfilter, true},
    ...
]}
```

#### 块大小

{{#1.4.0+}}
`sst_block_size` 设置 `.sst` 表文件中数据块的大小。每个数据块在 `.sst` 表文件的主索引中都有一个索引条目。
{{/1.4.0+}}
{{#1.4.0-}}
设置每个块包含的用户数据大小。对大型数据库来说，较大的块可以提升性能，所以把块大小设为 256k（或其他 2 的幂数）应该是个好主意。注意，LevelDB 默认的内部块缓存大小只有 8MB，所以如果增加了块大小，可能还要增加 `cache_size`。
{{/1.4.0-}}

默认值：`4096` (4K)

{{#1.3.0-}}

```erlang
{eleveldb, [
    ...,
    {block_size, 4096},  %% 4K blocks
    ...
]}
```

<div class="note">
<div class="title">Riak 1.2 中的块大小</div>
<p>在 Riak 1.2 中不建议修改默认的块大小。如果大于 4K，就会破坏性能。</p>
</div>

{{/1.3.0-}}
{{#1.3.0+}}

```erlang
{eleveldb, [
    ...,
    {sst_block_size, 4096},  %% 4K blocks
    ...
]}
```
{{/1.3.0+}}

#### 块重启间隔时间

`block_restart_interval` 设置块中键索引能保持的键数量。

大多数情况下，请不要修改这个值。

默认值：`16`

```erlang
{eleveldb, [
      ...,
      {block_restart_interval, 16}, %% # of keys before restarting delta encoding
      ...
]}
```

### Database Integrity

`verify_checksums` 和 `verify_compactions` 设置硬盘中的每个数据块是否首先要使用 CRC32c 计算校验和。没有启用 CRC32c 验证时从硬盘读取数据很快，但如果硬盘把损坏的数据传给了 LevelDB，Riak 很有可能会崩溃。

#### 检查校验和

`verify_checksums` 设置 Riak 从 LevelDB 请求数据时，是否要代表用户进行验证。

{{#1.4.0-}}
默认值：`false`
{{/1.4.0-}}
{{#1.4.0+}}
默认值：`true`
{{/1.4.0+}}

```erlang
{eleveldb, [
    ...,
    {verify_checksums, true}, %% make sure data is what we expected it to be
    ...
]}
```

#### 检查压缩

`verify_compaction` 设置在压缩后台作业时 LevelDB 读取数据是否要进行验证。

默认值：`true`

```erlang
{eleveldb, [
    ...,
    {verify_compaction, true},
    ...
]}
```

<a id="Parameter-Planning"></a>
## 参数规划

下面的步骤详细说明了使用 LevelDB 时如何设置各项参数，以及如何计算所需的内存（例如，RAM）。

### 第 1 步：计算可用的工作内存

目前的类 Unix 系统（Linux / Solaris / SmartOS）会使用没被其他程序占用的物理内存作为硬盘操作的缓冲空间。在 Riak 1.2 中，LevelDB 被设计成依赖于这个操作系统的缓冲。必须为操作系统留有物理内存的 25-50%（如果服务器使用 SSD 阵列，需要 25-35%；如果服务器使用旋转式硬盘，则要 35-50%）。

LevelDB 所需工作内存就是总内存去除为操作系统保留的内存。

```bash
leveldb_working_memory = server_physical_memory * (1 - percent_reserved_for_os)
```

例如：

如果服务器的 RAM 有 32G，想保留 50%

```bash
leveldb_working_memory = 32G * (1 - .50) = 16G
```

### 第 2 步：计算每个虚拟节点所需的工作内存

Riak 1.2 会设置每个虚拟节点所需的内存。要得到这个内存大小，请用 LevelDB 的工作内存总量除以虚拟节点数。

```bash
vnode_working_memory = leveldb_working_memory / vnode_count
```

例如：

物理服务器上游 64 个虚拟节点

```bash
vnode_working_memory = 16G / 64 = 268,435,456 Bytes per vnode
```

### 第 3 步： 估计打开文件要使用的内存大小

打开文件所需的内存大小受很多因素的影响。下面的公式可以近似计算出中大型 LevelDB 所需的打开文件内存大小，误差在 10% 以内。

```bash
open_file_memory = (max_open_files-10) * (184 + (average_sst_filesize/2048) * (8 + ((average_key_size+average_value_size)/2048 +1) * 0.6)
```

如果服务器上有 64 个虚拟节点，相应的设置值如下表

```bash
open_file_memory =  (150-10)* (184 + (314,572,800/2048) * (8+((28+1024)/2048 +1)*0.6 = 191,587,760 Bytes
```

例如：

<table class="centered_table">
    <tr>
        <th>参数</th>
        <th>设置值</th>
    </tr>
    <tr>
        <td>max_open_files</td>
        <td>150</td>
    </tr>
    <tr>
        <td>average_sst_filesize</td>
        <td>314,572,800 字节</td>
    </tr>
    <tr>
        <td>average_key_size</td>
        <td>28 字节</td>
    </tr>
    <tr>
        <td>average_value_size</td>
        <td>1,024 字节</td>
    </tr>
    <tr>
        <td>总计</td>
        <td>191,587,760 字节</td>
    </tr>
</table>
<br>


### 第 4 步：计算写缓冲的平均大小

计算 `write_buffer_size_min` 和 `write_buffer_size_max` 的平均值。其默认值分别是 31,457,280 字节（30 MB） 和 62,914,560 字节（60 MB）。因此平均值是 47,185,920 字节（45 MB）。

### 第 5 步：计算虚拟节点的内存使用量

虚拟节点预计的内存使用量是下列各项之和：

<ul>
  <li>average_write_buffer_size（由第 4 步得出）</li>
  <li>cache_size（在 [[app.config|设置文件]] 文件中查看)</li>
  <li>open_file_memory（由第 3 步得出）</li>
  <li>20 MB（为了管理文件）</li>
</ul>

例如：

<table>
    <tr>

        <th>参数</th>
        <th>字节</th>
    </tr>
    <tr>
        <td>average_write_buffer_size</td>
        <td>47,185,920</td>
    </tr>
    <tr>
        <td>cache_size</td>
        <td>8,388,608</td>
    </tr>
    <tr>
        <td>open_file_memory</td>
        <td>191,587,760</td>
    </tr>
    <tr>
        <td>管理文件</td>
        <td>20,971,520</td>
    </tr>
    <tr>
        <td>总计</td>
        <td>268,133,808 (~255 MB)</td>
    </tr>
</table>

### 第 6 步：比较第 2 步和第 5 步得到的值，并作相应调整

例如：

在第 2 步，计算得到每个虚拟节点需要的工作内存是 268,435,456 字节。第 5 步，预计虚拟节点需要将近 268,133,808 字节的内存。这两步得到的结果相差 301,648 字节（约 300KB）。这两个值很接近，但比实际需求要精确一些。只要两个值相差不超过 5% 就行。

上面的计算过程可以在[这个电子表格](https://github.com/basho/basho_docs/raw/master/source/data/LevelDB1.2MemModel_calculator.xls)中自动完成。

## 调整 LevelDB

虽然对持久性存储来说，eLevelDB 很快，但其性能好坏还是取决于如何调整。所有的设置项目都在 `eleveldb` 区中。

<div id="Tips-Tricks"></div>
### 提示和技巧

  * __注意文件句柄限制__

    `max_open_files` 控制 eLevelDB 可以使用的文件描述符数量。eLevelDB 默认的设置是 20（也是最小值），也就是说，在一个有 64 个分区的集群中，某个时间点最多只能使用 1280 个文件句柄。在某些系统上会导致问题。（例如，OS X 默认的限制是 256）解决办法是增加可用的文件句柄数量。请参照“[[打开文件限制]]”一文。

  * __禁用 `noatime`，避免额外的硬盘磁头寻道__

    eLevelDB 读取和写入文件时非常粗暴。鉴于此，如果把 `noatime` 挂载选项加入 `/etc/fstab` 可以提速不少。设置后，所有文件都不会记录“上次访问时间”，因此减少了磁头寻道时间。如果需要记录上次访问时间，但又想从这种优化措施中受益，可以试一下 `relatime`。

    ```bash
    /dev/sda5    /data           ext3    noatime  1 1
    /dev/sdb1    /data/inno-log  ext3    noatime  1 2
    ```

### 推荐设置

下面是在 Linux 系统中推荐使用的一般设置。用户应该根据应用程序的需求做出调整。

在生产环境中，我们推荐在 `/etc/syscfg.conf` 中做如下设置：

```bash
net.core.wmem_default=8388608
net.core.rmem_default=8388608
net.core.wmem_max=8388608
net.core.rmem_max=8388608
net.core.netdev_max_backlog=10000
net.core.somaxconn=4000
net.ipv4.tcp_max_syn_backlog=40000
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
```

#### 块设备调度器

从 kernel 2.6 起，Linux 提供了 4 种 IO [电梯模型](http://www.gnutoolbox.com/linux-io-elevator/)。我们推荐使用 NOOP 电梯算法，请在 Linux 的 `boot` 命令中加入 `elevator=noop`。

#### ext4 选项

ext4 文件系统默认包含两个选项可以提升完整性，但性能会降低。Riak 的完整性通过在多个节点中保存相同的数据实现，这两个选项可以提升 levelDB 的性能。我们推荐的设置是：`barrier=0` 和 `data=writeback`。

#### CPU 节流

如果启用了 CPU 节流功能，将其禁用可以提升 levelDB 的性能。

#### 没有熵

如果使用 HTTPS 协议，kernel 2.6 中的程序经常会停止，等待 SSL 的熵位（entropy bit）。如果使用 HTTPS，我们推荐安装 [HAVEGE](http://www.irisa.fr/caps/projects/hipsor/)，生成伪随机数字。

#### clocksource（时钟源）

我们推荐在 kernel 的 `boot` 命令中加入 `clocksource=hpet`。TSC 时钟源被证实在使用多个物理内核或 CPU 节流的电脑中会导致问题。

#### swappiness

我们推荐在 `/etc/sysctl.conf` 文件中加入 `vm.swappiness=0`。`vm.swappiness` 默认值是 60，针对的是使用视窗程序的笔记本电脑用户。这个设置在 mysql 服务器中是个关键的设置，在介绍数据库性能的文章中经常会用到。

## FAQ

  * 在 Riak 1.0 之后的版本中如果要使用二级索引（2i），被索引的 bucket 必须使用 eLevelDB。

## 实现细节

[LevelDB](http://leveldb.googlecode.com/svn/trunk/doc/impl.html) 是由 Google 赞助的开源项目，然后被封装到一个 Erlang 应用程序，集成到 Riak 中用来在硬盘中存储键值对数据。LevelDB 的实现方法和单个 Bigtable 表很像。

### 如何管理多个“层级”

LevelDB 基于 memtable/sstable 模式设计。按序排列的表由多个层级控制。每个层级中存储的数据大约是上一级的 10 倍。从缓存中移出的数据存储在最低层（也叫 level-0）。当最底层中的文件超过某个值时（目前是 4），其中的所有文件会和下一级 level-1 中的重叠文件合并，生成一个新的 level-1 文件（每个 level-1 文件保存 2MB 数据）。

最低层中的文件可能会包含重叠的键。不过其他层级中的文件不会有重叠的键范围。我们来看一下 level-L，其中 L>=1。当 level-L 中的文件总大小超过 (10^L) MB 时（例如，level-1 是 10MB，level-2 是 100MB，以此类推），level-L 中的一个文件会和 level-(L+1) 中所有的重叠文件合并，在 level-(L+1) 中生成一系列新文件。这样的合并过程只需进行大块读和写操作，就可以逐步把低层中的数据更新到上一级（例如，使用最少的硬盘寻道时间）。

如果 level-L 超出了大小限制，LevelDB 会在后台线程中压缩数据。压缩的过程会从 level-L 中选择一个文件，并从 level-(L+1) 中选择所有的重叠文件。注意，如果 level-L 中文件只和 level-(L+1) 中的部分文件重叠，那么 level-(L+1) 中的所有文件都会输入压缩程序，压缩完成后会删除这些文件。从 level-0 到 level-1 的压缩有点特殊，因为 level-0 是特殊的层级（其中保存的文件相互之间可能会有重叠）。level-0 中的压缩会选择多个文件，以防相互之间有重叠。

压缩的过程会合并选中的文件，在 level-(L+1) 中生成一系列新文件。如果当前的输出文件超过了大小限制（2MB），LevelDB 会自动创建新文件。如果当前的输出文件中保存的键范围覆盖了 level-(L+2) 文件的 10 倍，LevelDB 也会创建一个新文件。最后一条规则可以确保以后压缩 level-(L+1) 文件时不用在 level-(L+2) 中选择太多的数据。

压缩的过程会保持原有的键顺序。详细说来，对于 level-L，LevelDB 会记住上一次在 level-L 中进行压缩时的最后一个键。下次在 level-L 中进行压缩时，会选择以这个键后面的那个键开始的文件（如果找不到符合要求的文件，就从键空间的开头开始）。

level-0 中的压缩会读取最多 4 个 1MB 的文件，最差的情况下会读取 level-1 中的所有文件（10MB）（此时 LevelDB 会读取 14MB 数据，再写入 14MB 数据）。

除了特殊的 level-0，在其他层级中压缩时，LevelDB 会从 level-L 中选择一个 2MB 的文件。在最坏的情况下，这样会覆盖 level-(L+1) 中将近 12 个文件（有 10 个是因为 level-(L+1) 是 level-L 大小的 10 倍，另外还要两个 2 个是因为 level-L 中的文件范围和 level-(L+1) 中的文件范围不匹配。）。因此，压缩的过程中会读取 26MB 数据，写入 26MB 数据。假设硬盘的 IO 速率是 100MB/s，最坏的情况下需要大约 0.5 秒。

如果限制后台写操作在一个合理的水平，例如是整个速率的 10%，压缩就要使用 5 秒。如果用户使用 10MB/s 的速率写入，LevelDB 有可能会创建很多的 level-0 文件（要保存 5*10MB 的数据，大约需要 50 个文件）。这回显著增加读操作的消耗，因为每个读操作中要合并更多的文件。

### 压缩

各层级中的数据最终会压缩到按序排列的数据文件中。压缩程序首选会计算各层级的得分，即层级中总字节数和所要字节数之比。对 level-0 来说，计算的是总文件数和所要文件数之比。得分最高的层级会进行压缩。

压缩 level-0 时需要处理一个特殊情况，选定要压缩的 level-0 主文件后，还要查看其他的 level-0 文件，看一些重叠的程度。这个过程的目的是为了节省一些 IO，我们期望针对 level-0 的压缩通常会使用“level-0 中的所有文件”。

具体细节请参照[这里](http://www.google.com/codesearch#mHLldehqYMA/trunk/db/version_set.cc)的 PickCompaction。

### eLevelDB 和 Bitcask 对比

LevelDB 是持久的有序映射，而 Bitcask 是持久的哈希表（无顺序）。Bitcask 把所有的键都保存在内存中，对于有大量键的数据库，这回耗尽物理内存，转而使用虚拟内存，导致服务器性能下降。LevelDB 可以保证每次查找最多只会进行一次硬盘搜索，降低硬盘搜索时间。例如，读取操作需要在每个层级中进行一次搜索（在最后一个层级中，前面的所有层级应该都在系统的缓冲中有缓存了）。如果存储总量的 1% 可以放入内存，LevelDB 就需要进行两次搜索。

## 恢复

LevelDB 绝不会在当前位置写入数据，而是把数据附加到日志文件的末尾，或者把现有的文件合并生成新文件。因此系统崩溃会生成一个部分写入日志记录（或很多）。恢复时，LevelDB 会检查校验和找到不完整的记录并跳过这些记录。

### eLevelDB 的数据库文件

下面列出了两个文件夹，其内容就是使用 eLevelDB 时可以在硬盘上看到的。在这个例子中，我们使用的是有 64 个分区的环，所以有 64 个文件夹，各自对应到自己的 LevelDB 数据库。

```bash
leveldb/
|-- 0
|   |-- 000003.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- MANIFEST-000002
|-- 1004782375664995756265033322492444576013453623296
|   |-- 000005.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- LOG.old
|   |-- MANIFEST-000004
|-- 1027618338748291114361965898003636498195577569280
|   |-- 000005.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- LOG.old
|   |-- MANIFEST-000004

... etc ...

|-- 981946412581700398168100746981252653831329677312
    |-- 000005.log
    |-- CURRENT
    |-- LOCK
    |-- LOG
    |-- LOG.old
    |-- MANIFEST-000004

64 directories, 378 files
```

进行多次 PUT 请求（写操作）后，使用 eLevelDB 的 Riak 集群看上去如下所示：

```bash
gburd@toe:~/Projects/riak/dev/dev1/data$ tree leveldb/
leveldb/
|-- 0
|   |-- 000118.sst
|   |-- 000119.sst
|   |-- 000120.sst
|   |-- 000121.sst
|   |-- 000123.sst
|   |-- 000126.sst
|   |-- 000127.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- LOG.old
|   |-- MANIFEST-000125
|-- 1004782375664995756265033322492444576013453623296
|   |-- 000120.sst
|   |-- 000121.sst
|   |-- 000122.sst
|   |-- 000123.sst
|   |-- 000125.sst
|   |-- 000128.sst
|   |-- 000129.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- LOG.old
|   |-- MANIFEST-000127
|-- 1027618338748291114361965898003636498195577569280
|   |-- 000003.log
|   |-- CURRENT
|   |-- LOCK
|   |-- LOG
|   |-- MANIFEST-000002

... etc ...

|-- 981946412581700398168100746981252653831329677312
    |-- 000003.log
    |-- CURRENT
    |-- LOCK
    |-- LOG
    |-- MANIFEST-000002

64 directories, 433 files
```
