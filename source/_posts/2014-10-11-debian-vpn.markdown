---
layout: post
title: "Debian上开启VPN(PPTP)服务"
date: 2014-10-11 10:37:11 +0000
comments: true
categories: Debian Linux VPN PPTP
---

有了纽约的服务器貌似必须开启代理模式, 虽然ShadowSocks要比VPN好多了, 但毕竟需要额外的软件或者额外的硬件, 而VPN的客户端却是各种平台上预先搭载的, 因此就有了想搭建VPN的想法, 开动.....

1.First, 安装pptp的服务端

```bash
>> sudo apt-get install pptpd
```

2.Second, 配置在VPN模式下各主机的IP, `localip` 指的是VPN模式下PPTP服务器的IP, `remoteip` 指的是连接到PPTP服务器上的客户端的IP, 通常是一段范围, 编辑文件 `sudo vim /etc/pptpd.conf`, 在文件最后加上类似代码, 具体参数自定

```bash
localip 192.168.92.1
remoteip 192.168.92.11-16
```

3.Third, 编辑PPTP服务器参数, 参照如下参数配置, 编辑文件 `sudo vim /etc/pptpd.conf`

```bash
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
#nodefaultroute
#debug
#dump
proxyarp
lock
nobsdcomp
#nologfd
logfile /var/log/pptpd.log
```

**说明:**

+ name pptpd：pptpd server的名称

+ refuse-pap：拒绝pap身份验证模式

+ refuse-chap：拒绝chap身份验证模式

+ refuse-mschap：拒绝mschap身份验证模式

+ require-mschap-v2：在端点进行连接握手时需要使用微软的mschap-v2进行自身验证

+ require-mppe-128：MPPE 模块使用 128 位加密

+ ms-dns 8.8.8.8：ppp为Windows客户端提供DNS服务器IP地址，第一个ms-dns为DNS Master，第二个为DNS Slave, 此处选用的DNS是Google的

+ proxyarp：建立 ARP 代理键值

+ lock：锁定客户端 PTY 设备文件

+ nobsdcomp：禁用 BSD 压缩模式

+ nologfd：禁止将错误信息记录到标准错误输出设备(stderr)

4.设置用户, 编辑文件 `sudo vim /etc/ppp/chap-secrets`, 增加这样的条目 `username pptpd password *`, 其中 username 和 password 是登录口令, pptpd是服务器上PPTP软件名(默认不动), * 指代接受的IP地址

5.全部搞定后，我们需要重启 pptpd 服务使新配置生效 `sudo /etc/init.d/pptpd restart`

如果这时候尝试连接的话是可以连上的，但是只能访问机器资源，不能上网，想上网的话需要继续配置。

6.配置IPV4的转发

编辑文件 `sudo vim /etc/sysctl.conf`, 修改信息如下

```bash
#net.ipv4.ip_forward=1
net.ipv4.ip_forward=1
```

然后执行 `sudo sysctl –p` 使得修改生效, 看命令执行后的信息反馈中有无 `net.ipv4.ip_forward = 1` 这一条

7.防火墙iptable信息转发

```bash
>> iptables -t nat -A POSTROUTING -s 192.168.9.0/24 -o eth0 -j MASQUERADE
```

8.查看端口是否打开

```bash
>> netstat -antl
```

==============

参考资料:

1. Linux（VPS+Debian）搭建配置VPN（PPTP）服务 http://blog.csdn.net/frymgump/article/details/7346840

2. Debian搭建vpn http://www.cnblogs.com/timeship/archive/2013/03/09/2951184.html
