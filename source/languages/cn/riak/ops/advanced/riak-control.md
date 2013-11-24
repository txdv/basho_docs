---
title: Riak Control
project: riak
version: 1.4.2+
document: appendix
toc: true
audience: intermediate
keywords: [control]
---

Riak Control 是一个基于网页的管理控制台，用来查看和管理 Riak 集群。

{{#1.4.0-}}
请观看下面的视频，简单的了解一下 Riak Control 的功能。

<div style="display:none" class="iframe-video" id="http://player.vimeo.com/video/38345840"></div>
{{/1.4.0-}}

## 需求

Riak Control 是一个[单独维护的项目](https://github.com/basho/riak_control)，Riak 1.1+ 提供了运行所需的代码，不过还要手动安装。

强烈建议使用 Riak Control 时启用 SSL，除非做了 `{auth, none}` 设置。SSL 可以在[[设置文件]]中开启。

## 安装 Riak Control

### 启用 SSL 和 HTTPS

在 `app.config` 中 `riak_core` 区下有两个注释掉得设置：`https` 和 `ssl`。

去掉 `https` 前面的注释，把端口改为 `8069`。你可以使用任何未被使用的端口，但切记不要使用默认值，因为默认值和访问 Riak 的 `http` 端口一样。

```erlang
{https, [{ "127.0.0.1", 8069 }]},
```

如果没有 SSL 证书，请按照[这里](http://www.akadia.com/services/ssh_test_certificate.html)的说明获取一个。

然后，去掉 `ssl` 的注释。把 `keyfile` 和 `certfile` 的路径设为 SSL 证书所在的位置。

```erlang
{ssl, [
       {certfile, "./etc/cert.pem"},
       {keyfile, "./etc/key.pem"}
      ]},
```

#### 中级授权的 SSL

如果使用的 SSL 包含中级授权，请添加 `cacertfile` 设置：

```erlang
{ssl, [
       {certfile, "./etc/cert.pem"},
       {cacertfile, "./etc/cacert.pem"},
       {keyfile, "./etc/key.pem"}
      ]},
```

### 启用 Riak Control

在 `app.config` 的底部找到 `riak_control` 区。默认情况下，Riak Control 没有启用，所以需要把 `enabled` 设为 `true`：

```erlang
{riak_control, [
         %% Set to false to disable the admin panel.
          {enabled,true},
```

## 其他设置

### 身份验证

目前，Riak Control 只支持两种身份验证方式：`none` 和 `userlist`（HTTP 基本验证）。默认使用的是 `userlist`。如果不想使用身份验证，请把 `auth` 改为 `none`，或者直接注释掉。

```erlang
%% Authentication style used for access to the admin
%% panel. Valid styles are 'userlist' and 'none'.
{auth, userlist}
```

如果使用 `userlist`，必须制定一个用户名和密码列表。

```erlang
%% If auth is set to 'userlist' then this is the
%% list of usernames and passwords for access to the
%% admin panel.
{userlist, [{"user", "pass"}
           ]},
```

默认的用户名和密码是 "user" 和 "pass"。请根据需求修改。

*注意：修改 `app.config` 后要重启节点。*

设置好身份验证后，就可以登入 Riak Control 了。

### 启用模块

Riak Control 允许集群的管理员启用或禁用不同的模块。目前只有一个模块（`admin`），用来启用每种资源。如果禁用了这个模块，Riak Control 也就不能用了。

```erlang
%% The admin panel is broken up into multiple
%% components, each of which is enabled or disabled
%% by one of these settings.
{admin, true}
```

## 用户界面

请访问 <https://localhost:8069/admin>。

如果浏览器提示无法验证网页，这说明你用的是自签名的证书。

如果在 `app.config` 中启用了身份验证，那么接下来就会要求输入用户名和密码。

### 快照页面

第一次访问 Riak Control，看到的是快照页面：

{{#1.4.0-}}
![Snapshot View](/images/control_snapshot.png)
{{/1.4.0-}}
{{#1.4.0+}}
[ ![Snapshot View](/images/control_current_snapshot.png) ](/images/control_current_snapshot.png)
{{/1.4.0+}}

在这个页面中可以清楚的看到集群的健康状况。如果有问题，绿色的对号会变成红色的错号（`X`），而且会列出问题的原因。每个原因都会链接到其他页面，获取关于该问题的更多信息。

### 集群管理页面

管理面板的右上角是导航条。如果点击“Cluster”，就进入了集群管理页面。

{{#1.4.0-}}
在这个页面中会看到集群中的所有节点，以及各节点的状态、环的使用百分比、内存消耗。还可以修改集群，例如添加节点、删除节点、下线节点。

![Cluster View](/images/control_cluster.png)
{{/1.4.0-}}
{{#1.4.0+}}
在这个页面中会看到集群中的所有节点，以及各节点的状态、环的使用百分比、内存消耗。还可以暂存然后提交对集群的改动，例如添加节点、删除节点、下线节点。

暂存的集群变动：

[ ![Cluster Management Staged](/images/control_cluster_management_staged.png) ](/images/control_cluster_management_staged.png)

变动以提交，正在转移数据：

[ ![Cluster Management Transfers](/images/control_cluster_management_transfers.png) ](/images/control_cluster_management_transfers.png)

改动后集群正在稳定：

[ ![Cluster Management Stable](/images/control_cluster_management_stable.png) ](/images/control_cluster_management_stable.png)

### 节点管理页面

在节点管理页面中可以操作集群中的单个节点。

[ ![Node Management](/images/control_node_management.png) ](/images/control_node_management.png)
{{/1.4.0+}}

### 环页面

比集群页面信息更详细的是环页面。在这个页面可以看到每个虚拟节点的健康状况。

{{#1.4.0-}}
![Ring View](/images/control_ring.png)
{{/1.4.0-}}
{{#1.4.0+}}
[ ![Ring View](/images/control_current_ring.png) ](/images/control_current_ring.png)
{{/1.4.0+}}

大多数时候，环比较多，不便管理，我们可以使用过滤器方便的查看分区所有权、无法访问的主区，已经正在进行的移交操作。
