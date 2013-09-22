---
title: "Taste of Riak: Erlang"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, erlang]
---

如果你还没有创建 Riak 节点并启动，请先阅读 [[Prerequisites|Taste of Riak: Prerequisites]]。

要使用本文介绍的 Riak 开发方法，必须先正确安装 Erlang。你也可以使用 Riak 安装包中附带的 “erts” Erlang 安装程序。

### 安装客户端

请从 GitHub 上下载最新的 Erlang 客户端（[zip](https://github.com/basho/riak-erlang-client/archive/master.zip), [仓库](https://github.com/basho/riak-erlang-client/)），解压到工作目录。

然后打开 Erlang 终端，并指定客户端代码库的路径：

```bash
erl -pa CLIENT_LIBRARY_PATH/ebin/ CLIENT_LIBRARY_PATH/deps/*/ebin
```

现在我们来创建一个到 Riak 节点的连接。

如果本地只有一个 Riak 节点，请使用下面的方法创建连接：

```erlang
{ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087).
```

如果参照 [[five minute install]] 中的方法在本地架设了 Riak 集群，请使用下面的方法创建连接：

```erlang
{ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 10017).
```

现在可以和 Riak 交互了。

### 在 Riak 中创建对象

首先，我们来创建几个 Riak 对象。

```erlang
%% For these examples we will be using the "test" bucket.
MyBucket = <<"test">>.

Val1 = 1.
Obj1 = riakc_obj:new(MyBucket, <<"one">>, Val1).
riakc_pb_socket:put(Pid, Obj1).
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```erlang
Val2 = "two".
Obj2 = riakc_obj:new(MyBucket, <<"two">>, Val2).
riakc_pb_socket:put(Pid, Obj2).
```

上面的例子都很简单。下面来存储一个复杂的对象，元组（tuple）。你现在应该已经熟知存储的过程了。

```erlang
Val3 = {value, 3}.
Obj3 = riakc_obj:new(MyBucket, <<"three">>, Val3).
riakc_pb_socket:put(Pid, Obj3).
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```erlang
{ok, Fetched1} = riakc_pb_socket:get(Pid, MyBucket, <<"one">>).
{ok, Fetched2} = riakc_pb_socket:get(Pid, MyBucket, <<"two">>).
{ok, Fetched3} = riakc_pb_socket:get(Pid, MyBucket, <<"three">>).

Val1 =:= binary_to_term(riakc_obj:get_value(Fetched1)).
Val2 =:= binary_to_term(riakc_obj:get_value(Fetched2)).
Val3 =:= binary_to_term(riakc_obj:get_value(Fetched3)).
```

很简单，只需通过 bucket 和键查询即可。

### 更新 Riak 中保存的对象

有些数据可能是静态的，但其他类型的数据或许需要更新。更新的过程也很简单。我们来把第三个例子中的值修改成 42，更新这个 Riak 对象，然后保存。

```erlang
NewVal3 = setelement(2, Val3, 42).
UpdatedObj3 = riakc_obj:update_value(Fetched3, NewVal3).
{ok, NewestObj3} = riakc_pb_socket:put(Pid, UpdatedObj3, [return_body]).
```

我们可以读出存储的值来验证新的值成功保存了：

```erlang
rp(binary_to_term(riakc_obj:get_value(NewestObj3))).
```

### 从 Riak 中删除对象

没有删除功能的数据库是不完整的，幸好删除操作也很简单。

```erlang
riakc_pb_socket:delete(Pid, MyBucket, <<"one">>).
riakc_pb_socket:delete(Pid, MyBucket, <<"two">>).
riakc_pb_socket:delete(Pid, MyBucket, <<"three">>).
```

然后验证一下对象确实从 Riak 中删除了。

```erlang
{error,notfound} =:= riakc_pb_socket:get(Pid, MyBucket, <<"one">>).
{error,notfound} =:= riakc_pb_socket:get(Pid, MyBucket, <<"two">>).
{error,notfound} =:= riakc_pb_socket:get(Pid, MyBucket, <<"three">>).
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面的记录包含了一本书的信息。

```erlang
rd(book, {title, author, body, isbn, copies_owned}).

MobyDickBook = #book{title="Moby Dick",
                     isbn="1111979723",
                     author="Herman Melville",
                     body="Call me Ishmael. Some years ago...",
                     copies_owned=3}.
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```erlang
MobyObj = riakc_obj:new(<<"books">>,
                        list_to_binary(MobyDickBook#book.isbn),
                        MobyDickBook).

riakc_pb_socket:put(Pid, MobyObj).
```

有些人可能会想，“Riak 的 Erlang 客户端是怎么编码和解码对象的呢？”我们把这本书的信息读出来，然后以字符串的形式打印到屏幕就知道了：

```erlang
{ok, FetchedBook} = riakc_pb_socket:get(Pid,
                                        <<"books">>,
                                        <<"1111979723">>).

rp(riakc_obj:get_value(FetchedBook)).
```

```erlang
<<131,104,6,100,0,4,98,111,111,107,107,0,9,77,111,98,121,
  32,68,105,99,107,107,0,15,72,101,114,109,97,110,32,77,
  101,108,118,105,108,108,101,107,0,34,67,97,108,108,32,
  109,101,32,73,115,104,109,97,101,108,46,32,83,111,109,
  101,32,121,101,97,114,115,32,97,103,111,46,46,46,107,0,
  10,49,49,49,49,57,55,57,55,50,51,97,3>>
```

这是 Erlang 中的二进制数据！Riak 的 Erlang 客户端会对所有数据做二进制编码。如果想读取书籍对象，可以使用 `binary_to_term/1` 取回原始的对象：

```erlang
rp(binary_to_term(riakc_obj:get_value(FetchedBook))).
```

最后，做些善后工作：

```erlang
riakc_pb_socket:delete(Pid, <<"books">>, <<"1111979723">>).
riakc_pb_socket:stop(Pid).
```

### 下一步

更复杂的用法都可以通过基本的创建（create）、读取（read）、更新（update）和删除（delete）（这四个操作简称 CRUD）操作完成。下一篇我们要介绍如何存储和查询更复杂的互联数据，例如文档。
