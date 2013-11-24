---
title: 命令行工具
project: riak
version: 1.4.2+
document: reference
toc: true
index: true
audience: beginner
keywords: [command-line]
---

本文列出了 Riak 命令行工具及其子命令。这些工具位于嵌入节点的 `bin` 目录中，
以及使用安装包安装时指定的路径（`/usr/sbin` or `/usr/local/sbin`）。

## riak

`[[riak|riak 命令]]` 是控制 Riak 节点进程的主要脚本。包含以下子命令：

* [[start|riak 命令#start]]
* [[stop|riak 命令#stop]]
* [[restart|riak 命令#restart]]
* [[reboot|riak 命令#reboot]]
* [[ping|riak 命令#ping]]
* [[console|riak 命令#console]]
* [[attach|riak 命令#attach]]
* [[chkconfig|riak 命令#chkconfig]]

## riak-admin

`[[riak-admin|riak-admin 命令]]` 用来处理和节点运行状态无关的操作，包括节点的
成员，备份和基本状态。大多数命令都要求节点处于运行状态。包含下列子命令：

* [[cluster|riak-admin 命令#cluster]]
  * [[cluster join|riak-admin 命令#cluster join]]
  * [[cluster leave|riak-admin 命令#cluster leave]]
  * [[cluster force-remove|riak-admin 命令#cluster force-remove]]
  * [[cluster replace|riak-admin 命令#cluster replace]]
  * [[cluster force-replace|riak-admin 命令#cluster force-replace]]
* [[join|riak-admin 命令#join]]
* [[leave|riak-admin 命令#leave]]
* [[backup|riak-admin 命令#backup]]
* [[restore|riak-admin 命令#restore]]
* [[test|riak-admin 命令#test]]
* [[status|riak-admin 命令#status]]
* [[reip|riak-admin 命令#reip]]
* [[js-reload|riak-admin 命令#js-reload]]
* [[wait-for-service|riak-admin 命令#wait-for-service]]
* [[services|riak-admin 命令#services]]
* [[ringready|riak-admin 命令#ringready]]
* [[transfers|riak-admin 命令#transfers]]
* [[force-remove|riak-admin 命令#force-remove]]
* [[down|riak-admin 命令#down]]
* [[cluster-info|riak-admin 命令#cluster-info]]
* [[member-status|riak-admin 命令#member-status]]
* [[ring-status|riak-admin 命令#ring-status]]
* [[vnode-status|riak-admin 命令#vnode-status]]

## search-cmd

`[[search-cmd|search 命令]]` 用了和 Riak 提供的搜索功能交互。包含下列子命令：

* [[set-schema|search 命令#set-schema]]
* [[show-schema|search 命令#show-schema]]
* [[clear-schema-cache|search 命令#clear-schema-cache]]
* [[search|search 命令#search]]
* [[search-doc|search 命令#search-doc]]
* [[explain|search 命令#explain]]
* [[index|search 命令#index]]
* [[delete|search 命令#delete]]
* [[solr|search 命令#solr]]
* [[install|search 命令#install]]
* [[uninstall|search 命令#uninstall]]
* [[test|search 命令#test]]
