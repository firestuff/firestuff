<!--# set var="title" value="Redundant Network Interfaces" -->
<!--# set var="date" value="March 21, 2006" -->

<!--# include file="include/top.html" -->

I’ve been doing alot of work on methods for using multiple network interfaces on servers as redundant connections to the same network. There are a ton of methods for doing this, and several are actually useful, depending on your network configuration. Choose your own adventure:

1. Do you have control over your managed switches?<br>
   Yes? _Continue_. No? Step __#5__.
1. Are the interfaces connected to different switches?<br>
   Yes? _Continue_. No? Step __#4__.
1. Do you want your server to take over bridging as a last resort?<br>
   Yes? __STP__. No? __bonding:active-backup__.
1. Do you want your interfaces to share bandwidth when both are up?<br>
   Yes? __bonding:802.3ad__. No? __bonding:active-backup__.
1. Do you want your interfaces to share bandwidth when both are up?<br>
   Yes? __bonding:balance-alb__. No? __bonding:active-backup__.

### STP

This bonding method actually uses Linux’s support for interface bridging. If a bridge is set up between two interfaces connected to the same network and spanning tree protocol is activated, one interface will be put into blocking state and won’t pass traffic. This doesn’t aggregate bandwidth between interfaces when both are up, but it has the interesting effect of allowing the server to bridge traffic between the switches if there are no other available connections. Special configuration at the switches is required to prevent it from being used as a link under normal circumstances.

First, you’ll need the brctl program. In Debian, run:

	apt-get install bridge-utils

Then shut your interfaces down. Edit /etc/network/interfaces and disable the eth\* interfaces. Add a br0 interface with standard syntax and the added lines:

	bridge_ports eth0 eth1
	bridge_stp on

You’ll need to teach one switch on your network to really want to be the STP root bridge. This will prevent the bridge in Linux from becoming root in normal circumstances. In Cisco IOS:

	configure terminal
	spanning-tree vlan 1 priority 0
	end

On each switch port connected to your server, you’ll also need to increase the cost so the path is less preferred:

	configure terminal
	interface FastEthernet0/23
	spanning-tree cost 100
	end

Then, run on your server:

	ifup br0

You can then view the status of the bridge on the server with:

	brctl show
	brctl showstp br0

And on the IOS switches:

	show spanning tree

One side of one interface should be blocking.

### bonding

For any of the bonding methods, you’ll need the ifenslave program. In Debian:

	apt-get install ifenslave-2.6

You’ll also need at least one IP address on your network that can be monitored to see if links are up. Using more than one is advisable, in case one goes down. We’ll use 10.0.0.2 and 10.0.0.3 as examples here.

After probing the module with the appropriate mode option in each case, you’ll need to disable your eth\* interfaces in /etc/network/interfaces and add a bond0 interface. In Debian Etch, add the option:

	slaves eth0 eth1

In Sarge, you have to add:

	up ifenslave bond0 eth0 eth1
	down ifenslave -d bond0 eth0 eth1

Then run:

	ifup bond0

### bonding:active-backup

This bonding mode keeps one interface completely blocked (including not sending ARP replies out it), using it strictly as a backup.

First:

	modprobe bonding mode=active-backup arp_interval=500 arp_ip_target=10.0.0.2,10.0.0.3

Follow the general bonding instructions above, and you’re all set!

### bonding:802.3ad

This bonding mode uses the standardized IEEE 802.3ad bonding method, with a protocol (LACP) for both sides to agree on bonding information. All links must be the same speed and duplex. The balancing method between links is determined by each end; a single connection will only go over one link, and sometimes traffic with a single (ethernet-level) peer will use a single link as well.

First:

	modprobe bonding mode=802.3ad miimon=100

You’ll need to set up the interfaces on the switch side too:

	configure terminal
	interface FastEthernet0/1
	channel-protocol lacp
	channel-group 1 mode active
	end

After you’ve done this for all the interfaces:

	show etherchannel port-channel

Then follow the general bonding instructions.

### bonding:balance-alb

This bonding mode balances outgoing traffic accoridng to interface speed and usage. It intercepts and rewrites outgoing ARP replies to make them come from different physical interfaces, tricking the network fabric into balancing incoming traffic as well.

First:

	modprobe bonding mode=balance-alb arp_interval=500 arp_ip_target=10.0.0.2,10.0.0.3

Follow the general bonding instructions above, and you’re all set!

<!--# include file="include/bottom.html" -->
