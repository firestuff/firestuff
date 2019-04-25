<!--# set var="title" value="Flashing without Microsoft or floppy drives" -->
<!--# set var="date" value="2006-01-22" -->

<!--# include file="include/top.html" -->

Ran into an issue where we had to flash upgrade some firmware in a server. As usual, firmware downloads came as MS-DOS programs, and told you to put them on a bootable DOS floppy disk and boot from it. This is becoming a real pain in the ass — who actually uses that Microsoft crap anymore? :) Also, what server has a floppy drive?

So, we improvise. Grab this [FreeDOS boot disk](files/boot.img). Mount in Linux:

	sudo mount -o loop boot.img /mnt

Copy whatever files were provided by the vendor (hint: unzip handles most Windows self-extracting .exe’s) into /mnt.

	sudo umount /mnt

Build a CD image:

	mkdir cdimage
	mkdir cdimage/boot
	cp boot.img cdimage/boot
	mkisofs -r -b boot/boot.img -c boot/boot.catalog -o cdimage.iso cdimage

Then burn with your favorite CD burning program. Presto!

<!--# include file="include/bottom.html" -->
