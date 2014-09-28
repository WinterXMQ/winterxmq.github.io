---
layout: post
title: "Octopress特性设置-新建Blog脚本功能定制"
date: 2014-09-28 12:52:34 +0000
comments: true
categories: Blog Octopress Rake
---

# 新建Blog并自动使用vim打开新建文档

在使用 `rake new_post` 或者 `rake new_post['title']` 后, 需要手动打开新建的Makedown文件, 太过于繁琐
Octopress是采用Ruby make脚本即rake来完成的, 因此只需要修改Ruby的任务脚本 `Rakefile` 即可

首先, 现在脚本文件的开头位置定义编辑器

```bash
...
require "stringex"

# Editor_config
editor = "vim"
...
```

然后再每个new_post的任务结尾处加上下述代码

```bash
...
task :new_post, :title do |t, args|
...
  end
  if #{editor}
    system "#{editor} #{filename}"
  end
end
...
```

注: new_page任务中也需要同样的设置(虽然还不知道这个任务是干什么的)
