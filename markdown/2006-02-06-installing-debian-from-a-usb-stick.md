<!--# set var="title" value="Installing Debian from a USB stick" -->
<!--# set var="date" value="February 6, 2006" -->

<!--# include file="include/top.html" -->

Credit to [dilinger](http://lists.debian.org/debian-boot/2004/09/msg01722.html) for this one.

Partition the USB stick (some come unpartitioned and expect you to mount the full device; that won’t work here). Make the partition bootable, type Linux (0×83).

We’ll assume the device node for the partition is /dev/sda1 from here on.

	mkfs.ext3 -m 0 /dev/sda1
	mount /dev/sda1 /mnt
	grub-install –root-directory=/mnt /dev/sda
	mkdir -p /mnt/boot/grub

Save [menu.lst](files/menu.lst) into /mnt/boot/grub/

Save the appropriate vmlinuz and initrd.gz files and an install ISO into /mnt/

If you don’t have these already, try [here](http://http.us.debian.org/debian/dists/sarge/main/installer-i386/current//images/hd-media/2.6/) and [here](http://debian.osuosl.org/debian-cdimage/current/i386/iso-cd/) (use the “netinst” or “businesscard” ISO images unless you have a good reason to need the whole image and a > 512MiB flash drive).

	umount /mnt

That’s it!

<!--# include file="include/bottom.html" -->
