---
title: Multi
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: intermediate
keywords: [backends, planning, multi, leveldb, memory, bitcask]
prev: "[[Memory]]"
up:   "[[Choosing a Backend]]"
interest: false
---

## 概览

Riak 允许在一个实例中使用多个存储后台。这对下面这两种情况非常有用：

  1. 想在不同的 bucket 中使用不同的后台
  2. 在不同的 bucket 中使用相同的后台，但使用方式不一样

Multi 后台允许在同一个集群内同时使用多种后台。

## 安装

Riak 中包含了 Multi 后台，所以无需额外安装。

## 设置

要想修改默认设置，请把下面的设置项目加入 [[app.config|Configuration-Files]] 文件。
`multi_backend` 的设置必须放在 `app.config` 文件的 `riak_kv` 区中。

```erlang
%% Riak KV config
{riak_kv, [
    %% ...
    %% Use the Multi Backend
    {storage_backend, riak_kv_multi_backend},
    %% ...
]}
```

随便在 `riak_kv` 区中找个位置（可能会放在其他后台设置的附近）添加针对 Multi 后台的设置。

<div class="info">
<div class="title">设置的组织方式</div>
<p>因为这些设置可以放在 <tt>riak_kv</tt> 区的任何位置，我们建议将其放在其他后台设置的附近。</p>
</div>

```erlang
%% Use bitcask by default
{riak_kv, [
    %% ...
    {multi_backend_default, <<"bitcask_mult">>},
    {multi_backend, [
        %% Here's where you set the individual multiplexed backends
        {<<"bitcask_mult">>,  riak_kv_bitcask_backend, [
                         %% bitcask configuration
                         {config1, ConfigValue1},
                         {config2, ConfigValue2}
        ]},
        {<<"eleveldb_mult">>, riak_kv_eleveldb_backend, [
                         %% eleveldb configuration
                         {config1, ConfigValue1},
                         {config2, ConfigValue2}
        ]},
        {<<"second_eleveldb_mult">>,  riak_kv_eleveldb_backend, [
                         %% eleveldb with a different configuration
                         {config1, ConfigValue1},
                         {config2, ConfigValue2}
        ]},
        {<<"memory_mult">>,   riak_kv_memory_backend, [
                         %% memory configuration
                         {config1, ConfigValue1},
                         {config2, ConfigValue2}
        ]}
    ]},
    %% ...
]},
```

<div class="note">
<div class="title">Multi 后台的内存使用量</div>
每种后台都有设置项目制定所用的内存量，这些内存可以用来缓存数据（LevelDB），或者用来存储
整个数据集（“内存”后台）。每中后台都建议分配可用内存的 50%。使用 Multi 后台时，所有后台
的内存总量要是可用内存的 50% 或更少。三种后台都设成可用内存的 50% 会导致问题。
</div>

<div class="note">
<div class="title">Multi 后台的设置</div>
某些设置，例如 Bitcask 的 <code>merge_window</code>，是在每个节点中设置的，而不是针对
后台设置的，所以必须在 <code>app.config</code> 文件的顶级后台区中设置。
</div>

设置好后就可以启动 Riak 集群了。默认情况下，所有的新 bucket 都会
使用 `multi_backend_default` 中的设置，除非设定使用其他的存储引擎。要想使用其他的存储引擎，
乐意在 Erlang 控制台中设置，或通过 HTTP 接口设置，这两种方法都很简单，直接修改 bucket 的
属性。下面是两个例子：

  - 使用 Erlang 控制台
    可以在 Erlang 控制台中直接连接运行中的节点，然后直接设置 bucket 的属性。

    ```bash
    $ riak attach
    ...
    1> riak_core_bucket:set_bucket(<<"MY_BUCKET">>, [{backend, <<"second_bitcask_mult">>}]).
    ```

  - 使用 HTTP REST API
    还可以通过 HTTP API 连接到 Riak，然后修改 bucket 的属性。

    ```
    $ curl -XPUT http://riaknode:8098/buckets/transient_example_bucketname/props \
      -H "Content-Type: application/json" \
      -d '{"props":{"backend":"memory_mult"}}'
    ```

注意，如果在 `app.config` 中修改了 bucket 默认使用的存储引擎，必须重启节点设置才能生效。
