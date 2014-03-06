---
title: Buckets
project: riak
version: 0.10.0+
document: appendix
audience: intermediate
keywords: [appendix, concepts]
moved: {
  '1.4.0-': '/references/appendices/concepts/Buckets'
}
---

Buckets are virtual keyspaces that enable you to:

1. group keys together in a way that suits the needs of a particular use case, e.g. `portfolios` or `data_from_sensor_117` or `user_1a2b3c_blog_posts`.
2. define isolated configuration spaces, e.g. when a particular set of keys all need to be stored with an `n_val` of 5 (more on that in [[Replication Properties]]).

Buckets might be compared to tables in relational databases or folders in filesystems, but with the crucial difference that they are _flat_ namespaces. The keys within a particular bucket share only that bucket's configuration{{#2.0.0+}}---defined by the bucket's **[[bucket type|Using Bucket Types]]**---{{/2.0.0+}} and the bucket name. Contrast this with a relational database, in which the members of the table `fruits` share a similar data structure. In Riak, there is no such requirement.

{{#2.0.0-}}
Buckets with the default configuration are essentially "free" from a computational perspective, whereas non-default configurations need to be gossiped around the ring to take effect.
{{/2.0.0-}}
{{#2.0.0+}}
The configuration of _all_ buckets, without exception, is determined by the bucket's bucket type. We encourage you to read the documentation on [[using bucket types]].
{{/2.0.0+}}

## Configuration

For each bucket{{#2.0.0+}} type{{/2.0.0+}}, a number of configuration properties can be selectively defined, overriding the defaults.

### n_val

Specifies the number of copies of each object to be stored in the cluster. See [[Replication]]. Must be an integer. The default is `3`.

### allow_mult

Determines whether sibling values can be created. See [[Siblings|Vector Clocks#Siblings]]. Must be a Boolean. The default is `false`.

### last_write_wins

Indicates if an object's vector clocks will be used to decide the canonical write based on time of write in the case of a conflict. See [[Conflict resolution|Concepts#Conflict-resolution]]. Must be a Boolean. The default is `false`.

### r, pr, w, dw, pw, rw

Sets for reads and writes the number of responses required before an operation is considered successful. See [[Reading Data|Concepts#Reading-Writing-and-Updating-Data]] and [[Writing and Updating Data|Concepts#Reading-Writing-and-Updating-Data]]. Possible values are `all`, `quorum`, `one`, or an integer. The default is `quorum`. 

### precommit

A list of erlang or javascript functions to be executed before writing an
object. See [[Pre-Commit Hooks|Using Commit Hooks#Pre-Commit-Hooks]].

### postcommit

A list of erlang functions to be executed after writing an object. See [[Post-Commit Hooks|Using Commit Hooks#Post-Commit-Hooks]].

For more details on setting default bucket properties see [[Configuration Files|Configuration Files#default_bucket_props]], {{#2.0.0-}}[[HTTP Set Bucket Properties]]{{/2.0.0-}}{{#2.0.0+}}[[Using Bucket Types]]{{/2.0.0+}}, or the documentation for your client driver.

{{#2.0.0-}}
### backend

Specify which named backend to use for the bucket when using `riak_kv_multi_backend`.
{{/2.0.0-}}