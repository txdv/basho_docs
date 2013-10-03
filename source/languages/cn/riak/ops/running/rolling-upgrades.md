---
title: Rolling Upgrades
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [upgrading]
---

{{#1.4.0+}}
<div class="note">
<div class="title">升级到 Riak 1.4+ 的注意事项</div>
<p>因为 Riak 1.0 和 1.4 两个版本之间有差异，因此无法直接升级，需要先升级
到 Riak 1.3.2，再升级到 Riak 1.4.0+。</p>
<p>运过运行了 riak_control，在滚动升级的过程中应该禁用。</p>
</div>
{{/1.4.0+}}

Riak 节点现在可以相互之间协商，决定支持的操作模式。这一功能运行运行着不同版本
的 Riak 集群无需做特殊的设置就可以正常操作，还可以简化滚动升级的过程。

在以前的 Riak 版本中，滚动升级时必须要禁用新功能，当所有节点都升级完后才能启用。

{{#1.1.0-}}

<div class="note">
<div class="title">升级到 Riak 1.0 的注意事项</div>
<p>按照下面针对不同操作系统的说明，应该可以从 Riak 0.13+ 升级到 Riak 1.0。
但升级时还是要考虑几件事。Rial 1.0 添加了一些新功能，滚动升级时需要额外的操作。
这些新功能有 Riak Pipe，MapReduce 用到的新数据处理代码库，以及为支持
异步 keylisting 而升级的后台 API。如果升级后没有启用这些功能，Riak 会使用旧有
功能。这些功能**只有**集群中所有的节点都升级到 1.0 后才能启用。</p>

<p>在升级到 1.0 之前，请在所有使用 1.0.0 之前版本的节点中执行下面的命令，确保
转移命令能正常汇报。如果还没进入 Riak 控制台，请执行 `riak attach` 命令。</p>

```erlang
> riak_core_node_watcher:service_up(riak_pipe, self()).
```

<p>如果忘了执行上述命令（或者使用 1.0.0 之前版本的节点重启了），随时都可以执行。</p>

<p>升级到 1.0 之后，请按照针对各操作系统的说明执行第 9 步和第 10 步。</p>
</div>

{{/1.1.0-}}

## Debian/Ubuntu

下面演示了如何升级使用 Basho 提供的 Debian 安装包安装的 Riak 节点。

1\. 停止 Riak

```bash
riak stop
```

2\. 备份 Riak 的 etc 和数据文件夹等

```bash
sudo tar -czf riak_backup.tar.gz /var/lib/riak /etc/riak
```

3\. 升级 Riak

```bash
sudo dpkg -i <riak_package_name>.deb
```

4\. 重启 Riak

```bash
riak start
```

5\. 验证 Riak 是否使用了新版本

```bash
riak-admin status
```

6\. 等待 riak_kv 服务启动

```bash
riak-admin wait-for-service riak_kv <target_node>
```

* &lt;target_node&gt; 是刚升级的节点（例如 riak@192.168.1.11）

7\. 等待所有提示移交转移操作完成

```bash
riak-admin transfers
```

* 这个节点下线时，其他节点会担起责任接受写入操作。节点上线后数据会转移过来。

8\. 对集群中其他节点重复执行上述步骤

{{#1.3.1+}}
<div class="info">
<div class="title">关于二级索引的注意事项</div>
如果使用 Riak 的二级索引，而且从 Riak 1.3.1 之前的版本升级，需要
执行 [[riak-admin reformat-indexes|riak-admin Command Line#reformat-indexes]] 命令
重新格式化索引。关于重新格式化索引的详细信息请阅读
[发布说明](https://github.com/basho/riak/blob/master/RELEASE-NOTES.md)。
</div>
{{/1.3.1+}}

{{#1.1.0-}}

<div class="note">
只有从 Riak 1.0 之前的版本升级到 1.0，才需要执行下面两步。
</div>

9\. 所有节点都升级完成后，把下面的代码加入每个节点 `/etc/riak` 目录
下的 `app.config` 文件中。首先，把下面的代码加入 `riak_kv` 区：

```erlang
{legacy_keylisting, false},
{mapred_system, pipe},
{vnode_vclocks, true}
```

然后，把下面的代码加入 `riak_core` 区：

```erlang
{platform_data_dir, "/var/lib/riak"}
```

10\. 在集群中所有节点上按次序执行 `riak stop` 和 `riak start` 命令。
或者在每个节点中执行 `riak attach` 命令，然后在执行下面的命令：

```erlang
> application:set_env(riak_kv, legacy_keylisting, false).
> application:set_env(riak_kv, mapred_system, pipe).
> application:set_env(riak_kv, vnode_vclocks, true).
```

{{/1.1.0-}}

## RHEL/CentOS

下面演示了如何升级使用 Basho 提供的 RHEL/CentOS 安装包安装的 Riak 节点。

1\. 停止 Riak

```bash
riak stop
```


2\. 备份 Riak 的 etc 和数据文件夹等

```bash
sudo tar -czf riak_backup.tar.gz /var/lib/riak /etc/riak
```

3\. 升级 Riak

```bash
sudo rpm -Uvh <riak_package_name>.rpm
```

4\. 重启 Riak

```bash
riak start
```

5\. 验证 Riak 是否使用了新版本

```bash
riak-admin status
```

6\. 等待 riak_kv 服务启动

```bash
riak-admin wait-for-service riak_kv <target_node>
```

* &lt;target_node&gt; 是刚升级的节点（例如 riak@192.168.1.11）

7\. 等待所有提示移交转移操作完成

```bash
riak-admin transfers
```

* 这个节点下线时，其他节点会担起责任接受写入操作。节点上线后数据会转移过来。

8\. 对集群中其他节点重复执行上述步骤

{{#1.3.1+}}
<div class="info">
<div class="title">关于二级索引的注意事项</div>
如果使用 Riak 的二级索引，而且从 Riak 1.3.1 之前的版本升级，需要
执行 [[riak-admin reformat-indexes|riak-admin Command Line#reformat-indexes]] 命令
重新格式化索引。关于重新格式化索引的详细信息请阅读
[发布说明](https://github.com/basho/riak/blob/master/RELEASE-NOTES.md)。
</div>
{{/1.3.1+}}

{{#1.1.0-}}
<div class="note">
只有从 Riak 1.0 之前的版本升级到 1.0，才需要执行下面两步。
</div>

9\. 所有节点都升级完成后，把下面的代码加入每个节点 `/etc/riak` 目录
下的 `app.config` 文件中。首先，把下面的代码加入 `riak_kv` 区：
```erlang
{legacy_keylisting, false},
{mapred_system, pipe},
{vnode_vclocks, true}
```

然后把下面的代码加入 `riak_core` 区：

```erlang
{platform_data_dir, "/var/lib/riak"}
```

10\. 在集群中所有节点上按次序执行 `riak stop` 和 `riak start` 命令。
或者在每个节点中执行 `riak attach` 命令，然后在执行下面的命令：

```erlang
> application:set_env(riak_kv, legacy_keylisting, false).
> application:set_env(riak_kv, mapred_system, pipe).
> application:set_env(riak_kv, vnode_vclocks, true).
```

{{/1.1.0-}}

## Solaris/OpenSolaris

下面演示了如何升级使用 Basho 提供的 Solaris/OpenSolaris 安装包安装的 Riak 节点。

1\. 停止 Riak

```bash
riak stop
```

<div class="note">
如果使用“服务管理工具”（SMF）管理 Riak，那么就不能使用 `riak stop`，而
要用 `svcadm`：
<br /><br />
```bash
sudo svcadm disable riak
```
</div>

2\. 备份 Riak 的 etc 和数据文件夹等

```bash
sudo gtar -czf riak_backup.tar.gz /opt/riak/data /opt/riak/etc
```

3\. 卸载 Riak

```bash
sudo pkgrm BASHOriak
```

4\. 安装 Riak 新版本

```bash
sudo pkgadd -d <riak_package_name>.pkg
```

{{#1.1.0-}}
<div class="note">
如果从 Riak 0.12 升级，需要使用第二步中的备份恢复 etc 文件夹。卸载时 0.12 安装包删除了 etc 文件夹。
</div>
{{/1.1.0-}}

5\. 重启 Riak

```bash
riak start
```

<div class="note">如果使用 SMF，启动 Riak 要使用 `svcadm`：
<br /><br />
```bash
sudo svcadm enable riak
```
</div>

6\. 验证 Riak 是否使用了新版本

```bash
riak-admin status
```

7\. 等待 riak_kv 服务启动

```bash
riak-admin wait-for-service riak_kv <target_node>
```

* &lt;target_node&gt; 是刚升级的节点（例如 riak@192.168.1.11）

8\. 等待所有提示移交转移操作完成

```bash
riak-admin transfers
```

* 这个节点下线时，其他节点会担起责任接受写入操作。节点上线后数据会转移过来。

9\. 对集群中其他节点重复执行上述步骤

{{#1.3.1+}}
<div class="info">
<div class="title">关于二级索引的注意事项</div>
如果使用 Riak 的二级索引，而且从 Riak 1.3.1 之前的版本升级，需要
执行 [[riak-admin reformat-indexes|riak-admin Command Line#reformat-indexes]] 命令
重新格式化索引。关于重新格式化索引的详细信息请阅读
[发布说明](https://github.com/basho/riak/blob/master/RELEASE-NOTES.md)。
</div>
{{/1.3.1+}}

{{#1.1.0-}}
<div class="note">
只有从 Riak 1.0 之前的版本升级到 1.0，才需要执行下面两步。
</div>

10\. 所有节点都升级完成后，把下面的代码加入每个节点 `/etc/riak` 目录
下的 `app.config` 文件中。首先，把下面的代码加入 `riak_kv` 区：

```erlang
{legacy_keylisting, false},
{mapred_system, pipe},
{vnode_vclocks, true}
```

然后把下面的代码加入 `riak_core` 区：

```erlang
{platform_data_dir, "/opt/riak/data"}
```

11.\ 在集群中所有节点上按次序执行 `riak stop` 和 `riak start` 命令。
或者在每个节点中执行 `riak attach` 命令，然后在执行下面的命令：

```erlang
> application:set_env(riak_kv, legacy_keylisting, false).
> application:set_env(riak_kv, mapred_system, pipe).
> application:set_env(riak_kv, vnode_vclocks, true).
```

{{/1.1.0-}}

## Basho 补丁

升级后，应该确保 `basho-patches` 文件夹中的所有自定义补丁可以在升级后的版本中
正常使用。如果发现无法正常使用的补丁，必须在部署到生产环境前将其删除。

下表列出了在所支持的操作系统中 `basho-patches` 文件夹的位置：

<table style="width: 100%; border-spacing: 0px;">
<tbody>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>CentOS &amp; RHEL Linux</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/lib64/riak/lib/basho-patches</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>Debian &amp; Ubuntu Linux</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/lib/riak/lib/basho-patches</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>FreeBSD</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/local/lib/riak/lib/basho-patches</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>SmartOS</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/opt/local/lib/riak/lib/basho-patches</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>Solaris 10</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/opt/riak/lib/basho-patches</tt></p>
</td>
</tr>
</tbody>
</table>

{{#1.3.0+}}
## Riaknostic

升级后最好检查以下基本的设置和 Riak 节点的健康状况，这一过程可以
使用 Riak 内置的诊断工具 *Riaknostic* 完成。

确保节点上运行着 Riak，然后执行下面的命令：

```
riak-admin diag
```

按照上述命令的输出操作，以获得最优性能。
{{/1.3.0+}}
