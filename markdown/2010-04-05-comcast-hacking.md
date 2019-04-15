<!--# set var="title" value="Comcast hacking" -->
<!--# set var="date" value="April 5, 2010" -->

<!--# include file="include/top.html" -->

I finally gave up on my principled stand against traffic shaping and switched to Comcast when I moved. The 10x speed for the same price over Speakeasy might have had something to do with it. It's been an interesting road getting it working as I wanted, and here's the notes list:

* D-Link modems don't work (well, at least). The one I got needed a custom firmware to work with Comcast according to D-Link's website, and the instructions for flashing the firmware included running a local TFTP server, then telnetting to the modem. Connection refused. Classy, guys. Took it back to Fry's, noticed that every single D-Link and Linksys cable modem box had a returned sticker on it. Bought a [Motorola SB6120](http://www.amazon.com/Motorola-SB6120-SURFboard-eXtreme-Broadband/dp/B001UI2FPE).
* [DOCSIS](http://en.wikipedia.org/wiki/DOCSIS) seems to support remote firmware flashing. The modem comes up with a firmware with the string "walledgarden" in the name, and all your connections get redirected to Comcast's activation page. The redirection is only DNS-level, though; switch to [Google Public DNS](http://code.google.com/speed/public-dns/) servers on your router/DHCP server/computer and you can surf just fine.
* [Speed](http://www.comcast.com/Corporate/Learn/HighSpeedInternet/speedcomparison.html) seems to be enforced per-account, not per-link. That means that they can't apply any speed package to you until you go through the activation wizard, which registers your modem's HFC-side MAC address with Comcast. The "walledgarden" speed actually appears to be Comcast's Ultra package (22/5mbps). That means that if you're not signed up for Ultra or Extreme (50/10), but chose Performance (12/2) or Blast! (16/2) instead, it's actually in your best interest to not activate.
* If you have to activate, the technician workflow is way easier: no installing software that messes with your network settings, and it works in Linux.

More on the great wireless network project coming soon.

<!--# include file="include/bottom.html" -->
