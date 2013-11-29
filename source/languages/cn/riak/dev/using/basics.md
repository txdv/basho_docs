---
title: 查询基础
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers]
---

对 Riak 的基本操作和其他任何基于键值对的数据库一样，使用 CRUD（创建，读取，更新，删除）。

## 操作对象和键

Riak 中的数据依照 bucket、键和值的方式组织。值（或称对象）使用唯一的键标识，键值对都保存在 bucket 中。在 Riak 中，bucket 基本上就是一种命名空间，允许在不同的 bucket 中出现相同的键，还能针对各个 bucket 做设置，例如副本数量和提交前后钩子。

和 Riak 的交互基本上就是使用键存储和取出值。本文将使用 Riak HTTP API 做演示，Riak 还为 Erlang、Java、PHP、Python、Ruby 和 C/C++ 提供了客户端代码库（[[支持的客户端代码库|客户端代码库]]）。.NET、Node.js、Python、Perl、Clojure、Scala、Smalltalk 等其他语言的代码库由社区维护（[[社区支持的项目|客户端代码库]]）。

### 读取对象

下面是从 bucket 中读取某个键对应对象的基本命令。

```bash
GET /riak/BUCKET/KEY
```

响应的主体中包含对象的值（如果对象存在的话）。

Riak 能理解很多 HTTP 报头，例如 用于协商内容类型的 `Accept`（处理兄弟数据（sibling）时会用到，参见[[通过 HTTP API 获取兄弟数据的示例|通过 HTTP 获取对象]]），以及用于条件请求的 `If-None-Match`/`ETag` 和 `If-Modified-Since`/`Last-Modified`。

Riak 还能接收很多请求参数，例如 `r`，设置当前 GET 请求的 R 值（R 值表示回返几个副本时表明响应是成功的）。如果省略请求参数 `r`，Riak 取默认值 2.

常规响应码：

* `200 OK`
* `300 Multiple Choices`
* `304 Not Modified`

常见的错误代码：

* `404 Not Found`

了解上述内容后，请运行如下命令，从 `test` bucket 中获取（GET）键 `doc2` 对应的值：

```bash
$ curl -v http://localhost:8098/riak/test/doc2
```

这个请求会返回 `404 Not Found`，因为键 `doc2` 不存在（还没创建）。

### 存储对象

应用程序一般都会定义一个方法，生成数据的键。如果生成了键，存储数据就简单了。基本的请求方式如下。

*这并不是唯一的 URL 格式，其他格式参见 [[HTTP API]]。*

```bash
PUT /riak/BUCKET/KEY
```

<div class="info">为了兼容，也可以使用 <code>POST</code>。</div>

在 Riak 中，不用主动创建 bucket，把键存入时 bucket 就自动创建了，如果把 bucket 中的所有键都删掉了，bucket 也就不存在了。

必须为PUT 请求指定一些请求报头：

* 必须为要存储的对象设定 `Content-Type`，设定值为事后想取出的类型。
* 如果对象存在，`X-Riak-Vclock` 设定地向量时钟会附加到对象上；如果是新对象，可以省略 `X-Riak-Vclock`。

以下报头对 PUT 请求是可选的：

* `X-Riak-Meta-YOUR_HEADER` 指定要为存储对象设定地其他元数据（例如 `X-Riak-Meta-FirstName`）。
* `Link` 指定用户和系统定义的指向其他资源的链接。详细说明参见“[[链接]]”一文。

GET 请求可以接收请求参数 `r`，类似的，`PUT` 请求也能接收这些参数：

* `r`（默认值为 `2`）：写入之前，要取出多少个已存对象的副本
* `w`（默认值为 `2`）：返回成功的响应之前要写入多少个副本
* `dw`（默认值为 `0`）：返回成功的响应之前要提交多少个副本到“持久存储”（durable storage）
* `returnbody` （布尔值，默认为 `false`）：是否返回存储对象的内容

常规响应码：

* `200 OK`
* `204 No Content`
* `300 Multiple Choices`

如果 `returnbody=true`，任何一个 `GET` 请求的响应报头都可能出现在 `PUT` 请求的响应报头中。和 `GET` 请求一样，如果有兄弟数据，或者在请求中创建了兄弟数据，可能会返回 `300 Multiple Choices`。对响应报文的处理也和 `GET` 请求类似。

我们来试一下，在终端执行如下命令：

