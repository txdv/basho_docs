---
title: "初试 Riak：PHP 篇"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, php]
---

如果你还没有创建 Riak 节点并启动，请先阅读“[[事先准备|初试 Riak：事先准备]]”。

要使用本文介绍的 Riak 开发方法，必须先正确安装 PHP。

### 安装客户端

请从 GitHub 上下载最新的 PHP 客户端（[zip](https://github.com/basho/riak-php-client/archive/master.zip), [仓库](https://github.com/basho/riak-php-client/)）。

把压缩文件解压到工作目录，然后从当前目录启动 PHP 交互 shell：

然后，在 shell 中输入下面的代码，加载客户端代码库：

```php
require_once('riak-php-client/src/Basho/Riak/Riak.php');
require_once('riak-php-client/src/Basho/Riak/Bucket.php');
require_once('riak-php-client/src/Basho/Riak/Exception.php');
require_once('riak-php-client/src/Basho/Riak/Link.php');
require_once('riak-php-client/src/Basho/Riak/MapReduce.php');
require_once('riak-php-client/src/Basho/Riak/Object.php');
require_once('riak-php-client/src/Basho/Riak/StringIO.php');
require_once('riak-php-client/src/Basho/Riak/Utils.php');
require_once('riak-php-client/src/Basho/Riak/Link/Phase.php');
require_once('riak-php-client/src/Basho/Riak/MapReduce/Phase.php');
```

如果本地只有一个 Riak 节点，请使用下面的方法初始化客户端实例：

```php
$client = new Basho\Riak\Riak('127.0.0.1', 8098);
```

如果参照“[[花五分钟安装]]”一文中的方法在本地架设了 Riak 集群，请使用下面的方法初始化客户端实例：

```php
$client = new Basho\Riak\Riak('127.0.0.1', 10018);
```

现在可以和 Riak 交互了。

### 在 Riak 中创建对象

首先，我们来创建一个 bucket，然后在其中创建几个对象。

```php
$myBucket = $client->bucket('test');

$val1 = 1;
$obj1 = $myBucket->newObject('one', $val1);
$obj1->store();
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```php
$val2 = 'two';
$obj2 = $myBucket->newObject('two', $val2);
$obj2->store();
```

上面的例子都很简单。下面来存储一个关联数组。你现在应该已经熟知存储的过程了。

```php
$val3 = array('myValue' => 3);
$obj3 = $myBucket->newObject('three', $val3);
$obj3->store();
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```php
$fetched1 = $myBucket->get('one');
$fetched2 = $myBucket->get('two');
$fetched3 = $myBucket->get('three');

assert($val1 == $fetched1->getData());
assert($val2 == $fetched2->getData());
assert($val3 == $fetched3->getData());
```

很简单，只需通过 bucket 和键查询即可。

### 更新 Riak 中保存的对象

有些数据可能是静态的，但其他类型的数据或许需要更新。更新的过程也很简单。我们来把第三个例子中 myValue 的值改成 42。

```php
$fetched3->data['myValue'] = 42;
$fetched3->store();
```

### 从 Riak 中删除对象

最后，我们要演示如何删除数据。只需在获取的对象上调用 `delete()` 方法。

```php
$fetched1->delete();
$fetched2->delete();
$fetched3->delete();
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面这个“简单 PHP 对象”（POPO）包含了一本书的信息。

```php
class Book {
    var $title;
    var $author;
    var $body;
    var $isbn;
    var $copiesOwned;
}

$book = new Book();
$book->isbn = '1111979723';
$book->title = 'Moby Dick';
$book->author = 'Herman Melville';
$book->body = 'Call me Ishmael. Some years ago...';
$book->copiesOwned = 3;
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```php
$booksBucket = $client->bucket('books');
$newBook = $booksBucket->newObject($book->isbn, $book);
$newBook->store();
```

有些人可能会想，“Riak 的 Erlang 客户端是怎么编码和解码对象的呢？”我们把这本书的信息读出来，然后以字符串的形式打印到屏幕就知道了：

```php
$riakObject = $booksBucket->getBinary($book->isbn);
print($riakObject->data);
```

```json
{"title":"Moby Dick",
 "author":"Herman Melville",
 "body":"Call me Ishmael. Some years ago...",
 "isbn":"1111979723",
 "copiesOwned":3}
```

是 JSON 格式！代码库把 POPO 编码成 JSON 格式的字符串。如果要读取数据对象，可以使用 `$mobyDick = $booksBucket->get(book.ISBN)->data`，然后使用读取数组元素的方式（`$mobyDick['isbn']`）去除所需的信息。

既然我们已经解开了对象编码的谜团，接下来就要善后了：

```php
$newBook->delete();
```

### 下一步

更复杂的用法都可以通过基本的创建（create）、读取（read）、更新（update）和删除（delete）（这四个操作简称 CRUD）操作完成。下一篇我们要介绍如何存储和查询更复杂的互联数据，例如文档。
