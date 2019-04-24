<!--# set var="title" value="Spanning Tree Protocol Introduction" -->
<!--# set var="date" value="March 16, 2006" -->

<!--# include file="include/top.html" -->

I’ve been considering increased network redundancy for awhile. After trying a few more things live than I should have, I decided to set up some gear in the lab and do some testing. First up is spanning tree.

STP is, simply, an ethernet-level protocol for disabling redundant links until they’re needed to avoid loops (which effectively kill ethernet networks). It works by electing a root “bridge” (meaning switch in this case). Every other bridge checks to see if it has more than one link to the root; if it does, it puts every link but one in blocking state. This lets you build neat redundant networks:

<img src="data:image/webp;base64,<!--# include file="images/stp.webp.base64" -->" alt="">

(__A__, __B__ and __C__ are switches; __1__ and __2__ are servers)

I just plugged the above arrangement in (three Catalyst 2950s) and it worked. STP is enabled on Cisco switches by default.

A little closer examination showed more details. On __B__:

	#show spanning-tree
	….
	This bridge is the root
	….
	Fa0/2 Desg FWD
	Fa0/3 Desg FWD

__B__ is the root, and both links out of it are “desg” — designated links to those switch segments and “FWD” — forwarding packets.

On __A__:

	#show spanning-tree
	….
	Fa0/1 Desg FWD
	Fa0/2 Root FWD

This is the first oddity: Fa0/1 links to __C__, and should be blocking. However, apparently only one end of each link blocks. The switch knows that Fa0/2 is a link to the root bridge.

On __C__:

	#show spanning-tree
	….
	Fa0/1 Altn BLK
	Fa0/3 Root FWD

This switch has realized that there’s a loop, and blocked the port that provides the longest route to the root bridge, as expected.

Now, I start a ping of __2__ from __1__. Then I unplug the link between __A__ and __B__ that is currently carrying the traffic. The ping stops. 49 seconds later, it starts again. The Fa0/1 interface on __C__ went from BLK to LIS to LRN to FWD.

Now, I plug the link back in. The ping stops again. Fa0/1 on __C__ sees the loop immediately and goes to BLK. The restored interface on __B__ goes to LIS, then LRN, and finally FWD. The ping resumes in 31 seconds.

Spanning tree isn’t particularly fast, and it doesn’t really “route”. Ethernet packets often traverse less-than-optimal paths through the switch fabric since STP doesn’t care where they came from or where they’re going; it only shuts down interfaces that might loop. Nevertheless, it’s simple and effective at building switch redundancy.

<!--# include file="include/bottom.html" -->
