---
layout: post
title: "Archlinux 的安装"
date: 2014-09-28 00:08:29 +0000
comments: true
categories: System Archlinux Linux
---

其实很早就像写个Archlinux的安装Blog, 但是由于很多原因就一直拖到现在才开始动手

Archlinux和Linux的其他发行版不同, Arch就像是四驱赛车一样, 需要自己挑选零件、自己组装, 因此具有很大的自由度而且难度也不是非常大<当然相比于其他的发行版已经是难多了, 其实我比较推从gentoo, 它比Arch还要复杂, 因为它连零件都要自己制作>。选择Arch的第二个原因是它的软件中心, 支持自定义软件。

接下来我们谈谈Arch的安装问题, 我分别在虚拟机`Vbox`和实体机都装过, 因此在这个Blog中会详细的谈谈。在Arch安装中最复杂的就是桌面环境的配置, 我也尚未完全搞定, 因此不再Blog中做过多的说明。

# Basic System Install

基本系统的安装在虚拟机和实体机上的差别为0, 其中的注意点就是在于软件包的选择和安装上。

## Download the system for installation

首先需要下载[官方镜像][Arch_Download], 无论用什么下载工具都无所谓。

在这个小节中最重要的就是如何制作安装U盘<如果只是为了说明如何下载就开一个新的小节来说明就显得太脑残了, 同时这一小节也是虚拟机和实体机安装中为数不多的差别中的第一个>。

> Linux

在Linux中, 启动U盘相对好做一点<毕竟要安装的是Linux, 同时是因为Linux中对待磁盘的工具比较灵活, 可以满是不同的磁盘操作需求>。

首先, 通过 `lsblk` 来找到你的U盘

然后通过下面的命令完成镜像的写入[^Arch_USB_Flash_Install]

```bash
>> dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx && sync
```

> Windows

在Windows下需要借助第三方的软件来达到目标, 采用[Rufus][Download_Rufus]。当然也有其他的解决方案, 但是不怎么方便<其实是我自己没有成功过>。

> **注意点**:

>   1. 任何被用来制作Arch Linux的安装盘的U盘中的数据都会被清除, 而且无论U盘是多大的, 制作完毕后可用的内存都是24M<没记错的是话就是这么大的>。

>   2. 如果U盘需要还原, 在以后的Blog中介绍

>   3. 对于这部分有什么疑问的可以参照[Arch Linux的官方Wiki][Arch_USB_Flash_Install]

## Configure the Install System

*说明: 开这个小节主要是为了总结我的安装过程, 很多朋友应该可以直接忽略*

首先启动系统<如何启动系统就不说了>

### Configure the net

配置网络:

  1. 虚拟机: 一般的新建的虚拟机都可以正常的访问网络<如果有问题, 请问度娘>

  2. 实体机:

    * Wifi: 运行 `wifi-menu interface-name`

    * dsl:  依次运行 `pppeo-setup`, `pppoe-start` 来启动dsl, 运行 `pppoe-stop` 来停止dsl

*对于虚拟机可能需要配置静态IP, 通过 `ip addr add dev enp0s8 192.168.1.109/24` 来完成*

### About the Sources

这的地方的配置主要是为了解决国外源速度慢的问题, 把源换成国内相对比较快的。

首先先备份一下

```bash
>> cd /etc/pacman.d/
>> mv mirrorlist mirrorlist.origin
```

设置软件源, 由于[Arch提供软件源查询][Arch_mirrorlist]的功能, 我们采用官方查询的方式解决。

```bash
>> wget -c "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&ip_version=4&ip_version=6" -O mirrorlist
```

**注意点**: 下载官方软件源查询出来的文件中的软件源都是被注释掉的, 我们需要手动打开 `nano mirrorlist`, 即去除 `mirrorlist` 文件中的 #

此外, 还可以采用Arch中的一个工具对配置中的软件源进行速度排序<可以试试>, 具体操作如下

```bash
>> mv mirrorlist mirrorlist.backup
>> rankmirrors -n 6 mirrorlist.backup > mirrorlist
```

