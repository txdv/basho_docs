---
title: Advanced Search Schema
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [search, schema]
---

Riak Search 的设计目的就是和 Riak 无缝结合，所有保留了很多 Riak 的特性，其中一个就是无需模式（schema-free）。换句话说，不用预先定义索引字段就可以直接把数据添加到新索引中。

也就是说，Riak Search 确实有定义自定义模式的能力。这种能力可以用来指定所需的字段和自定义分析工具。

## 默认的模式

模式默认会把所有的字段都当成字符串，除非按照下面的方式指定字段名的后缀：

* *FIELDNAME_num* - 数字字段。使用整数分析器。值会被扩充到 10 个字符
* *FIELDNAME_int* - 数字字段。使用整数分析器。值会被扩充到 10 个字符
* *FIELDNAME_dt* - 日期字段。使用 No-Op 分析器
* *FIELDNAME_date* - 日期字段。使用 No-Op 分析器
* *FIELDNAME_txt* - 全部是文本的字段。使用标准分析器
* *FIELDNAME_text* - 全部是文本的字段。使用标准分析器
* 其他的所有字段都是用空白分析器

默认的字段名是 *value*。

## 定义模式

索引的模式存储在 `_rs_schema` bucket 中，键名就是索引名。例如，“book”索引的模式存储在 `_rs_schema/books` 中。不要直接写入 `_rs_schema` bucket。

而是通过命令行工具写入或读取索引的模式：

```bash
# Set an index schema.
bin/search-cmd set-schema Index SchemaFile

# View the schema for an Index.
bin/search-cmd show-schema Index
```

注意，修改模式文件后*不会*影响修改前的索引数据。如果修改了字段定义，特别是“type”或“analyzer_factory”字段，建议重建文件的索引：列出相应的键，把文档读取出来然后再写入 Riak。

下面是一个模式文件示例，其格式使用 Erlang 类型，其中的空格没什么关系，但一定要确保括号是成对出现的，所有条目后面都要有逗号，最后一个花括号后面要有点号：

```erlang
{
    schema,
    [
        {version, "1.1"},
        {default_field, "title"},
        {default_op, "or"},
        {n_val, 3},
        {analyzer_factory, {erlang, text_analyzers, whitespace_analyzer_factory}}
    ],
    [
        %% Don't parse the field, treat it as a single token.
        {field, [
            {name, "id"},
            {analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}
        ]},

        %% Parse the field in preparation for full-text searching.
        {field, [
            {name, "title"},
            {required, true},
            {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}
        ]},

        %% Treat the field as a date, which currently uses noop_analyzer_factory.
        {field, [
            {name, "published"},
            {type, date}
        ]},

        %% Treat the field as an integer. Pad it with zeros to 10 places.
        {field, [
            {name, "count"},
            {type, integer},
            {padding_size, 10}
        ]},

        %% Alias a field
        {field, [
            {name, "name"},
            {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}},
            {alias, "LastName"},
            {alias, "FirstName"}
        ]},

        %% A dynamic field. Anything ending in "_text" will use the standard_analyzer_factory.
        {dynamic_field, [
            {name, "*_text"},
            {analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}
        ]},

        %% A dynamic field. Catches any remaining fields in the
        %% document, and uses the analyzer_factory setting defined
        %% above for the schema.
        {dynamic_field, [
            {name, "*"}
        ]}
    ]
}.
```

## 模式层级的属性

下面的属性在模式层级定义：

* *version* - 必须设定。版本好，面前没什么用。
* *default_field* - 必须设定。指定搜索时使用的默认字段。
* *default_op* - 可选。可设成“and”或“or”，定义默认的布尔值。默认值是“or”。
* *n_val* - 可选。设置搜索数据的副本数量。默认值是 3。
* *analyzer_factory* - 可选。默认值是“com.basho.search.analysis.DefaultAnalyzerFactory”。

## 字段和字段层级的属性

字段可以是静态的也可以是动态的。静态字段通过字段定义前面的 `field` 指定，动态字段通过字段定义前面的 `dynamic_field` 指定。

二者的区别是，静态字段会在字段名上进行完全的字符串匹配，而动态字段会在字符串名字上进行通配符匹配。通配符可以出现在字段的任何位置，但一般在开头或结尾。（如前所述，模式默认使用动态字段，这样就可以在字段名后加上后缀来创建不同数据类型的字段。）

<div class="info">字段匹配按照模式定义中指明的循序进行。这样就可以创建很多静态字段，然后再创建一个动态字段来匹配其他所有值。</div>

下面是在字段层级定义的属性，在静态字段和动态字段中都可使用：

