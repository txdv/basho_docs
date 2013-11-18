---
title: Using Search
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, search, kv]
---

要想使用 Riak Search 必须先将其[[启用|Riak Search Settings]]。

## 介绍

Riak Search 是建立在 Riak Core 之上的分布式全文搜索引擎，包含在 Riak 开源项目中。Riak Search 是除 MapReduce 之外最功能最强大的查询方式，但更简单，更易于使用，对集群资源的消耗更少。

Riak Search 通过 pre-commit 钩子在存入数据的时候建立索引。基于对象的 MIME 类型和搜索模式，钩子可以自动提取并分析数据，建立索引。Riak 的客户端 API 能够执行搜索查询，返回“bucket/键”组合列表。目前，PHP、Python、Ruby 和 Erlang 客户端代码库都集成了对 Riak Search 的支持。

### 特性

* 支持自动提取多种 MIME类型的数据（JSON，XML，纯文本，Erlang，Erlang 二进制）
* 支持多种分析器（把文本分解成词法单元），包括空白分析器，整数分析器和 No-Op 分析器
* 健壮且易于使用的查询语言
* 精确匹配查询
  * 通配符查询
  * 范围内和范围外查询，支持 AND/OR/NOT 运算
  * 分组查询
  * 前缀匹配查询
  * 邻近搜索
  * 关键字权重
