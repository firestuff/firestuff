<!--# set var="title" value="Why isn’t mod_auth_pam working with NIS?" -->
<!--# set var="date" value="February 26, 2006" -->

<!--# include file="include/top.html" -->

If you’re trying to authenticate against NIS from Apache using mod\_auth\_pam, you have a problem. All (sane) Apache configurations run as a non-privileged user. All (sane) NIS servers deny requests to shadow.byname originating from ports < 1024. If you check your NIS server logs, you’ll find request authentication errors.

If the server you’re running Apache on has no untrusted user processes (no shells, no Apache CGI uploading, etc.), you can disable port security for just that host on your NIS server. This isn’t much of a security risk; you better be within the same network if you were relying on port security anyway, so host-based security is just as good (it still sucks). Just before the uncommented lines in your /etc/ypserv.conf on your NIS master, add:

	<client IP address>:*:shadow.byname:none

Then restart ypserv et all. In Debian:

	/etc/init.d/nis restart

If your client machine does have untrusted users, there isn’t a nice solution, as far as I know.

<!--# include file="include/bottom.html" -->
