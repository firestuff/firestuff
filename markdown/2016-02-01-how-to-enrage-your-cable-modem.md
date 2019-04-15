<!--# set var="title" value="How to enrage your cable modem" -->
<!--# set var="date" value="February 1, 2016" -->

<!--# include file="include/top.html" -->

I have an [Arris SB6183](http://www.amazon.com/ARRIS-SURFboard-SB6183-DOCSIS-Cable/dp/B00MA5U1FW). While setting up a new (non-consumer) router behind it, I kept managing to trigger a modem protection mechanism. The router’s MAC address would disappear from the modem’s list of client addresses, and the modem would refuse to talk to the router at all.

At first I assumed that I’d accidentally set up a DHCP server facing the cable modem, and it was blocking me to prevent pollution of the local broadcast domain.

    sudo tcpdump -i <network-interface> port 67 or port 68 -v -e -n

Just DHCP requests from my router, going unanswered, and broadcast replies to requests from other clients.

Next up: add config settings one by one and see what breaks it.

Turns out, enabling IPv6 causes it reliably. Apparently, Cisco IOS routers begin spewing IPv6 router advertisements when you turn on IPv6. You can [sniff these](https://www.prolixium.com/mynews?id=804) (thanks prox). You can also [suppress them](http://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipv6/command/ipv6-cr-book/ipv6-i3.html#wp2583862361).

<!--# include file="include/bottom.html" -->
