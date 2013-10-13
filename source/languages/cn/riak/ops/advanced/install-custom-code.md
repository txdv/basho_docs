---
title: Installing Custom Code
project: riak
version: 1.4.2+
document: tutorial
toc: true
audience: advanced
keywords: [operators, code, erlang, javascript]
---

Riak 允许在编译好的模块中使用 Erlang 函数做 [[pre/post-commit 钩子|Advanced Commit Hooks]]，
还可以使用 Erlang 函数进行 MapReduce 操作。这篇文档会介绍这两种情况的安装步骤。

开发者可以编译[[自己编写的 Erlang 代码|Advanced Commit Hooks]]，然后以 *beam* 格式分发。
请注意，在 Erlang 中文件的名字必须和模块名一样。所以，如果为文件起好了名字 `validate_json.beam`，
就不要轻易修改。

*注意：[[设置|Installing Custom Code#Configure]]这一步也可用于安装 JavaScript 文件。*

### 编译

如果有一些 Erlang 代码想编译，请谨记下面的说明。

<div class="info">
<div class="title">Note on the Erlang Compiler</div>
必须使用 Riak 附带的 Erlang 编译器（<tt>erlc</tt>）。如果是从源码安装的 Riak，则必须使用
和编译 Riak 源码时使用的 Erlang 编译器相同的版本。如果使用安装包安装，可以查看下面的表格 1，
找到所支持平台上 Riak <tt>erlc</tt> 存储的位置。如果从源码安装，请使用编译 Riak 时使用的
 Erlang 编译器。
</div>

<table style="width: 100%; border-spacing: 0px;">
<tbody>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>CentOS 和 RHEL Linux</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/lib64/riak/erts-5.9.1/bin/erlc</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>Debian 和 Ubuntu Linux</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/lib/riak/erts-5.9.1/bin/erlc</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>FreeBSD</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/usr/local/lib/riak/erts-5.9.1/bin/erlc</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>SmartOS</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/opt/local/lib/riak/erts-5.9.1/bin/erlc</tt></p>
</td>
</tr>
<tr align="left" valign="top">
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;"><strong>Solaris 10</strong></td>
<td style="padding: 15px; margin: 15px; border-width: 1px 0 1px 0; border-style: solid;">
<p><tt>/opt/riak/lib/erts-5.9.1/bin/erlc</tt></p>
</td>
</tr>
</tbody>
</table>

表格 1：在所支持的系统中使用安装包安装 Riak 后 Erlang 编译器存放的位置

模块的编译很简单。

```text
erlc validate_json.erl
```

接着，需要制定一个位置，用来保存编译的模块。例如，我们使用临时文件夹 `/tmp/beams`，不过
要选择一个文件夹存放生产环境中用到的函数，这样在需要使用时才能找到。

<div class="info">确保所选的文件夹 <tt>riak</tt> 用户有读权限。</div>

编译成功后会生成一个 `.beam` 文件，本例中是 `validate_json.beam`。

<a name="Configure"></a>
### 设置

把 `validate_json.beam` 复制到 `/tmp/beams` 文件夹中。

```text
cp validate_json.beam /tmp/beams/
```

复制完成后，必须修改 `app.config`，运行 Riak 从这个文件夹加载编译的模块。

编辑 `app.config`，在 `riak_kv` 区加入 `add_paths` 设置，如下所示：

```erlang
{riak_kv, [
  %% ...
  {add_paths, ["/tmp/beams/"]},
  %% ...
```

更新 `app.config` 后，必须重启 Riak。在生产环境中，如果要修改多个节点的设置，必须滚动
进行，花点时间确保 Riak 的键值对存储完全初始化可以使用了。

这个操作可以使用 `riak-admin wait-for-service` 命令完成，
详情参照 [[Commands documentation|riak-admin Command Line#wait-for-service]]。

<div class="note">在重启下一个节点之前一定要确保 riak_kv 正在运行。</div>
