<!--# set var="title" value="More poll()/epoll fun" -->
<!--# set var="date" value="2016-03-02" -->

<!--# include file="include/top.html" -->

I generally assume that select(), poll(), and epoll are interfaces to the same thing. Sure, they have different input flags (notably, epoll suppports edge-triggered), but I expect that each is a superset of the previous, with a better interface for large numbers of fds.

Of course, though, there are quirks. poll() and epoll behave very differently if you’ve got some fds to regular files in the mix. I spent awhile chasing this, because people all over the web claim that poll() doesn’t work on regular files. It actually does; [this bug](https://bugzilla.kernel.org/show_bug.cgi?id=15272) has a decent description.

> If you look at fs/select.c, line 723 to 731, you notice that in case f\_op->poll is not provided by the device, DEFAULT\_POLLMASK is used as returned mask, where DEFAULT\_POLLMASK is defined as (POLLIN | POLLOUT | POLLRDNORM | POLLWRNORM).

> Later on, this DEFAULT\_POLLMASK is masked with your mask, which returns POLLIN, even though no test have been really performed with the device, since a file device does not provide an f\_op->poll() function.

> Epoll will fail you explicitly, while poll/select will not. but nothing meaningful is returned from poll/select on file system files.

Unfortunately, the poll() behavior is probably what you want (a regular file is always readable, because there’s either more data or you’re at EOF). If you want to get the same behavior in an epoll loop, you’ve got to keep a separate list of regular fds that failed epoll\_ctl(EPOLL\_CTL\_ADD) with EPERM, and treat them as always readable/writable within your code. Linux should really add an EPOLL\_SHUT\_UP\_I\_KNOW\_ITS\_JUST\_A\_FILE that emulates the poll() behavior and saves implementors the complexity.

<!--# include file="include/bottom.html" -->
