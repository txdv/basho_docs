---
title: "初试 Riak：Python 篇"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, python]
---

如果你还没有创建 Riak 节点并启动，请先阅读“[[事先准备|初试 Riak：事先准备]]”一文。

要使用本文介绍的 Riak 开发方法，必须先正确安装 Python，最好是 Python 2.7。安装客户端还需要用到 Python 的包管理工具 `setuptools` 或 `pip`。

在 OS/X 上可以使用 MacPorts 安装 `setuptools`，请执行 `sudo
port install py-distribute`。 Homebrew 中安装 Python 的脚本中包含了 `setuptools` 和 `pip` 的安装脚本，请执行 `brew install python`。

### 安装客户端

安装客户端最简单的方式是使用 `easy_install` 或 `pip` 命令。下面两个命令中的任一个都会把客户端及其依赖库安装到加载路径中。Python 安装目录不一，可能需要使用 `sudo` 执行这两个命令。

```bash
easy_install riak
pip install riak
```

要想从源码安装，请从 GitHub 上下载最新的 Python 客户端（[zip](https://github.com/basho/riak-python-client/archive/master.zip),
[仓库](https://github.com/basho/riak-python-client)），解压到工作目录。

然后编译客户端。

```bash
python setup.py install
```

### 连接到 Riak

现在，我们要打开 Python REPL，输入下面的命令：

```python
import riak
```

如果本地只有一个 Riak 节点，请使用下面的方法创建客户端实例：

```python
myClient = riak.RiakClient(pb_port=8087, protocol='pbc')
```

如果参照“[[花五分钟安装]]”一文中的方法在本地架设了 Riak 集群，请使用下面的方法创建客户端实例：

```python
myClient = riak.RiakClient(pb_port=10017, protocol='pbc')
```

现在可以和 Riak 交互了。

### 在 Riak 中创建对象

首先，我们来创建一个 bucket，然后在其中创建几个对象。

```python
myBucket = myClient.bucket('test')

val1 = 1
key1 = myBucket.new('one', data=val1)
key1.store()
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```python
val2 = "two"
key2 = myBucket.new('two', data=val2)
key2.store()
```

上面的例子都很简单。下面来存储一些 JSON 数据。你现在应该已经熟知存储的过程了。

```python
val3 = {"myValue": 3}
key3 = myBucket.new('three', data=val3)
key3.store()
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```python
fetched1 = myBucket.get('one')
fetched2 = myBucket.get('two')
fetched3 = myBucket.get('three')

assert val1 == fetched1.data
assert val2 == fetched2.data
assert val3 == fetched3.data
```

很简单，只需通过键查询即可。

### 更新 Riak 中保存的对象

有些数据可能是静态的，但其他类型的数据或许需要更新。更新的过程也很简单。我们来把第三个例子中 myValue 的值改成 42。

```python
fetched3.data["myValue"] = 42
fetched3.store()
```

### 从 Riak 中删除对象

没有删除功能的数据库是不完整的，幸好删除操作也很简单。

```python
fetched1.delete()
fetched2.delete()
fetched3.delete()
```

然后验证一下对象确实从 Riak 中删除了。

```python
assert myBucket.get('one').exists == False
assert myBucket.get('two').exists == False
assert myBucket.get('three').exists == False
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面的对象包含了一本书的信息。

```python
book = {
  'isbn': "1111979723",
  'title': "Moby Dick",
  'author': "Herman Melville",
  'body': "Call me Ishmael. Some years ago...",
  'copies_owned': 3
}
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```python
booksBucket = myClient.bucket('books')
newBook = booksBucket.new(book['isbn'], data=book)
newBook.store()
```

有些人可能会想，“Riak 的 Python 客户端是怎么编码和解码对象的呢？”我们把这本书的信息读出来，然后以字符串的形式打印到屏幕就知道了：

```python
fetchedBook = booksBucket.get(book['isbn'])

print(fetchedBook.encoded_data)
```

```javascript
{"body": "Call me Ishmael. Some years ago...",
"author": "Herman Melville", "isbn": "1111979723",
"copies_owned": 3, "title": "Moby Dick"}
```

是 JSON 格式！只要可以，Riak 的 Python 客户端就会把数据编码成 JSON 格式。如果我们要读取未序列化的对象，直接调用 `fetchedBook.data` 方法即可。

最后，做些善后工作：

```python
fetchedBook.delete()
```

### 下一步

更复杂的用法都可以通过基本的创建（create）、读取（read）、更新（update）和删除（delete）（这四个操作简称 CRUD）操作完成。下一篇我们要介绍如何存储和查询更复杂的互联数据，例如文档。
