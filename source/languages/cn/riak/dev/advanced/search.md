---
title: Riak Search 高级用法
project: riak
version: 1.4.2+
document: guide
toc: true
audience: advanced
keywords: [developers, search, kv]
---

## Riak Search 是如何工作的

### 架构，分区和索引

在 Raik 集群中启用 Riak Search 后，会创建和 KV 虚拟节点数量相同的另一批虚拟节点，用来处理 Raik Search 请求。如果在 bucket 中启用 Riak Search，写入数据时会通过 pre-commit 钩子生成对象的索引。存储在 Raik Search 虚拟节点上的索引数据会使用与 Raik KV 相同的机制在集群中创建副本，但会使用时间戳而不是向量时钟提升性能。

![Enabling a Node for Search](/images/riak_search_enabling_physical_node.png)

Riak Search 使用基于关键字的分区技术（也叫做全局索引）。例如，有 5 个文档，包含 3 个不同的词，“dog”这个词出现在文档 1 和文档 2 中（在 Riak 中要说键 1 和键 2）。“and”这个词出现在文档1 、2、3、4 中。

![Search Document Table](/images/riak_search_document_table.png)

创建索引时，Riak Search 会分析文档，把记录存在索引中。系统参照模式（在各索引上定义）决定哪些字段是必须的，哪个是唯一的键，默认的分析器是什么，以及各字段应该使用哪个分析器。自定义的分析器可以使用 Java 或 Erlang 开发。字段别名（多个字段组成一个字段）和动态字段（通配符匹配的字段）也是支持的。

分析好文档得到索引后，系统使用一致性哈希按关键字把索引条目分区存到集群中。这个过程叫做基于关键字的分区，是和其他常用分布式索引的重要不同点。之所以选择使用基于关键字的分区技术，是因为它可以提供更高的查询流量，目前做的比 2i 还好。（当处理大量数据时可能导致查询的迟延增高。）

### 持久性

对于存储后台，Riak Search 团队开发了 merge\_index。merge\_index 参考了 Lucene 文件格式、Bitcask（Riak KV 的标准存储后台）和 SSTables（按照 Google 的 BigTable 论文开发），数据结构简单、易于恢复，在不降低性能的前提下能够提供同步读取和写入操作，还充分利用了短写入周期来压缩和优化数据，这样能有效避免突发写入。

### 副本

Riak Search 索引上有个 `n_val` 设置， 设定要存储多少个索引副本。副本会写入位于不同物理节点的不同分区中。

Riak Search 的底层数据存放在 Raik KV 中，副本也完全一样。不过，从底层数据中建立的 Raik Search 索引，其创建副本的方式因技术层面的原因而有所不同。

* Riak Search 使用时间戳而不是向量时钟来解决版本冲突。时间戳无法完全保证数据的时效（如果依赖挂钟的时间，可能由于时间错误导致问题），但这是为了性能而做出的妥协。
* 写入（索引）数据时，Riak Search 不使用法定值。数据以“发射后不管”（fire and forget）的方式写入。如果有节点下线，Riak Search 会使用提示移交保证写入的可用性。
* 读取（查询）数据时，Riak Search 不使用法定值。只会读取一个数据副本，从那个分区读取取决于查询的整体效率。

## 主要组件

Riak Search 由以下组件组成：

* *Riak Core* -  受 Dynamo 启发的分布式系统框架
* *Riak KV* - 受 Amazon Dynamo 启发的分布式键值对存储
  * *Bitcask* -  Riak KV 使用的默认存储后台
* *Riak Search* - 分布式索引和全文搜素引擎
  * *Merge Index* - Riak Search 使用的存储后台。这是一个纯 Erlang 的存储格式，参照其他存储格式开发：日志结构合并树，SSTables，Bitcask 和 Lucene 文件系统
  * *Riak Solr* - 为 Riak Search 添加对部分 Solr HTTP 接口的支持

## 查询得分

