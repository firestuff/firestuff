<!--# set var="title" value="Confusing BIND with CNAMEs" -->
<!--# set var="date" value="2009-09-11" -->

<!--# include file="include/top.html" -->

Given the zone:

	subdomain IN NS nameserver
	nameserver IN CNAME nameserver.otherserver

in a BIND server that is both recursive and authoritative, requests without RD (recursion desired) return the NS record, while requests with RD return SERVFAIL. Changing it to:

	subdomain IN NS nameserver.otherserver

fixes the problem, though both resolution trees are perfectly valid.

<!--# include file="include/bottom.html" -->
