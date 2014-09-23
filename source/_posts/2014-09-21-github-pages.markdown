---
layout: post
title: "GitHub Pages"
date: 2014-09-21 13:44:02 +0000
comments: true
categories: Blog Coding
---

# 用GitHub Pages来构建基于Octopress的Blog系统

把Blog的源码托管在Github上，采用Github的Pages功能来呈现

[TOC]

## 配置git的ssh key

``` bash
  >> ssh-keygen -t rsa -C "WinterXMQ@google.com"
  >> clip < ~/.ssh/id_rsa.pub
```

在执行 `ssh-keygen` 后需要输入 `passphrase`
执行完两个命令后ssh的公钥就已经在系统的粘贴板上了，然后登陆Github的设置->添加ssh公钥上完成相关的添加
接着按照下面的指令完成相关的测试

```bash
  >> ssh -T git@github.com
```

当出现如下的提示，则说明配置成功

```bash
Enter passphrase for key '/home/xmq/.ssh/id_rsa': 
Hi WinterXMQ! You've successfully authenticated, but GitHub does not provide shell access.
```

