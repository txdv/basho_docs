---
title: 集群搭建基础
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: beginner
keywords: [operator, cluster]
---

要设置 Riak 集群，必须有一个节点监听非本地的（例如，不是 `127.0.0.1`）端口，然后合并其他节点，组成集群。

大多数的设置都是在 [[app.config|设置文件#app.config]] 文件中进行的，如果是从源码编译的，这个文件位于 `rel/riak/etc/` 目录下，如果使用安装包安装，这个文件位于 `/etc/riak/` 目录下。

下面用到的命令假定你是从源码安装的，如果是从安装包安装的，可以把 `bin/riak` 命令换成 `sudo /usr/sbin/riak`，把 `bin/riak-admin` 换成 `sudo /usr/sbin/riak-admin`。


<div class="info">
<div class="title">修改 -name 参数的注意事项</div>
<p>如果可能，不应该在修改 <code>vm.args</code> 的 <code>-name</code> 参数前启动 Riak。如果已经使用默认设置启动了 Riak，再修改 <code>-name</code> 就无法正常启动节点。</p>
<p>如果修改 -name 参数后无法重启，有两个解决方法：</p>
<ol>
<li>删除 <code>ring</code> 文件夹中的内容，烧毁现有的环元数据。这么做要重新把所有节点合并，组成集群。</li>
<li>使用 [[riak-admin cluster replace|riak-admin 命令#cluster-replace]] 命令重命名节点。如果启动的集群中只有一个节点就无法使用这个方法。</li>
</ol>
</div>

## 设置第一个节点

首先，如果 Riak 节点正在运行，请停止：

    bin/riak stop

修改 `app.config` 文件 riak_core 区下 `http{}` 设置中的 IP 地址。（端口 8098 无需修改）假设所在电脑的 IP 地址是 192.168.1.10。（这个 IP 地址只是个示例，具体的 IP 要查看你的电脑）

    {http, [ {"127.0.0.1", 8098 } ]},

修改成

    {http, [ {"192.168.1.10", 8098 } ]},

如果要使用 Protocol Buffers，也要做类似设置。在 riak_kv 区修改 IP 地址：

    {pb_ip,   "127.0.0.1" },

修改成

    {pb_ip,   "192.168.1.10" },


接下来修改 `etc/vm.args` 文件，把 `-name` 设为正确地主机名：

    -name riak@127.0.0.1

修改成

    -name riak@server.example.com

<div class="info">
<p><strong>节点名</strong></p>
<p>集群中节点的名字请使用“完全限定的域名”（FQDN）。例如，“riak@cluster.example.com”和 “riak@192.168.1.10” 都是可以使用的命名方式。但推荐使用 FQDN 形式。</p>
<p>如果节点已近启动，这时需要修改名字就要把数据文件夹中的环文件删除，使用 [[riak-admin reip|riak-admin 命令#reip]] 命令，或者使用 [[riak-admin cluster force-replace|riak-admin 命令#cluster-force-replace]] 命令替换节点。</p>
</div>

然后启动节点：

    bin/riak start

如果 Riak 节点已经启动了，就要使用 `riak-admin cluster replace` 命令修改名字，而且还要更新节点的环文件。

    bin/riak-admin cluster replace riak@127.0.0.1 riak@192.168.1.10

<div class="info">
<p><strong>单个节点</strong></p>
<p>如果单个节点使用默认的设置启动了（在搭建首个测试环境时可能这么做），修改 <code>etc/vm.args</code> 之后要删除数据文件夹中的环文件，这时就不能使用 <code>riak-admin cluster replace</code> 命令，因为节点还没加入到集群中。</p>
</div>

如果要修改集群中的所有节点，就要查看 `riak-admin cluster plan` 命令的规划，然后运行 `riak-admin cluster commit` 命令确定所做的设置。

现在节点已经设置好，可以用来合并组成集群了。接下来要向集群中加入第二个节点了。

## 向集群中加入第二个节点

在同一个网络中按上述的步骤设置第二个主机。这个节点启动后，运行 `riak-admin cluster join` 命令和第一个节点合并，组成 Riak 集群。

    bin/riak-admin cluster join riak@192.168.1.10

上述命令的输出如下：

    Success: staged join request for `riak@192.168.1.11` to `riak@192.168.1.10`

然后，做规划，然后提交变动：

    bin/riak-admin cluster plan
    bin/riak-admin cluster commit

上述第二个命令执行完，你可以看到：

    Cluster changes committed

如果你看到类似上面的输出，说明第二个金额点已经加入了集群，而且开始和第一个节点同步数据了。Riak 提供了几种用来查看集群环状态的方法，下面介绍其中两种：

使用 `riak-admin` 命令：

    bin/riak-admin status | grep ring_members

输出结果如下：

    ring_members : ['riak@192.168.1.10','riak@192.168.1.11']

使用 `riak attach` 命令：

    riak attach
    1> {ok, R} = riak_core_ring_manager:get_my_ring().
    {ok,{chstate,'riak@192.168.1.10',.........
    (riak@192.168.52.129)2> riak_core_ring:all_members(R).
    ['riak@192.168.1.10','riak@192.168.1.11']

要想加入更多的节点，请重复上述步骤。添加或删除节点更详细的信息请阅读“[[添加和删除节点]]”一文。

<div class="info">
<p><strong>ring_creation_size</strong></p>
<p>集群中的所有节点都要有 <code>ring_creation_size</code> 设置，这样才能合并到集群中。这个设置可在 app.config 文件中设置。</p>
<p>如果看到类似 <code>Failed: riak@10.0.1.156 has a different ring_creation_size</code> 的错误，就要查看所有节点的 <code>ring_creation_size</code> 设置。</p>
</div>

## 在一个主机中运行多个节点

如果从源码编译安装 Riak，或者使用针对 Mac OS X 实现编译好的安装包安装，就可以轻易的在同一个主机中运行多个 Riak 节点。这么做基本上是为了尝试运行一个 Riak 集群。（注意：如果安装的是 .deb 或者 .rpm 包，要想使用下面的方法，必须重新下载源码编译安装。）

要想运行多个节点，请复制 `riak` 文件夹。

-   如果编译时使用的是 `make all rel`，那么这个文件夹就是 Riak 源码所在目录的 `./rel/riak`
-   如果你使用的是，这个文件夹就是解压 .tar.gz 文件所在的文件夹

假设你把 `./rel/riak` 复制到 `./rel/riak1`、`./rel/riak2`、`./rel/riak3` 等：

* 在每个节点的 `app.config` 文件中，修改 `http{}` 区中的 `handoff_port`、`pb_port` 和端口号，每个节点的值都要不一样
* 在 `vm.args` 文件中，修改 `-name riak@127.0.0.1`，每个节点的值都不一样

然后，启动这些节点，请适当的修改路径和节点：

    ./rel/riak1/bin/riak start
    ./rel/riak2/bin/riak start
    ./rel/riak3/bin/riak start
    (etc.)

然后，合并成集群：

    ./rel/riak2/bin/riak-admin cluster join riak1@127.0.0.1
    ./rel/riak3/bin/riak-admin cluster join riak1@127.0.0.1
    ./rel/riak2/bin/riak-admin cluster plan
    ./rel/riak2/bin/riak-admin cluster commit

## 在一个主机中运行多个集群

使用上面介绍的方式可以在一台电脑中运行多个集群。如果节点没有加入集群，其表现就像一个集群一样。在一台电脑中运行多个集群和运行两个或更多节点，以及合并入集群的节点没什么分别。
