---
title: Client Libraries
project: riak
version: 1.4.2+
document: reference
toc: true
index: true
audience: intermediate
keywords: [client, drivers]
---

## Basho 提供支持的代码库

Basho 官方支持多种编程语言的开源客户端和环境。

| 语言      | 源码                                                     | 文档           | 下载      |
|----------|----------------------------------------------------------|---------------|---------------|
| Erlang   | [riak-erlang-client (riakc)](https://github.com/basho/riak-erlang-client)<br>[riak-erlang-http-client (rhc)](https://github.com/basho/riak-erlang-http-client) | [edoc](http://basho.github.com/riak-erlang-client/)          |               |
| Java     | [riak-java-client](https://github.com/basho/riak-java-client)                                         | [javadoc](http://basho.github.com/riak-java-client), [wiki](https://github.com/basho/riak-java-client/wiki) | [Maven Central](http://search.maven.org/?#search%7Cgav%7C1%7Cg%3A%22com.basho.riak%22%20AND%20a%3A%22riak-client%22) |
| PHP      | [riak-php-client](https://github.com/basho/riak-php-client)                                          | [doxygen](http://basho.github.com/riak-php-client)       |               |
| Python   | [riak-python-client](https://github.com/basho/riak-python-client)                                       | [sphinx](http://basho.github.com/riak-python-client)        | [PyPI](http://pypi.python.org/pypi?:action=display&name=riak#downloads)          |
| Ruby     | [riak-ruby-client](https://github.com/basho/riak-ruby-client)                                         | [rdoc](http://rdoc.info/gems/riak-client/frames), [wiki](https://github.com/basho/riak-ruby-client/wiki)    | [RubyGems](https://rubygems.org/gems/riak-client)      |


所有官方支持的客户端都使用 GitHub 提供的问题追踪系统收集程序错误反馈。

除了官方支持的客户端，Basho 还提供了一些非官方的客户端代码库，如下所示。除此之外，还有很多客户端代码库和相关的项目，参见 [[community projects]]。

| 语言                 | 源码                 |
|---------------------|------------------------|
| C/C++               | [riak-cxx-client](https://github.com/basho/riak-cxx-client)        |
| Javascript (jQuery) | [riak-javascript-client](https://github.com/basho/riak-javascript-client) |


## 功能比较

下面列出了很多表格，比较了官方客户端代码库对 Riak API 的支持情况，也比较了优秀客户端中应该实现的功能。我们编写这些表格的目的是要确保所有客户端实现相同的功能。

说明：

- ✓：已实现
- ✗：尚未实现
- 文本：部分实现
- 空白：未知

### HTTP

| Bucket 相关操作    | Erlang (rhc)           | Java | PHP                    | Python  | Ruby |
|-------------------|------------------------|------|------------------------|---------|------|
| 列出所有 bucket    | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 列出所有键          | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 读取 bucket 属性    | 部分实现                | ✓    | ✓                      | ✓       | ✓    |
| 设置 bucket 属性    | 部分实现                | ✓    | ✓                      | ✓       | ✓    |

| 对象/键相关操作     | Erlang (rhc)           | Java | PHP                    | Python  | Ruby |
|-------------------|------------------------|------|------------------------|---------|------|
| 获取对象（get）     | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 获取最少数          | 无 PR                  | ✓    | 无 PR                  | ✓       | ✓    |
| 存储对象（put）     | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 存储最少数          | 无 PW                  | ✓    | 无 PW                  | ✓       | ✓    |
| 删除对象            | ✓                      | ✓    | ✓                      | ✓       | ✓    |

| 查询相关操作        | Erlang (rhc)           | Java | PHP                    | Python  | Ruby |
|-------------------|------------------------|------|------------------------|---------|------|
| Link Walking      | ✗                      | ✓    | ✗                      | ✗       | ✓    |
| MapReduce         | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 二级索引           | ✗                      | ✓    | ✓                      | ✓       | ✓    |
| 搜索               | 通过 MapReduce 模拟     | ✓    | 通过 MapReduce 模拟     | ✓       | ✓    |

| 服务器相关操作      | Erlang (rhc)           | Java | PHP                    | Python  | Ruby |
|-------------------|------------------------|------|------------------------|---------|------|
| Ping              | ✓                      | ✓    | ✓                      | ✓       | ✓    |
| 状态               | 部分实现                | ✓    | ✗                      | ✓       | ✓    |
| 资源列表           | ✗                      | ✗    | ✗                      | ✓        | ✓    |

### Protocol Buffers

*注意：PHP 客户端不支持 Protocol Buffers，因此下列表格中没有对比 PHP。*

| Bucket 相关操作         | Erlang (riakc) | Java | Python  | Ruby |
|------------------------|----------------|------|---------|------|
| 列出所有 bucket         | ✓              | ✓    | ✓       | ✓    |
| 列出所有键              | ✓              | ✓    | ✓       | ✓    |
| 读取 bucket 属性        | ✓              | ✓    | ✓       | ✓    |
| 设置 bucket 属性        | ✓              | ✓    | ✓       | ✓    |

| 对象/键相关操作          | Erlang (riakc) | Java | Python  | Ruby |
|------------------------|----------------|------|---------|------|
| 获取对象（get）          | ✓              | ✓    | ✓       | ✓    |
| 获取最少数               | ✓              | ✓    | ✓       | ✓    |
| 存储对象（put）          | ✓              | ✓    | ✓       | ✓    |
| 存储最少数               | ✓              | ✓    | ✓       | ✓    |
| 删除对象                 | ✓              | ✓    | ✓       | ✓    |

| 查询相关操作             | Erlang (riakc) | Java | Python  | Ruby |
|---------- --------------|----------------|------|---------|------|
| MapReduce               | ✓              | ✓    | ✓       | ✓    |
| 二级索引（模拟的和内嵌的） | ✓✗             | ✓✗   | ✓✓      | ✓✓   |
| 搜索（模拟的和内嵌的）     | ✓✗             | ✓✗   | ✓✓      | ✓✓   |

| 服务器相关操作            | Erlang (riakc) | Java | Python  | Ruby |
|-------------------------|----------------|------|---------|------|
| Ping                    | ✓              | ✓    | ✓       | ✓    |
| 服务器信息                | ✓              | ✗    | ✓       | ✓    |
| 获取客户端 ID             | ✓              | ✓    | ✓       | ✓    |
| 设置客户端 ID             | ✓              | ✓    | ✓       | ✓    |

### 其他功能

| 协议                                    | Erlang                    | Java | PHP     | Python  | Ruby          |
|----------------------------------------|---------------------------|------|---------|---------|---------------|
| 集群连接/集群池                          | ✗                         | ✓    | ✗       | ✓       | ✓             |
| 失败后到其他节点重试                      | ✗                         | ✓    | ✗       |✓ ✓      | ✓ ✓           |
| Failure-sensitive node selection       | ✗                         | ✗    | ✗       | ✓       | ✓             |
| 自动选择协议                             | ✗                         | ✗    | ✗       | ✓       | ✓             |

| 媒介类型处理                             | Erlang                    | Java | PHP     | Python  | Ruby          |
|----------------------------------------|---------------------------|------|---------|---------|---------------|
| 使用任意的媒介类型                        | ✓                         | ✓    | ✓       | ✓       | ✓             |
| 使用 JSON 序列及反序列化                  | ✗                         | ✓    | ✓       | ✓       | ✓             |
| 包含的其他序列及反序列化方式               | Erlang 二进制              | ✗    | ✗       | ✗       | YAML, Marshal |
| 自定义序列及反序列化方式                   | ✗                         | ✓    | ✗       | ✓       | ✓             |

| 最终一致性                              | Erlang                    | Java | PHP     | Python  | Ruby          |
|----------------------------------------|---------------------------|------|---------|---------|---------------|
| 支持兄弟数据                             | ✓                         | ✓    | ✓       | ✓       | ✓             |
| 相抵数据解决方案                         | ✗                         | ✓    | ✗       | ✓       | ✓             |
| Mutators (encapsulating change ops)    | ✗                         | ✓    | ✗       | ✗       | ✗             |

| 主要数据类型/对象映射                    | Erlang                    | Java | PHP     | Python* | Ruby*         |
|----------------------------------------|---------------------------|------|---------|---------|---------------|
| 物化抽象主要数据类型                      | ✗                         | ✓    | 部分支持 | ✓       | ✓             |
| 主要数据类型嵌套                         | ✗                         | ✓    |         | ✓       | ✓             |
| 在特定领域层次处理兄弟数据                 | ✗                         | ✓    | ✗       | ✗       | ✓             |
| 集成二级索引                             | ✗                         | ✓    | 部分支持 | ✓       | ✓             |
| 集成 Riak Search                        | ✗                         | ✓    | ✗       | ✓       | ✗             |

很多[[社区项目|community projects]]都支持 Python 和 Ruby 中的主要数据类型和对象映射。上表中列出的支持情况是下面这些项目集成的功能：

- *Ruby*: [ripple](https://github.com/basho/ripple)，[risky](https://github.com/aphyr/risky) 和 [curator](https://github.com/braintree/curator)
- *Python*: [riakkit](https://github.com/shuhaowu/riakkit)，[riakalchemy](https://github.com/Linux2Go/riakalchemy) 和 [django-riak-engine](https://github.com/oubiwann/django-riak-engine)

## 社区开发的代码库

Riak 社区的开发很活跃，代码库和驱动的数量不断增长。下面列出了可能符合你所用编程语言需求的项目，也可以满足你的好奇心。如果你知道有其他项目可以加到这个列表中，或者你自己开发的项目想加入这个列表，请在 GitHub 上 fork [这各 repo](https://github.com/basho/basho_docs)，然后发送 pull request。

<div class="info">
这里列出的项目和代码库的完成度不一，可能并不符合你的程序需求。
</div>

### 客户端代码库和框架

*C/C++*

* [[riak-cpp|https://github.com/ajtack/riak-cpp]] - Riak 的 C++ 客户端代码库，用于 C++11 编译器
* [[Riak C Driver|https://github.com/fenek/riak-c-driver]] - 使用 cURL 和 Protocol Buffers 与 Riak 通信的代码库
* [[Riack|https://github.com/trifork/riack]] - 简单地 C 客户端代码库
* [[Riack++|https://github.com/TriKaspar/riack_cpp]] - riack 的 C++ 包装库

*Clojure*

* [[knockbox|https://github.com/reiddraper/knockbox]] - 为 Clojure 开发的最终一致性工具集
* [[Welle|http://clojureriak.info]] - Riak 的 Clojure 客户端代码库
* [[clj-riak|http://github.com/mmcgrana/clj-riak]] - 绑定到 Riak Protocol Buffers API 上的 Clojure 代码库
* [[sumo|https://github.com/reiddraper/sumo]] - Riak 的 Protocol Buffer 客户端，支持 K/V 存储，2i 和 MapReduce

*ColdFusion*

* [[Riak-Cache-Extension|https://github.com/getrailo/Riak-Cache-Extension]] - 基于 Riak 的 Railo/ColdFusion 缓存扩展

*Common Lisp*

* [[cl-riak (1)|https://github.com/whee/cl-riak]]
* [[cl-riak (2)|https://github.com/eriknomitch/cl-riak]]

*Dart*

* [[riak-dart|http://code.google.com/p/riak-dart/]] - 使用 Dart 开发的 Riak HTTP 客户端

*Django*

* [[django-riak-sessions|https://github.com/flashingpumpkin/django-riak-sessions]] - 基于 Riak 的 Django 会话存储
* [[Django Riak Engine|https://github.com/oubiwann/django-riak-engine]] - 在 Django 中使用 Riak 存储数据

*Go*

* [[goriakpbc|https://github.com/tpjg/goriakpbc]] - 使用 Go 开发的 Riak 客户端，受 Basho 开发的 riak-client 和 mrb 开发的 riakpbc 的启发
* [[riakpbc|https://github.com/mrb/riakpbc]] - 使用 Go 语言开发的 Riak Protocol Buffer 客户端
* [[Shoebox|https://github.com/mrb/shoebox]] - 使用 [[riakpbc|https://github.com/mrb/riakpbc]] 开发的 Go 语言项目
* [[riak.go|http://github.com/c141charlie/riak.go]] - 为 Go 语言编写的 Riak 客户端

*Grails*

* [[Grails ORM for Riak|http://www.grails.org/plugin/riak]]

*Griffon*

* [[Riak Plugin for Griffon|http://docs.codehaus.org/display/GRIFFON/Riak+Plugin]]

*Groovy*

* [[spring-riak|https://github.com/jbrisbin/spring-riak]] - 为 Groovy 和 Java 提供 Riak 支持

*Erlang*

* [Uriak Pool](https://github.com/unisontech/uriak_pool) - [Unison|http://www.unison.com]] 团队开发的 Erlang 连接池代码库
* [[Riak PBC Pool|https://github.com/snoopaloop/Riak-PBC-Pool]] - Riak Protocol Buffer 客户端池程序
* [[Pooly|https://github.com/aberman/pooly]] - Riak 进程池
* [[riakpool|https://github.com/dweldon/riakpool]] - 管理连接到 Riak 数据库上的 Protocol Buffer 客户端动态池
* [[pooler|https://github.com/seth/pooler]] - OTP 进程池程序
* [[krc|https://github.com/klarna/krc]] - 简单地包装了官方的 Erlang 客户端
* [[riakc_pool|https://github.com/brb/riakc_pool]] - 基于 poolboy 超级简单地 Riak 客户端进程池

*Haskell*

* [[Riak Haskell Client|https://github.com/bos/riak-haskell-client]] - MailRank 团队开发的超快的 Haskell 客户端代码库

*Java*

* [[Riak-Java-PB-Client|http://github.com/krestenkrab/riak-java-pb-client]] - 基于 Protocol Buffers API 开发的 Java 客户端代码库
* [[Asynchronous Riak Java Client|https://github.com/jbrisbin/riak-async-java-client]] - 基于 NIO 的 Protocol Buffers 异步客户端

*Lisp Flavored Erlang*

* [[Gutenberg|https://github.com/dysinger/gutenberg/]] - 使用 LFE 编写的 Riak MapReduce 示例

*.NET*

* CorrugatedIron ([[project page|http://corrugatediron.org/]] | [[source|https://github.com/DistributedNonsense/CorrugatedIron]] | [[Nuget package|http://www.nuget.org/List/Packages/CorrugatedIron]])
* [[Hebo|http://github.com/bubbafat/hebo]] - 实验性的 Riak 客户端
* [[Data.RiakClient|http://github.com/garethstokes/Data.RiakClient]] - 支持 Protocol Buffer 的 Riak 客户端

*Node.js*

* [zukai](https://github.com/natural/zukai) - Troy Melhase 为 Node.js 编写的 Riak ODM
* [riak-pb](https://github.com/CrowdProcess/riak-pb) - [CrowdProcess](http://crowdprocess.com) 团队为 Node.js 开发的 Riak Protocol Buffers 客户端
* [[node_riak|https://github.com/mranney/node_riak]] - Voxer 在生产环境中使用的 Riak Node.js 客户端
* [[nodiak|https://npmjs.org/package/nodiak]] - 支持批量读取、保存和删除数据，支持自动处理兄弟数据、MapReduce 链、Riak Search 和 2i
* [[resourceful-riak|https://github.com/admazely/resourceful-riak]] - [[flatiron|https://github.com/flatiron/]] 开发的 [[resourceful|https://github.com/flatiron/resourceful/]] 模型框架引擎
* [[Connect-Riak|https://github.com/frank06/connect-riak]] - Connect 的会话存储，后台使用 [[Riak-js|http://riakjs.org/]]
* [[Riak-js|http://riakjs.com]] - Node.js 客户端，支持 HTTP 和 Protocol Buffers
* [[Riakjs-model|https://github.com/dandean/riakjs-model]] - 基于 riak-js 的模型抽象工具
* [[Node-Riak|http://github.com/orlandov/node-riak]] - 包装了 Node 的 HTTP 工具，用来和 Riak 通信
* [[Nori|https://github.com/sgonyea/nori]] - 参照 Ripple 开发的实验性 Riak HTTP 代码库
* [[OrionNodeRiak|http://github.com/mauritslamers/OrionNodeRiak]] - Sproutcore 使用的基于 Node 的服务器和数据库前台
* [[Chinood|https://npmjs.org/package/chinood]] - 基于 Nodiak 的 Riak 对象映射程序
* [[SimpleRiak|https://npmjs.org/package/simpleriak]] - 很简单的 Riak HTTP 客户端

*OCaml*

* [[Riak OCaml Client|http://metadave.github.com/riak-ocaml-client/]] - Riak OCaml 客户端
* [OCaml Riakc](https://github.com/orbitz/ocaml-riakc) - ocaml-riakc

*Perl*

* [[Net::Riak|http://search.cpan.org/~franckc/Net-Riak/]] - Riak 的 Perl 语言接口
* [[AnyEvent-Riak adapter|http://github.com/franckcuny/anyevent-riak]] - 使用 anyevent 的非阻塞 Riak 适配器
* [[riak-tiny|https://github.com/tempire/riak-tiny]] - 不支持 Moose 的 Perl 语言接口
* [[Riak::Light|https://metacpan.org/module/Riak::Light]] - 快速、轻量级的 Perl 客户端（只支持 PBC）

*PHP*

* [[Ripple-PHP|https://github.com/KevBurnsJr/ripple-php]] - 使用 PHP 开发的 Ripple 克隆
* [[riiak|https://bitbucket.org/intel352/riiak]] - 为 [[Yii 框架|http://www.yiiframework.com/]] 开发的 Riak 客户端代码库
* [[riak-php|https://github.com/marksteele/riak-php]] - 使用 PHP 开发的 Riak 代码库，支持 Protocol Buffers
* [[RiakBundle|https://github.com/remialvado/RiakBundle]] - 可以简便的和 Riak 交互的 [[Symfony|http://symfony.com]]
* [[php_riak|https://github.com/TriKaspar/php_riak]] - 使用 C 语言编写的 PHP 扩展，既是 Riak 客户端，也是 PHP 会话模块

*Play*

* [[为 Play 框架开发的 Riak 模块|http://www.playframework.org/modules/riak-head/home]]

*Python*

* [[Riakasaurus|https://github.com/calston/riakasaurus]] - 为 Twisted 开发的 Riak 客户端代码库（基于 txriak）
* [[RiakKit|http://shuhaowu.com/riakkit]] - 基于 riak-python-client 的小型 ORM，类似 mongokit 和 couchdbkit
* [[riakalchemy|https://github.com/Linux2Go/riakalchemy]] - 使用 Python 编写的 Riak 对象映射程序
* [[riak_crdt|https://github.com/ericmoritz/riak_crdt]] - 使用 [[crdt API|https://github.com/ericmoritz/crdt]] 开发的 CRDT（Conflict-Free Replicated Data Type）加载程序
* [[txriak|https://launchpad.net/txriak]]- 通过 HTTP 接口和 Riak 通信的 Twisted 模块
* [[txriakidx|https://github.com/williamsjj/txriakidx]] - 为 Twisted 开发的 Riak 客户端，试想了透明索引

*Racket*

* [[riak.rkt|https://github.com/shofetim/riak.rkt]] - 实现 Riak HTTP API 的 Racket 接口
* [[Racket Riak|https://github.com/dkvasnicka/racket-riak]] - 使用 Racket 1.3.x 开发的 Raik 客户端

*Ruby*

* [[Shogun|https://github.com/krainboltgreene/shogun]] - 一个轻量级但很强大的 Ruby Web 程序框架，很好地支持了 Riak
* [[Risky|https://github.com/aphyr/risky]] - 使用 Ruby 编写的轻量级 Riak ORM
* [[riak_sessions|http://github.com/igorgue/riak_sessions]] - 基于 Riak 的 Rack 会话存储
* [[Riaktor|http://github.com/benmyles/riaktor]] - Ruby 客户端和对象映射程序
* [[dm-riak-adapter|http://github.com/mikeric/dm-riak-adapter]] - 为 Riak 编写的 DataMapper 适配器
* [[Riak PB Client|https://github.com/sgonyea/riak-pbclient]] - 使用 Ruby 编写的 Riak Protocol Buffer 客户端
* [[Devise-Ripple|http://github.com/frank06/devise-ripple]] - 在 Riak 中使用 Devise 实现的 ORM 策略
* [[ripple-anaf|http://github.com/bkaney/ripple-anaf]] - 让 Ripple 支持嵌套属性
* [[Pabst|https://github.com/sgonyea/pabst]] - 使用 Objective-C 和 Objective-C++ 开发的跨平台扩展，让 Ruby 支持 Protocol Buffers

*Scala*

* [[Riakka|http://github.com/timperrett/riakka]] - 和 Riak 交互的 Scala 代码库
* [[Ryu|http://github.com/softprops/ryu]] - Tornado Whirlwind Kick Scala 客户端，支持纯 HTTP 接口

*Smalltalk*

* [[Phriak|http://www.squeaksource.com/Phriak/]] - 基于 Runar Jordan 的 EpigentRiakInterfacea 为 Pharo Smalltalk 开发的 Riak 客户端
* [[EpigentRiakInterface|http://www.squeaksource.com/EpigentRiakInterface/]] - Pharo Smalltalk 的 Riak 客户端（[[有篇文章|http://blog.epigent.com/2011/03/riak-interface-for-pharo-smalltalk.html]]详细的介绍了这个客户端）
