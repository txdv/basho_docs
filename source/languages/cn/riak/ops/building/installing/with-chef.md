---
title: 通过 Chef 安装 Riak
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [operator, installing, chef]
---

如果使用开源的设置管理框架 [Chef](http://www.opscode.com/chef/)，可以使用我们维护的 [cookbook](http://community.opscode.com/cookbooks/riak)，通过 Chef 安装 Riak。

## 开始安装

要想使用 Riak cookbook，请把 `recipe[riak]` 加入节点的运行列表中。默认的设置后从 Basho 维护的安装包仓库安装并设置 Riak。

### 通过安装包安装

安装有三种可选方式：`source`，`package` 和 `enterprise_package`。默认使用的是 `package`（安装 Riak 开源版）。在基于 Red Hat 和 Debian 的操作系统中推荐使用这种方式安装。如果要从源码安装 Riak，推荐使用 Erlang/OTP R15B01 及以上版本。

### 从源码安装

通过 `source` 方式可以从源码安装 Riak。这种方式需要 `git`、`build-essential` 和`erlang` cookbook 的支持。

### 安装企业版

要安装 Riak 企业版，需要为 `node['riak']['package']['enterprise_key']` 指定一个 Basho 提供的序列号。

如果通过 cookbook 安装 Riak 企业版，必须使用安装包的形式安装。

### 基本设置

所有的设置都位于 `node['riak']['config']` 命名空间之下。如果需要使用 Erlang 数据类型，请使用 [erlang_template_helper](https://github.com/basho/erlang_template_helper) 中列出的适当方法。

#### 网络

Riak 客户端通过 HTTP 或 Protocol Buffers 接口和集群中的节点通信，而且可以同时使用这两种接口。每个接口都要设置监听的 IP 地址和 TCP 端口。HTTP 接口的默认设置是 `localhost:8098`，Protocol Buffers 接口的默认设置是 `0.0.0.0:8087`（客户端可以连接到服务器上的任意地址，TCP 端口都是 8087）。

默认的 HTTP 接口设置不能在其他节点上使用，所以如果要使用 HTTP 接口必须修改默认的设置。也就是时候，不推荐允许客户端直接连接位于 Riak 和客户端之间的某种负载平衡处理程序。

```ruby
default['riak']['config']['riak_core']['http'] = [[node['ipaddress'].to_erl_string, 8098].to_erl_tuple]
default['riak']['config']['riak_api']['pb_ip'] = node['ipaddress'].to_erl_string
default['riak']['config']['riak_api']['pb_port'] = 8087
```

集群内部的移交要有专用的端口，默认为 `8099`。

```ruby
default['riak']['config']['riak_core']['handoff_port'] = 8099
```

设置中还要针对节点之间通讯的端口设置。

```ruby
default['riak']['config']['kernel']['inet_dist_listen_min'] = 6000
default['riak']['config']['kernel']['inet_dist_listen_max'] = 7999
```

#### Erlang

在 cookbook 中还可以设置一些 Erlang 参数。对于搭建多节点的集群来说，最重要的设置是节点的 `-name` 和 `-setcookie`。

其余的参数基本上针对的是性能调整，默认会启用 kernel 轮询和 SMP。示例设置如下：

```ruby
default['riak']['args']['-name'] = "riak@#{node['fqdn']}"
default['riak']['args']['-setcookie'] = "riak"
default['riak']['args']['+K'] = true
default['riak']['args']['+A'] = 64
default['riak']['args']['+W'] = "w"
default['riak']['args']['-env']['ERL_MAX_PORTS'] = 4096
default['riak']['args']['-env']['ERL_FULLSWEEP_AFTER'] = 0
default['riak']['args']['-env']['ERL_CRASH_DUMP'] = "/var/log/riak/erl_crash.dump"
default['riak']['args']['-env']['ERL_MAX_ETS_TABLES'] = 8192
default['riak']['args']['-smp'] = "enable"
```

#### 存储后台

使用 Riak 时必须挑选一个存储后台，每个后台都由很多设置项目。Riak 支持为不同的 bucket 设置使用不同的后台，但这在 Chef 中暂时无法实现。

最长使用的后台是 [[Bitcask]]、[[LevelDB]] 和 [[多种后台|Multi]]。各种后台的常见设置和默认值如下。

##### Bitcask

默认使用的 Bitcask 后台的设置。更多信息请阅读 [[Bitcask]] 的文档。

```ruby
default['riak']['config']['bitcask']['io_mode'] = "erlang"
default['riak']['config']['bitcask']['data_root'] = "/var/lib/riak/bitcask".to_erl_string
```

##### LevelDB

LevelDB 后台的设置。更多信息请阅读 [[LevelDB]] 的文档。

```ruby
default['riak']['config']['eleveldb']['data_root'] = "/var/lib/riak/leveldb".to_erl_string
```

### Lager

[Lager](https://github.com/basho/lager) 是 Riak 使用的日志框架。也可以结合 Erlang/OTP 使用。

```ruby
error_log = ["/var/log/riak/error.log".to_erl_string,"error",10485760,"$D0".to_erl_string,5].to_erl_tuple
info_log = ["/var/log/riak/console.log".to_erl_string,"info",10485760,"$D0".to_erl_string,5].to_erl_tuple

default['riak']['config']['lager']['handlers']['lager_file_backend'] = [error_log, info_log]
default['riak']['config']['lager']['crash_log'] = "/var/log/riak/crash.log".to_erl_string
default['riak']['config']['lager']['crash_log_msg_size'] = 65536
default['riak']['config']['lager']['crash_log_size'] = 10485760
default['riak']['config']['lager']['crash_log_date'] = "$D0".to_erl_string
default['riak']['config']['lager']['crash_log_count'] = 5
default['riak']['config']['lager']['error_logger_redirect'] = true
```

### Sysmon

Sysmon 监控 Riak 的垃圾回收过程，会把相关的信息写入日志。

```ruby
default['riak']['config']['riak_sysmon']['process_limit'] = 30
default['riak']['config']['riak_sysmon']['port_limit'] = 2
default['riak']['config']['riak_sysmon']['gc_ms_limit'] = 0
default['riak']['config']['riak_sysmon']['heap_word_limit'] = 40111000
default['riak']['config']['riak_sysmon']['busy_port'] = true
default['riak']['config']['riak_sysmon']['busy_dist_port'] = true
```

### 索引合并

与二级索引和 Riak Search 索引有关的设置。

```ruby
default['riak']['config']['merge_index']['data_root'] = "/var/lib/riak/merge_index".to_erl_string
default['riak']['config']['merge_index']['buffer_rollover_size'] = 1048576
default['riak']['config']['merge_index']['max_compact_segments'] = 20
```

## 扩展阅读

这份文档中还有更多关于集群设置和搭建开发环境的文章。

* [[花五分钟安装]]
