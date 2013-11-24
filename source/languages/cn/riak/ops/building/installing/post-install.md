---
title: 安装之后
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, upgrading]
prev: "[[从源码安装 Riak]]"
up:   "[[安装和升级]]"
---

安装好 Riak 后，你可能想查看各节点的生存状态，确保能正确处理请求。

下面介绍的是查看 Riak 节点可正常使用的常见方法，确认节点可以正常工作，要开始使用 Riak时，请阅读一下“接下来呢？”一节列出的文章。

## 启动 Riak 节点

<div class="note">
<div class="title">从源码安装的请注意</div>
<p>从源码安装的 Riak，要想启动 Riak 节点，可以把 Riak 的可执行文件目录加入 PATH。</p>
<p>例如，如果在 `/home/riak` 目录中编译 Riak，可以把可执行文件所在的目录（`/home/riak/rel/riak/bin`）加入 PATH，这样 Riak 相关的命令就能和通过安装包安装一样使用了。</p>
</div>

要启动 Riak 节点，请执行 `riak start` 节点：

```bash
riak start
```

如果启动成功，不会有任何输出。如果启动时出错了，会在标准错误中输出错误信息。

如果要打开附带 Erlang 控制台的 Riak，请执行：

```bash
riak console
```

Riak 节点经常使用控制台模式启动，这样可以从 Riak 启动序列中获取更详细的信息，有利于调试和查错。注意，如果使用这种方式启动 Riak 节点，节点是以前台程序的形式运行的，退出控制台后节点也会关闭。

关闭控制台可以在 Erlang 终端输入如下命令：

```erlang
q().
```

节点启动后，可以通过 `riak ping` 命令确认其确实在运行：

```bash
riak ping
pong
```

如果节点正在运行，上述命令会返回 **pong**，如果由于某些原因节点不可连通，就返回 **pang**。

<div class="note">
<div class="title">打开文件限制</div>
你可能注意到了，如果没有调整打开文件限制的话（`ulimit -n`），启动时 Riak 会警告限制数量太少。运行 Riak 时建议你增加操作系统默认的文件打开限制。这么做的原因请参阅“[[打开文件限制]]”一文。
</div>

## 节点可以工作吗？

测试单个 Riak 节点是否准备好读写数据的一个简单方式是使用 `riak-admin test` 命令：

```bash
riak-admin test
```

`riak-admin test` 成功后的输出如下所示：

```text
Attempting to restart script through sudo -H -u riak
Successfully completed 1 read/write cycle to 'riak@127.0.0.1'
```

要查看 Riak 是否工作也可以使用 `curl` 命令行工具。现在有一个运行着的节点，我们可以运行下面的命令试着从获取 `test` bucket 及其属性：

```bash
curl -v http://127.0.0.1:8098/riak/test
```

请把上述命令中的 `127.0.0.1` 改成你的 Riak 节点 IP 地址，或者完整的域名。这个命令应该会输出以下响应：

```text
* About to connect() to 127.0.0.1 port 8098 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 8098 (#0)
> GET /riak/test HTTP/1.1
> User-Agent: curl/7.21.6 (x86_64-pc-linux-gnu)
> Host: 127.0.0.1:8098
> Accept: */*
>
< HTTP/1.1 200 OK
< Vary: Accept-Encoding
< Server: MochiWeb/1.1 WebMachine/1.9.0 (someone had painted it blue)
< Date: Wed, 26 Dec 2012 15:50:20 GMT
< Content-Type: application/json
< Content-Length: 422
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
{"props":{"name":"test","allow_mult":false,"basic_quorum":false,
 "big_vclock":50,"chash_keyfun":{"mod":"riak_core_util",
 "fun":"chash_std_keyfun"},"dw":"quorum","last_write_wins":false,
 "linkfun":{"mod":"riak_kv_wm_link_walker","fun":"mapreduce_linkfun"},
 "n_val":3,"notfound_ok":true,"old_vclock":86400,"postcommit":[],"pr":0,
 "precommit":[],"pw":0,"r":"quorum","rw":"quorum","small_vclock":50,
 "w":"quorum","young_vclock":20}}
```

上面的输出是一个成功响应（HTTP 200 OK），列出了各报头的内容，还显示了这个 bucket 的属性。

{{#1.3.0+}}
## Riaknostic

安装之后最好验证以下基本设置及 Riak 几点的常规状态，这些操作可以使用 Riak 提供的诊断工具 *Riaknostic* 完成。

确保 Riak 节点正常运行，请执行下面的命令：

```
riak-admin diag
```
确保该命令输出的结果符合最优节点的设置。
{{/1.3.0+}}

## 然后呢？

你的 Riak 节点可以正常的运行！

接下来你或许想阅读下面的文章。

* 阅读“[[客户端代码库]]”一文，学习如何通过你最喜欢的编程语言使用 Riak
* [[学习 Riak 中的高级概念|概念]]
