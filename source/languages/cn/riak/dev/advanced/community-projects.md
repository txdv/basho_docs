---
title: Community Projects
project: riak
version: 1.4.2+
document: reference
toc: true
index: true
audience: intermediate
keywords: [client, drivers]
---

## 监控，管理和 GUI 工具

* [[riak_node (for Munin)|https://github.com/munin-monitoring/contrib/blob/master/plugins/riak/riak_node]] - Munin 插件，监控 GET 和 PUT 流量
* [[riak_memory (for Munin)|https://github.com/munin-monitoring/contrib/blob/master/plugins/riak/riak_memory]] - Munin 插件，监控内存使用
* [[Nagios Plugins for Riak|https://github.com/xb95/nagios-plugins]]
* [[Riak-Console|https://github.com/lucaspiller/riak-console]] - Riak 交互命令行界面
* [[Rekon|https://github.com/basho/rekon]] - Riak 节点数据浏览器
* [[Gmond Python Modules for Riak|http://github.com/jnewland/gmond_python_modules/tree/master/riak]] - Ganglia 模块，用来连接 Riak
* [[riak-admin|http://bitbucket.org/harmen/riak-admin/]] - Java 编写的 GUI 工具，可以浏览和更新 Riak 数据库
* [[Riak Admin|http://github.com/frank06/riak-admin]] - 类似 Futon 的 Raik 网页界面
* [[riak-session-manager|https://github.com/jbrisbin/riak-session-manager]] - 基于 Raik 的 Tomcat 会话管理器
* [[app-karyn|https://github.com/tempire/app-karyn]] - 处理 Riak 对象的简单命令行工具
* [[Briak|http://github.com/johnthethird/Briak]] - 使用 Sinatra 开发的 Riak 网页浏览器
* [[riak_stats|https://gist.github.com/4064937]] - shell 脚本，把 riak-admin 统计信息发送到 [[Librato|https://metrics.librato.com/]]
* [[riak_graphite_stats|https://gist.github.com/4064990]] - shell 脚本，把 riak-admin 统计信息发送到 [[Graphite|http://graphite.wikidot.com/]]

## 备份工具

* [[Brackup|http://code.google.com/p/brackup/]] - 现代化基于网络的备份系统，支持去重复、智能分段和基于 GPG 的加密等功能

## riak_core

* [[Misultin riak_core Vnode Dispatcher|https://github.com/jbrisbin/misultin-riak-core-vnode-dispatcher]] - 示例程序，演示如何把 Web 请求分发到 riak_core 虚拟节点
* [[ecnty|https://github.com/benmmurphy/ecnty]] - 基于 Riak Core 的分区计数器
* [[rebar_riak_core|https://github.com/websterclay/rebar_riak_core]] - 生成 riak_core 应用程序的 Rebar 模板
* [[Try Try Try|https://github.com/rzezeski/try-try-try/]] - Ryan Zezeski 的工作博客，介绍了 riak_core 的很多功能（干货十足的文章）
* [[riak_zab|https://github.com/jtuple/riak_zab]] - riak_core 扩展，提供对“完全有序原子广播”的支持
 that provides totally ordered atomic broadcast capabilities
* [[riak_zab_example|https://github.com/jtuple/riak_zab_example]] - 示例程序，演示如何使用 riak_zab 搭建多节点的集群

## Riak 和 RabbitMQ

* [[Riak/RabbitMQ Commit Hook|https://github.com/jbrisbin/riak-rabbitmq-commit-hooks]] - post-commit 钩子，使用 Erlang AMQP 客户端把记录发送到 RabbitMQ 代理程序
* [[riak-exchange|https://github.com/jbrisbin/riak-exchange]] - 为 Raik 的 sticking 消息定义 RabbitMQ 交换类型
* [[rabbit_riak_queue|https://github.com/jbrisbin/rabbit_riak_queue]] - 实现基于 Riak 的 RabbitMQ 持久化队列
* [[msg_store_bitcask_index|https://github.com/videlalvaro/msg_store_bitcask_index]] - 用 Bitcask 做后台的 RabbitMQ 消息存储索引
* [[RabbitMQ riak_core Vnode Dispatcher|https://github.com/jbrisbin/rabbitmq-riak_core-vnode-dispatcher]] - 演示如何把 Web 请求分发到 riak_core 虚拟节点

## Lager

* [[Lager AMQP Backend|https://github.com/jbrisbin/lager_amqp_backend]] - AMQP RabbitMQ Lager 后台

## 秘诀，cookbook 和设置

* [[Scalarium-Riak|https://github.com/roidrage/scalarium-riak]] - Scalarium 平台上的 Riak Cookbooks
* [[Riak Chef Recipe|https://github.com/basho/riak-chef-cookbook]] - 安装和设置 Raik 的 Vanilla Chef 秘诀
* [[在 Engine Yard AppCloud 上运行 Raik 的 Chef 秘诀|https://github.com/engineyard/ey-cloud-recipes/tree/master/cookbooks/riak]]
* [[RiakAWS|http://github.com/roder/riakaws]] - 在 Amazon Cloud 上部署 Raik 集群的简单方法
* [[使用 Nginx 作 Raik 的前台|http://rigelgroupllc.com/wp/blog/using-nginx-as-a-front-end-for-riak]]
* [Protocol Buffers 接口的 HAProxy 设置示例](http://lists.basho.com/pipermail/riak-users_lists.basho.com/2011-May/004387.html)（特别感谢 Scott M. Likens）
* [Protocol Buffers 接口的 HAProxy 设置示例](http://lists.basho.com/pipermail/riak-users_lists.basho.com/2011-May/004388.html)（特别感谢 Bob Feldbauer）

## 其他工具和项目

* [[riak_mapreduce_utils|http://github.com/whitenode/riak_mapreduce_utils]] - 使用 Erlang 开发的实用 MapReduce 函数库
* [[riakbloom|http://github.com/whitenode/riakbloom]] - 让 Bloom 过滤器可以在 MapReduce 作业中创建和使用
* [[Qi4j Riak EntityStore|http://qi4j.org/extension-es-riak.html]] - 使用 Riak bucket 实现的 Qi4j EntityStore 服务
* [[ldapjs-riak|https://github.com/mcavage/node-ldapjs-riak]] - [[ldapjs|http://ldapjs.org]] 的 Riak 后台
* [[otto|https://github.com/ncode/otto]] - 建立在 Cyclone 之上的 S3 Clone，支持 Raik
* [[Riaktivity|https://github.com/roidrage/riaktivity]] - Ruby 代码库，可以在 Raik 中存储时间线数据
* [[Timak|https://github.com/bretthoerner/timak]] - Python 代码库，可以在 Raik 中存储时间线数据
* [[Statebox_Riak|https://github.com/mochi/statebox_riak ]] - 一个很方便的代码库，让 [[Statebox|https://github.com/mochi/statebox]] 结合 Riak 使用变得很简单（Mochi 团队写了[[一篇博客|http://labs.mochimedia.com/archive/2011/05/08/statebox/]]，介绍如何在生产环境中使用这个代码库）
* [[bitcask-ruby|https://github.com/aphyr/bitcask-ruby]] - Bitcask 存储系统的接口
* [[Riak BTree Backend|https://github.com/krestenkrab/riak_btree_backend]] - 基于 couch_btree 的 Riak/KV 后台
* [[Riak Link Index|https://github.com/krestenkrab/riak_link_index]] - 基于链接的 Riak 简易索引程序
* [[rack-rekon|https://github.com/seomoz/rack-rekon]] - 服务于 [[Rekon|https://github.com/adamhunter/rekon/]] 的 Rack 程序
* [[ring-session-riak|https://github.com/ossareh/ring-session-riak]] - 使用 Riak 实现 Ring Session
* [[Riak to CSV Export|https://github.com/bradfordw/riak_csv]] - 一种简单的方法把 Raik bucket 中的数据导出为 CSV 文件
* [[Couch to Riak|http://github.com/mattsta/couchdb/tree/couch_file-to-riak]]
* [[Chimera|http://github.com/benmyles/chimera]] - Riak 和 Redis 对象映射程序
* [[Riak_Redis Backend|http://github.com/cstar/riak_redis_backend]]
* [[Riak Homebrew Formula|http://github.com/roidrage/homebrew]]
* [[Riak-fuse|http://github.com/johnthethird/riak-fuse]] - Raik 的 FUSE 驱动
* [[riakfuse|http://github.com/crucially/riakfuse]] - 基于 Riak 的分布式文件系统
* [[ebot|http://www.redaelli.org/matteo-blog/projects/ebot/]] - 支持使用 Raik 做后台的伸缩式 Web 爬虫
* [[riak-jscouch|https://github.com/jimpick/riak-jscouch]] - 使用 Raik 完成的 JSCouch 演示
* [[riak_tokyo_cabinet|http://github.com/jebu/riak_tokyo_cabinet]] - 为 Riak 开发的 Tokyo Cabinet 后台
* [[Logstash Riak Output|http://logstash.net/docs/1.1.9/outputs/riak]] - Logstash 的输出插件

## 演示程序

下面列出了一些使用 Raik 和 Raik Core 开发的程序示例。

### Riak

* [[yakriak|http://github.com/seancribbs/yakriak]] - Riak 驱动的 Ajax 轮询聊天室
* [[riaktant|https://github.com/basho/riaktant]] - 一个完整的 node.js 程序，把系统日志存入 Riak，并使用 Raik Search 实现搜索功能
* [[selusuh|https://github.com/OJ/selusuh]] - 实现使用 JSON 编写幻灯片的 Raik 程序（感谢 [OJ](http://twitter.com/thecolonial)）
* [[Rekon|https://github.com/adamhunter/rekon]] - Riak 数据浏览器，一个独立的 Raik 程序
* [[Slideblast|https://github.com/rustyio/SlideBlast]] - 分享可管理幻灯片的网络程序
* [[riak_php_app|http://github.com/schofield/riak_php_app]] - 小型 PHP 程序，演示如何使用 Riak 的 PHP 库
* [[riak-url-shortener|http://github.com/seancribbs/riak-url-shortener]] - 小型 Ruby 程序（使用 Sinatra 开发），创建短链接，并将其存入 Riak
* [[wriaki|https://github.com/basho/wriaki]] - 用 Riak 做后台的维基
* [[riagi|https://github.com/basho/riagi]] - 使用 Riak、Django 和 Riak Search 开发的 类 imgur.com 程序

### Riak Core

_Riak Core（在代码中写做 riak_core）是支撑 Riak 的分布式系统框架。关于 Raik Core 的更多信息，请从[这篇博客](http://blog.basho.com/2011/04/12/Where-To-Start-With-Riak-Core/)开始了解。_

* [[riak_id|https://github.com/seancribbs/riak_id]] - 克隆 Twitter 的 Snowflake，建立在 riak_core 之上
* [[basho_banjo|https://github.com/rustyio/BashoBanjo]] - 一个程序，使用 Riak Core 播放分布式存储的音乐
* [[riak_zab|https://github.com/jtuple/riak_zab]] - 在 Riak Core 之上实现的  Zookeeper 协议
* [[try-try-try|https://github.com/rzezeski/try-try-try]] - Ryan Zezeski 的工作博客，介绍了 riak_core 的很多功能（而且逐步介绍如何开发一个名为“RTS”的应用程序）
