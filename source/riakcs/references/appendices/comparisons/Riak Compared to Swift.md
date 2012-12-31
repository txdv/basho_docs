---
title: Riak CS Compared to Swift
project: riakcs
version: 1.2.0+
document: appendix
toc: true
index: true
keywords: [comparisons, swift]
---
Riak CS and Swift (the object storage component of OpenStack) are both cloud storage systems with many design and implementation details in common. The purpose of this document is not to serve as an introduction to Riak CS and Swift, or their commonalities, but rather to enumerate interesting differences between the two systems. The intended audience for this document is someone who has a basic understanding of both systems.

If you feel this comparison is unfaithful at all for whatever reason, please [fix it](https://github.com/basho/basho_docs/issues/new) or send an email to **docs@basho.com**.


## Feature/Capability Comparison

The table below gives a high level comparison of Riak and Cassandra features/capabilities.  To keep this page relevant in the face of rapid development on both sides, low level details are found in links to Riak and Cassandra online documentation.

<table>
    <tr>
        <th WIDTH="15%">Feature/Capability</th>
        <th WIDTH="42%">Riak</th>
        <th WIDTH="43%">Swift</th>
    </tr>
    <tr>
        <td>Anti-Entropy</td>
        <td>Riak CS has continuous anti-entropy as a feature in progress, with a targeted release timeframe in Q4 2012. Riak CS currently supports “passive” read-time anti-entropy, which provides repair of inconsistencies immediately at client-read time. Swift does not perform repair at read or write time, but rather resolves such issues during its next rsync cycle.  
		</td>
        <td>Swift has a continuous anti-entropy process via frequent invocation of “rsync” for repairing any inconsistencies between data node file systems.
		</td>
    </tr>
    <tr>
        <td>Write-Time Communication & Host Failures</td>
        <td>Riak CS always writes to the full number of desired hosts, using fallback nodes to perform hinted handoff and stand in for any missing or failing hosts in order to immediately reach full redundancy. As soon as the primary Riak CS nodes are once again reachable, copies on the fallbacks will be sent to them, quickly repairing the state of the cluster.		
	 </td>
        <td> Swift will write at least a majority/quorum of replicas before declaring success, and will allow anti-entropy to bring the number of replicas up to the full count later if needed due to node failures.
		</td>
    </tr>
    <tr>
        <td>Quorum Models</td>
        <td>Riak CS’s underlying quorum model is not only about availability, it also provides a latency- smoothing effect by replying to the user without the need to block on the slowest host in the replication set. This prevents brief per-host performance problems from affecting end-users. 
			</td>
        <td>Swift, despite only replying with the “best” single response, will wait for all relevant storage nodes to finish before sending a response to a write request. This can adversely impact latency. However, Swift’s read requests do not wait for a quorum; they simply try one replica at a time in random until they get a response with a fairly short timeout before moving on to try another. There are plans to improve the latency of Swift’s write requests.	
	 </td>
    </tr>
    <tr>
        <td>Full Stack Integration</td>
        <td>Riak CS stands alone as a storage service that has no specific related services for compute, VM image management, etc.
	</td>
        <td>Though it can run on its own, Swift is part of the OpenStack project– a well regarded, defined “stack” of services.
	</td>
    </tr>
	<tr>
        <td>Languages</td>
        <td>Riak CS is written in Erlang, a language and platform engineered for extremely high availability, making it easier to build Riak CS on industry-tested distributed systems components, and to attract engineers that specialize in such systems.
		 </td>
		
        <td>Swift is written in Python, a language with a very large, accessible developer community who could readily contribute to Swift without the need to learn a new language.		
	 </td>
    </tr>
		</tr>
	        <td>Installation</td>
	        <td>Riak CS is designed for easy installation, with a relatively small number of independent components to manage. A minimal installation requires installing just three components and editing less than 10 lines of configuration data.
			</td>

	        <td>Swift’s “toolbox” approach requires the installation and ongoing operational supervision of various components including Memcached, SQLite, and Keystone (OpenStack auth server), each of which have deep dependency trees of their own. An upside of this approach is that the system’s overall behavior is extremely modifiable, by changing the behavior of any of the many dependencies.			
		 </td>
	    </tr>
    <tr>
        <td>Operations</td>
        <td>With Riak CS a single administrative command on a newly provisioned host tells the system to automatically integrate the new device. Well-defined underlying system components ensure correct behavior during transitions.
	 </td>
        <td>Swift requires a high degree of manual management. Devices are added to the definition of the ring by defining their node, name and zone. To change the definitions, mapping must be regenerated and new definitions must be pushed out to every node with whichever means is available (rsync appears to be the most common). When these files fall out of sync, the system will experience strange behavior or cease to function altogether.
	 </td>
    </tr>
    <tr>
        <td>Support For Amazon S3 API</td>
        <td>Riak CS directly and natively supports the widely adopted S3 API, including such commonly used aspects as S3-keyed ACLs, hostname-to-bucket translation, etc.
	
        <td>Cassandra allows you to add new nodes dynamically with the exception of manually calculating a node's token (though users can elect to let Cassandra calculate this). It's recommended that you double the size of your cluster to add capacity. If this isn't feasible, you can elect to either add a number of nodes (which requires token recalculation for all existing nodes), or to add one node at a time, which means leaving the initial token blank and "will probably not result in a perfectly balanced ring but it will alleviate hot spots". 
			<ul>
			  <li>[[Adding Capacity to an Existing Cluster|http://www.datastax.com/docs/1.1/operations/cluster_management#adding-capacity-to-an-existing-cluster]]</li>
			</ul>
	</td>
    </tr>
    <tr>
        <td>Multi-Datacenter Replication</td>

		<td>Riak features two distinct types of replication. Users can replicate to any number of nodes in one cluster (which is usually contained within one datacenter over a LAN) using the Apache 2.0 database. Riak Enterprise, Basho's commercial extension to Riak, is required for Multi-Datacenter deployments (meaning the ability to run active Riak clusters in N datacenters). 
		
		<ul>
			<li><a href="http://basho.com/products/riak-enterprise/">Riak Enterprise</a></li>
		<ul>
			
        <td>Cassandra has the ability to spread nodes over multiple datacenters via various configuration parameters. 
			<ul>
			  <li>[[Multiple Datacenters|http://www.datastax.com/docs/1.1/initialize/cluster_init_multi_dc]]</li>
			</ul>
	
	</td>
    </tr>
    <tr>
        <td>Graphical Monitoring/Admin Console</td>
        <td>Starting with Riak 1.1.x, Riak ships with Riak Control, an open source graphical console for monitoring and managing Riak clusters.
			<ul>
				<li>[[Riak Control]]</li>
				<li>[[Introducing Riak Control|http://basho.com/blog/technical/2012/02/22/Riak-Control/]]
			</ul>
	</td>
        <td>Datastax distributes the DataStax OpsCenter, a graphical user interface for monitoring and administering Cassandra clusters. This includes a free version available for production use, as well as a for-pay version with additional features.
			<ul>
				<li>[[DataStax OpsCenter|http://www.datastax.com/products/opscenter]]</li>
			</ul>
	 </td>
    </tr>
</table>
