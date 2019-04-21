<!--# set var="title" value="Is sleep(3) effected by time changes?" -->
<!--# set var="date" value="February 13, 2006" -->

<!--# include file="include/top.html" -->

It’s an interesting question. I tried it; it isn’t. Here’s my guess at an explanation:

[sleep(3)](http://www.tin.org/bin/man.cgi?section=3&topic=sleep) is implemented internally on most systems as [alarm(2)](http://www.tin.org/bin/man.cgi?section=2&topic=alarm) and [sigsuspend(2)](http://www.tin.org/bin/man.cgi?section=2&topic=sigsuspend). This means that this is an in-kernel question, not a userspace question. However, we know from [clock\_gettime(3)](http://www.tin.org/bin/man.cgi?section=3&topic=clock_gettime) that the kernel has multiple internal clocks. CLOCK\_MONOTONIC is defined as:

> Clock that cannot be set and represents monotonic time since some unspecified starting point.

This must be what’s used for alarm(), which makes sense.

On a related note:

Those annoying programs that behave very oddly when you change the system time are broken. They’re using [gettimeofday(2)](http://www.tin.org/bin/man.cgi?section=2&topic=gettimeofday) or something that derives from it (i.e. [time(2)](http://www.tin.org/bin/man.cgi?section=2&topic=time)) instead of properly calling clock\_gettime(CLOCK\_MONOTONIC).

<!--# include file="include/bottom.html" -->
