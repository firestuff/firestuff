<!--# set var="title" value="My DVD drive won’t play movies" -->
<!--# set var="date" value="July 8, 2006" -->

<!--# include file="include/top.html" -->

I think I might be the last one to this party, but here goes. I installed Linux on my new laptop before it ever booted Windows. Since then, I haven’t been able to play movies on the internal DVD drive. I’ve been getting by with the external drive, expecting someone to fix the hardware support at some point. Turns out, the laptop shipped without the region set on the drive. There’s a [handy utility](http://linvdr.org/projects/regionset/) for doing this in Linux:

	cerberus% sudo regionset /dev/cdrom
	regionset version 0.1 — reads/sets region code on DVD drives
	Current Region Code settings:
	RPC Phase: II
	type: NONE
	vendor resets available: 4
	user controlled changes resets available: 5
	drive plays discs from region(s):, mask=0xFF

	Would you like to change the region setting of your drive? [y/n]:y
	Enter the new region number for your drive [1..8]:1
	New mask: 0xFFFFFFFE, correct? [y/n]:y
	Region code set successfully!

And poof!, it plays.

<!--# include file="include/bottom.html" -->
