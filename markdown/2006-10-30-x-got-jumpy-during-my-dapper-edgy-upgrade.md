<!--# set var="title" value="X got jumpy during my Dapper -> Edgy upgrade" -->
<!--# set var="date" value="2006-10-30" -->

<!--# include file="include/top.html" -->

Xorg got really jumpy for me after my upgrade to Ubuntu Edgy. I couldn’t play DVDs fullscreen, and even some Flash animations drove the thing nuts. I poked through alot of launchpad bugs, and finally came up with a solution. I added this to the end of my /etc/X11/xorg.conf file:

	Section “Extensions”
	Option “Composite” “Disable”
	EndSection

Poof, everything back to pre-Edgy wonderfulness. Obviously, composite’s got a way to go; this laptop has some serious GL hardware, and a little alpha-blending really shouldn’t be an issue.

<!--# include file="include/bottom.html" -->
