---
title: 打开文件限制
project: riak
version: 1.4.2+
document: cookbook
toc: true
audience: advanced
keywords: [troubleshooting, os]
---

Riak 的常规操作会消耗很多打开文件句柄。一般来说，Bitcask 后台在有机会运行合并进程之前，会堆积很多数据文件。可以使用下面的命令统计 bitcask 目录下有多少数据文件：

```bash
ls data/bitcask/*/* | wc -l
```

请注意，创建数量众多的数据文件是正常行为。每次启动 Riak，Bitcask 都会为每个分区创建数据文件，一段时间后 Bitcask 会把一系列的数据文件合并成单个文件，避免消耗过多的文件句柄。我们可以不断写入数据再重启 Riak，人为增加 Bitcask 使用的文件句柄量。下面的 shell 命令可以完成这个操作：

```bash
for i in {1..100}
  do
    riak stop
    riak start
    sleep 3
    curl http://localhost:8098/riak/test -X POST -d "x" \
      -H "Content-Type: text/plain"
    ls data/bitcask/*/* | wc -l
done
```

## 修改限制

在大多数操作系统中可以使用 `ulimit -n` 命令修改打开文件限制。例如：

```bash
ulimit -n 65536
```

不过，这个命令只会修改**当前 shell 会话**的限制。全局修改限制的方法，依操作系统而异。

## Linux

大多数 Linux 发型版本中，打开文件的总限制是由 `sysctl` 控制的。

```bash
sysctl fs.file-max
fs.file-max = 50384
```
如你所见，这个值经常要设的比 Riak 需求的高。如果系统上还运行了其他程序，修改这个设置的具体方法请参照  [[sysctl manpage|http://linux.die.net/man/8/sysctl]] 。不过一般需要修改的是针对每个用户的打开文件限制。这需要修改 `/etc/security/limits.conf` 文件，必须是超级用户才能修改。如果是使用安装包安装的 Riak 或 Riak Search ，请按照下面的方式修改，指定所需的硬限制和软限制：

在 Ubuntu 中，如果使用 init 脚本启动 Riak，可以创建 `/etc/default/riak` 文件，然后指定一个限制：

```bash
ulimit -n 65536
```

这个文件会自动引入 init 脚本，使用 init 脚本启动的 Riak 进程会正确的继承这个设置。init 脚本总是以 root 用户运行，所以如果你只使用 init 脚本就无需再在 `/etc/security/limits.conf` 文件中设置限制了。

在 CentOS/RedHat 中，请确保为进行常规操作（包括管理 Riak）的用户设置合适的限制。在 CentOS 中，sudo 会正确继承当前用户的设置。

参考资源：[[http://www.cyberciti.biz/faq/linux-increase-the-maximum-number-of-open-files/]]

### 在 Debian 和 Ubuntu 中启用基于 PAM 的限制

我们可以设置基于 PAM 的限制，这样可以为非 root 用户，例如 riak，指定一个最大的打开文件数量。下面的步骤会为**系统中的所有用户**启用基于 PAM 的限制，并设置软限制和硬限制，最多可打开 *65536* 个文件。

1. 编辑 `/etc/pam.d/common-session`，添加下面这行：

       session    required   pam_limits.so

2. 保存并关闭该文件

3. 编辑 `/etc/security/limits.conf`，添加下面这行：

       *               soft     nofile          65536
       *               hard     nofile          65536

4. 保存并关闭该文件

5. （可选）如果想通过 ssh 访问 Riak 节点，还要修改 `/etc/ssh/sshd_config`，去掉下面这行的注释：

       #UseLogin no

   然后把值修改成 *yes*，如下所示：

       UseLogin yes

6. 重启系统，以便设置生效，执行下面的命令确认新设置是否生效：

       ulimit -a


### 在 CentOS 和 Red Hat 中启用基于 PAM 的限制

1. 编辑 `/etc/security/limits.conf`，添加下面这两行：

       *               soft     nofile          65536
       *               hard     nofile          65536

2. 保存并关闭该文件

3. 重启系统，以便设置生效，执行下面的命令确认新设置是否生效：
       ulimit -a


<div class="note">
<div class="title">注意</div>
在上面的示例中，为系统中所有用户提升了打开文件限制。如果只想修改 riak 用户的限制，可以把上面示例中的两个星号（*）改为 <code>riak</code>。
</div>

## Solaris

在 Solaris 8 中，每个进程默认的限制是 1024 个文件描述符。在 Solaris 9 中，默认的限制增加到了 65536。要在 Solaris 中提升每个进程的限制，请把下面这行加入 `/etc/system`：

```bash
set rlim_fd_max=65536
```

参考资源：[[http://blogs.oracle.com/elving/entry/too_many_open_files]]

## Mac OS X

要查看 Mac OS X 当前的限制，请执行：

```bash
launchctl limit maxfiles
```

输出结果的最后两栏分别是软限制和硬限制。

要想在 OS X 10.7（Lion）或新版中调整打开文件限制的最大值，请编辑 `/etc/launchd.conf`，把软限制和硬限制改为所需的值。

例如，要把软限制改为 16384，硬限制改为 32768，请按照下面的步骤操作：

查看当前的限制：

```bash
launchctl limit

    cpu         unlimited      unlimited
    filesize    unlimited      unlimited
    data        unlimited      unlimited
    stack       8388608        67104768
    core        0              unlimited
    rss         unlimited      unlimited
    memlock     unlimited      unlimited
    maxproc     709            1064
    maxfiles    10240          10240
```

编辑（或新建） `/etc/launchd.conf`，提升相应的限制。添加如下所示的代码（指定适用你的环境的值）：

```bash
limit maxfiles 16384 32768
```

保存文件，然后重启系统，以便新限制生效。重启后，执行 `launchctl limit` 命令验证是否生效：

```bash
launchctl limit

    cpu         unlimited      unlimited
    filesize    unlimited      unlimited
    data        unlimited      unlimited
    stack       8388608        67104768
    core        0              unlimited
    rss         unlimited      unlimited
    memlock     unlimited      unlimited
    maxproc     709            1064
    maxfiles    16384          32768
```
