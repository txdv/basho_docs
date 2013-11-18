---
title: User Subscriptions/Events/Timelines
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

*这是典型的一对多和多对多关联*

## 简单用例

有时需要处理复杂或特定类型的用户数据模型，比如用来组成社会化网络的时间轴。要创建用户的时间轴，可以把数据存储在“timeline” bucket 中，其中的键使用用户唯一的 ID，其值就是时间轴所需的数据：一系列状态更新的 ID，可以用来从其他 bucket 中取出完整的信息；或者直接存储完整的状态更新。如果还要存储其他信息，例如时间戳，分类或列表属性，可以使用哈希类型。注意，Riak 无法向对象添加信息，要把事件添加到时间轴中，必须先读出整个对象，向哈希中添加新值，然后再写入。

## 社区使用示例

<table class="links">
    <tr>
        <td><a href="http://player.vimeo.com/video/21598799" target="_blank" title="Yammer 如何使用 Riak">
           <img src="http://b.vimeocdn.com/ts/139/033/139033664_640.jpg"/>
         </a></td>
        <td><a href="http://player.vimeo.com/video/21598799" target="_blank" title="Yammer 如何使用 Riak">Yammer 如何使用 Riak</a>
        <br>
        这个视频是在 2012 年 3 月旧金山 Riak 聚会上录制的，内容很丰富。来自 Yammer 的 Coda Hale 和 Ryan Kennedy 深入介绍了他们如何开发 Streamie、用户提醒系统，为什么会选择使用 Riak，以及这整个过程中的收获。更多信息和幻灯片可以在<a href="http://basho.com/blog/technical/2011/03/28/Riak-and-Scala-at-Yammer/" target="_blank">这篇文章</a>中获取。
        </td>
    </tr>

    <tr>
        <td><a href="http://player.vimeo.com/video/44498491" target="_blank" title="Voxer 如何使用 Riak">
           <img src="http://b.vimeocdn.com/ts/309/154/309154350_960.jpg"/>
         </a></td>
        <td><a href="http://player.vimeo.com/video/44498491" target="_blank" title="Voxer 如何使用 Riak">Voxer 如何使用 Riak</a>
        <br>
        Voxer 团队早就在不同的服务中使用 Riak 作为主要的数据存储系统。他们按照自己的方式使用 Riak，成为我们的典型客户。他们的产品在 2011 年底登顶 App Store 排行榜时就已经使用 Riak 了。我们对这个客户充满了爱，因为他们开源了 Node.js 客户端。更多信息和幻灯片可以在<a href="http://basho.com/blog/technical/2012/06/27/Riak-at-Voxer/" target="_blank">这篇文章</a>中获取。
        </td>
    </tr>
</table>
