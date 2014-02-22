---
title: Dotted Version Vectors
project: riak
version: 2.0.0+
document: appendix
toc: true
audience: intermediate
keywords: [appendix, concepts, dotted-version-vectors, dvvs]
---

Mechanism for tracking changes in distributed systems; DSs always pose the problem that different agents in the system update data at the same time; DVVs are one mechanism (among many possible) for determining which update is most recent (or in which order updates occurred); the goal is causality tracking; DVVs are not perfect, but they are often better than vclocks (prevent certain kinds of false )

Initial state: all vector counters are at 0
Updates => local agent increments the counter by one
Upon synchronization: any two replicas are either identical, concurrent, or ordered (a < b or a > b)

## Distinction Between DVVs and Vector Clocks

## References

http://gsd.di.uminho.pt/members/vff/dotted-version-vectors-2012.pdf
https://github.com/ricardobcl/Dotted-Version-Vectors
http://en.wikipedia.org/wiki/Version_vector