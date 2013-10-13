---
title: Bitcask
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: intermediate
keywords: [backends, planning, bitcask]
prev: "[[Choosing a Backend]]"
up:   "[[Choosing a Backend]]"
next: "[[LevelDB]]"
interest: false
---

## 概览

[Bitcask](https://github.com/basho/bitcask) 是一个 Erlang 程序，提供了 API 把键值对
存储在日志结构的哈希表中，速度非常快。其设计借鉴了很多日志结构文件系统的原则，也受到了日志
文件合并的启发。

### 优点

  * 各条目读写时迟延很低

    因为 Bitcask 数据库文件“只写入一次，而后附加”的特性

  * 高吞吐量，特别是把随机的条目写入输入流中时

    因为要写入的数据不需要在硬盘上排序，还因为日志结构的设计在写入时只需要最少得磁头移动，
    磁头移动往往会用尽硬盘的 IO 和带宽

  * 无需降级即可处理比 RAM 更大的数据集

    因为在 Bitcask 中获取数据时是直接查看内存中的哈希表来查找硬盘上的数据的，这种方式效率
    很高，即使数据集很大也不怕

  * 读取任何数据只需单次寻道

    Bitcask 在内存中保存的键哈希表直接指明了数据在硬盘上的位置，因此读取数据时磁盘寻道
    从来不会超过一次，某些情况下，因为操作系统的文件系统有缓存，甚至一次都不用

  * 可预测的查询和插入性能

    从上面的说明可以看出，读取操作的方式是固定可预测的。你可能没发现，这种特性对写入操作
    同样有效。写入操作只要找到当前打开文件的末尾，把数据附加其后即可

  * 快速、有限制的恢复

    因为“只写入一次，而后附加”的特性，恢复的过程异常简单而且快速。唯一会丢失的数据是上次
    打开文件写入末尾的记录。恢复时只要检查最后一到两个记录仪，确认 CRC 数据保证数据的一致性

  * 备份简单

    在大多数系统中备份都很复杂，得益于“只写入一次，而后附加”，Bitcask 简化了这个过程。
    任何能按照硬盘上的顺序存储或复制文件的工具都可以备份或复制 Bitcask 数据库

### 缺点

  * 键必须能装入内存

    Bitcask 总是把所有的键都保存在内存中，因此系统必须有足够大的内存才能放得下全部的键，
    而且还要有余量处理其他操作和常驻内存的文件系统缓冲。

## 安装 Bitcask

Riak 中就包含了 Bitcask。其实 Bitcask 是默认的存储引擎，无需再安装。

`app.config` 中针对 Bitcask 的默认设置如下：

```erlang
 %% Bitcask Config
 {bitcask, [
             {data_root, "/var/lib/riak/bitcask"}
           ]},
```

## 设置 Bitcask

要想修改 Bitcask 的默认行为，请把下面的设置加入 [[app.config|Configuration Files]] 文件
的 `bitcask` 区。

### 打开超时

`open_timeout` 设置指定在尝试创建或打开数据文件夹时 Bitcask 允许使用的最长时间，单位
为秒，默认值是 `4`。一般来说无需修改这个值。如果由于某些原因导致超时了，会在日志中看到
消息：`"Failed to start bitcask backend: ...`。这时才需要设置一个较长的超时值。

```erlang
{bitcask, [
        ...,
            {open_timeout, 4} %% Wait time to open a keydir (in seconds)
        ...
]}
```

### 同步策略

`sync_strategy` 设置何时把数据同步到硬盘来控制写入的持久性。默认的设置可以避免因应用程序
出错导致数据丢失，但却有可能因为系统出错（例如 硬件问题，OS 问题，或者停电）导致其中的数据丢失。

默认的设置是 `none`，即在操作系统刷新缓存时，会把其中的数据写入硬盘。如果在刷新之前系统出
问题了（停电，损毁等），数据就会丢失。

设置为 `o_sync` 就可以强制每次写入缓冲后都摆数据存入硬盘。这样可以得到更好地持久性，不过写
操作的吞吐量会增加，因为每次写入都要等待完全写入硬盘。

___可用的同步策略___

* `none` - （默认值）交由操作系统管理同步写操作
* `o_sync` - 使用 O_SYNC 旗标，强制每次写操作都要同步
* `{seconds, N}` - Riak 会强制 Bitcask 每 `N` 秒同步一次

```erlang
{bitcask, [
        ...,
            {sync_strategy, none}, %% Let the O/S decide when to flush to disk
        ...
]}
```

<div class="note"><div class="title">Bitcask doesn't actually set O_SYNC on
Linux</div><p>At the time of this writing, due to an unresolved Linux <a
href="http://permalink.gmane.org/gmane.linux.kernel/1123952">kernel issue</a>
related to the <a
href="https://github.com/torvalds/linux/blob/master/fs/fcntl.c#L146..L198">implementation
of <code>fcntl</code></a> it turns out that Bitcask will not set the
<code>O_SYNC</code> flag on the file opened for writing, the call to
<code>fcntl</code> doesn't fail, it is silently ignored by the Linux kernel.
You will notice a <a
href="https://github.com/basho/riak_kv/commit/6a29591ecd9da73e27223a1a55acd80c21d4d17f#src/riak_kv_bitcask_backend.erl">warning
message</a> in the log files of the format:<br /><code>{sync_strategy,o_sync} not
implemented on Linux</code><br /> indicating that this issue exists on your system.
Without the <code>O_SYNC</code> setting enabled there is potential for data
loss if the OS or system dies (power outtage, kernel panic, reboot without a
sync) with dirty buffers not yet written to stable storage.</div>

### Disk-Usage and Merging Settings

Riak K/V stores each vnode partition of the ring as a separate Bitcask
directory within the configured bitcask data directory. Each of these
directories will contain multiple files with key/value data, one or more
"hint" files that record where the various keys exist within the data files,
and a write lock file. The design of Bitcask allows for recovery even when
data isn't fully synchronized to disk (partial writes). This is accomplished
by maintaining data files that are append-only (never modified in-place) and
are never reopened for modification (only reading).

The data management strategy trades disk space for operational efficiency.
There can be a significant storage overhead that is un-related to your
working data set but can be tuned to best fit your usage. In short, disk
space is used until a threshold is met, then unused space is reclaimed
through a process of merging. The merge process traverses data files and
reclaims space by eliminating out-of-date versions of key/value pairs writing
only the current key/value pairs to a new set of files within the directory.

The merge process is affected by the settings described below. In the
discussion, "dead" refers to keys that are no longer the latest value or
those that have been deleted; "live" refers to keys that are the newest value
and have not been deleted.

#### Max File Size

The `max_file_size` setting describes the maximum permitted size for any
single data file in the Bitcask directory. If a write causes the current
file to exceed this size threshold then that file is closed, and a new file
is opened for writes.

Increasing `max_file_size` will cause Bitcask to create fewer, larger
files, which are merged less frequently while decreasing it will cause
Bitcask to create more numerous, smaller files, which are merged more
frequently. If your ring size is 16 your servers could see as much as 32GB
of data in the bitcask directories before the first merge is triggered
irrespective of your working set size. Plan storage accordingly and don't
be surprised by larger than working set on disk data sizes.

Default is: `16#80000000` which is 2GB in bytes

```erlang
{bitcask, [
        ...,
        {max_file_size, 16#80000000}, %% 2GB default
        ...
]}
```

#### Merge Window

The `merge_window` setting lets you specify when during the day merge
operations are allowed to be triggered. Valid options are:

* `always` (default) No restrictions
* `never` Merge will never be attempted
* `{Start, End}` Hours during which merging is permitted, where `Start` and
  `End` are integers between 0 and 23.

If merging has a significant impact on performance of your cluster, or your
cluster has quiet periods in which little storage activity occurs, you may
want to change this setting from the default.

Default is: `always`

```erlang
{bitcask, [
        ...,
            {merge_window, always}, %% Span of hours during which merge is acceptable.
        ...
]}
```

<div class="note"><div class="title"> `merge_window` and Multi-Backend</div>
When using Bitcask with [[Multi-Backend|Multi]], please note that if you
wish to use a merge window, you *must* set it in the global `bitcask`
section of your `app.config`.  `merge_window` settings in per-backend
sections are ignored.
</div>


#### Merge Triggers

Merge triggers determine under what conditions merging will be
invoked.

* _Fragmentation_: The `frag_merge_trigger` setting describes what ratio of
  dead keys to total keys in a file will trigger merging. The value of this
  setting is a percentage (0-100). For example, if a data file contains 6
  dead keys and 4 live keys, then merge will be triggered at the default
  setting. Increasing this value will cause merging to occur less often,
  whereas decreasing the value will cause merging to happen more often.

  Default is: `60`

* _Dead Bytes_: The `dead_bytes_merge_trigger` setting describes how much
  data stored for dead keys in a single file will trigger merging. The
  value is in bytes. If a file meets or exceeds the trigger value for dead
  bytes, merge will be triggered. Increasing the value will cause merging
  to occur less often, whereas decreasing the value will cause merging to
  happen more often.

  When either of these constraints are met by any file in the directory,
  Bitcask will attempt to merge files.

  Default is: `536870912` which is 512MB in bytes

```erlang
{bitcask, [
        ...,
        %% Trigger a merge if any of the following are true:
            {frag_merge_trigger, 60}, %% fragmentation >= 60%
        {dead_bytes_merge_trigger, 536870912}, %% dead bytes > 512 MB
        ...
]}
```

#### Merge Thresholds

Merge thresholds determine which files will be chosen to be included in a
merge operation.

- _Fragmentation_: The `frag_threshold` setting describes what ratio of
    dead keys to total keys in a file will cause it to be included in the
    merge. The value of this setting is a percentage (0-100). For example,
    if a data file contains 4 dead keys and 6 live keys, it will be included
    in the merge at the default ratio. Increasing the value will cause fewer
    files to be merged, decreasing the value will cause more files to be
    merged.

    Default is: `40`

- _Dead Bytes_: The `dead_bytes_threshold` setting describes the minimum
    amount of data occupied by dead keys in a file to cause it to be included
    in the merge. Increasing the value will cause fewer files to be merged,
    decreasing the value will cause more files to be merged.

    Default is: `134217728` which is 128MB in bytes

- _Small File_: The `small_file_threshold` setting describes the minimum
    size a file must have to be _excluded_ from the merge. Files smaller
    than the threshold will be included. Increasing the value will cause
    _more_ files to be merged, decreasing the value will cause _fewer_ files
    to be merged.

    Default is: `10485760` while is 10MB in bytes

When any of these constraints are met for a single file, it will be
included in the merge operation.

```erlang
{bitcask, [
        ...,
        %% Conditions that determine if a file will be examined during a merge:
            {frag_threshold, 40}, %% fragmentation >= 40%
        {dead_bytes_threshold, 134217728}, %% dead bytes > 128 MB
        {small_file_threshold, 10485760}, %% file is < 10MB
        ...
]}
```

<div class="note"><div class="title">Choosing Threshold Values</div><p>The
values for <code>frag_threshold</code> and <code>dead_bytes_threshold</code>
<i>must be equal to or less than their corresponding trigger values</i>. If
they are set higher, Bitcask will trigger merges where no files meet the
thresholds, and thus never resolve the conditions that triggered
merging.</p></div>

#### 折叠键阈值

如果另一个折叠在 `max_fold_age` 之前开始，而且有不超过 `max_fold_puts` 个更新，那么
折叠键会重用键目录。否则就会等到所有当前的折叠键完成后再开始。把前面这两个设置设为 -1 则
完全禁止折叠键。

```erlang
{bitcask, [
        ...,
            {max_fold_age, -1}, %% Age in micro seconds (-1 means "unlimited")
        {max_fold_puts, 0}, %% Maximum number of updates
        ...
]}
```

#### 自动过期

默认情况下，Bitcask 会保存所有数据。如果数据具有时效性，或者空间有限需要清除数据，那么就
可以设定 `expiry_secs` 选项。如果要在一天后自动清除数据，请将其设为 `86400`。

默认值：`-1`，即禁用自动过期

```erlang
{bitcask, [
        ...,
        {expiry_secs, -1}, %% Don't expire items based on time
        ...
]}
```

<div class="note">
<p>被过期数据占用的空间可能不会立马就能使用，但这些数据立即就无法请求。向键写入新的数据会
修改时间戳，因此不会过期。</p>
</div>

{{#1.2.1+}}

默认情况下，只要数据文件包含过期的键就会触发合并操作。某些情况下，会导致过多的合并。
为了避免发生这样的事，可以设置 `expiry_grace_time` 选项。如果只是由于键过期，Bitcask 会
延迟触发合并所设置的秒数。设置为 `3600` 可以有效限制每个桶每小时只进行一次合并。

默认值：`0`

```erlang
{bitcask, [
        ...,
        {expiry_grace_time, 3600}, %% Limit rate of expiry merging
        ...
]}
```

{{/1.2.1+}}

## 调整 Bitcask

Bitcask 有很多令人满意的功能，在生产环境中已经证实其很稳定、很可靠，迟延小，吞吐量大。

### 提示和技巧

  * __Bitcask 依赖于文件系统的缓存__

    某些数据存储层把页缓冲和块缓冲放在内存中，但 Bitcask 不是这样。Bitcask 依赖于文件系统
    的缓存。调整文件系统的缓存可以影响 Bitcask 的性能。

  * __注意文件句柄限制__

    请阅读“[[打开文件限制|Open-Files-Limit]]”一文了解详情。

  * __避免每次读写操作更新文件元数据的开销（例如上次访问时间）__

    如果把 `noatime` 挂载选项加入 `/etc/fstab` 可以提速不少。设置后，所有文件都不会记录
    “上次访问时间”，因此减少了磁头寻道时间。如果需要记录上次访问时间，但又想从这种优化措施
    中受益，可以试一下 `relatime`。

    ```
    /dev/sda5    /data           ext3    noatime  1 1
    /dev/sdb1    /data/inno-log  ext3    noatime  1 2
    ```

  * __不要频繁修改键__

    如果频繁修改键，分段数量会显著增多。为了避免这种情况，应该把片段触发和阈值设的小一点。

  * __限制空间用量__

    如果限制了空间用量，控制死亡键占用的空间就显得尤为重要了。为了避免浪费空间，可以把死亡
    键字节阈值和触发阈值设的小一点。

  * __定期清除过期数据__

    如果要自动清除过期数据，请设置一个所需的 `expiry_secs` 值。
    等于或超过 `expiry_secs` 时间没有修改的键就无法访问了。

  * __各节点的分区数多一些__

    集群中分区越多，Bitcask 能[[打开的文件|Open-Files-Limit]]就越多。如果要减少打开文件
    数，可以增加 `max_file_size`，写入更大的文件。还可以减少分段和死亡键设置，并
    增加 `small_file_threshold`，这样合并操作会把打开文件数保持在一个很低的水平上。

  * __白天流量多，晚上流量少__

    为了复制大量写入卷而不降低性能，应该避免在高峰期进行合并操作。尽量把 `merge_window` 的
    值设在一天中流量很低的时段。

  * __多集群副本（Riak Enterprise）__

    如果 Riak Enterprise 激活了副本功能，集群可能会由于“重演”（replay）产生大量分段和
    死亡字节。而且，因为完整同步会操作全部分区，尽量连续的访问数据（在较少的文件之间）可以
    提高效率。减少分段和死亡字节设置可以提高性能。

## FAQ

  * [[为什么好像只有 Riak 节点重启时 Bitcask 才会进行合并？|Developing on Riak FAQs#why-does-it-seem-that-bitc]]
  * [[如果键索引超出了内存大小，Bitcask 会怎么办？|Operating Riak FAQs#if-the-size-of-key-index-e]]
  * [[Bitcask 容量规划|Bitcask Capacity Planning]]

## Bitcask 的实现细节

Riak 会为使用 Bitcask 数据库的虚拟节点创建一个文件夹。在每个文件夹中，一次最多只有一个
数据库文件打开接受数据写入。写入的这个文件会一直保持打开只到其大小超过了某个值，然后会被
关闭，系统再创建一个新文件接受写入操作。只要文件被关闭了，不管是有意的还是因为服务器出问题了，
这个文件就无法再被修改，无法再次打开接受写入操作了。

当前打开接受写入操作的文件只能把数据附加到文件末尾，也就是说，连续的写入不会明显增加
硬盘的 IO 使用量。注意，如果文件系统启用了 `atime`，可能会破坏写入操作，因为硬盘磁头要在
来回移动更新数据块和文件及文件夹的元数据块。基于日志的数据块其主要优势是可以最小化硬盘磁头的
寻道时间。从 Bitcask 中删除数据分两步。首先，我们在打开的文件末尾加入一个“墓碑”记录，把值
标记为删除。同时，我们从内存中的 `keydir` 中删除这个键的引用。

合并时，只会扫描不活动的数据文件，而且只有那些不是“墓碑”的值才会合并到活动的数据文件中。
这样可以很高效的删除过期数据，并将其占用的空间释放出来。这种数据管理方式久而久之便会用掉
很多空间，因为只写入新数据，而不动旧数据。一个我们称之为“合并”的压缩过程可以避免这个问题。
合并操作会遍历 Bitcask 中所有不活动的文件，生成的文件中只包含新鲜数据，即每个键对应最新
版本的值。

### Bitcask 数据库文件

下面列出了两个文件夹，其内容就是使用 Bitcask 时可以在硬盘上看到的。在这个例子中，我们使用
的是有 64 个分区的环，所以有 64 个文件夹，各自对应到自己的 Bitcask 数据库。

```
bitcask/
|-- 0-131678707860265
|-- 1004782375664995756265033322492444576013453623296-1316787078215038
|-- 1027618338748291114361965898003636498195577569280-1316787078218073

... etc ...

`-- 981946412581700398168100746981252653831329677312-1316787078206121
```

注意，节点刚启动时只会为每个虚拟节点分区创建保存数据的文件夹，不会有 Bitcask 相关的文件。

在使用 Bitcask 的 Riak 集群中执行一次PUT 请求（写操作）

```
curl http://localhost:8098/riak/test/test -XPUT -d 'hello' -H 'content-type: text/plain'
```

这个集群的 N 值是 3，所以你会看到有 3 个虚拟节点的分区响应了这个请求，这是就创建
了 Bitcask 数据库文件。

```
bitcask/

... etc ...

|-- 1118962191081472546749696200048404186924073353216-1316787078245894
|   |-- 1316787252.bitcask.data
|   |-- 1316787252.bitcask.hint
|   `-- bitcask.write.lock

... etc ...


|-- 1141798154164767904846628775559596109106197299200-1316787078249065
|   |-- 1316787252.bitcask.data
|   |-- 1316787252.bitcask.hint
|   `-- bitcask.write.lock

... etc ...


|-- 1164634117248063262943561351070788031288321245184-1316787078254833
|   |-- 1316787252.bitcask.data
|   |-- 1316787252.bitcask.hint
|   `-- bitcask.write.lock

... etc ...

```

随着数据不断的写入集群，Bitcask 文件的数量会不断增多，只到触发合并操作。

```
bitcask/
|-- 0-1317147619996589
|   |-- 1317147974.bitcask.data
|   |-- 1317147974.bitcask.hint
|   |-- 1317221578.bitcask.data
|   |-- 1317221578.bitcask.hint
|   |-- 1317221869.bitcask.data
|   |-- 1317221869.bitcask.hint
|   |-- 1317222847.bitcask.data
|   |-- 1317222847.bitcask.hint
|   |-- 1317222868.bitcask.data
|   |-- 1317222868.bitcask.hint
|   |-- 1317223014.bitcask.data
|   `-- 1317223014.bitcask.hint
|-- 1004782375664995756265033322492444576013453623296-1317147628760580
|   |-- 1317147693.bitcask.data
|   |-- 1317147693.bitcask.hint
|   |-- 1317222035.bitcask.data
|   |-- 1317222035.bitcask.hint
|   |-- 1317222514.bitcask.data
|   |-- 1317222514.bitcask.hint
|   |-- 1317223035.bitcask.data
|   |-- 1317223035.bitcask.hint
|   |-- 1317223411.bitcask.data
|   `-- 1317223411.bitcask.hint
|-- 1027618338748291114361965898003636498195577569280-1317223690337865
|-- 1050454301831586472458898473514828420377701515264-1317223690151365

... etc ...

```

以上是 Bitcask 的常见表现。
