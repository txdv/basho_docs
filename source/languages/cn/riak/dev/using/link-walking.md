---
title: Link Walking
project: riak
version: 1.4.2+
document: cookbook
audience: beginner
keywords: [developers, linkwalking]
---

## 链接是什么？

键值对存储提供的数据模型相对有限，有很多种方法可以对其进行扩展，其中一种就是使用“链接”，以及一种称为“链接遍历”（link walking）的查询。

Riak 中的链接是一种元数据，在对象之间建立单项关系。关系建立后就可以执行查询，从一个对象连到另一个对象。链接是一种对象间的轻量级指针，例如从“projects”指向“milestones”，再从“milestones”指向“tasks”，然后可以使用简单的 API 命令按照这种分级结果选择数据。（某些情况下，链接可以用作轻量级的图形数据库，只要能保证键上的链接数量很少。）链接是 Riak 提供的强大功能，如果合理使用可以让应用程序变得更强大。

## 使用链接

链接是对象的元数据，通过“Link”报头指定。下面就是一个“Link”报头：

```bash
Link: </riak/people/dhh>; riaktag="friend"
```

这个报头是什么意思呢？尖括号中是链接指向的 IRL 地址。前缀“riak”后面跟着的是 bucket 名（“people”），而后是键名（“dhh”）。然后是“riaktag”，指定要捕获的链接关系。本例中“riaktag”是“friend”。

下面的例子使用 CURL 进行 PUT 请求，其中就包含“Link”报头：

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/people/timoreilly \
  -H 'Link: </riak/people/dhh>; riaktag="friend"' \
  -H "Content-Type: text/plain" \
  -d 'I am an excellent public speaker.'
```

在这个例子中，我们把`Link: &lt;/riak/people/dhh&gt;; riaktag="friend"` 附加到“people”这个 bucket 的“timoreilly”键上。

你可以动手试一下，很简单吧。你刚刚就把一个链接附加到了 Riak 对象上！

<div class="info">把链接从对象上删除也很简单：先读取（GET 请求）对象，把链接删掉，然后再把对象写入 Riak。</div>

使用下面的命令取出对象，查看刚附加的链接：

```bash
$ curl -v http://127.0.0.1:8091/riak/people/timoreilly
```

在响应报头中查找“Link”字段。这个字段显示的就是链接信息。

好的，我们已经存储了“timoreilly”对象，并把“friend”标签指向了对象“dhh”。现在我们要存储“dhh”对象：

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/people/dhh \
  -H "Content-Type: text/plain" \
  -d 'I drive a Zonda.'
```

很好，现在我们在“peopel”这个 bucket 中存储了“timoreilly”对象，并将其链接到同样存储在“people”中的“dhh”对象。

那怎么处理这种链接关系呢？使用链接遍历。

## 链接遍历

使用链接为 Riak 对象打上标签后，可以使用一种称为“链接遍历”的操作进行遍历。在一次请求中可以进行任何数量的链接遍历，还可以一步处理结果中的所有对象。

继续使用上面的例子，现在“timoreilly”对象已经指向了“dhh”对象。我们可以使用链接遍历查询从“timoreilly”跟踪到“dhh”。使用的查询如下：

```bash
$ curl -v http://127.0.0.1:8091/riak/people/timoreilly/people,friend,1
```

你会发现，在请求的末尾我们加上了“/people,friend,1”，这就是指定链接的方式，包含三部分：

* Bucket 名 - 限制只在这个 bucket 中处理链接（上例中的“people”）
* 标签名 - 要查询的“riaktag”（上例中的“friend”）
* 是否保留（Keep） - 0 或 1，指明是否保留这一步的返回结果

如果一切正常，上述请求的响应主体中应该包含“dhh”对象。

链接格式中的“bucket”和标签都可以使用下划线，匹配所有 bucket 和标签。例如，下面的请求应该和上述请求返回相同的结果：

```bash
$ curl -v http://127.0.0.1:8091/riak/people/timoreilly/_,friend,1
```

