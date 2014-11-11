---
layout: post
title: "ArchLinux上磁盘扩展"
date: 2014-11-10 14:13:44 +0000
comments: true
categories: Linux ArchLinux Vbox ext4 lvm
---

问题: 在VBox上创建ArchLinux虚拟机的时候就想着如果硬盘不够用, 就到时候再想办法扩容, 因此当时就只搞了8G的硬盘, 其中还有1G的Swap分区; 没想到这个问题这么快就出现了, 因此就有了一下的解决方案

问题分析:

由于虚拟磁盘采用的是 `VirtualBox Disk Image`, 同时在ArchLinux中没有逻辑磁盘(LVM)还有就是就是系统只有单个分区, 所以不适合采用另加磁盘的挂载方式来解决。

问题解决方案:

总体方案: 给 `/` 分区扩容, 分两步, 1) 先给虚拟磁盘扩容; 2) 再想办法给 `/` 分区扩容

# VBox 的虚拟磁盘扩容

在 VBox 中有一个管理工具可以对磁盘扩容, 支持命令行, 操作更加简便

查看 VBox 下注册的虚拟磁盘

```bash
>> VBoxManage list hdds
UUID:           a314bb2f-c879-4e1d-9669-251a5e49f54f
Parent UUID:    base
State:          locked write
Type:           normal (base)
Location:       C:\OS\Arch_Box\ArchV.vdi
Storage format: VDI
Capacity:       20480 MBytes
```

便可得到磁盘的UUID为 a314bb2f-c879-4e1d-9669-251a5e49f54f

使用磁盘的UUID给磁盘扩容

```bash
>> VBoxManage modifyhd a314bb2f-c879-4e1d-9669-251a5e49f54f --resize 20480
```

此时磁盘中被扩展的那部分空间还没被分配, 需要在系统中操作

# 分区扩展

虽然说ext4分区的收缩和扩展技术是成熟的, 但由于之前的分区是老版的cfdisk创建的, 引导区的大小是62个扇区, 分区是从63扇区开始的, 而现在所有的Linux上的工具都默认从2048个扇区开始分配空间, 因此会造成根分区被删除后重建时, 分区上的数据信息会丢失, 目前对此没有找到可行的方案; 因此采用如下方案, 同时也会记录原方案, 方便以后对2,3,4分区的扩展; 采用的方案是: 采用Linux的逻辑卷(LVM)的管理办法。

## LVM解决方案

简单的说就是重构现在的磁盘结构, 全面换成LVM磁盘

(1) 创建一个新磁盘, 和安装盘一起连接到虚拟机上, 重启, 进入安装系统

(2) 开始新磁盘的分区操作

由于要采用LVM的磁盘管理办法, 首先要对安装系统做如下操作

安装lvm2

```bash
>> pacman -Syy
>> pacman -S lvm2
```

加载 dm_mod

```bash
>> modprobe dm_mod
```

物理分区, 和以前一样, 这次采用fdisk来处理

```bash
>> fdisk /dev/sdb
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-41943039, default 41943039):

Created a new partition 1 of type 'Linux' and of size 20 GiB.

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

>> fdisk -l /dev/sdb

Disk /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device    Boot Start       End   Blocks  Id System
/dev/sdb1       2048  41943039 20970496  8e Linux LVM

```

开始设置LVM磁盘系统

创建物理卷 Physical Volume

```bash
>> pvcreate /dev/sdb1
>> pvdisplay
--- Physical volume ---
  PV Name               /dev/sda1
  VG Name               root
  PV Size               20.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              5119
  Free PE               0
  Allocated PE          5119
  PV UUID               BduFVm-tKMn-JDPf-b1U8-vcs8-8YDk-FNsW0e

```

创建卷组 Volume Group

```bash
>> vgcreate root /dev/sdb1
>> vgdisplay
  --- Volume group ---
  VG Name               root
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               20.00 GiB
  PE Size               4.00 MiB
  Total PE              5119
  Alloc PE / Size       5119 / 20.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               kROehq-qYhI-U21s-Guaq-FFns-bv3R-8cIzDA

```

