---
title: 链接
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [appendix, concepts]
---

[[链接]] 是一些元数据，在对象之间建立一种单向关联，可以表示类似对象关联这种松散的模型。

## 链接报头

使用 [[HTTP API]] 读取及修改链接是通过 Link 报头进行的。这个报头模拟了 HTML 中的 &lt;link&gt; 标签，建立和其他 HTTP 资源之间的关联。Riak 使用的格式如下：

```bash
Link: </riak/bucket/key>; riaktag="tag"
```

尖括号中是一个相对地址，指向 Riak 中的另一个对象。双引号中的值可以是任意字符串，在应用程序中有一定意义。

对象中可以有多个链接，使用逗号分隔。例如，如果对象中有两个链接的对象，那么报头如下：

```bash
Link: </riak/list/1>; riaktag="previous", </riak/list/3>; riaktag="next"
```

<div class="info">
对象能包含的链接数量没有硬性限制。不过添加链接会增加对象的大小，针对数据的指导思想同样适用于链接：要在大小和可用性之间建立良好平衡。
</div>

## 在 Erlang API 中使用链接

Erlang API 中的链接已元组的形式存储在对象的元数据中，格式如下：

```bash
{{<<"bucket">>,<<"key">>},<<"tag">>}
```

要读取链接，先使用 `riak\_object:get\_metadata/1` 读取元数据字典，然后再从字典中读取 `<<"Links">>` 键。例如：

```bash
1> {ok, Object} = Client:get(<<"list">>,<<"2">>,1).
2> Meta = riak_object:get_metadata(Object).
3> Links = dict:fetch(<<"Links">>, Meta).
[{{<<"list">>,<<"1">>},<<"previous">>},{{<<"list">>,<<"3">>},<<"next">>}]
```

要把链接存入对象，先更新字典来更新对象的元数据，然后在写入对象：

```bash
4> NewMeta = dict:store(<<"Links">>, [{{<<"list">>,<<"0">>},<<"first">>}|Links], Meta).
5> NewObject = riak_object:update_metadata(Object, NewMeta).
6> Client:put(NewObject,2).
```

## 链接遍历

链接遍历是一种特殊的 [[MapReduce|MapReduce 高级用法]] 查询，可以通过 [[HTTP 链接遍历|通过 HTTP 进行链接遍历]] 进行。链接遍历从单个输入对象开始，跟踪该对象中的链接，找到符合查询条件的其他对象。单次请求中可以进行多次遍历，返回任意数量的中间结果。最后一次链接遍历总会返回结果。

-   [[链接遍历举例|http://basho.com/link-walking-by-example/]]（来自 Basho 的博客）
