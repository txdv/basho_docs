---
title: Advanced Commit Hooks
project: riak
version: 1.4.2+
document: guide
toc: true
audience: advanced
keywords: [developers, commit-hooks, beam]
---

Riak 支持在编译好的模块中使用 Erlang 具名函数，实现 pre-commit 钩子、
post-commit 钩子和 MapReduce 操作。本文介绍如何使用自定义的具名函数，
以及模块编译、设置和安装步骤。

## Pre-Commit 钩子示例

在这个 pre-commit 钩子示例中，我们要定义一个函数，在把数据写入 bucket 之前
验证键对应的 JSON 内容。

下面就是我们编写的 `validate_json` 模块和所需的 `validate` 函数：

```erlang
-module(validate_json).
-export([validate/1]).

validate(Object) ->
  try
    mochijson2:decode(riak_object:get_value(Object)),
    Object
  catch
    throw:invalid_utf8 ->
      {fail, "Invalid JSON: Illegal UTF-8 character"};
    error:Error ->
      {fail, "Invalid JSON: " ++ binary_to_list(list_to_binary(io_lib:format("~p", [Error])))}
  end.
```

把上述代码保存为 `validate_json.erl` 文件，然后编译。

<div class="info">
    <div class="title">Erlang 编译器的注意事项</div>
    必须使用 Riak 中的 Erlang 编译器（<tt>erlc</tt>），或者使用编译 Riak 源码
    时使用的 Erlang 版本。如果要用 Riak 中包含的 <tt>erlc</tt>，请参照下面的
    表格找到相应平台上的位置。如果是从源码编译安装的 Raik，直接使用当时所用
    版本的 <tt>erlc</tt> 即可。
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

表格 1：使用安装包安装 Riak 时，各平台上 Erlang 编译器的位置

模块的编辑很简单。

```text
erlc validate_json.erl
```

然后，要指定一个路径用来保存和加载编译后的模块。在这个例子中，我们使用
临时文件夹 `/tmp/beams`。在实际运用中，你应该根据需求选择合适的路径，
需要使用时才能找到。

<div class="info">确保所选的文件夹 <tt>riak</tt> 用户有读权限。</div>

成功编译后会生成 `.beam` 文件，本例中生成的是 `validate_json.beam`。

把编译好的文件发给操作员，或者阅读“[[安装自定义代码|installing custom code]]”
一文，学习如何在 Raik 节点中安装代码。

重启 Riak 后，剩下的步骤就是把 pre-commit 钩子安装到目标 bucket 中。在本例中，
只有一个 bucket，名为 `messages`，我们要把 `validate` pre-commit 函数安装到
这个 bucket 中。

可以同过 Riak 的 HTTP 接口使用 `curl` 命令行工具把具名函数安装到相应
的 bucket 中。在本例中，我们要把 `validate_json` 模块的 `validate` 函数安装
到 `messages` 这个 bucket 中，方法如下：

```bash
curl -XPUT -H "Content-Type: application/json" \
http://127.0.0.1:8098/buckets/messages/props    \
-d '{"props":{"precommit":[{"mod": "validate_json", "fun": "validate"}]}}'
```

然后查看 bucket 的属性列表，看是否列出了这个钩子：

```bash
curl http://localhost:8098/buckets/messages/props | python -mjson.tool
```

输出结果如下所示：

```json
{
    "props": {
        "allow_mult": false,
        "basic_quorum": false,
        "big_vclock": 50,
        "chash_keyfun": {
            "fun": "chash_std_keyfun",
            "mod": "riak_core_util"
        },
        "dw": "quorum",
        "last_write_wins": false,
        "linkfun": {
            "fun": "mapreduce_linkfun",
            "mod": "riak_kv_wm_link_walker"
        },
        "n_val": 3,
        "name": "messages",
        "notfound_ok": true,
        "old_vclock": 86400,
        "postcommit": [],
        "pr": 0,
        "precommit": [
            {
                "fun": "validate_json",
                "mod": "validate"
            }
        ],
        "pw": 0,
        "r": "quorum",
        "rw": "quorum",
        "small_vclock": 50,
        "w": "quorum",
        "young_vclock": 20
    }
}
```

可以看到，`precommit` 属性中确实有 `validate_json` 模块的 `validate` 函数。
现在我们试着存入不合法的 JSON，测试一下这个 pre-commit 钩子。

```bash
curl -XPUT localhost:8098/buckets/messages/keys/1 \
-H 'Content-Type: application/json' -d@msg3.json
```

如果 `msg3.json` 的格式不合法，会得到如下响应：

```bash
Invalid JSON: {case_clause,{{const,<<"authorName">>},{decoder,null,160,1,161,comma}}}
```

## Post-Commit 钩子示例

