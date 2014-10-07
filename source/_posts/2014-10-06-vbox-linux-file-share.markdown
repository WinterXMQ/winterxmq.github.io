---
layout: post
title: "VBox下Linux与主机Windows的文件共享"
date: 2014-10-06 06:36:11 +0000
comments: true
categories: VBox Linux System
---

本文的方法参考自[jakiechen][Blog_jakiechen_VBox-Linux-FileShare], 有什么不对的地方请大家指点。

适用对象: VBox下 子系统为Linux, 安装了增强工具包(virtualbox-guest-utils in Arch Linux)

1. VBox 下设置共享文件夹

在VBox下设置一个共享文件夹, 菜单栏 -> 设备 -> 共享文件夹, 在 '共享文件夹列表' 下增加一个固定分配。

选择共享文件夹, 设置共享文件夹名称(不要含中文或者其他方块字)。

**注意:** 1. 要记住共享文件夹的名字, 不要随意变更, 这个和Linux中的设置有关, 2. 不要选择 `Auto-mount` 即自动挂载[^Blog_jakiechen_AutoMount]

{% img center /p/pic/file_share_1.png 增加共享文件夹 %}

{% img center /p/pic/file_share_2.png 增加共享文件夹列表 %}

2. Linux 下挂载

创建文件夹 `mkdir -p /mnt/share`

挂载共享文件夹 `sudo mount -t vboxsf Tex /mnt/share`

然后就可以在 `/mnt/share` 下看到恭喜文件夹里的内容了

*为了方便管理, 我把这个文件夹软连接到我的工作文件夹下了, `ln -s /mnt/share ~/Code/tex`*

3. 设置自动挂载

为了方便使用, 将其设置成自动挂载

```bash
>> sudo vim /etc/fstab
Add following
# VBox share file
Tex     /mnt/share  vboxsf  rw,gid=100,uid=1000,auto    0 0
```

[Blog_jakiechen_VBox-Linux-FileShare]: http://blog.csdn.net/jakiechen68/article/details/7263023 "Blog_VBox-Linux 文件共享"

[^Blog_jakiechen_AutoMount]: 参考自jakiechen, 上面说在下次重启后会出现由于共享文件夹为空而挂载失败, 出现的错误提示为: /sbin/mount.vboxsf: mounting failed with the error: Invalid argument
