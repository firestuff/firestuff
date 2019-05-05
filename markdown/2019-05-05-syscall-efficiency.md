<!--# set var="title" value="Syscall efficiency" -->
<!--# set var="date" value="2019-05-05" -->

<!--# include file="include/top.html" -->

System calls have come a long way since the interrupt days. [vDSO](http://man7.org/linux/man-pages/man7/vdso.7.html) has moved many simple syscalls (e.g. `getpid()`) into pure userspace, making them as fast as indirect function calls.

That still doesn't work for I/O, though. Arkanis has some [simple measurements](http://arkanis.de/weblog/2017-01-05-measurements-of-system-call-performance-and-overhead) that show the difference between `getpid()` and `read()`, and it's clear that minimizing `read()` calls is still worth the effort.

So, how's the world doing on that? Here's [h2load](https://nghttp2.org/documentation/h2load-howto.html), an HTTP/2 load testing client that clearly has a reason for a performance focus, connecting and making 3 requests to a server:

    socket(AF_INET6, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 5
	setsockopt(5, SOL_TCP, TCP_NODELAY, [1], 4) = 0
	connect(5, {sa_family=AF_INET6, sin6_port=htons(443), inet_pton(AF_INET6, "...", &sin6_addr), sin6_flowinfo=htonl(0), sin6_scope_id=0}, 28) = -1 EINPROGRESS (Operation now in progress)
	epoll_ctl(4, EPOLL_CTL_ADD, 5, {EPOLLOUT, {u32=5, u64=4294967301}}) = 0
	epoll_wait(4, [{EPOLLOUT, {u32=5, u64=4294967301}}], 64, 59743) = 1
	getsockopt(5, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
	write(5, "\26\3\1\2\0\1\0\1\374\3\3$Xo\3a5:I\275\351Ge;\216b\201\300\312.\202\326"..., 517) = 517
	read(5, 0x7fd01ac32ac3, 5)  = -1 EAGAIN (Resource temporarily unavailable)
	epoll_ctl(4, EPOLL_CTL_MOD, 5, {EPOLLIN, {u32=5, u64=8589934597}}) = 0
	epoll_wait(4, [{EPOLLIN, {u32=5, u64=8589934597}}], 64, 59743) = 1
	read(5, "\26\3\3\0z", 5)    = 5
	read(5, "\2\0\0v\3\3\233\317P\30\33f\17\3772\6K\2446\267N\304\313\232\177\364\224\n\334\37\324{"..., 122) = 122
	read(5, "\24\3\3\0\1", 5)   = 5
	read(5, "\1", 1)            = 1
	read(5, "\27\3\3\0 ", 5)    = 5
	read(5, "8\315\331bnq\370w\346+j~\310\330\213\30\17\301~9\200ezU:\321\228\6\274\365\212", 32) = 32
	read(5, "\27\3\3\n!", 5)    = 5
	read(5, "\265\366\242\vqr\241\260\373G\325\370\330\227A\376e\243JY\317\340\226x}Fo\\\364=\306\306"..., 2593) = 2593
	read(5, "\27\3\3\1\31", 5)  = 5
	read(5, "&\356\321\337\346\240q\317\n\307^\23\362\1\35]D\304gc\334\302\367\340\34C\273\313\316\307yo"..., 281) = 281
	read(5, "\27\3\3\0E", 5)    = 5
	read(5, "\246m\377@\212@\244\276#vB\211\362\277\23-\17>\324c\237\5\265\265<\370\276\374\20k\353\352"..., 69) = 69
	write(5, "\24\3\3\0\1\1\27\3\3\0E)\235\322 \3\247N\216\202\300+\200\25K\177\341\376\300\212\235k"..., 80) = 80
	write(5, "\27\3\3\0\200\314Z.\260t2\0\336\315\351L&\256\221\344\222\2453;\201\n\223\305\r\27=\260"..., 133) = 133
	epoll_wait(4, [{EPOLLIN, {u32=5, u64=8589934597}}], 64, 59743) = 1
	read(5, "\27\3\3\0J", 5)    = 5
	read(5, "\325\27U^\346\20\2\320\266h\215\356DV\168\300K+\265\f\316|\355\337h\361\177\242V\213\271"..., 74) = 74
	read(5, "\27\3\3\0J", 5)    = 5
	read(5, "\0012/\311\351g\270\201\3176\273\245t\230[\257\336j3,\377\365\356\213W\225\301K\304\371\334l"..., 74) = 74
	read(5, "\27\3\3\09", 5)    = 5
	read(5, "yz,\375\306\0177T-\313M\7\256\376\r\vpY\215\222m\233\16\n\364\345\201\235\302\n\276\255"..., 57) = 57
	read(5, "\27\3\3\0\32", 5)  = 5
	read(5, "\346^[\215\243iA\324\343\37\200\245\311\270\331S\332\243\311\261\236\325\374\237\v\247", 26) = 26
	read(5, 0x7fd01acb91c3, 5)  = -1 EAGAIN (Resource temporarily unavailable)
	write(5, "\27\3\3\0\32\377Imr\325\234U\307Ez\253Un\346\276\6P\256\262\214\260\324J\250,\274", 31) = 31
	epoll_wait(4, [{EPOLLIN, {u32=5, u64=8589934597}}], 64, 59743) = 1
	read(5, "\27\3\3\0s", 5)    = 5
	read(5, "\225\322\26\225\266\356\305hL\6\232)_\242_\310P\32H|zL\277\351c?\317\7G\252Z]"..., 115) = 115
	read(5, 0x7fd01acb91c3, 5)  = -1 EAGAIN (Resource temporarily unavailable)
	write(5, "\27\3\3\0%L\334\214\234\245X}1\213\4\0\3*bky\370:\344\357T\316\360\342\f\243;"..., 42) = 42
	epoll_wait(4, [{EPOLLIN, {u32=5, u64=8589934597}}], 64, 59743) = 1
	read(5, "\27\3\3\0s", 5)    = 5
	read(5, "\351+\3gyf\305.V\272\373\354\240\231UI\222\25oq\244\200\0255c\221\301\t\2m\273\326"..., 115) = 115
	read(5, 0x7fd01acb91c3, 5)  = -1 EAGAIN (Resource temporarily unavailable)
	write(5, "\27\3\3\0%\300\337r\tR\252O,2\223B\256b\222\271\5\322\265\227\243\327\304G\10\272_3"..., 42) = 42
	epoll_wait(4, [{EPOLLIN, {u32=5, u64=8589934597}}], 64, 59743) = 1
	read(5, "\27\3\3\0s", 5)    = 5
	read(5, "\323D\n\313\323\2\353q\324\210\317\213\30\2550\3738L\200D<\326\214b\366\24\335\"\31\311w\223"..., 115) = 115
	read(5, 0x7fd01acb91c3, 5)  = -1 EAGAIN (Resource temporarily unavailable)
	write(5, "\27\3\3\0\"\217P\25^*\232\311vCy=u\207;~\"Gf\203h\247\25m&\255\272`"..., 39) = 39
	write(5, "\27\3\3\0\23\234SF\221\214\213\7<\336`\316\252\315\307\204\3\342AL", 24) = 24
	shutdown(5, SHUT_WR)        = 0
	close(5)                    = 0

(╯°□°)╯︵ ┻━┻

If you don't spend a lot of time reading `strace` output, that may not look odd or bad. It's a complete mess, though. Here's what stands out:

* The socket is created with `SOCK_NONBLOCK`. That's useful in some niche cases, but here it's mixed with `epoll_wait()` and this code is one-socket-per-thread anyway. That leads to behavior like calling `connect()`, getting `EINPROGRESS` back, and immediately calling `epoll_ctl()` and `epoll_wait()` to reconstruct blocking `connect()` behavior.
* `TCP_NODELAY` is set on the socket. That can be great if you know that you're writing chunks that should go out immediately. In this code, though, there are multiple `write()` calls one after another. With `TCP_NODELAY`, those get broken into separate packets, with lots of wasted overhead on the wire and at both ends.
* There's a call to `getsockopt(SO_ERROR)` just before a call to `write()`. If the socket was closed, the `write()` would fail with a distinct errno, so the `getsockopt()` is redundant.
* Wow, that's a lot of `read()` calls. Lots of small calls that are fulfilled with all the bytes they asked for, then immediately another `read()` for more data. h2load doesn't do this in unencrypted mode, so it's probably OpenSSL's fault.
* `shutdown()` gets called just before `close()` on the same file descriptor, uselessly.

Issues like this frequently creep in with abstractions. Attempts to separate layers of parser logic, or to make the OpenSSL library API sensible, require you to do work in discrete chunks. It's possible to work around much of it with good buffer usage, but it can complicate things.

Want to avoid this in your code? Some suggestions:

* Make a conscious choice of model, rather than stumbling into one. Are you using `epoll` or one-socket-pre-thread?
* Consider [optimisitic parsing](2019-05-05-optimistic-parsing.html).
* Avoid non-blocking sockets (`SOCK_NONBLOCK` and `O_NONBLOCK`). You really don't need them in either model.
* Use [`readv()`](https://linux.die.net/man/2/readv) and [`writev()`](https://linux.die.net/man/2/writev). They let you avoid copying in/out a buffer for I/O if you're dealing with complex structures. Copies are better than syscalls, but they're still not free.
* Only set `TCP_NODELAY` if you're being careful with `write()`.
* Don't pre-check for failure (`getsockopt(SO_ERROR)`). The socket can still go into error state between that call and your next `read()` or `write()`, so you have to handle errors in those anyway. That means the pre-check is useless, even if it catches 99% of closed connections.
* Run your code under `strace` regularly during development, and explain to yourself why each syscall is there.

<!--# include file="include/bottom.html" -->