在这个 post-commit 钩子示例中，我们要定义一个简单的函数，当对象成功写入 Riak 后，
向 `console.log` 中写入一条日志信息。

下面就是这个 post-commit 钩子函数：

```erlang
-module(log_object).
-export([log/1]).

log(Object) ->
  error_logger:info_msg("OBJECT: ~p~n",[Object]).
```

把这段代码保存为 `log_object.erl`，然后编译。
Save this file as `log_object.erl` and proceed to compiling the module.

<div class="info">
    <div class="title">Erlang 编译器的注意事项</div>
    必须使用 Riak 中的 Erlang 编译器（<tt>erlc</tt>），或者使用编译 Riak 源码
    时使用的 Erlang 版本。如果要用 Riak 中包含的 <tt>erlc</tt>，请参照下面的
    表格找到相应平台上的位置。如果是从源码编译安装的 Raik，直接使用当时所用
    版本的 <tt>erlc</tt> 即可。
</div>

编译模块的过程很简单。

```bash
erlc log_object.erl
```

然后要指定一个路径，用来保存和加载编译好的模块。

和 pre-commit 钩子的做法一样，可以把编译好的文件发给操作员，或者参照
“[[安装自定义代码|installing custom code]]”一文自行安装。

重启 Riak 后，剩下的步骤就是把这个 post-commit 钩子安装到目标 bucket 了。
在这个例子中，只有一个 bucket，名为 `updates`。我们要把 `log` 函数安装到
这个 bucket 中。

可以通过 Riak 的 HTTP 接口，使用 `curl` 命令行工具把具名函数安装到相应
的 bucket 中。在这个例子中，我们要把 `log` 函数安装到 `updates` bucket 中，
方法如下：

```bash
curl -XPUT -H "Content-Type: application/json" \
http://127.0.0.1:8098/buckets/updates/props    \
-d '{"props":{"postcommit":[{"mod": "log_object", "fun": "log"}]}}'
```

查看 bucket 的属性裂变，看是否包含刚安装的 post-commit。

```bash
curl localhost:8098/buckets/updates/props | python -mjson.tool
```

输出结果如下：

```json
{
    "props": {
        "allow_mult": false,
        "basic_quorum": false,
        "big_vclock": 50,
        "chash_keyfun": {
            "fun": "chash_std_keyfun",
            "mod": "riak_core_util"
        },
        "dw": "quorum",
        "last_write_wins": false,
        "linkfun": {
            "fun": "mapreduce_linkfun",
            "mod": "riak_kv_wm_link_walker"
        },
        "n_val": 3,
        "name": "updates",
        "notfound_ok": true,
        "old_vclock": 86400,
        "postcommit": [
            {
                "fun": "log",
                "mod": "log_object"
            }
        ],
        "pr": 0,
        "precommit": [],
        "pw": 0,
        "r": "quorum",
        "rw": "quorum",
        "small_vclock": 50,
        "w": "quorum",
        "young_vclock": 20
    }
}
```

可以看到，`postcommit` 属性中包含 `log_object` 模块的 `log` 函数。现在我们存入
一个对象，然后查看 `console.log` 文件，测试一下这个 post-commit 函数。

```bash
curl -XPUT localhost:8098/buckets/updates/keys/2 \
-H 'Content-Type: application/json' -d@msg2.json
```

在 `console.log` 中可以看到存入的对象。

```bash
2012-12-10 13:14:37.840 [info] <0.2101.0> OBJECT: {r_object,<<"updates">>,<<"2">>,[{r_content,{dict,6,16,16,8,80,48,{[],[],[],
[],[],[],[],[],[],[],[],[],[],[],[],[]},{{[],[],[[<<"Links">>]],[],[],[],[],
[],[],[],[[<<"content-type">>,97,112,112,108,105,99,97,116,105,111,110,47,
106,115,111,110],[<<"X-Riak-VTag">>,52,114,79,84,75,73,90,73,83,105,49,101,
120,53,87,103,106,110,56,71,114,83]],[[<<"index">>]],[],
[[<<"X-Riak-Last-Modified">>|{1355,163277,837883}]],[],
[[<<"X-Riak-Meta">>]]}}},<<"{    \"id\": 1,    \"jsonrpc\": \"2.0\",
\"total\": 1,    \"result\": [        {            \"id\": 1,
\"author\": \"foo@example.com\",            \"authorName\": \"Foo Bar\",
\"text\": \"Home of the example cocktail\"        }
]}">>}],[{<<35,9,254,249,80,193,17,247>>,{1,63522382477}}],{dict,1,16,16,8,
80,48,{[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]},{{[],[],[],[],[],[],
[],[],[],[],[],[],[],[],[[clean|true]],[]}}},undefined}
```
