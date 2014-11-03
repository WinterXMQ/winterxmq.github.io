---
layout: post
title: "Linux中的正则表达式"
date: 2014-10-31 12:18:44 +0000
comments: true
categories: Linux Shell Regular-expression
---


POSIX[^POSIX_DEFINE] 定义了两种正则表达式语法:

1) BRE 基本正则表达式(Basic Regular Expression);

2) ERE 扩展的正则表达式(Extended Regular Expression)

大多数的Linux程序符合BRE规则

`sed` 只支持大部分 BRE, 因为主要是受到速度的限制;

`grep` 可以支持 ERE, 只是需要增加额外参数 `-E`

`gwak` 使用 BRE

# Regular Expression 中的基本字符集

BRE定义语法符号

符号    | 模式含义
:-------|:--------
. | 匹配任何一个字符
[] | 字符集匹配
[^] | 字符集(取反)匹配
^ | 匹配开始位置
$ | 匹配结束位置
\(\) | 定义子表达式
\n | 子表达式向前引用, 即表示重复, n在{1,9}之间
* | 多次或者重复匹配(包括0次重复)
\ | 转义符
[] | 匹配括号内出现的字符, 如 [a-zA-Z0123]
p\{n\} | 匹配p出现n次
p\{n,\} | 匹配p至少出现n次
p\{n,m\} | 匹配所有p出现的次数大于n小于m的情况

ERE修改的语法符号

符号 | 状态 | 模式含义
:----|:----:|:--------
? | 新增 | 多次匹配(包括0次)
+ | 新增 | 至少一次匹配
| | 新增 | 或运算, 匹配两个子表达式的合集
() /{m,n} | 修改 | **注释:** 不需要转义 (, ), {, } 这些符号
\n | 取消 | ......

BRE 和 ERE 共享, 额外的一些定义:

特殊符号:

表一:

POSIX类 | perl类 | 描述
:-------|:------:|:-----
[:alnum:] |    | 数字集+字母集
[:alpha:] | \a | 字母集
[:lower:] | \l | 小写字母集
[:upper:] | \u | 大写字母集
[:blank:] |    | 空白字符集(空格+制表符)
[:space:] | \s | 所有空白字符(包括[:blank:])
[:cntrl:] |    | 不可打印的控制字符集(退格, 删除....)
[:digit:] | \d | 十进制数字
[:xdigit:] | \x | 十六进制数字
[:graph:] |    | 可打印的非空白字符
[:print:] | \p | 可打印的字符
[:pumct:] |    | 标点符号

表二:

perl类 | 等效POSIX | 描述
:-----:|:----------|:-----
\o | [0-7] | 八进制数字
\O | [^0-7] | 非八进制
\w | [[:alnum:]] | 单词
\W | [^[:alnum:]] | 非单词
\A | [^[:alphha:]] | 非字母
\L | [^[:lower:]] | 非小写字母
\U | [^[:upper:]] | 非大写字母
\S | [^[:space:]] | 非空白字符
\D | [^[:digit:]] | 非十进制数字
\X | [^[:xdigit:]] | 非十六进制数字
\P | [^[:print:]] | 非可打印字符

一些特殊定义:

转义定义: `\r` (回车), `\n` (换行), `\b` (退格), `\t` (制表符), `\v` (垂直制表符), `\"` 和 `\'`


# Regular Express 使用例子

1) 匹配任何单一字符(ASCII) `.`

2) 匹配行首 `^`, 例子如下

```bash
>> ls -l | grep '^d'
drwxr-xr-x 6 xmq users   4096 10月 12 15:53 Code/
drwxr-xr-x 2 xmq users   4096 9月  30 02:41 pic/

```

3) 匹配行尾 `$`


```bash
^$   ---  匹配空行
^.%  ---  匹配单字符行
```

4) 匹配重复字符 `*`

```bash
ro*t  <- 其中 rot, root, rooot 都符合其匹配结果
```

5) 特殊字符, 需要转义 `\ `

6) 匹配一个范围 `[]`

```bash
[0-9] or [0123456789]       <- 匹配数字
[a-zA-Z]                    <- 匹配所有大小写字母
[a-zA-Z0-9]                 <- 匹配字母和数字
[a-zA-Z]*                   <- 匹配所有单词
```

注意: 在 `[]` 中, `^` 表示否定的意思

```bash
[^A-Za-z]                   <- 匹配非字母
[^0-9]                      <- 匹配非数字
```

7) 匹配重复出现多次 `\{\}`

```bash
A\{2\}B                     <- 匹配 AAB
A\{2,\}B                    <- 匹配 AAB AAAB AAAAB ...
A\{2,3\}B                   <- 匹配 AAB AAAB
```

[^POSIX_DEFINE]: Portable Operating System Interface, 即可移植操作系统接口, 定义了操作系统应该为应用程序提供的接口标准, 是IEEE为要在各种UNIX操作系统上运行的软件而定义的一系列API标准的总称, 其正式称呼为IEEE 1003, 而国际标准名称为ISO/IEC 9945, 信息来自[百度百科](http://baike.baidu.com/view/209573.htm?fr=aladdin)

# 参考文档

1) http://blog.csdn.net/wklken/article/details/6429526

2) http://blog.chinaunix.net/uid-23045379-id-2562051.html

3) http://blog.csdn.net/a627088424/article/details/15435873
