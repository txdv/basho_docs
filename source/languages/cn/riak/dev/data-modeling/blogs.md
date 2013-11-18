---
title: Blog Posts, Articles and Other Content
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

## 简单用例

为博客文章等内容建立的最简单模型是，创建一个 bucket，各种内容类型存储在不同的属性中，例如“blogs”、“articles”等。键可以作为文章的唯一标识符，可以使用文章标题、文章标题加日期，或者可以用在 URL 中的数字。内容可以以任何一种格式存储，HTML、纯文本、JSON、XML 等。但要记住，Riak 中的数据是不透明的，在通过 Riak Search 索引之前，Riak 对对象一无所知。

## 复杂用例

对需要查询和搜索支持的复杂内容建模需要应用程序的支持。例如，在视图中你可能想生成不同类型的内容：文章，评论，用户资料等。很多 Riak 开发者会把不同类型的内容存到不同的 bucket 中，例如除 posts 之外，再在 Riak 集群中创建 comments。文章的评论可以存储时使用的键可以和文章的一样，只要保证“bucket/键”组合是唯一的就行。当然也可以使用自己的 ID 存储评论。生成包含评论的视图需要应用程序分别调用 posts 和 comments 这两个 bucket 中的数据。

另一种复杂的用例是，除了简单的获取键值对之外，还想进行搜索等查询操作。我们开发的全文本搜索引擎 Riak Search，具有和 Solr 类似的 API，非常适合对文本内容进行搜索。很多用户，比如 Clipboard，找到了一些优化搜索性能的好方法。对于比较轻量级的查询可以使用二级索引，在要查询的对象上添加额外的元数据就可以进行精确匹配和范围查询。使用二级索引，可以使用日期、时间戳、话题领域等给文章加上标签。但一定要保证数据集合可以使用 2i，因为在超过 512 个分区的集群中使用 2i 会严重影响性能。

## 社区使用示例

<table class="links">
  <tr>
    <td><a href="http://blog.clipboard.com/2012/03/18/0-Milking-Performance-From-Riak-Search" class="vid_img" target="_blank"><img src="/images/milking-perf-from-riak.png" title="榨取性能"></a>
    </td>
    <td>Clipboard 介绍<a href="http://blog.clipboard.com/2012/03/18/0-Milking-Performance-From-Riak-Search" target="_blank">如何在 Riak 中存储并搜索数据</a>
  </tr>
  <tr>
    <td><a href="http://media.basho.com/pdf/Linkfluence-Case-Study-v2-1.pdf" class="vid_img" link target="_blank"><img src="/images/linkfluence-case-study.png" title="榨取性能"></a>
    </td>
    <td>Linkfluence 对如何使用 Riak<a href="http://media.basho.com/pdf/Linkfluence-Case-Study-v2-1.pdf" target="_blank">存储社会化网络内容</a>的研究
  </tr>
  <tr>
    <td><a href="http://basho.com/assets/Basho-Case-Study-ideeli.pdf" class="vid_img" link target="_blank"><img src="/images/ideeli-case-study.png" title="榨取性能"></a>
    </td>
    <td>ideeli 对如何使用 Riak<a href="http://basho.com/assets/Basho-Case-Study-ideeli.pdf" target="_blank">提供网页服务</a>的研究
  </tr>
</table>
