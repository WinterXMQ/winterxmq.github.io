---
layout: post
title: "BBS的本地测试环境的搭建"
date: 2014-11-04 14:29:56 +0000
comments: true
categories: Linux Apache Discuz
---

本地环境的LAMP环境安装见[ArchLinux上搭建LAMP环境](/blog/2014/10/28/lamp/)

这个地方主要讲bbs的备份和本地还原

# 服务器备份

文档数据的备份

```bash
>> cd /var/www
>> tar czvf sns-data.tar.gz sns/
```

数据库的备份

```bash
>> mysqldump -hHOSTNAME -uUSER -pPASSWORD DATABASENAME > sns-date.sql
>> du -h sns-date.sql       ; 查看文件大小
```

# 本地还原

文档数据还原

```bash
>> rm -rf /srv/http/*
>> tar zxvf sns-date.tar.gz -C /srv/http/sns
```

数据库还原

```bash
>> mysql -uUSER -p
mysql> create database `sns`;
mysql> exit
Bye
>> mysql -uUSER -p sns < sns-date.sql
```

# 本地配置

(1) 虚拟主机配置

以ArchLinux为例, apache是ArchLinux的默认安装

打开配置文件, `sudo vim /etc/httpd/conf/extra/httpd-vhosts.conf`, 做如下修改

```bash
<VirtualHost *:80>
    DocumentRoot "/srv/http/sns"
    ServerName "bbs.winterxq.me"
    <Directory "/srv/http/sns">
        Options Indexes FollowSymLinks
        AllowOverride None
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
```

重启服务, `sudo systemctl restart httpd`

(2) 设置apache和mysql的开机自启

```bash
>> sudo systemctl enable httpd
>> sudo systemctl enable mysqld
```

(3) 设置文件夹所有权

```bash
>> sudo chown -R http:http data/
>> sudo chown -R http:http config/
>> sudo chown -R http:http uc_server/data/
>> sudo chown -R http:http uc_client/data/cache/
```