创建逻辑卷 Logical Volume, 及以后操作的卷

```bash
>> lvcreate -l +100%FREE root -n root
>> lvdisplay
  --- Logical volume ---
  LV Path                /dev/root/root
  LV Name                root
  VG Name                root
  LV UUID                YtEeaf-sqJJ-8VAq-MdYo-es8Q-uTtO-QulEHJ
  LV Write Access        read/write
  LV Creation host, time archiso, 2014-11-10 03:41:50 +0000
  LV Status              available
  # open                 1
  LV Size                20.00 GiB
  Current LE             5119
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:0

```

(3) 磁盘格式化, 选定磁盘系统(和以前一样)

```bash
>> mkfs.ext4 /dev/mapper/root-root
```

(4) 拷贝数据(不建议挂载磁盘后用cp命令来执行, 建议采用如下命令完成, 虽然步骤有点多, 但胜在可靠)

采用 `dd` 来镜像拷贝磁盘

```bash
>> dd if=/dev/sda1 of=/dev/mapper/root-root
```

这时候你用 `df -h` 去查看 `/dev/mapper/root-root` 的容量时会发现 `/dev/mapper/root-root` 的磁盘大小和 `/dev/sda1` 的是一样的, 由于拷贝的时候连同分区表信息都一起拷贝过来了(这个问题还是在正式进入系统后才发现的), 需要做如下处理来扩展磁盘

```bash
>> resize2fs /dev/mapper/root-root 20476M
```

(5) 新系统设置

生成新的分区表信息

```bash
>> genfstab -U -p /mnt
```

把生成的信息写入 `/etc/fstab`, 删除以前的分区信息

进入新系统

```bash
>> arch-chroot /mnt/new /bin/zsh
```

设置系统内核, 配合LVM文件系统

```bash
>> vim /etc/mkinitcpio.conf
```

确保 udev 和 lvm2 被 mkinitcpio 加载, 确保 lvm2 在 block 和 filesystem 之间

```bash
HOOKS="base udev ... block lvm2 filesystems"
```

以及确保 dm-mod 被加载

```bash
MODULES="dm_mod ..."
```

安装系统引导

```bash
>> grub-install --modules=lvm --target=i386-pc --recheck /dev/sda
```

会出现如下错误, 是由于/run在arch-chroot环境下不可用导致的, 但不会影响正常安装

```bash
  /run/lvm/lvmetad.socket: connect failed: No such file or directory
  WARNING: Failed to connect to lvmetad. Falling back to internal scanning.
```

更新grub列表

```bash
>> grub-mkconfig -o /boot/grub/grub.cfg
```

在正式进入系统后, 再重新执行一边

## Basic 解决方案

简单的来说就是基于基本磁盘的收缩和扩容方案, 这个方法在这里不适用的原因是前后引导区的大小不一致(扩容时需要把分区删掉重建, 由于删除重建前后的引导区大小不一致, 使得分区起始位置不同, 而导致的分区信息丢失, 磁盘类别不可识别, 引起扩容失败), 但对于第2, 3, 4分区的扩容以及引导分区大小不会变化的磁盘, 此方案可行, 已测试过

(1) 收缩磁盘

```bash
>> resize2fs /dev/sdaX size
```

注意: 1) size 小于实际分区大小且大于已用大小; 2) 此命令可能造成数据丢失, 谨慎操作; 3) 操作前, 可用 `e2fsck -f /dev/sdaX` 强制检查磁盘

(2) 扩充磁盘

采用 `fdisk /dev/sdaX` 来删除重建分区, 只要初始位置不变, 容量扩大, 不必担心删除时数据丢失, 之后再适用上条命令完成磁盘扩容


# 参考

> [1] http://www.2cto.com/os/201306/222822.html

> [2] https://wiki.archlinux.org/index.php/Lvm

> [3] http://www.byywee.com/page/M0/S834/834847.html

> [4] http://bbs.chinaunix.net/thread-1972006-1-1.html

> [5] http://linux.cn/article-3218-1.html
