---
title: Load Balancing and Proxy Configuration
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [operator, proxy]
---

生产环境中推荐使用的最佳实践是把 Riak 放在负载平衡系统或代理之后，这个系统可以是硬件也可以
是软件，总之不要直接把 Riak 暴漏给公开的网络接口。

Riak 用户反馈，在很多负载平衡和代理系统中成功使用了 Riak。常见的方法有，使用专有的硬件负载
平衡系统，基于云存储的负载平衡（例如 Amazon 的 Elastic），以及开源的软件，
例如 HAProxy 和 Nginx。

本文简单介绍了常用的开源软件 HAProxy 和 Nginx，以及从社区用户和 Basho 的工程师那里收集
的设置和操作上的小贴士。

本文不会深入讨论，知识做个入门说明，介绍如何选择适合自己的解决方案。

## HAProxy

[HAProxy](http://haproxy.1wt.eu/) 是个快速且可靠的开源软件，可以警醒负载平衡及
代理 HTTP 和 TCP 流量。

很多用户都说，他们成功的在 Riak 中使用了 HAProxy。这里介绍的示例设置来社区用户的经验，
外加 Basho 工程师的建议。

### 设置示例

下面的例子说明了如何在一个有 4 个节点的集群中使用 HAProxy 做负载平衡，以便客户端
从 Protocol Buffers 和 HTTP 接口访问 Riak。

<div class="info">
这个例子要求系统的打开文件限制大于 256000。
请阅读 [[Open Files Limit]] 了解如何在各种系统上修改这个限制值。
</div>

```
global
        log 127.0.0.1     local0
        log 127.0.0.1     local1 notice
        maxconn           256000
        chroot            /var/lib/haproxy
        user              haproxy
        group             haproxy
        spread-checks     5
        daemon
        quiet

defaults
        log               global
        option            dontlognull
        option            redispatch
        option            allbackups
        maxconn           256000
        timeout connect   5000

backend riak_rest_backend
       mode               http
       balance            roundrobin
       option             httpchk GET /ping
       option             httplog
       server riak1 riak1.<FQDN>:8098 weight 1 maxconn 1024  check
       server riak2 riak2.<FQDN>:8098 weight 1 maxconn 1024  check
       server riak3 riak3.<FQDN>:8098 weight 1 maxconn 1024  check
       server riak4 riak4.<FQDN>:8098 weight 1 maxconn 1024  check

frontend riak_rest
       bind               127.0.0.1:8098
       mode               http
       option             contstats
       default_backend    riak_rest_backend


backend riak_protocol_buffer_backend
       balance            leastconn
       mode               tcp
       option             tcpka
       option             srvtcpka
       server riak1 riak1.<FQDN>:8087 weight 1 maxconn 1024  check
       server riak2 riak2.<FQDN>:8087 weight 1 maxconn 1024  check
       server riak3 riak3.<FQDN>:8087 weight 1 maxconn 1024  check
       server riak4 riak4.<FQDN>:8087 weight 1 maxconn 1024  check


frontend riak_protocol_buffer
       bind               127.0.0.1:8087
       mode               tcp
       option             tcplog
       option             contstats
       mode               tcp
       option             tcpka
       option             srvtcpka
       default_backend    riak_protocol_buffer_backend
```

注意，上面的示例只是一个初始设置，基于[这个例子](https://gist.github.com/1507077)。
你应该仔细的检查设置，根据自己的环境适当修改。

### 使用 HAProxy 维护节点

在 Riak 中使用 HAProxy 后，可以通过 HAProxy 向集群中的每个节点发送 Ping 请求，如果
没有得到响应就自动把对应的节点删除。

还可以在 HAProxy 中做个循环设置，应用程序连接失败后等待一段时间再尝试连接，这样就能通过不断
重试连接到一个可用的节点。

HAPproxy 还有一个静止系统，在请求完成后从循环中删除节点。当然，还可以在 HAProxy 的命令行
中检查状态 socket，使用工具直接删除节点，例如 [socat](http://www.dest-unreach.org/socat/)：

    echo "disable server <backend>/<riak_node>" | socat stdio /etc/haproxy/haproxysock

此时，可以维护节点，下线节点等。等这些操作完成后，节点就可以重新上线，接受请求：

    echo "enable server <backend>/<riak_node>" | socat stdio /etc/haproxy/haproxysock

请阅读下面的文档，查看如何在你所用的环境中设置 HAProxy：

* [HAProxy 文档](http://code.google.com/p/haproxy-docs/w/list)
* [HAProxy 架构](http://haproxy.1wt.eu/download/1.2/doc/architecture.txt)

## Nginx

有些用户报告说，成功的在 Riak 集群中使用了 [Nginx](http://nginx.org/) 这个 HTTP 服务器
代理请求。下面的例子只介绍了如何通过 GET 请求访问 Riak 集群。

### 设置示例

下面是个初始设置，可以把 Nginx 作为有 5 个节点集群的前端代理。

这个例子转发了所有发到 Riak 节点上的 GET 请求，并拒绝其他类型的请求。

<div class="note">
<div class="title">注意 Nginx 的版本</div>
这里例子证实在 <strong>Nginx 1.2.3</strong> 上可用。注意，较早的版本
不支持 HTTP 1.1 和后端进行的上游通讯。因此在使用之前要仔细检查这些设置，并根据所用环境
做适当修改。
</div>

```
upstream riak_hosts {
  # server  10.0.1.10:8098;
  # server  10.0.1.11:8098;
  # server  10.0.1.12:8098;
  # server  10.0.1.13:8098;
  # server  10.0.1.14:8098;
}

server {
  listen   80;
  server_name  _;
  access_log  /var/log/nginx/riak.access.log;

  # your standard Nginx config for your site here...
  location / {
    root /var/www/nginx-default;
  }

  # Expose the /riak endpoint and allow queries for keys only
  location /riak/ {
      proxy_set_header Host $host;
      proxy_redirect off;

      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;

      proxy_buffer_size          64k;  # If set to a smaller value,
                                       # nginx can complain with an
                                       # "too large headers" error
      proxy_buffers              4 64k;
      proxy_busy_buffers_size    64k;
      proxy_temp_file_write_size 64k;

    if ($request_method != GET) {
      return 405;
    }

    # Disallow any link with the map/reduce query format "bucket,tag,_"
    if ($uri ~ "/riak/[^/]*/[^/]*/[^,]+,[^,]+," ) {
      return 405;
    }

    if ($request_method = GET) {
      proxy_pass http://riak_hosts;
    }
  }
}
```

<div class="note">
<div class="title">注意</div>
虽然这个例子中过滤并限制只能处理 GET 请求，你应该使用 Nginx 之外的系统做其他的访问限制，
例如使用防火墙限制入站连接只接受可信源。
</div>

### 通过 HTTP 执行二级索引查询

通过 HTTP 访问 Riak 及发起二级索引查询时，可能会遇到一个问题，这个问题的原因在于 Nginx 对
包含下划线的报头的处理方式。

默认情况下，Nginx 会对这种查询报错，不过可以在通过 HTTP 执行二级索引查询时让 Nginx 处理
这种报头名，把下面的设置加入 `nginx.conf` 文件的 `server` 区即可：

```
underscores_in_headers on;
```