* 通过 HTTP 提供有类似 Solr 的接口（和 [[Solr|http://lucene.apache.org/solr]] 不兼容）
* Protocol buffers 接口
* 为最相关的结果打分
* 搜索查询可作为 MapReduce 作业的输入数据

### 什么时候使用 Riak Search

* 收集、处理和存储像用户资料、博客文章、日记等这种数据时，为了快速而准确的取出数据，并对结果进行可靠的评分。
* 索引 JSON 数据。提取程序根据数据的 MIME 。类型取出数据，分析器按字段分析，模式描述要索引哪些字段，以及如何分析和存储结果。
* 需要使用强大的查询语言快速取出信息。

### 什么时候不要使用 Raik Search

* 使用精确匹配和范围查询时只要简单的为数据打上标签。这是使用[[二级索引|Using Secondary Indexes]]要更简单。
* 数据无法轻易的使用 Raik Search 分析。例如音频、视频等二进制格式。这时推荐使用二级索引。
* 需要使用内建的反熵和一致性时。这时 Raik Search 没有读取修复机制。如果 Raik Search 的索引数据丢失了，对许对整个数据集重建索引。

## 索引数据

在搜索之前，必须先建立索引。在标准模式下，必须手动建立索引。在“[[搜素索引参考手册|Search Indexing Reference]]”一文中有索引命令的详细列表。

如果想简单点但不是很直观的索引，可以参照“[[高级搜索|Advanced Search]]”中的“[[搜索，KV 和 MapReduce|Advanced Search#Search-KV-and-MapReduce]]”一节。

<!-- Was "Riak Search - Querying" -->

## 查询接口

### 在命令行中查询

Riak Search 提供了一个命令行工具 `search-cmd`，可用来测试查询的句法。

下面这个例子会列出标题匹配“See spot run”的文档 ID。

```bash
bin/search-cmd search books "title:\"See spot run\""
```

### Solr

Riak Search 支持一种和 Solr 兼容的接口，可以通过 HTTP 查询文档。默认情况下，查询的地址是 `http://hostname:8098/solr/select`。

或者把索引包含在地址中，例如 `http://hostname:8098/solr/INDEX/select`。

支持下面的请求参数：

  * `index=INDEX`：指定默认的索引名
  * `q=QUERY`：运行指定的查询
  * `df=FIELDNAME`：使用指定的字段做默认值。覆盖模式文件中的 `default_field` 设置
  * `q.op=OPERATION`：可用设置是 `and` 或 `or`。覆盖模式文件中的 `default_op` 设置。默认值为 `or`
  * `start=N`：指定查询结果的起始值，用于分页。默认值是 0
  * `rows=N`：指定返回结果的最大数量。默认值是 10
  * `sort=FIELDNAME`：找到结果后按指定的字段排序。默认值是 `none`，结果按照得分降序排列
  * `wt=FORMAT`：设置输出的格式。可选值是 `xml` 和 `json`。默认值是 `xml`。
  * `filter=FILTERQUERY`：使用运行在[[行间字段|Advanced Search#Fields-and-Field-Level-Properties]]上的额外查询过滤搜索结果
  * `presort=key|score`：在选择指定的行之前先按照 bucket 键或搜索得分排序结果。分页时可以确保返回结果的顺序一致
      <div class="info">
      <div class="title">presort 的限制</div>

      注意，使用 **presort** 对结果进行分页时，只能按照搜索得分或键的顺序排序结果。目前无法在任意的字段上进行事先排序操作。因此，要想根据某些字段进行分页，先创建包含字段值的键，再指定 `presort=key` 参数。
      </div>

通过 curl 查询数据的方式如下：

```bash
curl "http://localhost:8098/solr/books/select?start=0&rows=10000&q=prog*"
```

### Riak 客户端 API

Riak 客户端 API 已经更新，支持 Riak Search 查询。更多信息请参考客户端文档。目前支持 Ruby、Python、PHP 和 Erlang 客户端。

API 接受搜索索引和搜索查询，返回“bucket/键”组合列表。某些客户端还会根据设置把列表转换成对象。

### Map/Reduce

集成对 Riak Search 支持的客户端代码还支持使用搜索查询生成 MapReduce 操作的输入数据。这样可以根据搜索查询对数据做强大的分析和计算。更多信息请参考客户端文档。目前支持 Java、Ruby、Python、PHP 和 Erlang 客户端。

通过 HTTP 在 POST 请求主体中使用相同的结果进行 MapReduce 查询的方式如下：

```javascript
{
  "inputs": {
             "bucket":"mybucket",
             "query":"foo OR bar"
            },
  "query":...
 }
```

或

```javascript
{
  "inputs": {
             "bucket":"mybucket",
             "query":"foo OR bar",
             "filter":"field2:baz"
            },
  "query":...
 }
```

`query` 字段中的步骤和往常完全一样。符合搜索查询的结果会提供给第一个 Map 步骤进行处理，但第一步使用 Link 步骤或 Reduce 步骤也可以。

`query` 字段指定搜索使用的查询语句。其他 Raik Search 接口支持的查询句法都可以在这个字段中使用。可选的 `filter` 字段指定查询的过滤器。

旧的仍然可用的句法如下：

```javascript
{
  "inputs": {
             "module":"riak_search",
             "function":"mapred_search",
             "arg":["customers","first_name:john"]
            },
  "query":...
 }
```

输入的 `arg` 字段都是由两个元素组成的列表。第一个元素是要搜索的 bucket，第二个元素是搜索所用的查询语句。

## 查询的句法

Riak Search 的查询句法和 [Lucene](http://lucene.apache.org/java/2_9_1/queryparsersyntax.html) 一样，而且支持 Lucene 中的大多数操作符，包括 term 搜索、字段搜索、布尔值操作符、分组、字典范围查询和通配符查询（只能出现在词尾）。

### 单个关键字查询和多个关键字查询

查询可以只有一个关键字（例如“red”），也可以有多个关键字，包含在引号中（例如“See spot run”）。关键字使用索引的默认分析器分析。

索引模式中有个 `{{default_operator}}` 设置，设定多个关键字是按照 AND 操作还是按照 OR 操作。默认情况下，多个关键字按照 OR 操作。也就是说，如果匹配多个关键字中的任何一个都会返回结果。

### 字段

要想查询指定的字段，可以把字段放到要查询的关键字前面。例如：

```bash
color:red
```

或：

```bash
title:"See spot run"
```

而且还可以指定索引：在字段前面加上索引名。例如：

```bash
products.color:red
```

或：

```bash
books.title:"See spot run"
```

如果字段中包含特殊字符，例如 +、-、/、[、]、(、)、: 或空格，可以把关键字放到单引号中，或者转义每个特殊字符。

```bash
books.url:'http://mycompany.com/url/to/my-book#foo'
```

或

```bash
books.url:http\:\/\/mycompany.com\/url\/to\/my\-book\#foo
```

### 通配符搜索

关键字中可以使用 * 通配符，进行前缀匹配；或者使用问号（?）匹配单个字符。

目前，这两个符号只能放在词尾。

例如：

* "bus*" 能匹配 "busy"、"business"、"busted" 等
* "bus?" 能匹配 "busy"、"bust"、"busk" 等

### 邻近搜索

邻近搜索会在特定数量的词数范围内搜索关键词。在关键词后加上破折号参数指明使用邻近搜索。

例如：

```bash
"See spot run"~20
```

会在同一个长为 20 的句子内查找包含单词“see”、“spot”和“run”的文档。

### 范围查询

范围查询可以在指定的范围内查询包含关键字的文档。范围按照字典的顺序计算。包含边界的范围使用方括号指定。不包含边界的范围使用花括号指定。

下面这个例子会返回包含“red”、“rum”以及这二者之间的单词的文档。

```bash
"field:[red TO rum]"
```

下面这个例子会返回包含“red”和“rum”之间的单词的文档。

```bash
"field:{red TO rum}"
```

### 提升关键字的权重

可以在关键字后面加上“^”符号和权重因子来提升关键字的权重。

在下面这个例子中，包含关键字“red”的文档得分会高一些：

```bash
red^5 OR blue
```

### 布尔操作符 - AND，OR，NOT

查询中可以使用布尔操作符 AND、OR 和 NOT。布尔操作符必须使用全部大写的形式。

下面这个例子返回包含单词“red”和“blue”，但不包含“yellow”的文档。

```bash
red AND blue AND NOT yellow
```

+ 可以代替“AND”，- 可以代替“AND NOT”。例如，上面的查询可以重写如下：

```bash
+red +blue -yellow
```

### 分组

查询中的子句可以使用括号分组。下面的例子返回包含关键字“red”或“blue”，但不包含“yellow”的文档：

```bash
(red OR blue) AND NOT yellow
```

<!--
Most clients support Search as inputs to MapReduce
Java: http://basho.github.io/riak-java-client/1.1.1/com/basho/riak/client/query/SearchMapReduce.html
    You can't enable search (bucket property) via Java
Ruby: ?

* Errors

* For more information about establishing a Search environment:
   * Ops stuff link
   * Schema/other dev stuff link
 -->
