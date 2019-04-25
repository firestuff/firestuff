<!--# set var="title" value="How to install Debian Sarge on an IBM Blade" -->
<!--# set var="date" value="2006-01-23" -->

<!--# include file="include/top.html" -->

This is, unfortunately, complicated. You’ll need:

* [The full DVD #1 of Sarge](http://mirror.cs.wisc.edu/pub/mirrors/linux/debian-cd/3.1_r1/i386/bt-dvd/debian-31r1-i386-binary-1.iso.torrent)
* A USB drive containing:
  * [fixup-network.sh](files/fixup-network.sh)
  * [bcm5700-source\_7.3.5-4\_all.deb](files/bcm5700-source_7.3.5-4_all.deb)
  * kernel-headers-2.6.8-2\_2.6.8-16\_i386.deb [link broken in platform transfer]
  * [kernel-headers-2.6.8-2-686\_2.6.8-16\_i386.deb](files/kernel-headers-2.6.8-2-686_2.6.8-16_i386.deb)
  * [kernel-headers-2.6.8-2-686-smp\_2.6.8-16\_i386.deb](files/kernel-headers-2.6.8-2-686-smp_2.6.8-16_i386.deb)

Steps:

1. Attach the USB drive
1. Boot the blade from the DVD
1. At the boot prompt, type: `linux26 vga=771`
1. Go through the install as normal. Note that the drives are out of order (USB drive is first).
1. When asked “Do you want to install the GRUB bootloader to the master boot record?”, say No.
1. Enter _/dev/sdb_ to install to.
1. The install will reboot.
1. Let the disc eject or, if remote, change the boot order to boot from HD first.
1. GRUB will error when trying to boot; dismiss the error message.
1. Press “e” to edit the boot commands. Change “(hd1,0)” to “(hd0,0)” and “/dev/sdb1″ to “/dev/sda1″.
1. Press “b” to boot.
1. Use the “cdrom” access method for apt.
1. Go through the install as normal.
1. Log in as root.
1. Edit /etc/fstab, correcting the drive lettering for any partitions that are messed up.
1. Run: `mount /boot`
1. Edit /boot/grub/menu.lst, changing the lines starting with “# kopt=” and “# groot=” to reflect the changes made during boot.
1. Run: `update-grub`
1. If you configured RAID during installation, edit /etc/mdadm/mdadm.conf to reflect drive letter changes.
1. Mount the USB drive on /mnt.
1. Run: `apt-get install module-assistant kernel-kbuild-2.6-3 debhelper kernel-image-2.6.8-2-686-smp build-essential`
  (the non-SMP image will also work, if you want this off)
1. Run: `dpkg -i /mnt/bcm5700-source_7.3.5-4_all.deb /mnt/kernel-headers-2.6.8-2_2.6.8-16_i386.deb /mnt/kernel-headers-2.6.8-2-686_2.6.8-16_i386.deb /mnt/kernel-headers-2.6.8-2-686-smp_2.6.8-16_i386.deb`
1. Run: `cp /mnt/fixup-network.sh /etc/init.d/`
1. Run: `reboot`
1. When the machine reboots, run: `module-assistant prepare`
1. Run: `module-assistant auto-install bcm5700`
1. Run: `update-rc.d fixup-network.sh start 34 0 6 S .`
1. Run: `reboot`
1. The machine should now be usable. If you’ve got the BladeCenter internal Cisco switch, the install has probably triggerred flap suppression. telnet to the switch and shutdown/noshutdown the port (hints: show int status, conf t, int _interfacename_, shutdown, no shutdown).

<!--# include file="include/bottom.html" -->
