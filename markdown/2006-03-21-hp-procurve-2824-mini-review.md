<!--# set var="title" value="HP ProCurve 2824 Mini-Review" -->
<!--# set var="date" value="March 21, 2006" -->

<!--# include file="include/top.html" -->

I got one of [these](http://www.cdw.com/shop/products/default.aspx?EDC=530935) on demo through CDW, so I decided I’d blab about it here. Compare with a [Cisco Catalyst 2970](http://www.cdw.com/shop/products/default.aspx?EDC=511987), I think.

First impressions:

The console port is on the front, and is a nice standard DB9 instead of an RJ45 that needs a custom cable. This covers two of my running Cisco pet peeves.

The console interface feels like IOS at first, but issuing “setup” gets me a pseudo-GUI; nasty. STP was off by default, but enabling it in the GUI was easy enough. Output of “show spanning-tree” was certainly more intuitive than IOS.

SSH is built into the default firmware, and was pretty easy to enable with a bit of Google (can you say IOS clone?):

	configure
	crypto key generate ssh rsa
	ip ssh
	end

The only other concern I had was 802.3ad. The HP refers to this as “trunking” (argh), but it seems to be enabled (passive) on every port by default. This means that the aggregate just comes up in Linux and works.

Overall, the HP seems to offer the features that are critical to me plus a few nice usability enhancements over the Cisco. Given that it’s cheaper, I can’t think of a reason not to use them.

<!--# include file="include/bottom.html" -->
