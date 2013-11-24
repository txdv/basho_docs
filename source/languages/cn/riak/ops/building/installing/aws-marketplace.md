---
title: 在 AWS Marketplace 中安装
project: riak
version: 1.4.2+
document: tutorial
audience: beginner
keywords: [tutorial, installing, AWS, marketplace, amazon]
prev: "[[在 Windows Azure 中安装]]"
up:   "[[安装和升级]]"
next: "[[从源码安装 Riak]]"
---

## 在 AWS Marketplace 上运行 Riak VM

要想在 AWS Marketplace 上运行 Riak 虚拟机，先要注册 [Amazon Web Services](http://aws.amazon.com) 账户。

1. 访问 [https://aws.amazon.com/marketplace/](https://aws.amazon.com/marketplace/)，使用你的 Amazon Web Services 账户登录

2. 在“Databases & Caching”分类中找到 Riak，或者在任意页面搜索 Riak

3. 选择想使用的 AWS 地区，EC2 实例类型，防火墙设置和配对密钥

    ![AWS Marketplace Instance Settings](/images/aws-marketplace-settings.png)

4. 点击“Accept Terms and Launch with 1-Click”按钮

### 安全组设置

虚拟机创建好后，应该确保为 Riak 正确地设置了所选的 EC2 安全组。

1. 在 AWS EC2 Management Console 中，点击“Security Groups”，然后点击 Riak VM 的安全组名字

2. 在下部的面板中点击“Inbound”选项卡。安全组应该包含如下的打开端口：
    - 22 (SSH)
    - 8087 (Riak Protocol Buffers Interface)
    - 8098 (Riak HTTP Interface)

3. 你必须为这个安全组添加额外的规则，运行和 Riak 实例通信。为下面列出的每个端口范围创建一个新“Custom TCP rule”，把源设为安全组的 ID（可以在“Details”选项卡中找到）。
    - Port range: 4369
    - Port range: 6000-7999
    - Port range: 8099

4. 完成后，安装在应该包含下面列出的所有规则。如果落下的某个规则，在页面下部的面板中添加，然后点击“Apply Rule Changes”按钮

    ![EC2 Security Group Settings](/images/aws-marketplace-security-group.png)

更多内容参见“[[安全和防火墙]]”一文。

## 在 AWS 上搭建 Riak 集群

要搭建集群至少要有 3 个实例。实例准备好，安全组也设置好后，可以使用 SSH 或 PuTTY 以用户 ec2-user 的角色连接集群。

连接实例的更多信息可以在 [Amazon EC2 官方的实例指南](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/AccessingInstances.html)中查看。

<div class="note">下面搭建集群的过程，除非在 Amazon VPC 上部署，否则实例重启后就会失效。</div>

1. 在第一个节点中获得内部 IP 地址：

    ```text
    curl http://169.254.169.254/latest/meta-data/local-ipv4
    ```

2. 其他的节点，使用第一个节点的内部 IP 地址即可：

    ```text
    sudo riak-admin cluster join riak@<ip.of.first.node>
    ```

3. 加入所有的节点后，执行下面的命令：

    ```text
    sudo riak-admin cluster plan
    ```

    如果对上述命令的输出结果满意，请再执行下面的命令：

    ```text
    sudo riak-admin cluster commit
    ```

    使用下面的命令查看集群的状态：

    ```text
    sudo riak-admin member_status
    ```

至此，我们就在 AWS 上搭建了一个 Riak 集群。

进一步阅读：

- [[Riak API 基本操作|查询基础]]
