---
title: 在 Windows Azure 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, windows, azure]
prev: "[[在 SUSE 中安装]]"
up:   "[[安装和升级]]"
next: "[[在 AWS Marketplace 中安装]]"
---

下面介绍如何在 Windows Azure 平台中使用 Centos VM 安装 Riak。

## 创建 CentOS VM

如果要创建虚拟机，必须先注册 Windows Azure Virtual Machines “预览功能”（preview features）。如果还没有 Windows Azure 账户可以注册一个试用账户。

1. 访问 [https://account.windowsazure.com](https://account.windowsazure.com/)，使用你的 Windows Azure 账户登录；

2. 点击“preview features”，查看可用的预览；

    ![](/images/antares-iaas-preview-01.png)

3. 下拉到 Virtual Machines & Virtual Networks，点击“try it now”；

    ![](/images/antares-iaas-preview-02.png)

4. 选择你要订购的合约，然后点击“Check”；

    ![](/images/antares-iaas-preview-04.png)

### 创建运行 CentOS Linux 的虚拟机

1. 使用你的 Windows Azure 账户登录 Windows Azure (Preview) Management Portal；

2. 在 Management Portal 页面的左下角，点击“"+New"”，然后点击“Virtual Machine”，再点击“From Gallery”；

    ![](/images/createvm_small.png)

3. 从 Platform Images 中选择 CentOS 虚拟机镜像，然后点击页面右下角的下一步箭头；

    ![](/images/vmconfiguration0.png)

4. 在 VM Configuration 页面，填写如下信息：
    - Virtual Machine Name（虚拟机名称），例如“testlinuxvm”
    - New User Name（新用户名），例如“newuser”，这个用户会加入拥有 sudo 权限的列表文件中
    - New Password（新密码），输入一个很难破解的密码
    - 在 Confirm Password（密码确认）输入框中再次输入密码
    - 从 SIZE（大小）下拉列表中选择合适的大小
    - 点击下一步箭头继续

    ![](/images/vmconfiguration1.png)

5. 在 VM Mode 页面，填写如下信息：
    - **如果这是第一个节点**，选择“STANDALONE VIRTUAL MACHINE”单选按钮。**否则**，选择“CONNECT TO EXISTING VIRTUAL MACHINE”单选按钮，然后再下拉列表中选择第一个节点
    - 在 DNS Name（DNS 名字）输入框中填写一个可用的 DNS 地址，例如“testlinuxvm”
    - 在 Storage Account（存储账户）下拉列表中，选择“Use Automatically Generated Storage Account”
    - 在 Region/Affinity Group/Virtual Network 下拉列表中选择这个虚拟机要放在那个地区
    - 点击下一步箭头继续

    ![](/images/vmconfiguration2.png)

6. 在 VM Options 页面，在 Availability Set 下拉列表中选择“(none)”。点击对号按钮继续。

    ![](/images/vmconfiguration3.png)

7. 等待 Windows Azure 准备好你的虚拟机。

### 设置端点（endpoint）

创建好虚拟机后，必须设置端点才能远程连接。

1. 在 Management Portal 页面，点击“Virtual Machines”，然后点击新创建的 VM 名字，然后点击“Endpoints”

2. **如果这是第一个节点**，点击“Add Endpoint”，选中“Add Endpoint”，然后点击向右的箭头，在出现的表单中填写如下信息：
    - Name: riak_web
    - Protocol: 不变，TCP
    - Public Port: 8098
    - private Port: 8098

## 通过 PuTTY 或 SSH 连接到 CentOS VM

虚拟机创建好，端点也设置好后，就可以通过 SSH 或 PuTTY 连接了。

### 使用 SSH 连接

**针对 Linux 和 Mac 用户：**

    $ ssh newuser@testlinuxvm.cloudapp.net -o ServerAliveInterval=180

然后输入用户的密码。

**针对 Windows 用户，使用 PuTTY：**

如果你使用的是 Windows 系统，请使用 PuTTY 连接 VM。PuTTY 可以在 [PuTTY 下载页面](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) 下载。

1. 下载 putty.exe，保存到电脑的一个文件夹中。打开命令行，进入这个文件夹，然后执行 putty.exe

2. 填写在 Node's Dashboard 页面 SSH DETAILS  区域看到的信息，例如 Host Name（主机名）为“testlinuxvm.cloudapp.net”，Port（端口）为“22”

    ![](/images/putty.png)

## 使用 shell 脚本设置 CentOS 和 Riak

1. 在每一个节点中，使用上面介绍的方法连上虚拟机之后，执行如下命令

    sudo su -

    curl -s https://raw.github.com/glickbot/riak_on_azure/master/azure_install_riak.sh | sh

**对第一个节点**，注意节点控制台右侧列出的“INTERNAL IP ADDRESS”

**对其他节点**，使用第一个节点的“INTERNAL IP ADDRESS”

执行：

    riak-admin cluster join riak@<ip.of.first.node>

## 搭建 Riak 集群，加载测试数据

所有节点都创建好后，使用上面的方法合并，然后使用 SSH 或 PuTTY 连入其中一个节点，执行下面的命令：

    riak-admin cluster plan

如果对上述命令的输出结果满意，请再执行下面的命令：

    riak-admin cluster commit

使用下面的命令查看集群的状态：

    riak-admin member_status

至此，我们就在 Azure 上搭建了一个 Riak 集群。

### 加载测试数据

在任意一个节点中执行下面的命令：

    curl -s http://rekon.basho.com | sh

访问控制台中显示的 DNS 地址，端口为设置的端点：

    http://testlinuxvm.cloudapp.net:8098/riak/rekon/go

进一步阅读：

- [[Riak API 基本操作|查询基础]]
