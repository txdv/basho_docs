---
title: Data Modeling with Keys and Values
project: riak
version: 1.0.0+
document: cookbook
audience: intermediate
keywords: [relational, developers, key/value]
---

Riak was built as a key/value store, with the goal of providing maximum data availability and partition tolerance. It functions very differently from relational databases like [MySQL](http://www.mysql.com/), [PostgreSQL](http://www.postgresql.org/), and [Oracle DB](http://www.oracle.com/us/products/database/overview/index.html) in core respects, because those technologies, although powerful and very good at some things, . If your background is primarily in SQL-driven data modeling, working with a key/value store like Riak might present special challenges. Here, we'd like to walk you through some of the core distinctions between these two types of system.

## What Relational Databases Offer

Relational databases (RDBs henceforth) provide the following very useful features:

* **Relationships** --- Data is structured in a such a way that the relationship between data points is often firmly established, e.g. the classic row/column/table format.
* **Transactions** --- RDBs provide you with [acid transactions](http://en.wikipedia.org/wiki/ACID), which 