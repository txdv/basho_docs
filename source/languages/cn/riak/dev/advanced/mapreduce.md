---
title: Advanced MapReduce
project: riak
version: 1.4.2+
document: guide
toc: true
audience: advanced
keywords: [developers, mapreduce]
---

MapReduce 是 [[Google|http://research.google.com/archive/mapreduce.html]] 倡导
的编程范式，Raik 将其用作后台批量进程聚合结果。本文前半部分介绍 MapReduce 的高级用法，
后半部分说明 Riak 是如何实现 MapReduce 的。

## MapReduce

MapReduce 是 Google 倡导的编程范式。在 Raik 中，MapReduce 是不依赖主键的主要查询方式。

在 Raik 中，可以通过 Erlang API 和 HTTP API 两种方式运行 MapReduce 作业。本文我们将
使用 HTTP API。

### 为什么要使用 MapReduce 进行查询？

像 Raik 这种键值对存储系统出了保存和读取对象之外基本没什么其他功能。MapReduce 增强了查询
功能，也非常符合面向函数编程的 Raik 核心代码和数据存储的分布式特性。

MapReduce 主要目标是把查询操作传布到多个系统，发挥并行处理的优势。MapReduce 把查询分成很多
步骤，把数据集分成多个片段，然后在各物理主机的数据片段上执行这些步骤。在 Raik 中，
MapReduce 还有一个目的：增进数据的局限性。处理大型数据集时，在数据上做计算，比把数据引入
计算过程要高效。

“Map”和“Reduce”是查询过程中的两个步骤。“Map”接受一些输入数据，生成一个或多个输出结果。
如果你熟悉函数式编程中的“列表映射”（mapping over a list），对 map/reduce 查询中的“Map”
这一步就不会陌生。

<!-- MapReduce-Implementation.md -->

## Riak 如何传布处理过程

本文剩下的部分将详细介绍 Raik 是如何实现 MapReduce 的，包括 Riak 是如何把处理过程传布到
整个集群的，如何指定及运行查询，如何通过 HTTP API 和 Erlang API 运行 MapReduce 查询，
streaming MapReduce，步骤函数和设置。

处理大型数据集时，在数据上做计算，比把数据引入计算过程要高效。MapReduce 作业的代码基本上
都不超过 10KB，因此把这些代码发送到数 GB 的数据，比把数 GB 的数据引入代码更高效。

Riak 对数据局限性的处理决定了如何把处理过程传布到整个集群。Riak 节点可以协调读或写操作，把
请求直接发给负责维护这些数据的节点，与此相同，Riak 节点也能协调 MapReduce 查询，把“Map”
这一步的计算请求直接发给负责维护输入数据的节点。“Map”步骤的结果会回传给负责协调的节点，然后
“Reduce”步骤可以生成唯一的结果。

简单一点来说，Riak 在保存输入数据的节点上运行“Map”步骤，然后再负责协调 MapReduce 查询的
节点上运行“Reduce”步骤。

## 如何指定 MapReduce 查询

在 Raik 中，MapReduce 查询由两部分组成：输入列表和步骤列表。

输入列表中的元素是“bucket/键”组合。在“bucket/键”组合对应的对象上计算时，还可以使用
“键/数据”组合注解“bucket/键”组合，“键/数据”组合会作为参数传入“Map”函数。

步骤列表中的元素是“Map”函数、“Reduce”函数或“Link”函数的描述信息。描述信息中说明了到哪里寻找
步骤（Map 和 Reduce）函数的代码，执行各步时传入函数的静态数据，以及一个旗标，指明是否要在
查询的最终结果中包含各步的结果。

步骤列表说明了输入数据的操作流程，原始的输入会传给列表中的第一个步骤，得到的结果会作为输入
传给下一个步骤，直到完成列表中的所有步骤为止。

## 各步骤是如何工作的

### Map 步骤

Map 步骤的输入列表必须是一系列“bucket/键”组合（还可以有注解）。对每个键值对，Riak 都会向
存储对应数据的分区发送请求，计算 Map 函数。分区所在的虚拟节点会查找“bucket/键”组合对应的
数据，将其传入 Map 函数。如果有注解，会协同“bucket/键”组合和静态数据一起传入 Map 函数。

### Reduce 步骤

Reduce 步骤接受任意数据列表作为输入，然后生成任意的数据列表作为结果。Reduce 步骤还可以接受
查询中指定的步骤静态值。

注意，Reduce 步骤函数可以多次计算，前面的计算结果会传入后续的计算。

例如，Reduce 步骤可能实现了 [set-union](http://en.wikipedia.org/wiki/Union_(set_theory)#Definition) 函数。
此时，如果输入列表是 `[1,2,2,3]`，那么输出为 `[1,2,3]`。如果又输入了 `[3,4,5]`，
那么传入的输入列表是两个列表合并后的结果，即 `[1,2,3,3,4,5]`。

其他系统把第二次计算称为“re-reduce”。在 Raik 中，有很多 Reduce 查询实现策略。

其中一种策略是在 Reduce 步骤之前实现，这样其输出数据的形式就和 Reduce 步骤一样了。本文中
的示例代码使用的都是这种方式，我们觉得使用这种方式编写的代码更整洁。

还有一种策略是让 Reduce 步骤的输出便于识别，这样在后续的处理过程中就能从输入列表中将其提取
出来了。例如，如果上一步的输入是数字，Reduce 步骤的输出可以是对象或字符串。这样，函数就能
找到上一步的结果，然后在其上附加新的输入。

### “Link”步骤是如何工作的

Link 步骤会找到匹配查询条件的链接。查询条件中指明链接中必须包含哪些 bucket 和标签。

“跟踪链接”的意思是将其加入“Link”步骤的输出列表。Link 步骤的结果经常会作为 Map 步骤
或其他 Reduce 步骤的输入。

## HTTP API 示例

Riak 支持使用 JavaScript 和 Erlang 编写 MapReduce 查询函数，
可以通过 [[HTTP API]] 进行查询操作。

<div class="note">
<div class="title">“bad encoding”错误</div>
如果 MapReduce 查询报错“bad encoding”，而且查询中包含使用 Javascript 编写的函数，请确保
数据中没有错误的 Unicode 转义字符。传入 Javascript VM 的数据必须使用 Unicode 格式。
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

上述函数会创建一个 JSON 对象列表，文本中的每个单词（可重复出现）都对应一个元素。列表中各元素
都有一个键，即单词本身，以及一个值，整数 1。

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

上述函数会检查输入列表中的每个 JSON 对象，生成一个新对象，其键不变，值是这个键出现在其他对象
中的数量总和。创建的新对象还会以列表的形式输出，因为 Reduce 函数还可以再次在包含该对象的列表
上运行，或者可以从 Map 步骤接收更多的输入数据。

* 最终的输出结果是只有一个元素的列表，这个元素是 JSON 对象，所包含的元素其键是所有文档中的
单词（没有重复），其值是这个单词在文档中出现的次数。

### HTTP 查询句法

通过 HTTP 运行的 Map/Reduce 查询是发送到 `/mapred` 资源上的 *POST* 请求。
请求主体应该是 `application/json` 类型，符合这种格式 `{"inputs":[...inputs...],"query":[...query...]}`。

Map/Reduce 查询默认的请求超时时间是 60000 毫秒（60 秒）。默认的超时时间可以修改，使用这个
请求主体 `{"inputs":[...inputs...],"query":[...query...],"timeout": 90000}`。

如果请求超时了，协调 MapReduce 查询的节点会终止查询操作，向客户端发送错误信息。何时以及是否
会超时取决于涉及到的数据大小和集群的负载。如果经常超时，就要考虑把超时时间设的大一点，或者减少
运行 MapReduce 请求使用的数据量。

#### 输入

输入数据可以使用包含两个元素的列表形式 `[Bucket,Key]`，也可以使用包含三个列表的形式 `[Bucket,Key,KeyData]`。


You may also pass just the name of a bucket `({"inputs":"mybucket",...})`, which is equivalent to passing all of the keys in that bucket as inputs (i.e. "a map/reduce across the whole bucket").  You should be aware that this triggers the somewhat expensive "list keys" operation, so you should use it sparingly. A bucket input may also be combined with [[Key Filters|Using Key Filters]] to limit the number of objects processed by the first query phase.

If you're using Riak Search, the list of inputs can also [[reference a search query|Using Search#Querying-Integrated-with-Map-Reduce]] to be used as inputs.

If you've enabled Secondary Indexes, the list of inputs can also [[reference a Secondary Index query|Using Secondary Indexes#Examples]].

#### 查询

The query is given as a list of phases, each phase being of the form `{PhaseType:{...spec...}}`.  Valid `{PhaseType}` values are "map", "reduce", and "link".

Every phase spec may include a `keep` field, which must have a boolean value: `true` means that the results of this phase should be included in the final result of the map/reduce, `false` means the results of this phase should be used only by the next phase. Omitting the `keep` field accepts its default value, which is `false` for all phases except the final phase (Riak assumes that you were most interested in the results of the last phase of your map/reduce query).

##### Map

Map phases must be told where to find the code for the function to execute, and what language that function is in.

The function source can be specified directly in the query by using the "source" spec field.  It can also be loaded from a pre-stored riak object by providing "bucket" and "key" fields in the spec.  Or, a builtin JavaScript function can be used by providing a "name" field. Erlang map functions can be specified using the "module" and "function" fields in the spec.

<div class="info"> Riak comes with some prebuilt JavaScript functions. You can check them out at: [[https://github.com/basho/riak_kv/blob/master/priv/mapred_builtins.js|https://github.com/basho/riak_kv/blob/master/priv/mapred_builtins.js]] </div>

For example:


```javascript
{"map":{"language":"javascript","source":"function(v) { return [v]; }","keep":true}}
```

would run the JavaScript function given in the spec, and include the results in the final output of the m/r query.

```javascript
{"map":{"language":"javascript","bucket":"myjs","key":"mymap","keep":false}}
```

would run the JavaScript function declared in the content of the Riak object under *mymap* in the `myjs` bucket, and the results of the function would not be included in the final output of the m/r query.

```javascript
   {"map":{"language":"javascript","name":"Riak.mapValuesJson"}}
```

would run the builtin JavaScript function `mapValuesJson`, if you choose to store your JavaScript functions on disk. Any JS files should live in a directory defined by the `js_source_dir` field in your `app.config` file.

```javascript
{"map":{"language":"erlang","module":"riak_mapreduce","function":"map_object_value"}}
```

The above would run the Erlang function `riak_mapreduce:map_object_value/3`, whose compiled beam file should be discoverable by each Riak node process (more details can be found under [[advanced commit hooks]]).

Map phases may also be passed static arguments by using the `arg` spec field.

For example, the following map function will perform a regex match on object values using "arg" and return how often "arg" appears in each object:

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

##### Reduce

Reduce phases look exactly like map phases, but are labeled "reduce".

##### Link

Link phases accept `bucket` and `tag` fields that specify which links match the link query.  The string `_` (underscore) in each field means "match all", while any other string means "match exactly this string".  If either field is left out, it is considered to be set to `_` (match all).

The following example would follow all links pointing to objects in the `foo` bucket, regardless of their tag:

```javascript
{"link":{"bucket":"foo","keep":false}}
```

## Protocol Buffers API Examples

Riak also supports describing MapReduce queries in Erlang syntax via the Protocol Buffers API.  This section demonstrates how to do so using the Erlang client.

<div class="note"><div class="title">Distributing Erlang MapReduce Code</div>Any modules and functions you use in your Erlang MapReduce calls must be available on all nodes in the cluster.  You can add them in Erlang applications by specifying the *-pz* option in [[vm.args|Configuration Files]] or by adding the path to the `add_paths` setting in `app.config`.</div>

### Erlang Example

Before running some MapReduce queries, let's create some objects to run them on.

```erlang
1> {ok, Client} = riakc_pb_socket:start("127.0.0.1", 8087).
2> Mine = riakc_obj:new(<<"groceries">>, <<"mine">>,
                        term_to_binary(["eggs", "bacon"])).
3> Yours = riakc_obj:new(<<"groceries">>, <<"yours">>,
                         term_to_binary(["bread", "bacon"])).
4> riakc_pb_socket:put(Client, Yours, [{w, 1}]).
5> riakc_pb_socket:put(Client, Mine, [{w, 1}]).
```

Now that we have a client and some data, let's run a query and count how many occurrences of groceries.

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

<div class="note"><div class="title">Riak Object Representations</div>Note how the `riak_object` module is used in the MapReduce function, but the `riakc_obj` module is used on the client. Riak objects are represented differently internally to the cluster than they are externally.</div>

Given the lists of groceries we created, the sequence of commands above would result in L being bound to `[{"bread",1},{"eggs",1},{"bacon",2}]`.

### Erlang Query Syntax

`riakc_pb_socket:mapred/3` takes a client and two lists as arguments.  The first list contains bucket-key pairs, inputs to the MapReduce query.  The second list contains the phases of the query.

#### Inputs

The input objects are given as a list of tuples in the format `{Bucket, Key}` or `{{Bucket, Key}, KeyData}`. `Bucket` and `Key` should be binaries, and `KeyData` can be any Erlang term.  The former form is equivalent to `{{Bucket,Key},undefined}`.

#### Query

The query is given as a list of map, reduce and link phases. Map and reduce phases are each expressed as tuples in the following form:


```erlang
{Type, FunTerm, Arg, Keep}
```

*Type* is an atom, either *map* or *reduce*. *Arg* is a static argument (any Erlang term) to pass to each execution of the phase. *Keep* is either *true* or *false* and determines whether results from the phase will be included in the final value of the query.  Riak assumes the final phase will return results.

*FunTerm* is a reference to the function that the phase will execute and takes any of the following forms:

* `{modfun, Module, Function}` where *Module* and *Function* are atoms that name an Erlang function in a specific module.
* `{qfun,Fun}` where *Fun* is a callable fun term (closure or anonymous function).
* `{jsfun,Name}` where *Name* is a binary that, when evaluated in Javascript, points to a built-in Javascript function.
* `{jsanon, Source}` where *Source* is a binary that, when evaluated in Javascript is an anonymous function.
* `{jsanon, {Bucket, Key}}` where the object at `{Bucket, Key}` contains the source for an anonymous Javascript function.

<div class="info"><div class="title">qfun Note</div>
Using `qfun` can be a fragile operation. Please keep the following points in mind.

1. The module in which the function is defined must be present and **exactly the same version** on both the client and Riak nodes.

2. Any modules and functions used by this function (or any function in the resulting call stack) must also be present on the Riak nodes.

Errors about failures to ensure both 1 and 2 are often surprising, usually seen as opaque **missing-function** or **function-clause** errors. Especially in the case of differing module versions, this can be difficult to diagnose without expecting the issue and knowing of `Module:info/0`.

</div>

Link phases are expressed in the following form:


```erlang
{link, Bucket, Tag, Keep}
```


`Bucket` is either a binary name of a bucket to match, or the atom `_`, which matches any bucket. `Tag` is either a binary tag to match, or the atom `_`, which matches any tag. `Keep` has the same meaning as in map and reduce phases.


<div class="info">There is a small group of prebuilt Erlang MapReduce functions available with Riak. Check them out here: [[https://github.com/basho/riak_kv/blob/master/src/riak_kv_mapreduce.erl|https://github.com/basho/riak_kv/blob/master/src/riak_kv_mapreduce.erl]]</div>


## Bigger Data Examples

### Loading Data

This Erlang script will load historical stock-price data for Google (ticker symbol "GOOG") into your existing Riak cluster so we can use it.  Paste the code below into a file called `load_data.erl` inside the `dev` directory (or download it below).

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

Make the script executable:

```bash
$ chmod +x load_data.erl
```

Download the CSV file of stock data linked below and place it in the "dev" directory where we've been working.

* [goog.csv](https://github.com/basho/basho_docs/raw/master/source/data/goog.csv) - Google historical stock data
* [load_stocks.rb](https://github.com/basho/basho_docs/raw/master/source/data/load_stocks.rb) - Alternative script in Ruby to load the data
* [load_data.erl](https://github.com/basho/basho_docs/raw/master/source/data/load_data.erl) - Erlang script to load data (as shown in snippet)

Now load the data into Riak.

```bash
$ ./load_data.erl goog.csv
```

<div class="info"><div class="title">Submitting MapReduce queries from the shell</div>To run a query from the shell, here's the curl command to use:

<div class="code"><pre>curl -XPOST http://127.0.0.1:8091/mapred -H "Content-Type: application/json" -d @-</pre></div>

After pressing return, paste your job in, for example the one shown below in the section "Complete Job", press return again, and then `Ctrl-D` to submit it. This way of running MapReduce queries is not specific to this tutorial, but it comes in very handy to just run quick fire-and-forget queries from the command line in general. With a client library, most of the dirty work of assembling the JSON that's sent to Riak will be done for you.</div>

### Map: find the days where the high was over $600.00

*Phase Function*

```javascript
function(value, keyData, arg) {
  var data = Riak.mapValuesJson(value)[0];
  if(data.High && data.High > 600.00)
    return [value.key];
  else
    return [];
}
```

*Complete Job*

```json
{"inputs":"goog",
 "query":[{"map":{"language":"javascript",
                  "source":"function(value, keyData, arg) { var data = Riak.mapValuesJson(value)[0]; if(data.High && parseFloat(data.High) > 600.00) return [value.key]; else return [];}",
                  "keep":true}}]
}
```

[sample-highs-over-600.json](https://github.com/basho/basho_docs/raw/master/source/data/sample-highs-over-600.json)

### Map: find the days where the close is lower than open

*Phase Function*

```javascript
function(value, keyData, arg) {
  var data = Riak.mapValuesJson(value)[0];
  if(data.Close < data.Open)
    return [value.key];
  else
    return [];
}
```

*Complete Job*

```json
{"inputs":"goog",
 "query":[{"map":{"language":"javascript",
                  "source":"function(value, keyData, arg) { var data = Riak.mapValuesJson(value)[0]; if(data.Close < data.Open) return [value.key]; else return [];}",
                  "keep":true}}]
}
```

[sample-close-lt-open.json](https://github.com/basho/basho_docs/raw/master/source/data/sample-close-lt-open.json)

### Map and Reduce: find the maximum daily variance in price by month

*Phase functions*

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

*Complete Job*

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

### A MapReduce Challenge

Here is a scenario involving the data you already have loaded up.

MapReduce Challenge: Find the largest day for each month in terms of dollars traded, and subsequently the largest overall day. *Hint: You will need at least one each of map and reduce phases.*

## Erlang Functions

As an example, we'll define a simple module that implements a
map function to return the key value pairs contained and use it in a MapReduce query via Riak's HTTP API.

Here is our example MapReduce function:

```erlang
-module(mr_example).

-export([get_keys/3]).

% Returns bucket and key pairs from a map phase
get_keys(Value,_Keydata,_Arg) ->
  [{riak_object:bucket(Value),riak_object:key(Value)}].
```

Save this file as `mr_example.erl` and proceed to compiling the module.

<div class="info"><div class="title">Note on the Erlang Compiler</div> You
must use the Erlang compiler (<tt>erlc</tt>) associated with the Riak
installation or the version of Erlang used when compiling Riak from source.
For packaged Riak installations, you can consult Table 1 above for the
default location of Riak's <tt>erlc</tt> for each supported platform.
If you compiled from source, use the <tt>erlc</tt> from the Erlang version
you used to compile Riak.</div>


Compiling the module is a straightforward process:

```bash
erlc mr_example.erl
```

Next, you'll need to define a path from which to store and load compiled
modules. For our example, we'll use a temporary directory (`/tmp/beams`),
but you should choose a different directory for production functions
such that they will be available where needed.

<div class="info">Ensure that the directory chosen above can be read by
the <tt>riak</tt> user.</div>

Successful compilation will result in a new `.beam` file:
`mr_example.beam`.

Send this file to your operator, or read about [[installing custom code]]
on your Riak nodes. Once your file has been installed, all that remains
is to try the custom function in a MapReduce query. For example, let's
return keys contained within the **messages** bucket:

```bash
curl -XPOST http://localhost:8098/mapred \
   -H 'Content-Type: application/json'   \
   -d '{"inputs":"messages","query":[{"map":{"language":"erlang","module":"mr_example","function":"get_keys"}}]}'
```

The results should look similar to this:

```bash
{"messages":"4","messages":"1","messages":"3","messages":"2"}
```

<div class="info">Be sure to install the MapReduce function as described
above on all of the nodes in your cluster to ensure proper operation.</div>


## Phase functions

MapReduce phase functions have the same properties, arguments and return values whether you write them in Javascript or Erlang.

### Map phase functions

*Map functions take three arguments* (in Erlang, arity-3 is required).  Those arguments are:

  1. *Value* : the value found at a key.  This will be a Riak object, which
    in Erlang is defined and manipulated by the *riak_object* module.
    In Javascript, a Riak object looks like this:

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
  2. *KeyData* : key data that was submitted with the inputs to the query or phase.
  3. *Arg* : a static argument for the entire phase that was submitted with the query.

*A map phase should produce a list of results.* You will see errors if the output of your map function is not a list.  Return the empty list if your map function chooses not to produce output. If your map phase is followed by another map phase, the output of the function must be compatible with the input to a map phase - a list of bucket-key pairs or `bucket-key-keydata` triples.

#### Map function examples

These map functions return the value (data) of the object being mapped:

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

These map functions filter their inputs based on the arg and return bucket-key pairs for a subsequent map phase:

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

### Reduce phase functions

*Reduce functions take two arguments.* Those arguments are:

1. *ValueList*: the list of values produced by the preceding phase in the MapReduce query.
2. *Arg* : a static argument for the entire phase that was submitted with the query.

*A reduce function should produce a list of values*, but it must also be true that the function is commutative, associative, and idempotent. That is, if the input list `[a,b,c,d]` is valid for a given F, then all of the following must produce the same result:


```erlang
  F([a,b,c,d])
  F([a,d] ++ F([c,b]))
  F([F([a]),F([c]),F([b]),F([d])])
```


#### Reduce function examples

These reduce functions assume the values in the input are numbers and sum them:

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

These reduce functions sort their inputs:

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

### Debugging Javascript Map Reduce Phases

There are currently two facilities for debugging map reduce phases. If there was an exception in the Javascript VM you can view the error in the `log/sasl-error.log` file. In addition to viewing exceptions you can write to a specific log file from your map or reduce phases using the ejsLog function.

```javascript
ejsLog('/tmp/map_reduce.log', JSON.stringify(value))
```

Note that when used from a map phase the ejsLog function will create a file on each node on which the map phase runs. The output of a reduce phase will be located on the node you queried with your map reduce function.


## Streaming MapReduce

Because Riak distributes the map phases across the cluster to increase data-locality, you can gain access to the results of those individual computations as they finish via streaming.  Streaming can be very helpful when getting access to results from a high latency MapReduce job that only contains map phases.  Streaming of results from reduce phases isn't as useful, but if your map phases return data (keep: true), they will be returned to the client even if the reduce phases haven't executed.  This will let you use streaming with a reduce phase to collect the results of the map phases while the jobs are run and then get the result to the reduce phase at the end.

### Streaming via the HTTP API

You can enable streaming with MapReduce jobs submitted to the `/mapred` resource by adding `?chunked=true` to the url.  The response will be sent using HTTP 1.1 chunked transfer encoding with `Content-Type: multipart/mixed`.  Be aware that if you are streaming a set of serialized objects (like JSON objects), the chunks are not guaranteed to be separated along the same boundaries your that serialized objects are. For example, a chunk may end in the middle of a string representing a JSON object, so you will need to decode and parse your responses appropriately in the client.

### Streaming via the Erlang API

You can use streaming with Erlang via the Riak local client or the Erlang Protocol Buffers API.  In either case, you will provide the call to `mapred_stream` with a `Pid` that will receive the streaming results.

For examples, see:

1. [MapReduce localstream.erl](/data/MapReduce-localstream.erl){{1.3.0-}}
2. [MapReduce pbstream.erl](/data/MapReduce-pbstream.erl)
