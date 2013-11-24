---
title: riak Command Line
project: riak
version: 1.4.2+
document: reference
toc: true
audience: beginner
keywords: [command-line, riak]
---

# 命令行工具 - `riak`

`riak` 是控制 Riak 节点进程的主要脚本。

```bash
Usage: riak { start | stop | restart | reboot | ping | console | attach | chkconfig }
```

## start

启动节点，在后台运行。如果节点已经运行，会看到“Node is already running!”消息。如果节点尚未运行，不会看到任何输出。

```bash
riak start
```

## stop

停止运行节点。如果操作成功会显示“ok”，如果节点之前已经停止了，或者没有响应，则会显示“Node 'riak@127.0.0.1' not responding to pings.”。

```bash
riak stop
```

## restart

在不退出 Erlang VM 的前提下，停止然后再次启动运行着的节点。如果操作成功会显示“ok”，如果节点之前已经停止了，或者没有响应，则会显示“Node 'riak@127.0.0.1' not responding to pings.”。

```bash
riak restart
```

## reboot

退出 Erlang VM，停止然后再启动运行着的节点。如果操作成功会显示“ok”，如果节点之前已经停止了，或者没有响应，则会显示“Node 'riak@127.0.0.1' not responding to pings.”。

```bash
riak reboot
```

## ping

检查 Riak 节点是否正在运行。如果操作成功会显示“pong”，如果节点之前已经停止，或者无响应，则会显示“Node 'riak@127.0.0.1' not responding to pings.”。

```bash
riak ping
```

## console

启动 Riak 节点，在后台运行，可以访问 Erlang shell 和运行时信息。如果节点已经在后台运行，会显示“Node is already running - use 'riak attach' instead”。

```bash
riak console
```

## attach

附加到后台运行的 Riak 节点的控制台上，可以访问 Erlang shell 和运行时信息。如果无法访问节点，会显示“Node is not running!”。

```bash
riak attach
```

## chkconfig

确认 app.config 是否可用。

```bash
riak chkconfig
```
