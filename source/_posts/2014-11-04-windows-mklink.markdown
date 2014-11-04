---
layout: post
title: "Windows下的硬链接、软连接和快捷方式"
date: 2014-11-04 11:21:09 +0000
comments: true
categories: System Windows cmd
---

很久以前记得Windows下是没有硬链接、软连接这个功能的, 前段时间, 在关注Windows的WinSxS的时候, 有篇文章提到硬链接时才去查阅后才发现Windows支持这个特性了

在一些相关的资料中表明, Windows的这项特性其实很早就存在了, 只是不为别人所知, 在Win7的WinSxS中应用了这个技术, 使得我们以为这个是个新技术, 其实在XP中以及支持这一特性了

> **注意点:**

>   (1) Windows的链接技术只支持NTFS文件系统

>   (2) 硬链接不能跨卷, 简单的说不能把C盘的文件链接到D盘

>   (3) 软链接和符号链接不能跨磁盘

# 三种文件夹的异同

主要关注 `硬链接` 和 `软连接`

1) Symbolic Link(符号链接)

+ 图标与快捷方式很像
+ 在系统中不占用空间
+ 在文件系统中不是独立文件
+ 在操作系统层解析
+ 源文件丢失, 链接失效
+ 两者互不影响

2) Hard Link(硬链接)

+ 占用同一个空间, 引用同一个对象(不是拷贝)
+ 在操作系统层解析
+ 移除硬链接, 源文件不受影响
+ 源文件移除, 硬链接不受影响
+ 两者修改的是同一份文件

3) Shortcut(快捷方式)

# Windows XP 下的实现

文件硬链接的实现

```bash
>> fsutil hardlink create newFileName fileName

```

文件夹的硬链接实现, 通过 `junction.exe` 来实现, 具体程序网上下载

```bash
>> junction.exe Link Target     // 创建硬链接
>> junction.exe target /d       // 删除文件夹
```

**注意:**

 1) 创建文件夹硬连接, 这个可以跨分区

 2) 删除硬链接必须使用 `junction 文件夹连接名 /d`, 否则会删掉源文件


# Vista, Windows 7及以上版本下的实现

使用 `mklink` 来实现, 功能比 `fsutil` 强多了


```bash
>> mklink
MKLINK [[/D] | [/H] | [/J]] Link Target

        /D      Creates a directory symbolic link.  Default is a file
                symbolic link.
        /H      Creates a hard link instead of a symbolic link.
        /J      Creates a Directory Junction.
        Link    specifies the new symbolic link name.
        Target  specifies the path (relative or absolute) that the new link
                refers to.
```

简单的说:

+ /D 创建目录符号链接, 默认为文件符号链接
+ /H 创建硬链接
+ /J 创建目录联接

# 第三方工具 Link Shell Extension

在Windows下点击操作完成文件夹链接的工具[Link Shell Extension][Url-Link-Shell]

这个工具对文件夹可以完成以下7个功能: 1) Symbolic Link 2) Junction 3) Smart Copy 4) Smart Mirror 5) DeLorean Copy 6) Hardlink Clone 7) Symbolic Link Clone

每个功能的具体看这个工具的官网说明

[Url-Link-Shell]: "http://www.schina.priv.at/nt/hardlinkshellext/hardlinkshellext.html" "Link Shell Extension 官网"

# 参考

1) http://www.cnblogs.com/heqichang/archive/2012/04/26/241774.html

2) http://chenkegarfield.blog.163.com/blog/static/62330008201231153049164/

3) http://blog.csdn.net/wzy0623/article/details/3596572

4) http://www.cnblogs.com/plusium/archive/2010/03/17/1688511.html
