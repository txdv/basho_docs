---
title: Introduction to Riak 2.0
project: riak
version: 2.0.0+
document: guide
audience: beginner
keywords: [developers]
---

Riak version 2.0 includes a wide variety of new features not available in previous version, features that touch on all facets of Riak. Here, we'd like to describe these new features and to direct you to sections of the documentation that explain how you can put these features to work in your Riak cluster.

## New Features

The changes introduced in Riak 2.0 leave almost no aspect of 

### Riak Data Types

In distributed systems, there is an unavoidable trade-off between consistency and availability. This can complicate some aspects of application design if you're using Riak as a key/value store because the application is responsible for resolving conflicts between replicas of objects stored in different Riak nodes.

Riak 2.0 offers a solution to this problem for a wide range of uses cases in the form of [[Riak Data Types]]. Instead of forcing the application to resolve conflicts, Riak offers five Data Types that can cut through some of the complexities of developing using Riak: [[flags|Data Types#Flags]], [[registers|Data Types#Registers]], [[counters|Data Types#Counters]], [[sets|Data Types#Sets]], and [[maps|Data Types#Maps]].

#### Relevant Docs

* [[Using Data Types]] explains how to use Riak Data Types on the application side, with usage examples for all five Data Types in a variety of languages
* [[Data Types]] explains some of the theoretical concerns that drive Riak Data Types and shares some details about how they are implemented under the hood in Riak.

### Riak Search 2.0 (codename Yokozuna)

Riak Search 2.0 is a complete, top-to-bottom re-implentation of Riak Search, integrating Riak with [Apache Solr](https://lucene.apache.org/solr/)'s full-text search capabilities and supporting Solr's client query APIs.

#### Relevant Docs

* [[Using Search]] provides a broad-based overview of how to use the new Riak Search
* [[Search Details]]

### Strong Consistency

#### Relevant Docs

* [[Using Strong Consistency]] shows you how to enable Riak's strong consistency subsystem and to apply strong consistency guarantees to data in particular buckets

### Security

### Simplified Configuration Management

In older versions of Riak, a Riak node's configuration was determined by two separate files: `app.config` and `vm.args`. In Riak 2.0, configuration management has been streamlined into a single `riak.conf` file, where parameters are set using a simplified syntax:

```riakconf
parameter.sub-parameter = setting
```

Based on the [Cuttlefish](https://github.com/basho/cuttlefish) project is both simpler (leaving behind the Erlang syntax from the old system) and more comprehensive, with a wide 

#### Relevant Docs

* [[Configuration Files]] lists and describes all of the 

## Other Major Changes

### Bucket Types

#### Relevant Docs

* [[Using Bucket Types]] explains how to create, modify, and activate bucket types, as well as how the new system
