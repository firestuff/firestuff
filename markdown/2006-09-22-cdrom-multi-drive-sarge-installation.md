<!--# set var="title" value="CD-ROM multi-drive sarge installation" -->
<!--# set var="date" value="2006-09-22" -->

<!--# include file="include/top.html" -->

I realize we only have a couple of months left that this matters, but it drove me nuts for hours today, so I thought I’d share.

The Debian sarge installer completely flips out if there’s more than one CD/DVD drive, you have discs in both, and the Debian disc isn’t in the first.  The easy answer is, of course, take a disc out.  It’s rather hard when it’s in the BladeCenter tray in NJ and you’re in upstate NY.

You can’t mount the drive yourself.  There’s a bug in the installer that won’t detect which distro it’s trying to install, and it starts searching for files that don’t exist (/cdrom/dists//Release).  Useless.

However, it turns out that devfs is writable in places.  You can go into /dev/cdroms/, remove all the links, and recreate just a cdrom0 link to whichever /dev/scsi/ or /dev/ide/ device you like.  Poof, functional.

<!--# include file="include/bottom.html" -->
