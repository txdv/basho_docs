---
title: "Taste of Riak: Clojure"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, clojure]
---

如果你还没有创建 Riak 节点并启动，请先阅读 [[Prerequisites|Taste of Riak: Prerequisites]]。

要使用本文介绍的 Riak 开发方法，必须先正确安装 Java 和 [Leiningen](https://github.com/technomancy/leiningen)。

### 安装客户端

[Welle](http://clojureriak.info/) 是由社区维护的 Clojure 语言 Riak 客户端。

首先，把 Welle 加入项目的依赖库。

```clojure
[com.novemberain/welle "1.5.0"]
```

使用 Leiningen 启动 Clojure REPL：

```bash
$ lein repl
```

然后，输入下面的代码：

```clojure
(ns taste-of-riak.docs.examples
  (:require [clojurewerkz.welle.core    :as wc]
            [clojurewerkz.welle.buckets :as wb]
            [clojurewerkz.welle.kv      :as kv])
  (:import com.basho.riak.client.http.util.Constants))


;; Connects to a Riak node at 127.0.0.1:8098
(wc/connect! "http://127.0.0.1:8098/riak")
```

如果参照 [[five minute install]] 中的方法在本地架设了 Riak 集群，请输入下面的代码：

```clojure
;; Connects to a Riak node at 127.0.0.1:10018
(wc/connect! "http://127.0.0.1:10018/riak")
```

现在可以和 Riak 交互了。

### 在 Riak 中创建对象

首先，我们来创建一个 bucket，然后在其中创建几个对象。

```clojure
(wb/create "test")
(kv/store "test" "one" 1 :content-type "application/clojure")
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```clojure
(kv/store "test" "two" (.getBytes "two"))
```

上面的例子都很简单。下面来存储一些 JSON 数据。你现在应该已经熟知存储的过程了。

```clojure
(def three {:val 3})
(kv/store "test" "three" three :content-type Constants/CTYPE_JSON_UTF8)
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```clojure
(:value (first (kv/fetch "test" "one")))
; 1
(:value (first (kv/fetch "test" "one")))
(String. (:value (first (kv/fetch "test" "two"))))
; "two"
(:val (:value (first (kv/fetch "test" "three"))))
; 3
```

很简单，只需通过键查询即可。

### 从 Riak 中删除对象

最后，我们来演示如何删除数据。

```clojure
(kv/delete "test" "one")
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面 Map Hash 包含了一本书的信息。

```clojure
(def book {:isbn "1111979723",
           :title "Moby Dick",
           :author "Herman Melville",
           :body "Call me Ishmael. Some years ago...",
           :copies_owned 3})
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```clojure
(wb/create "books")
(kv/store "books" (:isbn book) book :content-type Constants/CTYPE_JSON_UTF8)
```

这里我们把 Clojure 的 Map 序列化成了 JSON 格式。如果取回书籍对象，得到的还是 Clojure Map。

```clojure
(:value (first (kv/fetch "books" "1111979723")))
; {:author "Herman Melville", :title "Moby Dick", :copies_owned 3, :isbn "1111979723", :body "Call me Ishmael. Some years ago..."}
```

如上所示，Welle 可以序列化并反序列化如下的数据类型：

* JSON
* JSON in UTF-8
* Clojure data (that can be read by the Clojure reader)
* Text
* Text in UTF-8

最后，做些善后工作：

```clojure
(kv/delete "books" "1111979723")
```
