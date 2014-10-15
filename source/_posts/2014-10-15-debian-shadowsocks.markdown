---
layout: post
title: "Debian上搭建ShadowSocks服务"
date: 2014-10-15 11:46:04 +0000
comments: true
categories: Debian Linux Proxy ShadowSocks
---

在DigitalOcean上搭建好Droplet后的第一件事就是搭建ShadowSocks服务, 用ShadowSocks翻墙时最受不了的就是服务器失效, 所以最靠谱的就是自己搭建一个

采用ShadowSocks的libev版本, 这个版本的特点是内存占用小(600k左右),使用libev和C编写，低CPU消耗，甚至可以安装在基于OpenWRT的路由器上[^Ref-Shadowsocks-libev]

这篇博客有借鉴价值, 对于Debian、Ubuntu、Arch等意义并不大, 这个发行版都有源

# Install

关于之前提到的三个发行版(Debian, Ubuntu, Arch), Debian和Ubuntu的情况差不多, 不过Ubuntu已经很久不玩了, 也不清楚什么状况, Arch相关的安装配置以后补上

## Debian源的配置

ShadowSocks不在官方源里, 需要额外配置[^Debian_ShadowSocks_yuan]

```bash
>> sudo vim /etc/apt/sources.list
```

按照系统的版本增加源, Debian Wheezy指的是Debian 7

```bash
# Debian Wheezy, Ubuntu 12.04 or any distribution with libssl > 1.0.1
deb http://shadowsocks.org/debian wheezy main

# Debian Squeeze, Ubuntu 11.04, or any distribution with libssl > 0.9.8, but < 1.0.0
deb http://shadowsocks.org/debian squeeze main
```

增加完后更新缓存

```bash
>> sudo apt-get update
```

## Install && Configure && Start Service

> Debian

采用如下命令安装shadowsocks-libev

```bash
>> sudo apt-get install shadowsocks
```

安装完后, 编辑配置文件, 设定监听地址、端口、密码以及加密方式, 然后启动服务

```bash
# Edit the configuration
>> sudo vim /etc/shadowsocks/config.json

# Start the service
>> sudo /etc/init.d/shadowsocks start
```

## 检测

通过如下命令检测服务是否开启

```bash
>> ps -ef | grep ss-server | grep -v ps | grep -v grep
```

也可以检测端口是否被监听来判断

```bash
>> netstat -antl
```

# Configure

## General

配置文件的内容如下

```bash
{
    "server":"my_server_ip",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
```

其中 `server` 是ShadowSocks监听的ip, 一般设置成服务器的公网IP; `server_port` 是ShadowSocks监听的端口, 据说拉低端口号会提高速度, 有一些人比较极端的会设置成443(https的端口); `password` 应该不用说了; `method` ShadooSocks支持很多中加密方式, 有些安全但速度比较慢, 有些不太安全但速度快, 看你怎么选择[^ShadowSocks_Configure]

## IPV4 And IPV6

因为在学校里有IPV6的环境, 方便在没有网络的时候可以采用IPV6来上网

如果把 `server` 设置成服务器的公网IP, 那就只能适用IPV4连接, 如果设置成服务器的IPV6地址, 那就只能IPV6连接, 为此还查了一番, 这个问题比较好解决, 按照这样设置即可 `"server": "::"`

如此设置时的确可以完成同时响应IPV4和IPV6, 但是在查看端口监听的时候只能发现程序监听了IPV6

```bash
>> netstat -antl | grep "server_port"
tcp6       0      0 :::2299                 :::*                    LISTEN
```

## 统计流量

由于我希望同时监听IPV4和IPV6, 而接下来要介绍的方法我不敢保证是否支持这一特性, 同时我也暂时没有时间, 因此没有测试, 仅供参考, 来自于[](http://yzs.me/)的[利用IPTABLES对Shadowsocks统计流量](http://yzs.me/2230.html)

原理: ShadowSocks监听内网地址, 通过iptables的网络转发功能把数据转发到内网地址上来实现

1) 添加一个loop back用的内网IP

```bash
>> ifconfig eth0:ss1 10.10.10.10 netmask 255.255.255.0 up
```

**注意:**

1. 网卡名不是eth0的自己修改

2. 以这种形式增加的内网地址在重启后会失效, 可以修改网卡的配置文件(/etc/network/interfaces或/etc/sysconfig/network-scripts/)添加IP，或者把添加IP的命令加到/etc/rc.local里面

2) 修改ShadowSocks监听的网络, 并重启 `sudo service shadowsocks restart`

```bash
"server":"10.10.10.10",
```

3) 开启系统的IPV4转发功能

```bash
>> sudo vim /etc/sysctl.conf
```

确保 `net.ipv4.ip_forward = 1` 前没有 `#`

如果有修改, 执行 `sudo sysctl -p` 使之生效

4) iptables 设置转发

```bash
>> iptables -t nat -I PREROUTING -p tcp --dport SERVER_PORT -j DNAT --to-destination 10.10.10.10
```

5) 设置统计流量

统计内网地址的入网和出网的流量

```bash
>> iptables -I INPUT -d 10.10.10.10
>> iptables -I OUTPUT -s 10.10.10.10
```

查询流量

```bash
>> iptables -L -n -v
```

**注意:**

这样设置无法清空10.10.10.10的统计数据, 解决办法: 因为加入到FORWARD里面了，不能直接-Z，否则会全部清零，如果要清零单条，最好创建另一个链，把这个记录加入那个链中，再把那个链加入FORWARD中，清零是直接iptables -Z 链名称就行了

[^Ref-Shadowsocks-libev]: 参考自[秋水逸冰](http://teddysun.com/)的[Debian下shadowsocks-libev一键安装脚本](http://teddysun.com/358.html)
[^Debian_ShadowSocks_yuan]: 参考自[ShadowSocks-libev](https://github.com/madeye/shadowsocks-libev)的[Install from repository](https://github.com/madeye/shadowsocks-libev#install-from-repository), 包括两份版本的Debian和Ubuntu的源
[^ShadowSocks_Configure]: 参考自[shadowsocks-libev作者的Github](https://github.com/clowwindy/shadowsocks#configuration), 里面有具体的说明