然后更新pacman的缓存 `pacman -Syy`, 同时装上vim方便修改配置文件 `pacman -S vim`

在这里, 提一下个人的习惯, 在终端下配置和安装系统总有些不习惯<开始玩Arch的时候, 现在无所谓了>, <如果条件允许>总是在另一个电脑上用ssh登陆, 进行远程安装<尤其是在虚拟机里安装时, 相对方便一些>

可以按照如下命令完成ssh server的配置安装, 同时需要记住本机IP, 通过 `ifconfig` 查看

```bash
>> pacman -S openssh
>> systemctl start sshd
```

## Install the System

在这里完成基本系统的安装, 使得电脑可以脱离安装光盘orU盘独立运行和配置

### About Partition

这里不涉及磁盘分区的具体知识, 也不涉及如何分区, 只提两点:

1. 如果在虚拟机里安装时, 初始安装不要求磁盘有多大<只要有2G就足够了, 后期不够可以再加>

2. home可以单独分区或分磁盘

按照如下命令完成分区操作

```bash
>> cfdisk /dev/sda      # 进行分区, 2G的Swap分区, 其余的/分区
>> lsblk
>> fdisk -l
>> mkfs.ext4 /dev/sda1  # 格式化 /分区
>> mkswap /dev/sda2     # 格式化 Swap分区
>> swapon /dev/sda2     # 挂载 Swap分区
>> mount /dev/sda1 /mnt # 挂在 /分区
>> fdisk -l             # 显示挂载情况
>> lsblk -f
```

### System Installation

完成基本系统的安装, 以及配置的基本工具, 按照如下指令完成

下面的四个命令分别完成 `基本系统`, `shell`, `网络连接工具`, `常用工具` 的安装

```bash
>> pacstrap -i /mnt base base-devel
>> pacstrap -i /mnt bash-completion zsh
>> pacstrap -i /mnt ifplugd wireless_tools wpa_supplicant iw wpa_actiond dialog net-tools rp-pppoe
>> pacstrap -i /mnt openssh vim
```

### System Configure

完成最基本的系统配置[^Arch_Wiki_Guide]

1. 生成分区列表

```bash
>> genfstab -U -p /mnt >> /mnt/etc/fstab
```

2. 进入系统, `arch-chroot /mnt /bin/zsh`

3. 配置语言环境

```bash
>> vim /etc/locale.gen
选择 en_US 和 zh_CN
>> locale-gen
>> export LANG="zh_CN.UTF-8"
>> export LANGUAGE="zh_CN:en_US:en"
>> locale > /etc/locale.conf            # 设置中文环境, 并写入配置
```

4. 设置系统时间

选择上海时区

```bash
>> ln -s /usr/share/zoneinfo/Zone/SubZone /etc/localtime
```

选择UTC

```bash
>> hwclock --systohc --utc
```

5. 设置主机名, `echo Arch-XMQ > /etc/hostname`

6. 设置内核模块加载, `mkinitcpio -p linux`

7. 用户设置

root用户设置

```bash
>> passwd
>> usermod -s /usr/bin/zsh root
```

普通用户创建和配置

```bash
>> useradd -m -g users -G video,audio,power,network,wheel -s /usr/bin/zsh xmq
>> usermod -a -G video,audio,lp,log,wheel,optical,scanner,games,users,storage,power xmq
>> passwd xmq
```

普通用户的超级权限配置

```bash
>> chmod 640 /etc/sudoers
>> vim /etc/sudoers
Add `xmq ALL=(ALL) ALL` or
Add `wheel ALL=(ALL) ALL`
>> chmod 440 /etc/sudoers
```

8. 引导系统的安装

```bash
>> pacman -S grub os-prober
>> grub-install /dev/sda
>> grub-mkconfig -o /boot/grub/grub.cfg
>> grep -v rootfs /proc/mounts > /etc/mtab
```

9. 退出重启

```bash
>> exit
>> umount /mnt
>> reboot
```

# Desktop Configuration

桌面的配置并没有完全搞定, 之前用过一段时间的KDE, Gnome, 也配置过一段时间的Openbox, 终究没用长久, 这里主要写一些关于XWindow的配置, 涉及一点的Openbox

