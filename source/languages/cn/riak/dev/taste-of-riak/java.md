---
title: "Taste of Riak: Java"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, java]
---

如果你还没有创建 Riak 节点并启动，请先阅读 [[Prerequisites|Taste of Riak: Prerequisites]]。

要使用本文介绍的 Riak 开发方法，必须先正确安装 Java。

### 安装客户端

先把[一体化的 Riak Java 客户端 jar 文件](http://riak-java-client.s3.amazonaws.com/riak-client-1.1.1-jar-with-dependencies.jar)下载到工作目录。

然后下载本教程的源码 [TasteOfRiak.java](https://github.com/basho/basho_docs/raw/master/source/data/TasteOfRiak.java)，存储在当前目录中。

<div class="note">
<div class="title">针对本地集群的设置</div>

如果你按照 [[five minute install]] 中介绍的方法在本地架设了 Riak 集群，请使用文本编辑器打开 `TasteOfRiak.java`，把第 20 行注释掉，再去掉第 23 行的注释，保存文件。修改后的代码如下：

```java
//IRiakClient client = RiakFactory.pbcClient();

// Note: Use this line instead of the former if using a local devrel cluster
IRiakClient client = RiakFactory.pbcClient("127.0.0.1", 10017);
```

</div>

然后可以在命令行或 IDE 中编译并运行代码：

```bash
javac -cp riak-client-1.1.0-jar-with-dependencies.jar TasteOfRiak.java

java -ea -cp riak-client-1.1.0-jar-with-dependencies.jar:.  TasteOfRiak
```

上述命令应该返回：

```text
Creating Objects In Riak...
Reading Objects From Riak...
Updating Objects In Riak...
Deleting Objects From Riak...
Working With Complex Objects...
Serialized Object:
	{"Title":"Moby Dick","Author":"Herman Melville","Body":"Call me Ishmael. Some years ago...","ISBN":"1111979723","CopiesOwned":3}
```

Java 没有 REPL 环境，我们来分析一下每一步都做了什么。

### 在 Riak 中创建对象

源码中我们首先使用 `RiakFactory` 类初始化了一个 Riak 客户端。然后获取了名为“test”的 bucket 的信息，并存储了第一个键值对。

```java
IRiakClient client = RiakFactory.pbcClient();

// Note: Use this line instead of the former if using a local devrel cluster
// IRiakClient client = RiakFactory.pbcClient("127.0.0.1", 10017);

Bucket myBucket = client.fetchBucket("test").execute();

int val1 = 1;
myBucket.store("one", val1).execute();
```

上面的例子中我们存储了整数 1，查询所用的键设为“one”。下面我们要存储一个简单的字符串“two”，并设定一个键。

```java
String val2 = "two";
myBucket.store("two", val2).execute();
```

上面的例子都很简单。下面来存储一个复杂的对象，`HashMap<String,Integer>` 子类的实例。你现在应该已经熟知存储的过程了。

```java
StringIntMap val3 = new StringIntMap();
val3.put("value", 3);
myBucket.store("three", val3).execute();
```

### 从 Riak 中读取对象

我们已经存储了几个对象，下面我们要读取这些对象，确保保存的值是正确地。

```java
Integer fetched1 = myBucket.fetch("one", Integer.class).execute();
IRiakObject fetched2 = myBucket.fetch("two").execute();
StringIntMap fetched3 = myBucket.fetch("three", StringIntMap.class).execute();

assert(fetched1 == val1);
assert(fetched2.getValueAsString().compareTo(val2) == 0);
assert(fetched3.equals(val3));
```

很简单，我们直接使用键查询对象，而且指定了一个 `Class` 对象，告知需要转换成什么数据类型。如果存储的值是字符串，可以省略 `Class` 参数，使用 `IRiakObject` 类的 `getValueAsString()` 方法。

### 更新 Riak 中保存的对象

有些数据可能是静态的，但其他类型的数据或许需要更新。更新的过程也很简单。我们来把 myValue 这个 Hashmap 的值改为 42.

```java
fetched3.put("myValue", 42);
myBucket.store("three", fetched3).execute();
```

要更新，直接使用原先的键存储新值即可。

### 从 Riak 中删除对象

没有删除功能的数据库是不完整的

```java
myBucket.delete("one").execute();
myBucket.delete("two").execute();
myBucket.delete("three").execute();
```

### 处理复杂对象

对象往往都是很复杂的，不止简单的整数或字符串，下面来看一下如何处理更复杂地对象。举个例子，下面这个“简单 Java 对象”（POJO）包含了一本书的信息。

```java
class Book
{
    public String Title;
    public String Author;
    public String Body;
    public String ISBN;
    public Integer CopiesOwned;
}

Book book = new Book();
book.ISBN = "1111979723";
book.Title = "Moby Dick";
book.Author = "Herman Melville";
book.Body = "Call me Ishmael. Some years ago...";
book.CopiesOwned = 3;
```

我们要保存就是这本关于 Moby Dick 的书，存储的过程你现在应该很熟练了：

```java
Bucket booksBucket = client.fetchBucket("books").execute();
booksBucket.store(book.ISBN, book).execute();
```

有些人可能会想，“Riak 客户端是怎么编码和解码对象的呢？”我们把这本书的信息读出来，然后以字符串的形式打印到屏幕就知道了：

```java
IRiakObject riakObject = booksBucket.fetch(book.ISBN).execute();
System.out.println(riakObject.getValueAsString());
```

```json
{"Title":"Moby Dick",
 "Author":"Herman Melville",
 "Body":"Call me Ishmael. Some years ago...",
 "ISBN":"1111979723",
 "CopiesOwned":3}
```

是 JSON 格式！代码库把 POJO 编码成 JSON 格式的字符串。如果要读取书籍对象，可以使用 `bookBucket.fetch(book.ISBN, Book.class);`，让客户端为我们创建正确地对象类型。

既然我们已经解开了对象编码的谜团，接下来就要善后了：

```java
booksBucket.delete(book.ISBN).execute();
client.shutdown();
```

### 下一步

更复杂的用法都可以通过基本的创建（create）、读取（read）、更新（update）和删除（delete）（这四个操作简称 CRUD）操作完成。下一篇我们要介绍如何存储和查询更复杂的互联数据，例如文档。
