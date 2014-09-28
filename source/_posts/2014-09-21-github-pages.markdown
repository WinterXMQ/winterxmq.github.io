---
layout: post
title: "GitHub Pages搭建基于Octopress的Blog"
date: 2014-09-21 13:44:02 +0000
comments: true
categories: Blog Coding
---

把Blog的源码托管在Github上，采用Github的Pages功能来呈现

[TOC]

# 配置git的ssh key

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

# 配置本地的ruby和Jekyll、Octopress环境

Octopress是基于Jekyll的，而Jekyll则是编写而成的，因此我们需要分别搭建这三个环境

## 关于Ruby的安装配置

网上有说需要保持ruby在某个版本上，根据我的测试，采用最新版本的ruby也同样没有问题，估计是早期的Jekyll对高版本的Ruby支持不好
在Arch Linux下采用 `pacman -S ruby` 完成Ruby的安装(默认Ruby已经安装)

Ruby 的官方源在国内的速度不佳，更换成淘宝的Ruby源

```bash
  >> gem sources -a https://ruby.taobao.org/
  >> gem sources --remove https://rubygems.org/
  >> gem sources -l
```
注: 确保只有一条地址

采用 `sudo gem update --system` 更新gem脚本

## 关于Jekyll和Octopress的安装

Jekyll是Octopress的一个依赖，因此不用特意安装Jekyll
确保系统安装有 `Git`, 从Github上获取Octopress官方源码

```bash
  >> cd Code
  >> git clone "git://github.com/imathis/octopress.git" blog
  >> cd blog
```

这个目录就是以后写Blog和发布Blog的工作目录

```bash
 + _deploy		<- 发布在Github上用于站点显示的master(gh-pages)分支
 + public
 + plugins		<- 用于放置Octopress的插件
 + sass			<- 似乎和模板的关系比较密切, 作用未知
 - source		<- 放置站点源码, 包括Blog的Makedown文件
   ...
   + _posts		<- 放置Blog的Makedown文件
 + .themes		<- 放置主题的
 . _config.yml	<- 站点总配置文件
 . Gemfile		<- Octopress安装脚本配置
 . Rakefile		<- Octopress控制脚本
```

Octopress是采用 `bundle` 来完成安装的, `bundle` 会读取当前目录下的 `Gemfile` 来获取本次安装的软件源、以及所需要安装的软件包, `bundle` 会给出一些软件的依赖关系, 并自动安装所依赖的软件
同时 `bundle` 也是Ruby的软件需要通过 `gem install bundler` 来完成安装
然而通过 `gem` 安装的软件会被安装在 `~/.gem/ruby/VERSION_RUBY/`, 需要添加环境变量

```bash
  >> sudo vim /etc/profile
  add follow to the end of the file
	RUBY_HOME=~/.gem/ruby/2.1.0
	PATH=${PATH}:${RUBY_HOME}/bin
	export RUBY_HOME PATH
  >> source /etc/profile
  >> bundle --version
```

此外我们需要把 `Gemfile` 第一行的软件源换成[淘宝Ruby源](https://ruby.taobao.org/) `source 'https://ruby.taobao.org/'`
然后执行 `bundle install`, 并耐性等待(当然采用国内的Ruby源, 安装时间不会太长)

# Blog工作目录与Github的设置

无论是站点源码还是Blog都是采用git来管理, 需要把本地目录和Github做对接, 同时对站点进行最初步的设置

## 与Github对接

```bash
  >> git remote rm origin			# 删除Octopress的远程分支
  >> rake setup_github_pages
    git@github.com:WinterXMQ/winterxmq.github.io.git
```

## 站点初始化设置

安装主题

```bash
  >> git clone git@github.com:shashankmehta/greyshade.git .themes/greyshade
  >> echo "\$greyshade: color;" >> sass/custom/_colors.scss
  >> rake "install[greyshade]"
```

生成站点数据

```bash
  >> rake generate
```
注: 在Jekyll编译的时候会出现错误, 提示没有Javascript的解释器, 这里有两三个解决方案, 我采用的是安装nodejs, 采用 `sudo pacman -S nodejs` 完成安装

通过 4000 端口在本地预览Blog站点, http://127.0.0.1:400

```bash
  >> rake preview
```

## 上传源码

把源码上传到Github的同个工程的source分支下

```bash
  >> git add .
  >> git commit -m "Init Octopress"
  >> git push origin source
```

# 注意点

## zsh引起无法新建Blog的问题

解决在zsh下无法新建Blog的问题, 具体见参考文档5

```bash
  >> rake new_post["arch-linux-reinstall-glibc.markdown"]
  zsh: no matches found: new_post[arch-linux-reinstall-glibc]
```

原因: zsh中若出现 '*', '(', '|', '<', '[', or '?' 符号, 则将其识别为查找文件名的通配符
解决办法:
+ rake "new_post[arch-linux-reinstall-glibc.markdown]"
+ rake new_post
+ vim .zshrc  添加 alias rake="noglob rake"


# 参考文档
> 1. http://blog.csdn.net/binyao02123202/article/details/20130891
> 2. http://blog.cnyingchao.com/website/disqus-simplified-chinese.html
> 3. http://xuhehuan.com/783.html
> 4. http://minejo.github.io/blog/2013/08/09/shi-yong-github-plus-octopresszuo-blog/
> 5. http://fancyoung.com/blog/use-octopress-new-post-function-with-zsh/
