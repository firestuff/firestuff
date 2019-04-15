<!--# set var="title" value="WiFi client router setup" -->
<!--# set var="date" value="March 13, 2016" -->

<!--# include file="include/top.html" -->

I’ve still got two devices in my home that can’t do WiFi natively, but that I don’t have a good wiring solution for (one is an RPi that has a strange device on the USB bus that panics if anything else is on the USB bus, and the other is a FireTV with [issues](2016-02-01-hall-of-2-4-ghz-shame-2016-edition.html)). This is a great opportunity to use another Raspberry Pi as a WiFi client <-> wired connection, providing a wired drop wherever I want it.

If you search for this on the Internets, you discover a problem. While 802.11 looks like Ethernet, there’s a critical difference in this case. Most access points won’t let clients speak with anything other than their own MAC address. If you’re two or more devices (the client and the devices wired to it), you have a problem, with a few ugly solutions:

* [NAT](https://wiki.archlinux.org/index.php/Software_access_point). Everyone loves to hate it, and the problems compound as you put more layers of it in.
* [ebtables to rewrite MAC addresses](https://wiki.debian.org/BridgeNetworkConnections#Bridging_with_a_wireless_NIChttps://wiki.debian.org/BridgeNetworkConnections#Bridging_with_a_wireless_NIC). Ugly. Confuses your DHCP server, and who knows what else.
* [Proxy ARP and host static routes](https://wiki.debian.org/BridgeNetworkConnectionsProxyArp). Ugly again. More DHCP confusion.

If you’ve got a router at the front of your network that supports static routes, though, you’ve got a conceptually simpler option: build a wireless client router. This is still a lot of moving parts and things to go wrong, but those things are going to be more debuggable when they do.

### Shopping list

* [Raspberry Pi 2 Model B](http://www.amazon.com/Raspberry-Pi-Model-Project-Board/dp/B00T2U7R7I). This probably works fine with a Pi 3; I just haven’t tested it.
* A case of some sort. [This one](http://www.amazon.com/gp/product/B00S4H4ZTS) is my current preference (and I’ve tested rather a lot of them), for a nice balance of protection, heat dissipation, cost, and simplicity.
* A WiFi client adapter. If you have a Pi 3, you can use the builtin one, though you’re limited to 2.4 GHz. My preference is the [Linksys N900](http://www.amazon.com/gp/product/B007ZLGXA8). It works in Raspbian without extra drivers or firmware, and is dual band. If you know of an 802.11ac adapter that works out of the box, please let me know.
* A [USB extension cable](http://www.amazon.com/gp/product/B002KNI796), so you can zip tie the adapter to the RPi and not snap it off sticking out the USB port.
* The normal RPi must-haves: [USB power](http://www.amazon.com/gp/product/B012WLUKHC), [SD card](http://www.amazon.com/gp/product/B012DT8OJ4).

<img src="data:image/webp;base64,<!--# include file="images/wifi-router.webp.base64" -->" alt="">

[Install and configure Raspbian Lite](https://dev.firestuff.org/firestuff/2016-03-13-raspbian-setup-notes.html). [Get your device connected via WiFi](https://wiki.archlinux.org/index.php/WPA_supplicant). (Side note: the ArchLinux wiki is really great).

### Assign a static IPv4 address

Your wired side is going to need static addresses. These should be a different subnet than your existing private network. Strangely, in the new world, we configure static IPv4 addresses in /etc/dhcpcd.conf. Add a stanza that looks like:

    interface eth0
     static ip_address=10.167.0.1/16
     nolink
     noipv6rs

### Assign a static IPv6 address

You’ll need IPv6 addresses. These are going to be hard to keep in sync with IPv6 addresses on your main network; multi-level [prefix delegation](https://en.wikipedia.org/wiki/Prefix_delegation) does not seem to be a thing yet, though that’s likely the future. In the meantime, set up unique local addresses so you can at least talk within your network. Go [generate a unique local address block](https://www.ultratools.com/tools/rangeGenerator) to start with. Take the first address from that network (network::1) and configure it, this time in /etc/network/interfaces:

    auto eth0
    iface eth0 inet6 static
      address fd28:ec48:8874:bd68::1
      netmask 64
      accept_ra 0
      autoconf 0
      privext 0

Really, don’t just use the address from this page; generate your own.

### Enable router advertisements

    sudo apt-get -y install radvd

Add a stanza to /etc/radvd.conf that looks like:

    interface eth0
    {
      AdvSendAdvert on;
      prefix fd28:ec48:8874:bd68::/64
      {
      };
      RDNSS 2001:4860:4860::8888 2001:4860:4860::8844
      {
      };
    };

### Enable IP forwarding

Edit /etc/sysctl.conf and uncomment the lines:

    net.ipv4.ip_forward=1
    
    net.ipv6.conf.all.forwarding=1

### Set up a DHCP server

    sudo apt-get -y install isc-dhcp-server

Edit /etc/default/isc-dhcp-server and set:

    INTERFACES=”eth0"

Edit /etc/dhcp/dhcpd.conf, comment out the example junk, and add:

    option domain-name-servers 8.8.8.8, 8.8.4.4;
    
    subnet 10.167.0.0 netmask 255.255.0.0 {
      range 10.167.0.2 10.167.255.254;
      option routers 10.167.0.1;
    }

### Static IP and route

Now you need to assign a static IPv4 address to the wireless interface of the machine, and create static routes for both IPv4 and IPv6. You should do both of these in your primary router; Google for instructions. The examples below are for Cisco IOS, which is likely not very useful to you.

    ip dhcp pool bridge2
     host 10.66.0.3 255.255.0.0
     client-identifier 0194.103e.7eba.f2
    
    ip route 10.167.0.0 255.255.0.0 10.66.0.3
    
    ipv6 route FD8B:CF21:31AC:69DF::/64 FD8B:CF21:31AC:A8CD:AD7F:4B19:EBD9:34CB

### Reboot

Reboot your RPi to pick up all these changes.

### Caveats

Because of the lack of multi-level prefix delegation, hosts behind your new router won’t have IPv6 connectivity to the world. Fingers crossed to fix this soon.

Linux doesn’t activate IPv6 addresses on interfaces until those interfaces come up and it can do duplicate address detection. This means that you won’t be able to ping the IPv6 addresses on eth0 until it’s plugged into something.

<!--# include file="include/bottom.html" -->