```
$ curl -v -XPUT http://localhost:8098/riak/test/doc?returnbody=true \
  -H "X-Riak-Vclock: a85hYGBgzGDKBVIszMk55zKYEhnzWBlKIniO8mUBAA==" \
  -H "Content-Type: application/json" \
  -d '{"bar":"baz"}'
```

### 存储新对象时指定随机键

如果应用程序把生成键的权力交给 Riak，请不用向 bucket/键发起 `PUT` 请求，而要想 bucket 的 URL 发起 `POST` 请求：

```bash
POST /riak/BUCKET
```

如果 bucket 后面没有指定键，Riak 就会自动生成一个。

这种请求支持的报头和针对 bucket/键的 `PUT` 请求一样，不过用不到 `X-Riak-Vclock`。支持的请求参数也一样。

常规状态码：

* `201 Created`

下面的命令会把对象存入 bucket `test`，并自动生成一个键：

```
$ curl -v -XPOST http://localhost:8098/riak/test \
  -H 'Content-Type: text/plain' \
  -d 'this is a test'
```

在输出中，`Location` 报头就是该对象的键。要想查看刚创建的对象，请在浏览器中打开 `http://localhost:8098/*_Location_*`。

如果一切顺利，应该看到存储的值（“this is a test”）。

### 删除对象

你可能已经猜到了，删除命令的结构和之前几个命令类似，如下：

```bash
DELETE /riak/BUCKET/KEY
```

`DELETE` 操作常见的响应码有 `204 No Content` 和 `404 Not Found`。

404 响应最常见，因为 `DELETE` 操作是幂等的。没找到对象就说明已经删除了。

请尝试以下命令：

```bash
$ curl -v -XDELETE http://localhost:8098/riak/test/test2
```

## Bucket 的属性和操作

Buckets 在 Riak 中就是命名空间，允许相同的键出现在不同的 bucket 中，还可以针对特定的 bucket 做一些设置。

<div class="info">
<div class="title">能创建多少个 bucket？</div>

bucket 几乎没什么消耗，<em>除非要修改 bucket 的默认设置</em>。修改 bucket 的属性后要广播到整个集群，因此增加了网络数据传送量。也就是说，只要使用默认设置，就可以尽情使用 bucket。
</div>

### 设置 bucket 的属性

bucket 除了作为键的命名空间，其属性还能影响其中保存的值。

想设置 bucket 的值，要对 bucket 的 URL 发起 `PUT` 请求：

```bash
PUT /riak/BUCKET
```

请求主体为 JSON 对象，只有一个条目“props”。不想改动的属性可以省略。

重要的报头：

* `Content-Type: application/json`

bucket 最重要的属性如下：

* `n_val`（默认值为 `3`）：bucket 中对象的副本数量；
  `n_val` 为整数，大于 0，且小于环中分区的数量。
  <div class="note">如果 bucket 中存储了键，修改 <code>n_val</code> 可能会发生错误。新值可能不会应用到所有分区。</div>

* `allow_mult`（布尔值，默认为 `false`）：如果为 `false`，客户端只能根据时间戳获取最新的对象；否则，Riak 会维护因并发写入（或网络隔断）导致的兄弟数据。

我们来修改一个 bucket 的属性。下面的 `PUT` 请求会创建一个新 bucket，名为 `test`，`n_val` 设为 `5`。

```
$ curl -v -XPUT http://localhost:8098/riak/test \
  -H "Content-Type: application/json" \
  -d '{"props":{"n_val":5}}'
```

### 读取 bucket

如果想使用 [[HTTP API]] 读取（`GET`） bucket 的属性或键，可以这么做：

```bash
GET /riak/BUCKET
```

可选的请求参数有：

* `props`: `true`|`false` - 是否返回 bucket 的属性，默认为 `true`
* `keys`: `true`|`false`|`stream` - 是否返回 bucket 中保存的键，默认为 `false`；如何处理 `keys=stream` 形式的响应，请阅读“[[通过 HTTP 列出键]]”一文。

知道上述内容后，请执行下面的命令，读取刚才设置的 bucket 信息：

```bash
$ curl -v http://localhost:8098/riak/test
```

还可以在浏览器中查看 bucket 的信息，访问 `http://localhost:8098/riak/test` 即可。

以上就是 [[HTTP API]] 的基本操作方式。强烈推荐您仔细阅读 HTTP API 文档，可以详细了解报头、请求参数以及响应码，即使使用客户端代码库对你也很有用。
