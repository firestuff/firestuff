<!--# set var="title" value="Asynchronous name resolution in C" -->
<!--# set var="date" value="2016-03-01" -->

<!--# include file="include/top.html" -->

Down another rabbit hole, this time into yet another seemingly simple problem: how do you turn a name into an address that you can connect() to without blocking your thread, in 2016. Let’s survey state of the world:

## [getaddrinfo\_a()](http://man7.org/linux/man-pages/man3/getaddrinfo_a.3.html)

Look, it’s exactly what we need! Just joking. It’s has the same resolution behavior as getaddrinfo, but:

* It’s a GNU extension. This may matter to you or not, but it does tie you to glibc.
* It allocates memory and gives you no way to free it. Calling freeaddrinfo() doesn’t do it. The manpage doesn’t even seem to consider that one might want to free memory. It’s possible that it’s a first-time-only allocation that hasn’t made it into valgrind’s default suppressions yet.
* It uses [sigevent](http://man7.org/linux/man-pages/man7/sigevent.7.html) to notify completion. This gives you a choice between a signal and a new thread. I thought we were doing this to avoid having to create a new thread for each resolution?

## [libadns](http://www.gnu.org/software/adns/)

* It’s GPLed. That’s cool, but it does limit options.
* It’s a direct DNS library, not a getaddrinfo() implementation. That means you have to reproduce all the getaddrinfo() behavior, including the configuration file, if you want the behavior that users expect.
* It will hand you file descriptors to block on, but you have to ask (using adns\_beforeselect()). This is designed for poll(), but doesn’t work well with epoll; it doesn’t tell you when to add and remove fds, so you have to track them yourself (since you can’t iterate an epoll set), diff them since the last result, and change the epoll set. It’s a mess.

## [libasyncns](http://0pointer.de/lennart/projects/libasyncns/)

* It uses getaddrinfo() underneath, so you get standard behavior. Woo!
* It notifies you via a file descriptor. Unfortunately, it’s only a single file descriptor across all requests. It doesn’t allow you to associate a pointer with a request, epoll-style, so you still have to track your own query list and higher-level data associations.
* Its API isn’t too crazy, but you wouldn’t call it simple.

## [c-ares](http://c-ares.haxx.se/)

I failed to find docs for this, but I found a gist with an [example](https://gist.github.com/mopemope/992777). Looks like the API is designed for use with select(), though there’s a hook to get an fd when it’s created, so you might be able to associate it with a query, possibly unreliably. Again, you’d have to recreate getaddrinfo() behavior yourself. Also, this gem is at the top of the header:

    #elif defined(WIN32)
    # ifndef WIN32_LEAN_AND_MEAN
    # define WIN32_LEAN_AND_MEAN
    # endif
    # include <windows.h>
    # include <winsock2.h>
    # include <ws2tcpip.h>

So maybe not.

## So now what?

Maybe we can build something. I really don’t need to write another DNS library in my lifetime (the c-ares [Other Libraries](http://c-ares.haxx.se/otherlibs.html) page links to my previous one, humorously). Let’s see if we can scope some requirements:

* Asynchronous resolution
* Configurable parallelism
* Per-request notification via file descriptor
* Easy epoll compatibility, including associating pointers with requests
* Full getaddrinfo() compatibility

And some nice-to-haves:

* Tiny: doesn’t need to be a separate library
* Doesn’t expose internal state beyond the file descriptor
* Simple threading model that’s hard to screw up

After looking at all these libraries, you’d think this would be a massive job. In fact, it’s [127 lines of C](https://github.com/flamingcowtv/asyncaddrinfo/blob/master/asyncaddrinfo.c), and that’s with generous error checking and readability. Hopefully, I never have to solve this problem again.

<!--# include file="include/bottom.html" -->
