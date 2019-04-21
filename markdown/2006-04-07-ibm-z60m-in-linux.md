<!--# set var="title" value="IBM Z60m in Linux" -->
<!--# set var="date" value="April 7, 2006" -->

<!--# include file="include/top.html" -->

I picked up a new IBM Z60m laptop at work. Here’s the rundown from trying to install Debian:

* Forget Sarge; it doesn’t support the wired or wireless network cards or the hard disk controller.
* Forget the [Sarge+2.6.15](http://kmuto.jp/b.cgi/debian/d-i-2615.htm) image with the internal CD-ROM drive; it doesn’t support it, though it finds the hard drive and the wired ethernet.
* Since I don’t have the 2.6.15 image on my USB drive, I pulled out the USB CD-ROM and installed from that.
* If you let the Debian installer partition for you, it leaves the 4.5GB restore partition. If you don’t want this, partition manually.
* After it installs, you’ll want to add the following your /etc/modules:
  * radeonfb
  * cpufreq\_userspace
  * speedstep\_centrino
* The console framebuffer comes out to a whopping 210×65 characters (1600×1050 pixels).
* Install powernowd to get the CPU scaling working properly.
* At 800mhz (the lowest SpeedStep) with the screen dimmed all the way, the battery gets about 3h:30m.
* You’ll need to put firmware for the IPW2200 driver in /lib/firmware; you can get it [here](http://ipw2200.sourceforge.net/).
* X is a real pain to get working. The ATI driver doesn’t seem to know about this card. The only way I managed was to disable the “dri” module and use the “fbdev” driver; I had to add an “fbset -depth 32″ at startup to get the color depth right.
* The CD-ROM/DVD drive is also a real trip. Edit /etc/mkinitramfs/modules and add:
  * libata atapi\_enabled=1
* Then dpkg-reconfigure your kernel image module (”dpkg-reconfigure linux-image-2.6.16-1-686″ for me).
* This will let you mount CDs, but doesn’t seem to support the raw access needed by libdvdcss2.  I still can’t play DVDs with this drive.  libata ATAPI support is under active development, so hopefully this will clean up soon.

<!--# include file="include/bottom.html" -->
