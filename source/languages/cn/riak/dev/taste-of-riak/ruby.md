---
title: "初试 Riak：Ruby 篇"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, ruby]
---

如果你还没有创建 Riak 节点并启动，请先阅读“[[事先准备|初试 Riak：事先准备]]”一文。

要使用本文介绍的 Riak 开发方法，必须先正确安装 Ruby。

### 安装客户端

首先，使用 `gem` 命令安装 Riak 的 Ruby 客户端。

```bash
gem install riak-client
```

打开 Ruby REPL，IRB，输入下面的命令：

```ruby
require 'riak'
```

如果本地只有一个 Riak 节点，请使用下面的方法创建客户端实例：

```ruby
client = Riak::Client.new(:protocol => "pbc", :pb_port => 8087)
```

如果参照“[[花五分钟安装]]”一文中的方法在本地架设了 Riak 集群，请使用下面的方法创建客户端实例：

```ruby
client = Riak::Client.new(:protocol => "pbc", :pb_port => 10017)
```

现在可以和 Riak 交互了。

### 在 Riak 中创建对象

首先，我们来创建一个 bucket，然后在其中创建几个对象。

```ruby
my_bucket = client.bucket("test")

val1 = 1
obj1 = my_bucket.new('one')
obj1.data = val1
obj1.store()
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```ruby
val2 = "two"
obj2 = my_bucket.new('two')
obj2.data = val2
obj2.store()
```

上面的例子都很简单。下面来存储一些 JSON 数据。你现在应该已经熟知存储的过程了。

```ruby
val3 = { myValue: 3 }
obj3 = my_bucket.new('three')
obj3.data = val3
obj3.store()
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```ruby
fetched1 = my_bucket.get('one')
fetched2 = my_bucket.get('two')
fetched3 = my_bucket.get('three')

fetched1.data == val1
fetched2.data == val2
fetched3.data.to_json == val3.to_json
```

很简单，只需通过键查询即可。最后一个例子，我们把数据转换成了 JSON 格式，这样才能比较字符串形式的键和 Symbol 形式的键。

### 更新 Riak 中保存的对象

有些数据可能是静态的，但其他类型的数据或许需要更新。更新的过程也很简单。我们来把第三个例子中 myValue 的值改成 42。

```ruby
fetched3.data["myValue"] = 42
fetched3.store()
```

### 从 Riak 中删除对象

最后，我们来掩饰如何删除数据。你会看到，删除数据所用的方法既可以在 Bucket 上调用，也可以在对象上调用。

```ruby
my_bucket.delete('one')
obj2.delete()
obj3.delete()
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面的 Ruby Hash 包含了一本书的信息。

```ruby
book = {
	:isbn => '1111979723',
	:title => 'Moby Dick',
	:author => 'Herman Melville',
	:body => 'Call me Ishmael. Some years ago...',
	:copies_owned => 3
}
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```ruby
books_bucket = client.bucket('books')
new_book = books_bucket.new(book[:isbn])
new_book.data = book
new_book.store()
```

有些人可能会想，“Riak 的 Ruby 客户端是怎么编码和解码对象的呢？”我们把这本书的信息读出来，然后打印出原始数据就知道了：

```ruby
fetched_book = books_bucket.get(book[:isbn])
puts fetched_book.raw_data
```

原始数据：

```javascript
{"isbn":"1111979723","title":"Moby Dick","author":"Herman Melville",
"body":"Call me Ishmael. Some years ago...","copies_owned":3}
```

是 JSON 格式！如果存储的是结构化数据，比如 Hash，Riak 的 Ruby 客户端会把对象序列化成 JSON 格式。如果想全方位的控制序列化过程，可以使用 [Ripple](https://github.com/basho/ripple)，这个库是 Riak 基本客户端之上的高级 Ruby 模型层。对 Ripple 的介绍已经超出了本文范围，不过以后会说明。

最后，做些善后工作：

```ruby
new_book.delete()
```

### 下一步

更复杂的用法都可以通过基本的创建（create）、读取（read）、更新（update）和删除（delete）（这四个操作简称 CRUD）操作完成。下一篇我们要介绍如何存储和查询更复杂的互联数据，例如文档。