## Configuration of Xorg

这一部分主要完成从终端环境切换到图形界面, 主要包括 `X` 和 `桌面环境` 的配置

### Xorg Install

完成Xorg的安装<说实话Linxu的图形界面到底没弄明白, 不清楚Xorg到底是什么东东>

```bash
>> sudo pacman -S xorg-server xorg-server-utils xorg-utils xorg-xinit
```

**注意:** 这个命令中会让你选择gl的类库, 这个跟显卡有关, 我本机是Nvidia的显卡, 因此实体机安装时选择 `nvidia-libgl`, 而虚拟机安装时, 由于显卡是虚拟出来的, 因此只要简单的选择 `mesa-libgl` 即可

### About VAG

这个地方是Arch Linux在安装过程中实体机与虚拟机的第二处不同点

1. 对于实体机而言只要安装了对应的驱动即可

```bash
>> sudo pacman -S nvidia
```

**注意:** 需要重启后才生效, 此时会发现屏幕的分辨率降低不少

同时需要安装输入驱动<包括键盘、鼠标和触摸板的驱动, 我遗忘里到底要安装多少, 以后再补上>

```bash
>> sudo pacman -S xf86-input-synapticsxf86-input-synaptics
```

2. 虚拟机安装

我只搞定了在VBox中的桌面安装, 在VMware中到底如何操作, 大家可以尝试尝试

首先安装VBox的驱动

```bash
>> sudo pacman -S virtualbox-guest-utils
```

内核加载模块<以下所有的操作需要管理员权限>

```bash
>> modprobe -a vboxguest vboxsf vboxvideo
>> depmod $(uname -r)
>> vim /etc/modules-load.d/virtualbox.conf
Add following
vboxguest
vboxsf
vboxvideo
>> VBoxClient-all
>> systemctl enable vboxservice
```

3. 3D加速 `sudo pacman -S mesa`

### About Desktop

主要完成openbox的安装, 以及部分软件的安装, 至于具体的配置以后再补上

安装 Openbox<桌面管理器>, slim<登陆界面>

```bash
>> sudo pacman -S slim openbox
```

安装中文字体

```bash
>> sudo pacman -S ttf-dejavu artwiz-fonts wqy-zenhei wqy-bitmapfont wqy-microhei ttf-arphic-ukai ttf-arphic-uming
```

配置和启动测试openbox

```bash
>> cp /etc/X11/xinit/xinitrc .xinitrc
>> vim ~/.xinitrc
Add following
exec openbox-session
>> mkdir -p ~/.config/openbox
>> cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} ~/.config/openbox
```

通过 `startx` 来启动测试openbox

使得slim生效, 并重启, 进出桌面时代<进入桌面时代, 并不意味着就不再接触终端环境了, 由于openbox的菜单没有配置好, 尽管号称进入桌面时代, 但在很长一段时间内还要和终端打交道>

```bash
>> sudo systemctl enable slim.service
```

### About the Software in Openbox

记录部分软件在Openbox中的安装和配置

1. shell

安装X环境下的shell执行器 `sudo pacman -S terminator`

2. gvim

采用gvim更换vim `sudo pacman -S gvim`


[^Arch_USB_Flash_Install]: [ArchLinux Official Wiki USB Flash Install Media](https://wiki.archlinux.org/index.php/USB_flash_installation_media "Arch Linux Official Wiki on USB-Flash-Install-Media")
[^Arch_Wiki_Guide]: [Arch Linux Official Wiki User Guide](https://wiki.archlinux.org/index.php/Beginners%27_guide "Arch Linux 官方用户新手指南")

[Arch_Download]: https://www.archlinux.org/download/ "Arch Linux System Download"
[Download_Rufus]: http://rufus.akeo.ie/ "Rufus 下载"
[Arch_USB_Flash_Install]: https://wiki.archlinux.org/index.php/USB_flash_installation_media "Arch Linux Official Wiki on USB-Flash-Install-Media"
[Arch_mirrorlist]: https://www.archlinux.org/mirrorlist "Arch Linux 官方软件园查询"