文档的得分基本上使用[这些公式](http://lucene.apache.org/core/old_versioned_docs/versions/3_0_2/api/all/org/apache/lucene/search/Similarity.html)计算。

这些公式的主要不同之处是，计算 Inverse Document Frequency 的方式。“Similarity”页面中介绍的公式需要事先知道搜索结果的文档总数。Riak Search 并不知道结果的总是，所以用查询中各关键字的搜索结果总数之和代替。

## 终止词

Riak Search 实现了终止词，和在 Solr 中差不多：

[[http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.StopFilterFactory]]

Riak Search 的默认分析器源码地址如下：

[[http://github.com/basho/riak_search/blob/master/src/text_analyzers.erl]]

简单来说，索引时会跳过下面的词。官方列表在源码中，地址如上所示。

```erlang
is_stopword(Term) when length(Term) == 2 ->
    ordsets:is_element(Term, ["an", "as", "at", "be", "by", "if", "in", "is", "it", "no", "of", "on", "or", "to"]);
is_stopword(Term) when length(Term) == 3 ->
    ordsets:is_element(Term, ["and", "are", "but", "for", "not", "the", "was"]);
is_stopword(Term) when length(Term) == 4 ->
    ordsets:is_element(Term, ["into", "such", "that", "then", "they", "this", "will"]);
is_stopword(Term) when length(Term) == 5 ->
    ordsets:is_element(Term, ["their", "there", "these"]);
```

如果要在“精确关键字”查询中使用这些词，就得使用其他的分析器。但请注意，这些词可以迅速阻碍索引。希望将来分析器能解决这个问题，还能保证相同的效率。

下面举例说明终止词对查询的影响。如果使用精确关键字查询：

```bash
?q=\"the dog is\"
```

鉴于上述的终止词，查询会被切成“dog”。这可能和你预想的不一样。

## 索引搜索

索引文档的步骤如下：

1. 读取文档
2. 把文档分成一个或多个字段
3. 把各字段分成一个或多个关键字
4. 规格化每个字段中的关键字
5.把 {Field, Term, DocumentID} 记录写入索引

详细的索引命令可以参照“[[Riak Search 索引参考手册]]”。

## Riak Search，KV 和 MapReduce

Riak Search 能够索引和查询存储在 Riak KV 中的数据。一般情况下能够迅速启用对纯文本、XML、JSON 数据的索引。

<div class="info">
<div class="title">Riak Search 和 MapReduce</div>
Riak Search 不仅可以索引 Riak KV 中的数据，还可以作为 MapReduce 作业的输入。
</div>

### 启用索引

Riak Search 对 KV 数据的索引可以在各 bucket 上启用。要在 bucket 上启用索引，只需把 Riak Search precommit 钩子加入 bucket 的属性即可。

在命令行中把 Riak Search precommit 钩子加入 bucket 很简单：

```bash
bin/search-cmd install my_bucket_name
```

任何设置 bucket 属性的方法都可以用来设置 Riak Search precommit 钩子。例如，使用 curl 通过 HTTP 设置的方法如下：

```bash
curl -XPUT -H "content-type:application/json" http://localhost:8098/riak/demo2 -d @- << EOF
{"props":{"precommit":[{"mod":"riak_search_kv_hook","fun":"precommit"}]}}
EOF
```

不过要注意，可能要先把 bucket 属性读出来，以防把已经设置的钩子抹掉。

设置好钩子后，在写入数据时 Riak Search 就会建立索引。

### 数据类型

Riak Search 无需设置就可以处理多种标准数据格式，只需把对象的 Content-Type 设置为相应的 MIME 类型。默认支持的格式有 XML、JSON 和纯文本。

#### JSON 数据

如果数据是 JSON 格式，需要把 Content-Type 设为 "application/json"、"application/x-javascript"、"text/javascript"、"text/x-javascript" 或 "text/x-json"。

Riak Search 会使用 JSON 对象的字段名作为索引字段名，嵌套的 JSON 则使用下划线（_）分隔的字段名。（只所以使用下划线是因为它不是 Lucene 的保留字。有些人建议使用点号，但点号在 Riak 中还有其他用途。）

例如，把下面的 JSON 对象对出在启用 Riak Search 功能的 bucket 中：

```javascript
{
 "name":"Alyssa P. Hacker",
 "bio":"I'm an engineer, making awesome things.",
 "favorites":{
              "book":"The Moon is a Harsh Mistress",
              "album":"Magical Mystery Tour"
             }
}
```

会索引四个字段：name，bio，favorites_book 和 favorites_album。然后可以使用“bio:engineer AND favorites_album:mystery”这种查询语句查询数据。

#### XML 数据

如果数据是 XML 格式，要把 Content-Type 设为 "application/xml" 或 "text/xml"。

Riak Search 会使用标签名作为索引的字段名。嵌套的标签会使用下划线分隔标签名。标签的属性存在单独的字段中，字段名是在标签名之后加上“@”符号，然后再跟着属性名。

例如，把下面的 XML 对象存入启用了 Riak Search 功能的 bucket 中：

```xml
<?xml version="1.0"?>
<person>
   <name>Alyssa P. Hacker</name>
   <bio>I'm an engineer, making awesome things.</bio>
   <favorites>
      <item type="book">The Moon is a Harsh Mistress</item>
      <item type="album">Magical Mystery Tour</item>
   </favorites>
</person>
```

会索引四个字段：person_name，person_bio，person_favorites_item 和 person_favorite_item@type。..._item 和 ..._item@type 字段的值会把两个元素中的值连接在一起（分别是“The Moon is a Harsh Mistress Magical Mystery Tour”和“book album”）。然后可以使用“person_bio:engineer AND person_favorites_item:mystery”这种查询语句查询数据。

#### Erlang 数据

如果对象中包含 Erlang 类型数据，要把 Content-Type 设为 application/x-erlang。其中的数据可以是属性列表（proplist）或嵌套的属性列表。如果是属性列表，键会作为字段名，值作为字段的值。如果是嵌套的属性列表，字段名是使用下划线连接的嵌套键。

#### 纯文本数据

如果数据是纯文本格式，要把 Content-Type 设为 text/plain。如果不设置 Content-Type 则会使用纯文本解码器解析数据。

Riak Search 会索引纯文本数据中的所有文本，存入一个字段，名为“value”。查询时可以指定字段，例如“value:seven AND value:score”；或者省去这个默认的字段，例如“seven AND score”。

#### 其他数据类型

如果数据不是 JSON、XML 或纯文本格式，或者不想使用默认的字段命名和提取值的方式，都可以自己编写提取程序。

通过 HTTP 设置提取程序的方式如下：

```bash
curl -XPUT -H 'content-type: application/json' \
    http://host:port/riak/bucket \
    -d '{"props":{"search_extractor":{"mod":"my_extractor", "fun":"extract", "arg":"my_arg"}}}'
```

提取程序中应该定义 `extract` 函数，接受两个参数。第一个参数是要索引的 Riak 对象。第二个参数是静态参数，在 `search_extractor` 属性中指定，如果没指定则使用 `undefined`。`extract` 函数的返回结果是由两个元组组成的列表，表示“字段名/值”组合。字段名和值都应该使用二进制类型。

```erlang
[
 {<<"field1">>,<<"value1">>},
 {<<"field2">>,<<"value2">>}
]
```

编写提取程序时可以参考 `riak_search_kv_json_extractor`，`riak_search_kv_xml_extractor` 和 `riak_search_kv_raw_extractor` 模块。

#### 字段类型

如果你参照“其他数据类型”一节编写编码器，会惊奇的发现所有的字段都是以字符串的形式提取出来的。这是因为字段的类型是由模式定义的。

如果没定义模式，则会使用默认的模式。默认的模式会把多有字段按照字符串进行索引，除非字段名是以“_num”或“_dt”结尾，或者是其他模式文档中列出的动态字段。

可以按照定义非 KV 索引模式的方式定义 KV 索引的模式，只要能保证字段名和通过提取工具生成的字段名相同即可。
