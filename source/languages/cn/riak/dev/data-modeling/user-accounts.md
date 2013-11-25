---
title: 用户账户
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

## 简单用例

存储用户账户就很简单了，一般是把 JSON 格式的数据存到“users” bucket 中。至于要使用什么作为键，就要根据应用程序的实际需求而定了。例如，如果程序有用户登录功能，最简单、读取最高效的方法是使用登录用户名作为对象的键。获取登录时使用的用户名，向用户的账户对象发起 GET 请求就行了。当然这种方法也有很多缺点，如果用户要修改用户名或 Email 地址怎么办？所以最常用的解决方案是使用唯一的 UUID 类型作为用户对象的键，为了提高查询效率，把用户名和 Email 地址存储为二级索引。

## 复杂用例

如果只是简单的取回每个账户的数据，提供用户 ID 就行了（或许还要使用用户名和 Email 地址的二级索引）。如果你遇见到要使用其他的属性（创建时间，用户类型，所在地区）查询用户数据，就要创建相应的二级索引，或者考虑使用 Riak Search 索引用户账户的 JSON 格式内容。

## 社区使用示例

<table class="links">
  <tr>
    <td><a href="https://player.vimeo.com/video/47535803" target="_blank" title="Braintree 如何使用 Riak"><img class="vid_img"src="http://b.vimeocdn.com/ts/329/711/329711886_640.jpg"/></a>
    </td>
    <td><a href="https://player.vimeo.com/video/47535803" target="_blank" title="Braintree 如何使用 Riak">Braintree 如何使用 Riak</a>
    <br>
    Braintree 的开发者 Ben Mills 介绍了他们的后台团队是如何把 Riak 集成到生成环境中的。他还介绍了他们使用的模型和仓库框架，使用 Ruby 开发的 Curator。更多内容和幻灯片可以在<a href="http://basho.com/blog/technical/2012/08/14/riak-at-braintree/" target="_blank">这篇文章</a>中获取。
    </td>
  </tr>
</table>
