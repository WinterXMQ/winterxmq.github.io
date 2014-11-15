---
layout: post
title: "Linux上建立GIT服务器"
date: 2014-11-13 15:37:28 +0000
comments: true
categories: Linux GIT
---

建立GIT私有服务器

# 取得客户端公钥

在客户端上生成SSH key

```bash
>> ssh-keygen -t rsa -C "your_email@example.com"
```

把公钥复制到粘贴板

```bash
>> clip < ~/.ssh/id_rsa.pub   ; Windows 上
>> echo ~/.ssh/id_rsa.pub     ; Linux 上
```

或者把公钥上传到Git服务器的`/tmp`目录下

```bash
>> scp .ssh/id_rsa.pub user@<host>:/tmp
```

# 配置服务器

(1) 配置用户, 一般意义上而言, git用户是默认创建的, 如果没有就按照如下创建, 并给git用户指定密码, 以方便进入git用户配置

```bash
>> sudo adduser -d /home/git -G httpd,users -m git
>> passwd git
```

(2) 配置用户默认目录

```bash
>> sudo usermod -d /home/git git
>> sudo mkdir -p /home/git
>> sudo chown -R git:users /home/git
>> sudo chmod -R 700 /home/git
```

(3) 切换到git用户, 配置公钥

```bash
>> su git
>> mkdir .ssh
>> cat /tmp/id_rsa.pub >> .ssh/authorized_keys
```

# 创建库

(1) 创建库文件夹

```bash
>> mkdir -p INC/sns
>> chown -R git:users INC
```

(2) git 初始化

```bash
>> cd INC/sns
>> git --bare init
```

# 客户端配置

建立本地库

```bash
>> mkdir p && cd p
>> git init
>> touch README
>> git add .                                        ; 加入提交等待列表
>> git cimmit -m "Init the project"                 ; 本地提交数据
>> git remote add origin git@<host>:INC/sns         ; 增加远程分支
>> git push origin master                           ; 推送数据
>> git brach --set-upstream-to=origin/master master ; 跟踪分支
```

# 问题

(1) 在推送的过程中出现如下问题

```bash
Permissions 0644 for ‘/root/.ssh/id_rsa’ are too open
```

需要把 `.ssh/id_rsa` 的权限降到 0600

```bash
>> chmod 600 ~/.ssh/id_rsa
```

(2) 在CyWin中, 无论怎么使用上一条命令都无法修改`.ssh/id_rsa`的权限到0600,其原因是CyWin中的文件属性中没有group属性, 全为None, 因此做如下修改

```bash
>> chown -R ming:users ~/.ssh/
```

(3) 无论怎么配置都只能使用密码登录, 会出现 `Permission denied (publickey..)` 的错误, 其原因是权限问题, 按如下权限修改

服务器上

```bash
/home/git                       0700
/home/git/.ssh                  0755
/home/git/.ssh/authorized_keys  0600
```

本机上

```bash
/home/users/.ssh/id_rsa.pub     0600
```

(*) 如果已经配置了git用户, 则需要配置默认shell, 以防止git用户登陆计算机

```bash
>> sudo usermod -s /usr/bin/git-shell git
```

(**) 如果希望增加 http 或者 https 协议的 Git 服务器, 参考[Apache上搭建git服务器](http://www.cnblogs.com/dudu/archive/2012/12/09/linux-apache-git.html)

# 参考

> [1] [密钥不识别, 无法登陆](http://www.cppblog.com/gezidan/archive/2011/08/19/153826.html)

> [2] [CygWin上无法修改权限](http://www.th7.cn/system/win/201311/46849.shtml)

> [3] [安装指导](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/00137583770360579bc4b458f044ce7afed3df579123eca000)

> [4] [公钥无法登陆](http://keben1983.blog.163.com/blog/static/143638081201242511182844/)