遍历的每一步称为一个步骤，因为链接遍历的底层机制和 MapReduce 一样，请求 URL 中的每一步都会转换成一个 MapReduce 步骤。如果要执行多个变量步骤，可以使用 Keep 参数指明真正感兴趣的步骤。

默认情况下，Riak 只会返回最后一步的结果。我们可以利用这个特点为对象建立关系图谱。为了演示处理的过程，我们再添加一个对象“davethomas”，作为“timoreilly”的朋友。

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/people/davethomas \
  -H 'Link: </riak/people/timoreilly>; riaktag="friend"' \
  -H "Content-Type: text/plain" \
  -d 'I publish books'
```

现在我们就可以直接从“davethomas”找到“dhh”，使用下面的请求即可：

```bash
$ curl -v localhost:8091/riak/people/davethomas/_,friend,_/_,friend,_/
```

最终结果只会返回“dhh”对象。最后一个参数设为“_”的话，Riak 就不会返回中间步骤的结果。如果要返回中间步骤的结果，想得到哪个步骤的结果，就把哪个 Keep 参数设为 1。

```bash
$ curl -v localhost:8091/riak/people/davethomas/_,friend,1/_,friend,_/
```

如果你自己执行了上面的请求，会发现结果有点看不懂，包含了两部分，每个都有很多对象。

我们可以直接给“dhh”和“davethomas”建立朋友关系，这样就真的组成关系网了。

```
$ curl -v -XPUT http://127.0.0.1:8091/riak/people/dhh \
  -H 'Link: </riak/people/davethomas>; riaktag="friend"' \
  -H "Content-Type: text/plain" \
  -d 'I drive a Zonda.'
```

请求中可以包含多个链接遍历，也可以通过“davethomas”从“dhh”遍历到“timoreilly”，甚至可以从“davethomas”遍历到“davethomas”，只需多添加一组请求参数就行。

```bash
$ curl -v localhost:8091/riak/people/davethomas/_,friend,_/_,friend,_/_,friend,_/
```

我们来回顾一下前面所做的事情：

1. 存储一个对象，并且附加了一个链接
2. 存储上一个对象指向的对象
3. 执行链接遍历请求，从一个对象遍历到另一个对象

这确实是很强大的功能。我们仅仅介绍了些皮毛。

## 链接遍历视频

在这个视频中，来自 Basho 的 Sean Cribbs 会为你介绍链接遍历的基本知识，以及更复杂更高级的用法。

<div style="display:none" class="iframe-video" id="http://player.vimeo.com/video/14563219"></div>

<p><a href="http://vimeo.com/14563219">Riak 中的链接和链接遍历</a>，<a href="http://vimeo.com/bashotech">Basho Technologies</a> 制作，托管在 <a href="http://vimeo.com">Vimeo</a> 上。</p>

## 链接遍历脚本

在上面的视频中，演示使用链接建立更深层次的关系时，Sean 使用了很多脚本，这些脚本的链接如下：

<dl>
<dt>[[load_people.sh|https://github.com/basho/basho_docs/raw/master/source/data/load_people.sh]]</dt>
<dt>[[people_queries.sh|https://github.com/basho/basho_docs/raw/master/source/data/people_queries.sh]]</dt>
</dl>

如果你看过这个视频，很显然你会知道如何使用这些脚本。如果没有看这个视频，或者想测试以下这些脚本，可以参照这个图片：
![Circle of Friends](/images/circle-of-friends.png)

`load_people.sh` 会自动把数据加载到包含三个节点的 Riak 集群中，并按照上图所示建立关系。

`people_queries.sh` 中包含一系列查询，探索 `load_people.sh` 脚本建立的关系。

要使用 `load_people.sh` 脚本，请下载这个文件，存放到 `dev` 目录中，然后执行下面的命令：

```bash
$ chmod +x load_people.sh
```

然后再执行下面的命令：

```bash
$ ./load_people.sh
```

等输出显示完毕后，对`people_queries.sh` 做相同的操作：

```bash
$ chmod +x people_queries.sh
```

再执行：

```bash
$ ./people_queries.sh
```

然后会看到如下输出：

```
Press [[Enter]] after each query description to execute.
Q: Get Sean's friends (A:Mark, Kevin)
```
