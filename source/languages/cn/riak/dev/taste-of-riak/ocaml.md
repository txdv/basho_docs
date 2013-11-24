---
title: "初试 Riak：OCaml 篇"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: intermediate
keywords: [developers, client, ocaml]
---

如果你还没有创建 Riak 节点并启动，请先阅读“[[事先准备|初试 Riak：事先准备]]”一文。

要使用本文介绍的 Riak 开发方法，必须先正确安装含有 [OPAM](http://opam.ocamlpro.com/doc/Quick_Install.html) 的 [OCaml](http://ocaml.org/)。

### 安装客户端

[riak-ocaml-client](http://metadave.github.io/riak-ocaml-client/) 是由社区维护的 OCaml 语言 Riak 客户端。

首先，使用 OPAM 下载 *riak-ocaml-client*。

```
opam install oasis
opam install riak
```

如果 OPAM 询问是否下载额外的依赖库，请同意。

然后，从 GitHub 上下载 `taste-of-ocaml` 示例程序。

```
git clone git@github.com:basho-labs/taste-of-ocaml.git
cd taste-of-ocaml
```

文件夹 `src` 中只有一个文件，`taste_of_riak.ml`。

示例程序默认尝试连接到 127.0.0.1:8098。如果参照“[[花五分钟安装]]”一文中的方法在本地架设了 Riak 集群，请修改 `pbip`，绑定到端口 **10017**：

```
 let pbip = 10017 in
 ...
```

然后执行下面的命令编译 `src/taste_of_riak.ml`：

```
./configure
make
```

运行 `./taste_of_riak.byte` 命令，应该得到如下输出：

```
$ ./taste_of_riak.byte
Ping
	Pong
Put: bucket=MyBucket, key = MyKey, value = MyValue
Get: bucket=MyBucket, key = MyKey
	Value = MyValue
Delete: bucket=MyBucket, key = MyKey
Get: bucket=MyBucket, key = MyKey
	Not found
```

### 连接

要想通过“协议缓存”（protocol buffers）连接到 Riak 节点，必须制定 IP 地址和端口号。这两个值可以在 Riak 的 `app.config` 文件中找到，在 `riak_api` 区的 `pb` 属性下面。

例如：

```
	{pb, [ {"127.0.0.1", 10017 } ]}
```

`riak_connect_with_defaults` 函数的参数为 IP 和端口号。例如：

```
  let pbhost = "127.0.0.1" in
  let pbip = 10017 in
  try_lwt
     lwt conn = riak_connect_with_defaults pbhost pbip in
     ...
```

Riak 的 OCaml 客户端使用 [Lwt](http://ocsigen.org/lwt/manual/) 以及 Lwt 句法扩展。下面的表格可以让你了解一下 OCaml 的句法预处理机制是如何简单的支持 Lwt 的：

Without Lwt           | With Lwt
----------------------|---------------------
let pattern1 = expr1  |	lwt pattern1 = expr1
try                   | try_lwt
match expr with       | match_lwt expr with
while expr do         | while_lwt expr do
raise exn             | raise_lwt exn
assert expr	          | assert_lwt expr


### 把数据存入 Riak

下面，我们要把一些示例数据存入 Riak。Bucket、键和值都是以字符串的形式存储的：

```
let my_bucket = "MyBucket" in
let my_key = "Foo" in
let my_value = "Bar" in
lwt _result = riak_put conn bucket (Some key) value [] in
```

最后一个参数，即上述代码中的空列表，指定的是 Riak 的 *put* 选项。

例如，要指定 `Put_return_body` 选项，可以这么写：

```
let put_options = [Put_return_body true] in
lwt _result = riak_put conn bucket (Some key) value put_options in
```

### 从 Riak 中读取数据

我们可以使用 bucket 和键取出数据。因为 `riak_get` 函数可能无法找到指定键对应的值，我们要对返回的 `Maybe` 值进行模式匹配。如果指定的键上有对应的值，还是要对 `Maybe` 进行模式匹配，以保证获取的是该键对应的真实值。

```
 lwt obj = riak_get conn bucket key [] in
  match obj with
      | Some o ->
          (match o.obj_value with
              | Some v -> print_endline ("Value = " ^ v);
                          return ()
              | None -> print_endline "No value";
                        return ())
      | None -> print_endline "Not found";
                return ()
```

注意每个分支结尾处由 Lwt 提供的 `return ()`。

要为获取操作指定选项，可以这么做：

```
let get_options = [Get_basic_quorum false; Get_head true] in
lwt obj = riak_get conn bucket key get_options in
...
```

### 从 Riak 中删除对象

如果要从 Riak 中删除数据，直接调用 `riak_del` 函数即可：

```
let key = "MyKey" in
let del_options = [] in
lwt _ = riak_del conn bucket key del_options in
    return ()
```

### 下一步

如果想了解 Riak OCaml 客户端的所有功能，请查看[该项目的网站](http://metadave.github.io/riak-ocaml-client/)，以及[集成的测试](https://github.com/metadave/riak-ocaml-client/blob/master/test/test.ml)。