* *name* - 必须设定。字段的名字。动态字段可使用通配符。注意，唯一标识文档的字段*必须*命名为“id”。
* *required* - 可选。布尔值，指明在文档搜索中是否需要这个字段。如果丢失，则文档通不过验证。默认值是 `false`。
* *type* - 可选。字段的类型，`string` 或 `integer`。如果设为 `integer`，而且字段层级没有设置 analyzer_factory，那么会使用空白分析器。默认值是 `string`。
* *analyzer_factory* - 可选。设置解析字段时使用的分析器。如果不指定，则使用模式层级设定的分析器（除非这个字段是整数类型。参照上一个属性）。
* *skip* - 可选。如果设为 `true`，字段虽然会存储，但不会被索引。默认值是 `false`。
* *alias* - 可选。映射到当前字段定义上的别名，把多个字段的不同字段名索引到同一个字段中。这个属性根据需要，想设多少个就设多少个。
* *padding_size* - 可选。值会扩展到这么长。字符串类型的默认值是 0，整数类型的默认值是 10。
* *inline* - 可选。可设定的值有 `true`、`false` 和 `only`（默认值是 `false`）。设为 `only` 时，字段将无法搜索自身，而是作为搜索其他字段的过滤器。这么做能提高某些查询的性能（例如某些情况下的范围查询），但会消耗更多的存储空间，因为字段的值和其他字段的索引存在一起。设为 `true` 时，除了行间存储之外，字段还会正常存储。过滤行间字段目前只有 [[Solr|Using Search#Query-Interfaces]] 接口支持。

<div class="info">
    <div class="title">别名的注意事项</div>

1. 千万不要把别名设成和字段名一样。这么做会导致字段中的值使用不确定的名字索引。
2. 多个别名会使用空格连接起来。如果 Name 有两个别名，那么 {LastName:"Smith", FirstName:"Dave"} 将会存储为“Smith Dave”。
</div>

## 分析器

Riak Search 提供了很多不同的分析器：

### 空白分析器

空白分析器使用空白拆分文本的方式分析字段。空白包括空格、制表符、换行、回车等。

例如，文本“It's well-known fact that a picture is worth 1000 words.”会被拆分为下面的词法单元：["It's", "a", "well-known", "fact", "that", "a", "picture", "is", "worth", "1000", "words."]。注意，字母的大小写和标点符号都保留着。

要想使用空白分析器，按照下面的方式设置 *analyzer_factory*：

```erlang
{analyzer_factory, {erlang, text_analyzers, whitespace_analyzer_factory}}}
```

### 标准分析器

标准分析器模拟了 Java/Lucene 的标准词法分析器。标准分析器可用来在多个使用英语编写的文档中进行全文搜索。该分析器根据下面的规格分析字段：

1. 在标点符号处进行拆分，除非是后面跟着字符的句点
2. 把所有词法单元转换成小写字母形式
3. 踢出少于三个字符的词法单元和终止词（常见的英语单词）

终止词包括："an"，"as"，"at"，"be"，"by"，"if"，"in"，"is"，"it"，"no"，"of"，"on"，"or"，"to"，"and"，"are"，"but"，"for"，"not"，"the"，"was"，"into"，"such"，"that"，"then"，"they"，"this"，"will""their"，"there"，"these"。

文本“It's well-known fact that a picture is worth 1000 words.”得到的词法单元是 ["well", "known", "fact", "picture", "worth", "1000", "words"]。

要使用标准分析器，按照下面的方式设置 *analyzer_factory*：

```erlang
{analyzer_factory, {erlang, text_analyzers, standard_analyzer_factory}}}
```

### 整数分析器

整数分析器会查找字段中的所有整数。整数使用字符串的方式表示，中间没有任何标点，可以以“-”开头，表示负数。

例如，文本“It's well-known fact that a picture is worth 1000 words.”得到的结果只有一个词法单元 “1000”。

要使用整数分析器，按照下面的方式设置 *analyzer_factory*：

```erlang
{analyzer_factory, {erlang, text_analyzers, integer_analyzer_factory}}}
```

### No-Op 分析器

No-Op 分析器不会分析字段，只是把字段的值作为结果返回。因此，适合在标识字段上使用。

例如，文本“WPRS10-11#B”经过分析后还是“WPRS10-11#B”。

要使用 No-Op 分析器，按照下面的方式设置 *analyzer_factory*：

```erlang
{analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}}
```

### 自定义分析器

可以使用 Erlang 自行开发分析器。

一些提示：

* 参照现有的分析器开发，[[https://github.com/basho/riak_search/blob/master/src/text_analyzers.erl]] 是一个示例代码

* 分析器应该接收字符串和设置参数作为输入，返回词法单元列表。词法单元的顺序对邻近搜索很重要。

* 确保把编译好的分析器添加到代码路径中。
