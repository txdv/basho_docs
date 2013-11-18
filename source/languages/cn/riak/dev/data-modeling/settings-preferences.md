---
title: User Settings/Preferences
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: intermediate
keywords: [use-cases]
---

*这是最经典的一对一关联*

## 简单用例

对于简单的、经常读取但很少修改的用户相关数据，可以存储到用户对应的对象中。另一种常用的方法是创建“用户设置”对象类型，为了便于读取，键使用用户的 ID。

## 复杂用例

如果应用程序经常修改用户数据，或者要动态的添加用户相关的数据，例如书签、订阅、或提醒，可以使用更复杂的数据模型。
