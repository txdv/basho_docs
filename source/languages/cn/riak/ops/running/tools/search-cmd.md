---
title: search 命令
project: riak
version: 1.4.2+
document: reference
toc: true
audience: beginner
keywords: [command-line, search]
---

# 命令行工具 - `search-cmd`

这个命令用来和 Riak 的搜索功能交互。确保已经[[启用了搜索功能|设置文件#riak_search]]。在所有命令中，`INDEX` 选项都是可选的，默认值为 `search`。

    search-cmd set-schema [INDEX] SCHEMAFILE : 设定索引的模式（schema）
    search-cmd show-schema [INDEX]           : 显示索引的模式
    search-cmd clear-schema-cache            : 清空所有节点的模式缓存
    search-cmd search [INDEX] QUERY          : 进行一次搜索操作
    search-cmd search-doc [INDEX] QUERY      : 进行一次文件搜索操作
    search-cmd explain [INDEX] QUERY         : 显示查询计划
    search-cmd index [INDEX] PATH            : 索引某路径中的文件
    search-cmd delete [INDEX] PATH           : 删除某路径中文件的索引
    search-cmd solr [INDEX] PATH             : 运行 Solr 文件
    search-cmd install BUCKET                : 安装 kv/search 集成钩子
    search-cmd uninstall BUCKET              : 写在 kv/search 集成钩子
    search-cmd test PATH                     : 运行测试包

## set-schema

    set-schema [INDEX] SCHEMAFILE

设置指定索引的[[模式|Riak Search 模式高级用法]]。如果不设定就是用默认的模式。

## show-schema

    show-schema [INDEX]

显示指定索引使用的[[模式|Riak Search 模式高级用法]]。

## clear-schema-cache

    clear-schema-cache

搜索会把模式存储在 Riak 中，就像保存其他对象一样。为了避免每次需要时都从 Riak 中读取对象，所用模式在每个节点中都有个缓存。如果修改了所用的模式，就需要清除这个缓存，确保从 Riak 读取的是修改后的模式。

## search

    search [INDEX] QUERY

在索引上执行指定的查询，返回文件 ID、属性和得分。[[查询的句法|使用 Riak Search]]和 Lucene 一样。

## search-doc

    search-doc [INDEX] QUERY

和 `search` 命令很像，不过还会返回所有字段（field）。

## explain

    explain [INDEX] QUERY

显示针对指定索引的查询计划。

## index

    index [INDEX] PATH

索引指定路径中的文件。详细信息请阅读[[这份文档|Riak Search 索引参考手册#Indexing-from-the-Command-Line]]。

## delete

    delete [INDEX] PATH

从索引中删除文件。详细信息请阅读[[这份文档|Riak Search 索引参考手册#Deleting-from-the-Command-Line]]。

## solr

    solr [INDEX] PATH

索引 Solr 文件。详细信息请阅读[[这份文档|Riak Search 索引参考手册#Indexing-using-the-Solr-Interface]]。

## install

    install BUCKET

在指定的 bucket 中安装搜索 precommit 钩子。这样就可以[[索引存入的对象|Riak Search 索引参考手册]]了。

## uninstall

    uninstall BUCKET

写在指定 bucket 中的 搜索 precommit 钩子。

## test

    test PATH

运行指定路径中的搜索测试脚本。
