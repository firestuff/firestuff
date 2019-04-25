<!--# set var="title" value="Stopping Debian from ejecting the CD-ROM during install" -->
<!--# set var="date" value="2006-09-23" -->

<!--# include file="include/top.html" -->

Another remote Debian install annoyance: the installer auto-ejects the CD-ROM, and there’s no way to turn it off in sarge (there’s a boot parameter in etch).

In sarge, when the question asking you “Install GRUB to the Master Boot Record?” appears, switch to the shell on console 2 (Alt-F2). Then run:

	rm /target/usr/bin/eject

<!--# include file="include/bottom.html" -->
