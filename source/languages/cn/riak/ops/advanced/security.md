---
title: Security and Firewalls
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [troubleshooting, security]
---

本文介绍为 Riak 集群做安全防护时采用的标准设置和端口设置。

对 Riak 来说，有两种访问控制：

* 集群中的其他节点
* 和 Riak 集群通信的客户端

这两种访问控制的设置都在 `app.config` 中。所有针对客户端的访问设置
都以 *ip* 和 *port* 结尾，例如 `web_ip`、`web_port`、`pb_ip` 和 `pb_port`。

设置防火墙，允许通过这些端口或 IP 地址和端口对进入的 TCP 连接。不过，
`handoff_ip` 和 `handoff_port` 例外。这两个设置针对 Riak 节点之间的通信。

大多数节点之间的通信都是用 Erlang 的分发机制。Riak 使用 Erlang 标示符识别环中其他的电脑
（`<hostname or IP>`，例如 `riak@10.9.8.7`）。Erlang 使
用 Erlang Port Mapper daemon（epmd）解析连接到 TCP 端口的节点标示符。

默认情况下，epmd 绑定到 TCP 的 4369 端口，监听这个通配符接口。节点之间通信时，Erlang 使用
一个随机的端口。绑定到端口 0，也就意味着使用第一个可以使用的端口。

为了便于设置防火墙，可以在 `app.config` 中设置 Erlang 解释器使用特定范围内的端口。例如，
要把范围设定在 6000-7999 之间，请把下面的设置添加到每个 Riak 节点的 `app.config` 文件中：

```erlang
{ kernel, [
            {inet_dist_listen_min, 6000},
            {inet_dist_listen_max, 7999}
          ]},
```

上面的代码应该加入到 `app.config` 中的顶级设置中，和其他设置同一等级（例如 **riak\_core**）。

然后设置防火墙，允许任何包含 Riak 节点的网络通过 TCP 端口 6000 到 7999 进入的连接。


**集群中的 Riak 节点要能自由的通过下面的端口和其他节点通信：**

* epmd 监听器：TCP:4369
* handoff_port 监听器：TCP:8099
* `app.config` 中设置的端口范围

**Riak 客户端要能通过下面的端口至少和集群中的一个电脑通信：**

* web_port: TCP:8098
* pb_port: TCP:8087

<div class="info">
<div class="title">重要说明</div>
即便节点上所有的 Erlang 解释器都退出了，epmd 进程还是会继续运行。如果在 <tt>app.config</tt> 中加入了 <tt>inet_dist_listen_min</tt> 和 <tt>inet_dist_listen_max</tt>，epmd 就会终止运行，加载新设置。
</div>


---

# Riak 安全社区

## Riak

Riak 是一个强大的开源分布式数据库，关注可与遇见及简单地扩放，即使有服务器宕机、网络隔断等的影响，仍能提供高可用性。

## 承诺

数据安全对很多用户来说是一个重要且敏感的问题。从实践中得到的经验让我们在开发快速、可扩放和操作简便的数据库时兼顾安全问题。

### 持续改进

虽然我们尽力避免安全漏洞（也通过第三方观察机构），但程序总是不完美的。我们不会标称 Riak 是
100% 安全的（你应该深度怀疑那些声称绝对安全的解决方案）。但我们能保证我们接受社区反馈的漏洞，
如果确实存在，会尝遍所有方法修正。

### 权衡

更多的安全层级会给操作和管理代码不便。有时这些不便很易解决，而有时则不然。我们采取的方式是，
在精力、财力和安全之间适当平衡。

例如，Riak 没有使用基于用户角色的安全管理。虽然这可以在数据库对比时给 Riak 增光添彩，但更多
时候从应用程序或服务层控制对数据的访问更好。

### 提醒 Basho

如果你发现了一个潜在安全问题，请发邮件给我们：security@basho.com，会在 48 小时内答复。

我们期望你们能先联系我们，这样我们就不要在网上搜索了。这样我们就能和安全社区讨论如何在不给
用户带来危险的情况下找到解决问题的方法。

对于敏感话题，可以发送加密消息。安全团队的 GPG 密匙是：

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.12 (Darwin)

