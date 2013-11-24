---
title: MapReduce 高级用法
project: riak
version: 1.4.2+
document: guide
toc: true
audience: advanced
keywords: [developers, mapreduce]
---

MapReduce 是 [[Google|http://research.google.com/archive/mapreduce.html]] 倡导的编程范式，Raik 将其用作后台批量进程聚合结果。本文前半部分介绍 MapReduce 的高级用法，后半部分说明 Riak 是如何实现 MapReduce 的。

## MapReduce

MapReduce 是 Google 倡导的编程范式。在 Raik 中，MapReduce 是不依赖主键的主要查询方式。

在 Raik 中，可以通过 Erlang API 和 HTTP API 两种方式运行 MapReduce 作业。本文我们将使用 HTTP API。

### 为什么要使用 MapReduce 进行查询？

像 Raik 这种键值对存储系统出了保存和读取对象之外基本没什么其他功能。MapReduce 增强了查询功能，也非常符合面向函数编程的 Raik 核心代码和数据存储的分布式特性。

MapReduce 主要目标是把查询操作传布到多个系统，发挥并行处理的优势。MapReduce 把查询分成很多步骤，把数据集分成多个片段，然后在各物理主机的数据片段上执行这些步骤。在 Raik 中，MapReduce 还有一个目的：增进数据的局限性。处理大型数据集时，在数据上做计算，比把数据引入计算过程要高效。

“Map”和“Reduce”是查询过程中的两个步骤。“Map”接受一些输入数据，生成一个或多个输出结果。如果你熟悉函数式编程中的“列表映射”（mapping over a list），对 map/reduce 查询中的“Map”这一步就不会陌生。

<!-- MapReduce-Implementation.md -->

## Riak 如何传布处理过程

本文剩下的部分将详细介绍 Raik 是如何实现 MapReduce 的，包括 Riak 是如何把处理过程传布到整个集群的，如何指定及运行查询，如何通过 HTTP API 和 Erlang API 运行 MapReduce 查询，streaming MapReduce，步骤函数和设置。

处理大型数据集时，在数据上做计算，比把数据引入计算过程要高效。MapReduce 作业的代码基本上都不超过 10KB，因此把这些代码发送到数 GB 的数据，比把数 GB 的数据引入代码更高效。

Riak 对数据局限性的处理决定了如何把处理过程传布到整个集群。Riak 节点可以协调读或写操作，把请求直接发给负责维护这些数据的节点，与此相同，Riak 节点也能协调 MapReduce 查询，把“Map”这一步的计算请求直接发给负责维护输入数据的节点。“Map”步骤的结果会回传给负责协调的节点，然后“Reduce”步骤可以生成唯一的结果。

简单一点来说，Riak 在保存输入数据的节点上运行“Map”步骤，然后再负责协调 MapReduce 查询的节点上运行“Reduce”步骤。

## 如何指定 MapReduce 查询

在 Raik 中，MapReduce 查询由两部分组成：输入列表和步骤列表。

输入列表中的元素是“bucket/键”组合。在“bucket/键”组合对应的对象上计算时，还可以使用“键/数据”组合注解“bucket/键”组合，“键/数据”组合会作为参数传入“Map”函数。

步骤列表中的元素是“Map”函数、“Reduce”函数或“Link”函数的描述信息。描述信息中说明了到哪里寻找步骤（Map 和 Reduce）函数的代码，执行各步时传入函数的静态数据，以及一个旗标，指明是否要在查询的最终结果中包含各步的结果。

步骤列表说明了输入数据的操作流程，原始的输入会传给列表中的第一个步骤，得到的结果会作为输入传给下一个步骤，直到完成列表中的所有步骤为止。

## 各步骤是如何工作的

### Map 步骤

Map 步骤的输入列表必须是一系列“bucket/键”组合（还可以有注解）。对每个键值对，Riak 都会向存储对应数据的分区发送请求，计算 Map 函数。分区所在的虚拟节点会查找“bucket/键”组合对应的数据，将其传入 Map 函数。如果有注解，会协同“bucket/键”组合和静态数据一起传入 Map 函数。

### Reduce 步骤

Reduce 步骤接受任意数据列表作为输入，然后生成任意的数据列表作为结果。Reduce 步骤还可以接受查询中指定的步骤静态值。

注意，Reduce 步骤函数可以多次计算，前面的计算结果会传入后续的计算。

例如，Reduce 步骤可能实现了 [set-union](http://en.wikipedia.org/wiki/Union_(set_theory)#Definition) 函数。此时，如果输入列表是 `[1,2,2,3]`，那么输出为 `[1,2,3]`。如果又输入了 `[3,4,5]`，那么传入的输入列表是两个列表合并后的结果，即 `[1,2,3,3,4,5]`。

其他系统把第二次计算称为“re-reduce”。在 Raik 中，有很多 Reduce 查询实现策略。

其中一种策略是在 Reduce 步骤之前实现，这样其输出数据的形式就和 Reduce 步骤一样了。本文中的示例代码使用的都是这种方式，我们觉得使用这种方式编写的代码更整洁。

还有一种策略是让 Reduce 步骤的输出便于识别，这样在后续的处理过程中就能从输入列表中将其提取出来了。例如，如果上一步的输入是数字，Reduce 步骤的输出可以是对象或字符串。这样，函数就能找到上一步的结果，然后在其上附加新的输入。

### “Link”步骤是如何工作的

Link 步骤会找到匹配查询条件的链接。查询条件中指明链接中必须包含哪些 bucket 和标签。

“跟踪链接”的意思是将其加入“Link”步骤的输出列表。Link 步骤的结果经常会作为 Map 步骤或其他 Reduce 步骤的输入。

## HTTP API 示例

Riak 支持使用 JavaScript 和 Erlang 编写 MapReduce 查询函数，可以通过 [[HTTP API]] 进行查询操作。

<div class="note">
<div class="title">“bad encoding”错误</div>

如果 MapReduce 查询报错“bad encoding”，而且查询中包含使用 Javascript 编写的函数，请确保数据中没有错误的 Unicode 转义字符。传入 Javascript VM 的数据必须使用 Unicode 格式。

</div>

### HTTP 示例

这个例子会把一些数据存入 Raik，然后通过 HTTP API 使用 MapReduce 计算文档中各单词出现的次数。

#### 加载数据

我们使用 Riak 的 HTTP 接口存入文本：

```bash
$ curl -XPUT -H "content-type: text/plain" \
    http://localhost:8098/riak/alice/p1 --data-binary @-<<\EOF
Alice was beginning to get very tired of sitting by her sister on the
bank, and of having nothing to do: once or twice she had peeped into the
book her sister was reading, but it had no pictures or conversations in
it, 'and what is the use of a book,' thought Alice 'without pictures or
conversation?'
EOF

$ curl -XPUT -H "content-type: text/plain" \
    http://localhost:8098/riak/alice/p2 --data-binary @-<<\EOF
So she was considering in her own mind (as well as she could, for the
hot day made her feel very sleepy and stupid), whether the pleasure
of making a daisy-chain would be worth the trouble of getting up and
picking the daisies, when suddenly a White Rabbit with pink eyes ran
close by her.
EOF

$ curl -XPUT -H "content-type: text/plain" \
    http://localhost:8098/riak/alice/p5 --data-binary @-<<\EOF
The rabbit-hole went straight on like a tunnel for some way, and then
dipped suddenly down, so suddenly that Alice had not a moment to think
about stopping herself before she found herself falling down a very deep
well.
EOF
```

#### 运行查询

加载数据后，现在可以运行查询了：

```bash
$ curl -X POST -H "content-type: application/json" \
    http://localhost:8098/mapred --data @-<<\EOF
{"inputs":[["alice","p1"],["alice","p2"],["alice","p5"]]
,"query":[{"map":{"language":"javascript","source":"
function(v) {
  var m = v.values[0].data.toLowerCase().match(/\w*/g);
  var r = [];
  for(var i in m) {
    if(m[i] != '') {
      var o = {};
      o[m[i]] = 1;
      r.push(o);
    }
  }
  return r;
}
"}},{"reduce":{"language":"javascript","source":"
function(v) {
  var r = {};
  for(var i in v) {
    for(var w in v[i]) {
      if(w in r) r[w] += v[i][w];
      else r[w] = v[i][w];
    }
  }
  return [r];
}
"}}]}
EOF
```

得到的结果是三个文档中各单词出现的次数。

```javascript
[{"the":8,"rabbit":2,"hole":1,"went":1,"straight":1,"on":2,"like":1,"a":6,"tunnel":1,"for":2,"some":1,"way":1,"and":5,"then":1,"dipped":1,"suddenly":3,"down":2,"so":2,"that":1,"alice":3,"had":3,"not":1,"moment":1,"to":3,"think":1,"about":1,"stopping":1,"herself":2,"before":1,"she":4,"found":1,"falling":1,"very":3,"deep":1,"well":2,"was":3,"considering":1,"in":2,"her":5,"own":1,"mind":1,"as":2,"could":1,"hot":1,"day":1,"made":1,"feel":1,"sleepy":1,"stupid":1,"whether":1,"pleasure":1,"of":5,"making":1,"daisy":1,"chain":1,"would":1,"be":1,"worth":1,"trouble":1,"getting":1,"up":1,"picking":1,"daisies":1,"when":1,"white":1,"with":1,"pink":1,"eyes":1,"ran":1,"close":1,"by":2,"beginning":1,"get":1,"tired":1,"sitting":1,"sister":2,"bank":1,"having":1,"nothing":1,"do":1,"once":1,"or":3,"twice":1,"peeped":1,"into":1,"book":2,"reading":1,"but":1,"it":2,"no":1,"pictures":2,"conversations":1,"what":1,"is":1,"use":1,"thought":1,"without":1,"conversation":1}]
```

#### 解说

想知道各句法的意思，或了解其他句法，请阅读下一小节。下面简单解说了这个 map/reduce 示例：

* `alice` 这个 bucket 中名为 *p1*、*p2* 和 *p5* 的对象是查询的输入
* Map 步骤的函数在每个对象上运行

```javascript
function(v) {
  var words = v.values[0].data.toLowerCase().match('\\w*','g');
  var counts = [];
  for(var word in words)
    if (words[word] != '') {
      var count = {};
      count[words[word]] = 1;
      counts.push(count);
    }
  return counts;
}
```

上述函数会创建一个 JSON 对象列表，文本中的每个单词（可重复出现）都对应一个元素。列表中各元素都有一个键，即单词本身，以及一个值，整数 1。

* Reduce 步骤的函数在 Map 步骤的输出结果上运行

```javascript
function(values) {
  var result = {};
  for (var value in values) {
    for(var word in values[value]) {
      if (word in result)
        result[word] += values[value][word];
      else
        result[word] = values[value][word];
    }
  }
  return [result];
}
```

上述函数会检查输入列表中的每个 JSON 对象，生成一个新对象，其键不变，值是这个键出现在其他对象中的数量总和。创建的新对象还会以列表的形式输出，因为 Reduce 函数还可以再次在包含该对象的列表上运行，或者可以从 Map 步骤接收更多的输入数据。

* 最终的输出结果是只有一个元素的列表，这个元素是 JSON 对象，所包含的元素其键是所有文档中的单词（没有重复），其值是这个单词在文档中出现的次数。

### HTTP 查询句法

通过 HTTP 运行的 Map/Reduce 查询是发送到 `/mapred` 资源上的 *POST* 请求。请求主体应该是 `application/json` 类型，符合这种格式 `{"inputs":[...inputs...],"query":[...query...]}`。

Map/Reduce 查询默认的请求超时时间是 60000 毫秒（60 秒）。默认的超时时间可以修改，使用这个请求主体 `{"inputs":[...inputs...],"query":[...query...],"timeout": 90000}`。

如果请求超时了，协调 MapReduce 查询的节点会终止查询操作，向客户端发送错误信息。何时以及是否会超时取决于涉及到的数据大小和集群的负载。如果经常超时，就要考虑把超时时间设的大一点，或者减少运行 MapReduce 请求使用的数据量。

#### 输入

输入数据可以使用包含两个元素的列表形式 `[Bucket,Key]`，也可以使用包含三个列表的形式 `[Bucket,Key,KeyData]`。

还可以直接传入 bucket 的名字（`{"inputs":"mybucket",...}`），这么做等同于把这个 bucket 中的所有键作为输入。但要知道，这种方法会触发较消耗资源的列键操作，所以要慎重使用。输入整个 bucket 时也可以使用[[键过滤器|使用键过滤器]]，限制传入查询第一步的对象数量。

如果使用 Riak Search，输入列表还可以使用“[[搜索查询引用|使用 Riak Search#Querying-Integrated-with-Map-Reduce]]”。

如果启用了二级索引，输入列表也可以使用“[[二级索引查询引用|使用二级索引#Examples]]”。

#### 查询

查询中包含一组步骤，每步使用这种格式 `{PhaseType:{...spec...}}`。合法的 `{PhaseType}` 有“map”、“reduce”和“link”。

每个步骤的定义中有可能还有 `keep` 字段，其值为布尔值：如果为 `true`，表明这一步的结果应该包含在 map/reduce, 查询的最终结果中；如果为 `false`，表明这一步的结果只作为下一步的输入使用。如果没有指定 `keep` 字段，除了最后一步，其他步骤都使用默认值，即 `false`（Riak 假定你最关注的是 map/reduce 查询最后一步得到的结果）。

##### Map 步骤

Map 步骤必须指明到哪里寻找函数的代码，以及这个函数是用什么语言开发的。

函数源码存放的位置可以直接在查询的 `source` 字段中指定，也可以从事先保存的 Riak 对象中加载。如果使用内建的 JavaScript 函数，可以指定 `name` 字段。使用 Erlang 函数可以指定 `module` 和 `function` 字段。

<div class="info">Riak 集成了一些 JavaScript 函数，可以到 [[https://github.com/basho/riak_kv/blob/master/priv/mapred_builtins.js|https://github.com/basho/riak_kv/blob/master/priv/mapred_builtins.js]] 中查看。</div>

例如：

```javascript
{"map":{"language":"javascript","source":"function(v) { return [v]; }","keep":true}}
```

会执行指定的 JavaScript 函数，并把结果包含在 m/r 查询的最终结果中。

```javascript
{"map":{"language":"javascript","bucket":"myjs","key":"mymap","keep":false}}
```

会执行 `myjs` 这个 bucket 中键 *mymap* 对应的对象中保存的 JavaScript 函数，但结果不会包含在 m/r 查询的最终结果中。

```javascript
   {"map":{"language":"javascript","name":"Riak.mapValuesJson"}}
```

如果硬盘上存有 JavaScript 函数，则会执行内建的 `mapValuesJson` 函数。所有 JS 文件都要保存在 `app.config` 文件中 `js_source_dir` 设置的文件夹内。

```javascript
{"map":{"language":"erlang","module":"riak_mapreduce","function":"map_object_value"}}
```

上面这个查询会执行 Erlang 函数 `riak_mapreduce:map_object_value/3`，这个函数编译得到的 beam 文件要能够被所有 Riak 节点读取（更多细节请阅读“[[Commit 钩子高级用法]]”一文）。

Map 步骤还可以传入静态参数，通过 `arg` 字段指定。

例如，下面的 Map 函数会在 `arg` 字段指定的值上进行正则匹配，返回 `arg` 指定的值在各对象中出现的次数：

```javascript
{"map":
  {"language":"javascript",
  "source":"function(v, keyData, arg) {
    var re = RegExp(arg, \"gi\");
    var m = v.values[0].data.match(re);
    if (m == null) {
      return [{\"key\":v.key, \"count\":0}];
    } else {
      return [{\"key\":v.key, \"count\":m.length}];
    }
  }",
  "arg":"static data used in map function"}
}
```

##### Reduce 步骤

Reduce 步骤和 Map 步骤使用的句法几乎一样，只是标签是“reduce”。

##### Link 步骤

Link 步骤中包含 `bucket` 和 `tag` 字段，指明哪些链接满足查询条件。字段中的“_”（下划线）的意思是匹配所有，其他的字符串则表明要完全匹配这个字符串。如果没有指定字段，则默认为 `_`（匹配所有）。

下面这个例子会跟踪指向 `foo` 这个 bucket 中对象的所有链接，不管 `tag` 是什么：

```javascript
{"link":{"bucket":"foo","keep":false}}
```

## Protocol Buffers API 示例

Riak 还支持使用 Erlang 句法通过 Protocol Buffers API 定义 MapReduce 查询。本节会演示如何使用 Erlang 客户端进行 MapReduce 查询。

<div class="note">
<div class="title">分发 Erlang MapReduce 代码</div>

使用 Erlang 定义 MapReduce 查询时，要保证使用的模块和函数可以被集群中所有节点读取。可以在 [[vm.args|设置文件]] 文件中设置 *-pz* 选项，把这些模块和函数加入 Erlang 应用程序，或者在 <code>app.config</code> 文件中添加 <code>add_paths</code> 设置。

</div>

### Erlang 示例

在执行 MapReduce 查询之前，先来创建一些对象。

```erlang
1> {ok, Client} = riakc_pb_socket:start("127.0.0.1", 8087).
2> Mine = riakc_obj:new(<<"groceries">>, <<"mine">>,
                        term_to_binary(["eggs", "bacon"])).
3> Yours = riakc_obj:new(<<"groceries">>, <<"yours">>,
                         term_to_binary(["bread", "bacon"])).
4> riakc_pb_socket:put(Client, Yours, [{w, 1}]).
5> riakc_pb_socket:put(Client, Mine, [{w, 1}]).
```

现在客户端和数据都有了，我们来执行一个查询，统计各种食品的数量。

```erlang
6> Count = fun(G, undefined, none) ->
             [dict:from_list([{I, 1}
              || I <- binary_to_term(riak_object:get_value(G))])]
           end.
7> Merge = fun(Gcounts, none) ->
             [lists:foldl(fun(G, Acc) ->
                            dict:merge(fun(_, X, Y) -> X+Y end,
                                       G, Acc)
                          end,
                          dict:new(),
                          Gcounts)]
           end.
8> {ok, [{1, [R]}]} = riakc_pb_socket:mapred(
                         Client,
                         [{<<"groceries">>, <<"mine">>},
                          {<<"groceries">>, <<"yours">>}],
                         [{map, {qfun, Count}, none, false},
                          {reduce, {qfun, Merge}, none, true}]).
9> L = dict:to_list(R).
```

<div class="note">
<div class="title">Riak 对象的表现方式</div>

注意，我们在 MapReduce 函数中使用的是 `riak_object` 模块，在客户端使用的是 `riakc_obj` 模块。Riak 对象在集群内部和外部表现的方式是不一样的。

</div>

传入创建好的食品列表后，上述的函数会把结果赋值给 L：`[{"bread",1},{"eggs",1},{"bacon",2}]`。

### Erlang 查询句法

`riakc_pb_socket:mapred/3` 函数有三个参数，一个客户端对象和两个列表。第一个列表为“bucket/键”组合，是 MapReduce 查询的输入。第二个列表是查询的各个步骤。

#### 输入

输入对象是元组列表，格式为 `{Bucket, Key}` 或 `{{Bucket, Key}, KeyData}`。`Bucket` 和 `Key` 必须使用二进制格式，`KeyData` 可以使用任何 Erlang 支持的类型。前一种格式等价于 `{{Bucket,Key},undefined}`。

#### 查询

查询通过一系列 Map、Reduce 和 Link 步骤指定。Map 和 Reduce 步骤都使用如下所示的元组定义：

```erlang
{Type, FunTerm, Arg, Keep}
```

其中，*Type* 是 *map* 或 *reduce*；*Arg* 是传入各步的静态参数（任何 Erlang 支持的类型）；*Keep* 是 *true* 或 *false*，指明是否要把这一步的结果包含在查询的最终结果中。Riak 假定最后一步要返回结果。

*FunTerm* 是这一步要运行的函数引用，可以使用如下的方式指定：

* `{modfun, Module, Function}`：*Module* 和 *Function* 指定要使用的 Erlang 模块和函数
* `{qfun,Fun}`：*Fun* 指定可调用的 fun 类型（闭包或匿名函数）
* `{jsfun,Name}`：使用 Javascript 函数时，*Name* 是二进制格式，指向内建的 Javascript 函数
* `{jsanon, Source}`：使用 Javascript 函数时，*Source* 是二进制格式，是个匿名函数
* `{jsanon, {Bucket, Key}}`：`{Bucket, Key}` 对应的对象中保存有匿名 Javascript 函数的源码

<div class="info">
<div class="title">qfun 注意事项</div>
`qfun` 这种方式很脆弱，使用时要考虑下面的注意事项。

1. 函数所在的模块在客户端和 Riak 节点中必须使用“完全一致的版本”

2. `qfun` 指定的函数中用到的任何模块和函数（或者结果调用堆栈中出现的任何函数）都要存在于 Raik 节点上

这两点导致的错误往往很奇怪，例如提示 **missing-function** 或 **function-clause**。特别是当模块的版本不同时，如果不知道 `Module:info/0` 的意思很难排查问题。

</div>

Link 步骤使用下面的形式定义：

```erlang
{link, Bucket, Tag, Keep}
```

`Bucket` 可以是要匹配的 bucket 名字，或者是 `_`，匹配所有 bucket。`Tag` 可以是要匹配的标签名，或者是 `_`，匹配所有标签。`Keep` 的用法和意思与 Map 和 Reduce 步骤一样。

<div class="info">Riak 事先定义好了一些 Erlang MapReduce 函数，可以在 [[https://github.com/basho/riak_kv/blob/master/src/riak_kv_mapreduce.erl|https://github.com/basho/riak_kv/blob/master/src/riak_kv_mapreduce.erl]] 文件中查看。</div>

## 大型数据示例

### 加载数据

下面这个 Erlang 脚本会把 Google 的历史股价存入 Riak 集群中供我们使用。把下面的代码存为 `load_data.erl`，放到 `dev` 文件夹中；或者通过下面的链接直接下载这个代码。

```erlang
#!/usr/bin/env escript
%% -*- erlang -*-
main([Filename]) ->
    {ok, Data} = file:read_file(Filename),
    Lines = tl(re:split(Data, "\r?\n", [{return, binary},trim])),
    lists:foreach(fun(L) -> LS = re:split(L, ","), format_and_insert(LS) end, Lines).

format_and_insert(Line) ->
    JSON = io_lib:format("{\"Date\":\"~s\",\"Open\":~s,\"High\":~s,\"Low\":~s,\"Close\":~s,\"Volume\":~s,\"Adj. Close\":~s}", Line),
    Command = io_lib:format("curl -XPUT http://127.0.0.1:8091/riak/goog/~s -d '~s' -H 'content-type: application/json'", [hd(Line),JSON]),
    io:format("Inserting: ~s~n", [hd(Line)]),
    os:cmd(Command).
```

把这个脚本设为可执行：

```bash
$ chmod +x load_data.erl
```

下载下面的 CSV 文件，放到 `dev` 文件夹中。

* [goog.csv](https://github.com/basho/basho_docs/raw/master/source/data/goog.csv) - Google 的历史股价数据
* [load_stocks.rb](https://github.com/basho/basho_docs/raw/master/source/data/load_stocks.rb) - 加载这些数据的 Ruby 脚本
* [load_data.erl](https://github.com/basho/basho_docs/raw/master/source/data/load_data.erl) - 加载这些数据的 Erlang 脚本（和上面的一样）

然后把数据加载到 Raik 中。

```bash
$ ./load_data.erl goog.csv
```

<div class="info">
<div class="title">从命令行中提交 MapReduce 查询</div>

要想在命令行中执行查询，可以使用下面的 curl 命令：

<div class="code"><pre>curl -XPOST http://127.0.0.1:8091/mapred -H "Content-Type: application/json" -d @-</pre></div>

然后回车，粘贴作业代码，例如下面“完整作业”中的代码，再回车，然后按 `Ctrl-D` 提交查询。这种执行 MapReduce 查询的方式本文不会用到，但在命令行中快速执行查询时却很方便。使用客户端代码库，组件 JSON 数据的繁重工作就不用自己动手了。
</div>

### Map 步骤：查找最高值大于 $600.00 的日期

*步骤函数*

```javascript
function(value, keyData, arg) {
  var data = Riak.mapValuesJson(value)[0];
  if(data.High && data.High > 600.00)
    return [value.key];
  else
    return [];
}
```

*完整作业*

```json
{"inputs":"goog",
 "query":[{"map":{"language":"javascript",
                  "source":"function(value, keyData, arg) { var data = Riak.mapValuesJson(value)[0]; if(data.High && parseFloat(data.High) > 600.00) return [value.key]; else return [];}",
                  "keep":true}}]
}
```

[sample-highs-over-600.json](https://github.com/basho/basho_docs/raw/master/source/data/sample-highs-over-600.json)

### Map 步骤：查找收盘价低于开盘价的日期

*步骤函数*

```javascript
function(value, keyData, arg) {
  var data = Riak.mapValuesJson(value)[0];
  if(data.Close < data.Open)
    return [value.key];
  else
    return [];
}
```

*完整作业*

```json
{"inputs":"goog",
 "query":[{"map":{"language":"javascript",
                  "source":"function(value, keyData, arg) { var data = Riak.mapValuesJson(value)[0]; if(data.Close < data.Open) return [value.key]; else return [];}",
                  "keep":true}}]
}
```

[sample-close-lt-open.json](https://github.com/basho/basho_docs/raw/master/source/data/sample-close-lt-open.json)

### Map 和 Reduce 步骤：按月查找单日最大浮动值

*步骤函数*

```javascript
/* Map function to compute the daily variance and key it by the month */
function(value, keyData, arg){
  var data = Riak.mapValuesJson(value)[0];
  var month = value.key.split('-').slice(0,2).join('-');
  var obj = {};
  obj[month] = data.High - data.Low;
  return [ obj ];
}

/* Reduce function to find the maximum variance per month */
function(values, arg){
  return [ values.reduce(function(acc, item){
             for(var month in item){
                 if(acc[month]) { acc[month] = (acc[month] < item[month]) ? item[month] : acc[month]; }
                 else { acc[month] = item[month]; }
             }
             return acc;
            })
         ];
}
```

*完整作业*

```json
{"inputs":"goog",
 "query":[{"map":{"language":"javascript",
                  "source":"function(value, keyData, arg){ var data = Riak.mapValuesJson(value)[0]; var month = value.key.split('-').slice(0,2).join('-'); var obj = {}; obj[month] = data.High - data.Low; return [ obj ];}"}},
         {"reduce":{"language":"javascript",
                    "source":"function(values, arg){ return [ values.reduce(function(acc, item){ for(var month in item){ if(acc[month]) { acc[month] = (acc[month] < item[month]) ? item[month] : acc[month]; } else { acc[month] = item[month]; } } return acc;  }) ];}",
                    "keep":true}}
         ]
}
```

[sample-max-variance-by-month.json](https://github.com/basho/basho_docs/raw/master/source/data/sample-max-variance-by-month.json)

### MapReduce 查询挑战

下面这个挑战可以直接使用已经加载的数据。

MapReduce 挑战：查找每月交易额最大的日期，以及全部月数中交易额最大的日期。*提示：每一个查询至少需要一个 Map 和 Reduce 步骤。*

## Erlang 函数

我们要定义一个简单的模块，实现一个 Map 函数，返回所包含的键值对，然后通过 RiaK 的 HTTP API将其用在 MapReduce 查询中。

下面就是这个 MapReduce 函数：

```erlang
-module(mr_example).

-export([get_keys/3]).

% Returns bucket and key pairs from a map phase
get_keys(Value,_Keydata,_Arg) ->
  [{riak_object:bucket(Value),riak_object:key(Value)}].
```

将其保存为 `mr_example.erl`，然后编译。

<div class="info">
<div class="title">Erlang 编译器的注意事项</div>

必须使用 Riak 中的 Erlang 编译器（<tt>erlc</tt>），或者使用编译 Riak 源码时使用的 Erlang 版本。如果要用 Riak 中包含的 <tt>erlc</tt>，请参照下面的表格找到相应平台上的位置。如果是从源码编译安装的 Raik，直接使用当时所用版本的 <tt>erlc</tt> 即可。

</div>

模块的编译很简单：

```bash
erlc mr_example.erl
```

然后，要制定一个路径，用来存储和加载编译好的模块。这里我们使用临时文件夹（`/tmp/beams`），在实际运用时要使用别的文件夹，这样在需要时才能找到。

<div class="info">确保使用的文件夹 <tt>riak</tt> 用户有读权限。</div>

成功编译后会得到一个 `.beam` 文件：`mr_example.beam`。

把这个文件发给操作员，或者阅读“[[安装自定义代码]]”一文，学习如何在 Raik 节点中安装代码。安装好之后，剩下的工作就是试着在 MapReduce 查询中自定义函数。例如，我们来取回 **messages** 这个 bucket 中的所有键：

```bash
curl -XPOST http://localhost:8098/mapred \
   -H 'Content-Type: application/json'   \
   -d '{"inputs":"messages","query":[{"map":{"language":"erlang","module":"mr_example","function":"get_keys"}}]}'
```

返回的结果如下：

```bash
{"messages":"4","messages":"1","messages":"3","messages":"2"}
```

<div class="info">确保把 MapReduce 函数安装到集群中的所有节点上，以保证操作能正常进行。</div>

## 步骤函数

不管使用 Javascript 还是 Erlang 开发，MapReduce 步骤函数都具有相同的属性、参数和返回值。

### Map 步骤函数

*Map 函数接受三个参数*（在 Erlang 中，后面的 3 必须指定），分别是：

  1. *Value*：根据键查找得到的值。可以是 Riak 对象，在 Erlang 中，使用 *riak_object* 模块
     定义和处理。在 Javascript 中，Riak 对象类似下面这种形式：

    ```
    {
     "bucket":BucketAsString,
     "key":KeyAsString,
     "vclock":VclockAsString,
     "values":[
               {
                "metadata":{
                            "X-Riak-VTag":VtagAsString,
                            "X-Riak-Last-Modified":LastModAsString,
                            "Links":[...List of link objects],
                            ...other metadata...
                           },
                "data":ObjectData
               },
               ...other metadata/data values (siblings)...
              ]
    }
    ```
  2. *KeyData*：随输入数据一起提交到查询或这一步中的键数据
  3. *Arg*：查询中提交的静态参数，用于整个步骤

*Map 步骤应该生成一个结果列表。*如果 Map 函数的输出结果不是列表，会看到错误提示。如果 Map 函数不需要生成输出结果，可以返回一个空列表。如果 Map 步骤后面还是 Map 步骤，则函数的输出结果必须和 Map 步骤的输入格式兼容：“bucket/键”组合列表，或者“bucket/键/键数据”组合。

#### Map 函数示例

下面的 Map 函数返回映射的对象值：

```erlang
fun(Value, _KeyData, _Arg) ->
    [riak_object:get_value(Value)]
end.
```

```javascript
function(value, keydata, arg){
  return [value.values[0].data];
}
```

下面的 Map 函数根据 `arg` 参数过滤输入，返回“bucket/键”组合，工后续的 Map 步骤使用：

```erlang
fun(Value, _KeyData, Arg) ->
  Key = riak_object:key(Value),
  Bucket = riak_object:bucket(Value),
  case erlang:byte_size(Key) of
    L when L > Arg ->
      [{Bucket,Key}];
    _ -> []
  end
end.
```

```javascript
function(value, keydata, arg){
  if(value.key.length > arg)
    return [[value.bucket, value.key]] ;
  else
    return [];
}
```

### Reduce 步骤函数

*Reduce 步骤函数接受两个参数*，分别是：

1. *ValueList*：MapReduce 查询的前一步生成的值列表
2. *Arg*：查询中提交的静态参数，用于整个步骤

*Reduce 函数应该生成一个值列表*，而且函数的参数顺序可交换、可联合，且是幂等的。也就是说，如果函数 F 的参数是 `[a,b,c,d]`，那么下面这几种用法应该得到相同的结果：

```erlang
  F([a,b,c,d])
  F([a,d] ++ F([c,b]))
  F([F([a]),F([c]),F([b]),F([d])])
```

#### Reduce 函数示例

下面的 Reduce 函数假定输入是数字，对其求和：

```erlang
fun(ValueList, _Arg) ->
  [lists:foldl(fun erlang:'+'/2, 0, List)]
end.
```

```javascript
function(valueList, arg){
  return [valueList.reduce(
   function(acc, value){
      return acc + value;
   }, 0)];
}
```

下面的 Reduce 函数按序排列输入数据：

```erlang
fun(ValueList, _Arg) ->
  lists:sort(ValueList)
end.
```

```javascript
function(valueList, arg){
  return valueList.sort();
}
```

### 调试 Javascript MapReduce 步骤

目前调试 MapReduce 步骤有两种方式。如果 Javascript VM 出现异常，可以查看 `log/sasl-error.log` 文件。而且可以在 Map 或 Reduce 步骤函数中调用 ejsLog 函数，把异常写入指定的日志文件。

```javascript
ejsLog('/tmp/map_reduce.log', JSON.stringify(value))
```

注意，如果在 Map 步骤中调用 ejsLog 函数，则会在所有执行 Map 步骤的节点上生成日志文件。Reduce 步骤的输出结果会存到执行 MapReduce 函数的节点上。

## MapReduce 流

为了增强数据局限性，Riak 会把 Map 步骤传布到整个集群，所以可以使用流的方式获取各次计算的结果。从只包含 Map 步骤的高迟延 MapReduce 作业中获取数据时使用流的方式会特别方便。用流的方式从 Reduce 步骤获取结果就不那么好用了。不过，如果 Map 步骤有返回结果（`keep: true`），即便没有执行 Reduce 步骤，使用流的话，结果也能返回到客户端。使用这个特性，可以在作业运行的同时收集 Map 步骤的结果，最后再获取 Reduce 步骤的结果。

### 通过 HTTP API 处理流

要想在 MapReduce 作业中启用流，可以在向 `/mapred` 资源提交查询时加上 `?chunked=true` 请求参数。响应会使用 HTTP 1.1 的分段传输编码方式 `Content-Type: multipart/mixed`。如果使用流的方式处理序列化的对象（例如 JSON），无法保证各分段的边界和定义时一样。例如，分段可能会在表示 JSON 对象的字符串中间切断，因此要适当的在客户端解码并解析响应。

### 通过 Erlang API 处理流

可以使用 Erlang 通过 Riak 本地客户端或 Erlang Protocol Buffers API 处理流。不管使用哪种方式，调用 `mapred_stream` 时都要指定接受结果流的 `Pid`。

示例：

1. [MapReduce localstream.erl](/data/MapReduce-localstream.erl){{1.3.0-}}
2. [MapReduce pbstream.erl](/data/MapReduce-pbstream.erl)
