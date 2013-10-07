---
title: Command Line Tools
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

`[[riak|riak Command Line]]` 是控制 Riak 节点进程的主要脚本。包含以下子命令：

* [[start|riak Command Line#start]]
* [[stop|riak Command Line#stop]]
* [[restart|riak Command Line#restart]]
* [[reboot|riak Command Line#reboot]]
* [[ping|riak Command Line#ping]]
* [[console|riak Command Line#console]]
* [[attach|riak Command Line#attach]]
* [[chkconfig|riak Command Line#chkconfig]]

## riak-admin

`[[riak-admin|riak-admin Command Line]]` 用来处理和节点运行状态无关的操作，包括节点的
成员，备份和基本状态。大多数命令都要求节点处于运行状态。包含下列子命令：

* [[cluster|riak-admin Command Line#cluster]]
  * [[cluster join|riak-admin Command Line#cluster join]]
  * [[cluster leave|riak-admin Command Line#cluster leave]]
  * [[cluster force-remove|riak-admin Command Line#cluster force-remove]]
  * [[cluster replace|riak-admin Command Line#cluster replace]]
  * [[cluster force-replace|riak-admin Command Line#cluster force-replace]]
* [[join|riak-admin Command Line#join]]
* [[leave|riak-admin Command Line#leave]]
* [[backup|riak-admin Command Line#backup]]
* [[restore|riak-admin Command Line#restore]]
* [[test|riak-admin Command Line#test]]
* [[status|riak-admin Command Line#status]]
* [[reip|riak-admin Command Line#reip]]
* [[js-reload|riak-admin Command Line#js-reload]]
* [[wait-for-service|riak-admin Command Line#wait-for-service]]
* [[services|riak-admin Command Line#services]]
* [[ringready|riak-admin Command Line#ringready]]
* [[transfers|riak-admin Command Line#transfers]]
* [[force-remove|riak-admin Command Line#force-remove]]
* [[down|riak-admin Command Line#down]]
* [[cluster-info|riak-admin Command Line#cluster-info]]
* [[member-status|riak-admin Command Line#member-status]]
* [[ring-status|riak-admin Command Line#ring-status]]
* [[vnode-status|riak-admin Command Line#vnode-status]]

## search-cmd

`[[search-cmd|search Command Line]]` 用了和 Riak 提供的搜索功能交互。包含下列子命令：

* [[set-schema|search Command Line#set-schema]]
* [[show-schema|search Command Line#show-schema]]
* [[clear-schema-cache|search Command Line#clear-schema-cache]]
* [[search|search Command Line#search]]
* [[search-doc|search Command Line#search-doc]]
* [[explain|search Command Line#explain]]
* [[index|search Command Line#index]]
* [[delete|search Command Line#delete]]
* [[solr|search Command Line#solr]]
* [[install|search Command Line#install]]
* [[uninstall|search Command Line#uninstall]]
* [[test|search Command Line#test]]
