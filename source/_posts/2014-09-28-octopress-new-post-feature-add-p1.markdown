---
layout: post
title: "Octopress特性设置-新建Blog脚本功能定制"
date: 2014-09-28 12:52:34 +0000
comments: true
categories: Blog Octopress Rake
---

# 新建Blog并自动使用vim打开新建文档

---

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

# 新建Blog时支持文件名和Blog的title分离

---

在Octopress中写Blog, 时常会出现新建完Blog后还要去修改Title, 虽然没有什么问题, 但总需要这么做就显得有点麻烦, 按照Octopress管理Blog的形式在Rake的任务脚本中自定义Rake任务, 自定义过程如下

这个任务与普通的new_post任务差别不大, 主要在于接受的参数多了一个, 此外在创建文件的文件名和写入文件的title名有区别而已, 在Rakefile中加入如下代码

{% include_code post.rb lang:ruby p/code/2014-10-03-new-post-add-post.rb  %}

# 增加自动新建Code的任务

---

Octopress总有新建Blog的任务, 当需要在Blog中插入大段代码时却需要手动新建代码文件, 略微显得有些蛋疼, 于是创建了这个任务

Octopress中有 `include_code` 的功能, 而此次为Octopress增加的 `新建 Code` 的任务也是为了这个功能设置的

## 小幅修改 include_code

在 `include_code` 中只需要给出Code文件的文件名, 系统会在预先设定的源码文件夹中寻找文件

因此, 第一点要修改源码的默认路径<什么文件都要放在download下, 你不觉得很失败吗>

此处需要修改两个地方: 1) 站点配置文件 `_config.yml` 下的 `code_dir` 2) `include_code`功能的代码生成器 `plugins\include_code.rb`中的相关设定

1) 对于这个没有什么好说明的, 只需要打开 `_config.yml`, 修改 `code_dir: p/code`, 唯一的**注意点**: 目录的前后都不要有 `/`

2) 需要替换 `plugins\include_code.rb` 中关于 `code_dir` 的默认设定

```ruby
default_dir = 'p/code'
# code_dir = (context.registers[:site].config['code_dir'].sub(/^\//,'') || 'dowanload/code')
code_dir = (context.registers[:site].config['code_dir'].sub(/^\//,'') || default_dir)
```

此外, 个人觉得在这个功能中只给出文件名有些不好, 因此就增加了同样支持给出完整的相对路径, 如 `p/code/filename`<纯属蛋疼>

在 `plugins\include_code.rb` 中修改如下代码<紧接着上面的代码>

```ruby
if @file.start_with?(code_dir)
  @file = @file[code_dir.length + 1, @file.length - 1]
end
```

## 增加Rake任务 Code

完成了对 `include_code` 的改造, 紧接着要完成最重要的内容, 即新增任务, 在 `Rakefile` 中增加如下内容

{% include_code new-code.rb lang:ruby 2014-10-04-new-post-new-code.rb %}
