---
title: Search Indexing Reference
project: riak
version: 1.4.2+
document: reference
toc: true
audience: advanced
keywords: [developers, reference, search]
---

使用 Riak Search 有很多方法可以索引文档。

## 从命令行建立索引

对存储在文件系统中的文档建立索引最简单的方法是使用 `search-cmd` 命令行工具：

```bash
bin/search-cmd index <INDEX> <PATH>
```

参数：

* *&lt;INDEX&gt;* - 索引名
* *&lt;PATH&gt;* - 递归建立索引的文件或文件夹的相对路径或绝对路径。可以使用通配符

文档会使用模式中定义的默认字段建立索引，文档 ID 是文件名加上扩展名。

```bash
bin/search-cmd index my_index files/to/index/*.txt
```

## 从命令行删除索引

要从命令行把之前建立的索引删除，同样使用 `search-cmd` 命令行工具。

```bash
bin/search-cmd delete <INDEX> <PATH>
```

参数：

* *&lt;INDEX&gt;* - 索引名
* *&lt;PATH&gt;* - 递归删除索引的文件或文件夹的相对路径或绝对路径。可以使用通配符

例如：

```bash
bin/search-cmd delete my_index files/to/index/*.txt
```

所有匹配文件名和扩展名的文档都会从索引中删除。删除操作会忽略文件中的内容。

## 使用 Erlang API 建立索引

下面的 Erlang 函数可以为存储在文件系统上的文档建立索引：

```erlang
search:index_dir(Path).

search:index_dir(Index, Path).
```

参数：

* *Index* - 索引名
* *Path* - 递归建立索引的文件或文件夹的相对路径或绝对路径。可以使用通配符.

文档会使用模式中定义的默认字段建立索引，文档 ID 是文件名加上扩展名。

```erlang
search:index_dir(<<"my_index">>, "files/to/index/*.txt").
```

还可以指定要建立索引的文档字段。

```bash
search:index_doc(Index, DocId, Fields)
```

参数：

* *&lt;INDEX>* - 索引名
* *&lt;DocID>* - 文档 ID
* *&lt;Fields>* - 要建立索引的字段键值对列表

例如：

```erlang
search:index_doc(<<"my_index">>, <<"my_doc">>, [{<<"title">>, <<"The Title">>}, {<<"content">>, <<"The Content">>}])
```

## 使用 Erlang API 删除索引

下面的函数可以把文件从索引中删除：

```erlang
search:delete_dir(Path).

search:delete_dir(Index, Path).
```

参数：

* *Index* - 索引名。默认值是 `search`
* *Path* - 递归删除索引的文件或文件夹的相对路径或绝对路径。可以使用通配符

例如：

```erlang
search:delete_dir(<<"my_index">>, "files/to/index/*.txt").
```

所有匹配文件名和扩展名的文档都会从索引中删除。删除操作会忽略文件中的内容。

还可以指定要删除索引的文档 ID。

```erlang
search:delete_doc(<<"my_index">>, <<"my_doc">>).
```

参数：

* *Index* - 索引名
* *DocID* - 要删除索引的文档 ID

## 通过 Solr 接口建立索引

Riak Search 支持通过 HTTP 使用和 Solr 兼容的接口为文档建立索引。文档必须使用简单的 Solr XML 格式，例如：

```xml
<add>
  <doc>
    <field name="id">DocID</field>
    <field name="title">Zen and the Art of Motorcycle Maintenance</field>
    <field name="author">Robert Pirsig</field>
    ...
  </doc>
  ...
</add>
```

或者把文档的 Content-Type 报头设为 text/xml。

目前，在 Riak Search 中，指明文档 ID 的字段必须命名为“id”，而且“add”、“doc”和“field”元素都不支持属性。（也就是还不支持“overwrite”、“commitWithin”和“boost”等。）

Solr 接口不支持  &lt;commit /&gt; 和 &lt;optimize /&gt; 命令。所有数据都按照下面的步骤自动提交：

* 解析输入的 Solr XML 文档。如果不符合 XML 的句法，会返回错误。
* 分析文档字段，生成关键字。如果出现问题，则返回错误。
* 并行索引文档的关键字。这些关键字能否在后续的请求中使用取决于所用的存储后台。

默认情况下，更新的 URL 地址是 http://hostname:8098/solr/update?index=INDEX。

URL 中也可以包含索引，例如 http://hostname:8098/solr/INDEX/update。

使用 curl 向系统中添加数据：

```bash
curl -X POST -H text/xml --data-binary @tests/books.xml http://localhost:8098/solr/books/update
```

或者在命令行中索引 Solr 文件：

```bash
bin/search-cmd solr my_index path/to/solrfile.xml
```

## 通过 Solr 接口删除索引

文档可以通过 Solr 接口从索引中删除，方法有二：通过文档 ID，通过查询。

要想通过文档 ID 删除文档，要把下面的 XML 发送到更新所用的 URL：

```xml
<delete>
  <id>docid1</id>
  <id>docid2</id>
  ...
</delete>
```

要想通过查询删除文档，要把下面的 XML 发送到更新所用的 URL：

```xml
<delete>
  <query>QUERY1</query>
  <query>QUERY2</query>
  ...
</delete>
```

所有符合查询条件的文档都会被删除。