mQENBFAQM40BCADGjCmwn9Q9xpWfJ4HpKGwt5kGyf4Oq4PglC28MhtscT9cGwtJv
gRK1ckzkwhCdw6uQKRN3o3iVFHFp+uD8G28zs1fGNfpUZls7WV29WyxfIgB3f01Q
Ll6tiZ2fLG69lSlLTPn7JlzZz1sRVrAKdwUVEYRKCidF0bqaztBCkKbcNAmIvV1E
TboEGMPLXqOnK2134NP+tp0B15oNwSQd9jmOrClvhCF5NR4ATQguS5ecp05/GldZ
8vQQ1XOBc2uiuWpzvhD2CAXQ/Spxir8JjbqpzjPo6d4yte7pYvx6wfnJ9b2KC+sn
AtdqqQslZ3saceXAFXFOIGk7NOq8LSattmRbABEBAAG0GkJhc2hvIDxzZWN1cml0
eUBiYXNoby5jb20+iQE4BBMBAgAiBQJQEDONAhsDBgsJCAcDAgYVCAIJCgsEFgID
AQIeAQIXgAAKCRDEq056TdGVhHl7B/9rXnzZOdC7M8NN+BAEO8kucw0dXGhgcahs
zS81WDRpRJD1fi+QBinfohGg2phIq5TlrXNmduFwCpvyujNkeiCr+Nh00mp6SdU2
m7XFzfPIz3ZWR0YNdvruaf0W5K6jAaHcJkkc3Xwpgk6rxTcNwWUqYRGD7zie4Iad
At0WLJXMUvJH2XoMf8MGO5mHspkqC5M/HvNvH3ZG5CldIHPqgZdg4NXMcGtFAr8z
72wFamick31oCpJyWq+AloOxh3mJpfhp94EBrc/lGbbOD/Sg4oyT+B/4Ee0zWqN5
hDBefi3FCyjo2NuhM1YyRrrvWe7Kwaj8iuItYPIpEwGUqEJzZ7kYuQENBFAQM40B
CAC4J0Pb1WXjGpsQnfOdzZUq57x63RaVA74IIuLSU7v//04wNgNGiLdMbz4isr6K
5NfXTu0i+GqQdcj7UnajwxYCUEnXYpKQBLfT82tTgdw/DPXYgSnxIC02POrwCnhr
wSDbUryuTdbZFS13HPrQPdOXZlmG8oHOgu04a9vPUlkshYmUZm+zRY2FIuW8fJ44
ysJBm49hxkF9WuyGnNiU8UJEvw0sS63x4EUkYdJXLzzdC9T8/t8HGV3aKFEZ3km0
GgYUlt04FdWtFjYcMQnrhJSf7atxwQLpfH78sFCyEH+PFIRfnkirVx9TbN0QSw/z
VaRNxJQde2SHfEft66mf0RJ5ABEBAAGJAR8EGAECAAkFAlAQM40CGwwACgkQxKtO
ek3RlYRPFwf+LiHlf9tCqRLwmI2X8bBmoQTV/Eb4pbPF/1WR6W/afAMp4ZiLpWtn
XeZ9UNdnQDPJIMPhaWrPHB4oLCnDBm1m6wq6FVjHcDur+s7QtWnnTuaVKBDKY42T
NkFj+WP3ZBsfDBtt49KRLm0bWqzkhK7IA+1DMKRmTUhf0tIeLb0um0hL+mXNucrE
dMk+Fdh/54IfHMMw3GwtNd+ZMLf8cht+z3Z0Y0qONe0ClfkiligYItD+P5tufhew
HtU5clY0rP8W/Nr7tC+ZGH2bjT1bmN1E9IM4wjBdyWGTosvY6ciIxuY5p5Iy/UhB
7Xk9zl4ZkKcsVnuscYQPNE2jb393XAhFEg==
=1KRp
-----END PGP PUBLIC KEY BLOCK-----
```

## 安全最佳实践

### 网络设置

作为一个分布式数据库，意味着 Riak 的安全和设置网络的方式有很大关系。我们有一些推荐的设置，
请参照 [[Security and Firewalls]] 一文。

### 客户端验证

很多 Riak 驱动都支持 HTTP 基本验证，不过这不是一个基于用户角色的安全方案。
或许你希望使用 HTTPS 或者通过 VPN 进行连接。

### 在多个数据中心存储副本
Multi Data Center Replication

对于支持在多个数据中心（MDC）存储副本的 Riak 版本，可以设置 Riak 1.2+ 使用 SSL 通信，无缝加密传输的信息。

*暂无链接，等待 EDS 文档发布*
