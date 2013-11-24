---
title: "初试 Riak：C-Sharp 篇"
project: riak
version: 1.4.2+
document: guide
toc: true
audience: beginner
keywords: [developers, client, csharp]
---

如果你还没有创建 Riak 节点并启动，请先阅读“[[事先准备|初试 Riak：事先准备]]”一文。

要使用本文介绍的 Riak 开发方法，必须先正确安装 .NET 框架或 Mono。

### 安装客户端

请通过 [Nuget](http://nuget.org/packages/corrugatediron) 或 Visual Studio Nuget 包管理工具安装 [CorrugatedIron](http://corrugatediron.org)。

<div class="note">
<div class="title">针对远程集群的设置</div>

默认情况下，CorrugatedIron 会在 `app.config` 文件中添加一个区，设置包含 4 个节点的本地集群。如果要使用远程集群，请打开 `app.config`，修改第 12-16 行，指向远程集群。

可参照的示例代码在 GitHub 上的 [CorrugatedIron 演示项目](http://github.com/DistributedNonsense/CorrugatedIron.Samples)中。
</div>

### 连接到 Riak

使用 CorrugatedIron 连接到 Riak 很简单，和创建集群对象再穿件客户端对象差不多。

把下面的代码写入一个新文件中：

```csharp
using System;
using CorrugatedIron;

namespace TasteOfRiak
{
    class Program
    {
        static void Main(string[] args)
        {
        	// don't worry, we'll use this string later
	        const string contributors = "contributors";
            var cluster = RiakCluster.FromConfig("riakConfig");
            var client = cluster.CreateClient();
        }
    }
}
```

上述代码会创建一个 `RiakCluster`，用来创建 `RiakClient`。`RiakCluster` 对象会处理追踪活动节点的种种细节，并且还能进行负载均衡。`RiakClient` 用来向 Riak 发送命令。

然后我们要确保集群是在线的。把下面的代码加入 `Main` 方法：

```csharp
var pingResult = client.Ping();

if (pingResult.IsSuccess)
{
    Console.WriteLine("pong");
}
else
{
    Console.WriteLine("Are you sure Riak is running?");
    Console.WriteLine("{0}: {1}", pingResult.ResultCode, pingResult.ErrorMessage);
}
```

上述代码是检测 Riak 集群中的节点在线的简单方式，发送一个简单的 Ping 消息。即便是没有集群，CorrugatedIron 也会返回响应消息。注意，一定要使用 `IsSuccess` 属性检查 Ping 是否成功，然后再检查错误和返回码。

### 把对象存入 Riak

Ping Riak 集群也许很好玩，但最终有人会要求我们做些实际性的工作。我们来创建一个类，表示一些数据，然后存入 Riak。

CorrugatedIron 使用 `RiakObject` 类封装 Riak 中的键值对对象。`RiakObject` 最基本的功能是识别对象，并将其转换成可以方便存入 Riak 的格式。

把 `CorrugatedIron.Models` 命名空间加入 `using` 声明。所有的 `using` 声明如下：

```csharp
using System;
using System.Collections.Generic;
using CorrugatedIron;
using CorrugatedIron.Models;
```

把 `Person` 类添加到 `TasteOfRiak` 命名空间：

```csharp
public class Person {
    public string EmailAddress { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}
```

下面来造些人！

```csharp
var people = new List<Person>
{
    new Person {EmailAddress = "oj@buffered.io", FirstName = "OJ", LastName = "Reeves"},
    new Person {EmailAddress = "jeremiah@brentozar.com", FirstName = "Jeremiah", LastName = "Peschka"}
};

foreach (var person in people)
{
    var o = new RiakObject(contributors, person.EmailAddress, person);
    var putResult = client.Put(o);

    if (putResult.IsSuccess)
    {
        Console.WriteLine("Successfully saved {1} to bucket {0}", o.Key, o.Bucket);
    }
    else
    {
        Console.WriteLine("Are you *really* sure Riak is running?");
        Console.WriteLine("{0}: {1}", putResult.ResultCode, putResult.ErrorMessage);
    }
}
```

上例中，我们创建了一个 `List<Person>`，然后把每个 `Person` 实例都存入了 Riak。

保存之前，我们创建一个 `RiakObject` 对象，封装要存储的 bucket、键和对象。从 `Person` 对象上创建 `RiakObject` 对象之后，就可以调用 `Client.Put()` 方法将其存入 Riak 了。

再次提醒，我们检查了 Riak 的响应。如果一切顺利，会显示一个消息，告知对象已经存入 Riak。如果出错了，会显示一个返回码和错误提示信息。

### 从 Riak 读取对象

我们来找一个人！

```csharp
var ojResult = client.Get(contributors, "oj@buffered.io");
var oj = new Person();

if (ojResult.IsSuccess)
{
    oj = ojResult.Value.GetObject<Person>();
    Console.WriteLine("I found {0} in {1}", oj.EmailAddress, contributors);
}
else
{
    Console.WriteLine("Something went wrong!");
    Console.WriteLine("{0}: {1}", ojResult.ResultCode, ojResult.ErrorMessage);
}
```

我们使用 `RiakClient.Get` 从 Riak 中取回对象，其返回值是一个 `RiakResult<RiakObject>` 对象，和 RiakResults 类似，封转了和 Riak 的通信细节。

验证了可以顺利与 Riak 通信，并且返回成功信息后，我们就可以使用 `GetObject<T>` 反序列化对象了。

### 修改已存的数据

修改甚至删除已存数据的过程很简单。

加入我们要把 oj 的名字改为 Oliver：

```csharp
oj.FirstName = "Oliver";

var o = new RiakObject(contributors, oj.EmailAddress, oj);
var updateResult = client.Put(o);

if (updateResult.IsSuccess)
{
    Console.WriteLine("Successfully updated {0} in {1}", oj.EmailAddress, contributors);
}
else
{
    Console.WriteLine("Something went wrong!");
    Console.WriteLine("{0}: {1}", updateResult.ResultCode, updateResult.ErrorMessage);
}
```

更新对象和创建新对象一样简单，只需调用 `RiakClient.Put` 方法保存已存对象即可。

### 删除数据

删除操作同样简单：

```csharp
var deleteResult = client.Delete(contributors, "jeremiah@brentozar.com");

if (deleteResult.IsSuccess)
{
    Console.WriteLine("Successfully got rid of a devious person");
}
else
{
    Console.WriteLine("Something went wrong!");
    Console.WriteLine("{0}: {1}", deleteResult.ResultCode, deleteResult.ErrorMessage);
}
```

和其他操作一样，我们要检查 Riak 返回的结果，确保对象成功删除了。当然，如果你不在乎数据是否真的被删除了，可以直接忽略返回的结果。

### 下一步

CorrugatedIron 还有很多功能，可以结合 Riak 开发高级复杂的程序。请查看其[文档](http://corrugatediron.org/)和[示例项目](http://github.com/DistributedNonsense/CorrugatedIron.Samples)，学习在 Riak 中使用 CorrugatedIron 的更多知识。
