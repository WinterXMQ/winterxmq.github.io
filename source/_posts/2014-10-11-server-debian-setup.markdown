---
layout: post
title: "DigitalOcean上成功搭建Debian服务器"
date: 2014-10-11 08:56:17 +0000
comments: true
categories: Debian Linux DigitalOcean
---

由于[Github][Github_Education]做活动, 赠送了很多关于网站和其他的服务, 其中就包括[DigitalOcean][Official_DigitalOcean]的$100的优惠, 又来, 你知道的。

# Create Droplet

在DigitalOcean上创建很简单, 把从Github上拿到的优惠码兑现也很简单, 因此就不再提了, 唯独要注意的是, DigitalOcean要用信用卡激活帐号(没有信用卡的用户, 比如我, 就得用PayPal向DigitalOcean充值至少$5, 貌似是要你向官方说明你有能力支付服务器产生的费用, 鬼知道是什么用意, 反正我花了￥30激活了帐号)

创建了服务器的过程也没什么好说(只要你有点脑子), 要说的只是几个注意点:

第一点就是关于 droplet setting, 见下图

![Droplet Setting](https://assets.digitalocean.com/articles/droplet/settings.png "Droplet Setting")

其中勾上Private Networking, 和 IPV6, 如果你想用数据备份服务可以选上Enbale Backups, 其中Enable User Data是只为CoreOS提供的[^Create_First_Droplet]

第二点就是当服务器创建完毕时, 你会收到一个邮件, 上面有服务器地址和登录口令

# Configurea Droplet

首先修改ssh的默认端口

其实登录后发现bash实在让人忍不了, 就先装了一个zsh, `apt-get install zsh` and `usermod -s /usr/bin/zsh root` then `nano ~/.zshrc`, 然后把自己的zshrc的内容放进去, Logout and Login(其实是exit and ssh), 然后就没有然后了, 可以正式开始了。

在修改ssh的配置文件的时候, 又没法忍受只有vi的服务器, 然后 `apt-get install vim`

正式开始, 修改配置文件 `vim /etc/ssh/sshd_config`

修改其中的 `Port 22`, 改成其他端口(要牢记)

重启ssh server, `service ssh restart`

以后在登录服务器的时要额外说明端口 `ssh username@ServerAdresss -p Port`

然后配置iptable/防火墙策略, 艹, 貌似防火墙就没有开启, 以后再搞。

增加普通用户

```bash
>> useradd -m -g users -G video,audio -s /usr/bin/zsh username
>> usermod -a -G video,audio,lp,games,users username
>> passwd username
```

在新建用户的时候, 又发现比较奇葩的现象, 系统里面没有`log wheel optical scanner storage power network`这些group

这不是重点, 重点是分配权限

```bash
>> chmod 640 /etc/sudoers
>> vim /etc/sudoers
```

找到 `root    ALL=(ALL:ALL) ALL` 在下面增加一条 `username     ALL=(ALL:ALL) ALL`

```bash
>> chmod 440 /etc/sudoers
```

然后, 然后就以后在说吧。

[Github_Education]: https://education.github.com/pack "Github 学生优惠"
[Official_DigitalOcean]: https://cloud.digitalocean.com/ "DigitalOcean 云服务器"
[^Create_First_Droplet]: 参考自DigitalOcean的官方社区, 详细信息参见[Etel Sverdlov的帖子](https://www.digitalocean.com/community/tutorials/how-to-create-your-first-digitalocean-droplet-virtual-server)
