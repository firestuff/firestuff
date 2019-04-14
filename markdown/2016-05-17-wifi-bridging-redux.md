<!--# set var="title" value="WiFi bridging redux" -->
<!--# set var="date" value="May 17, 2016" -->

<!--# include file="include/top.html" -->

I previously wrote about building [WiFi client routers](https://medium.com/where-the-flamingcow-roams/wifi-client-router-setup-9712a5f943e4#.z3wzhlub9) instead of bridges; they get you broadcast domain isolation and a degree of conceptual simplicity (no L2 tricks). I finally ran into a requirement on a different project to build an actual bridge; here’s how I did it.

You can copy the hardware from the router post, or use what you’ve got; I don’t believe this is driver-specific.

Your access point, however, does require support for this to work. It needs to:

* Make use of [4-address WDS](http://madwifi-project.org/wiki/AboutWDS). Basically, this means “don’t assume that the source MAC address of the ethernet frame and the source MAC address of the WLAN frame are the same”.
* Allow frames where the ethernet and WLAN source MAC addresses differ (like above, but a policy decision).
* Not assume that the WLAN MAC address is the only MAC at the other end of the link. This assumption is frequently used to reduce the effect of broadcast traffic in a WiFi environment by filtering. There may be settings like “Multicast optimization”, “Broadcast optimization”, or “DHCP optimization” that you need to turn off.

### Bridging

Linux supports bridging. There’s a bridge-utils package in Ubuntu with the tools you need:

    sudo apt-get install bridge-utils

To see current bridges, run:

    brcrl show

However, you can’t normally add a WiFi interface to a bridge:

    $ sudo brctl addif br0 eth0 wlan0
    can't add wlan0 to bridge br0: Operation not supported

Googling this error produces a wide range of well-meaning yet completely unhelpful results.

### Enable 4 address mode

To be able to add a WiFi interface to a bridge, you have to put it into 4-address mode first:

    # If necessary:
    # sudo apt-get install iw
    sudo iw dev wlan0 set 4addr on

From that point forward, the interface won’t be able to talk normally, and wpa\_supplicant is likely to time out in the association phase (run “sudo wpa\_cli” to watch its logs).

Now add the interface to a bridge:

    sudo brctl addif br0 wlan0

You should now be able to fetch an IP on br0 via DHCP. Unless, of course, you need wpa\_supplicant to work…

### wpa\_supplicant

wpa\_supplicant needs to be bridge-aware to work with 4-address mode. Fortunately, it has a flag (-b) to set the bridge interface. Unfortunately, this flag is broken in 2.1, the version in Ubuntu Trusty. I verified that it works in wpa\_supplicant 2.5 built from source; I haven’t verified 2.4 from Xenial.

A wpa\_supplicant commandline looks something like:

    wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -C /var/run/wpa_supplicant -P /var/run/wpa_supplicant.wlan0.pid -b br0

With that working, the interface should get to wpa\_state=COMPLETED, and br0 should work normally. Remember that wlan0 will still be unusable directly.

### Ordering

Bringing up these interfaces is tricky; the ordering is annoying.

* 4-address mode has to be on before you can add wlan0 to br0
* br0 must exist before you can start wpa\_supplicant
* wpa\_supplicant must be running before you can get an IP address on br0

### Putting it together

Because of the ordering issues, it’s easier to treat this all as one interface that has to come up together. Here’s an example interface stanza that does this:

    auto br0
    iface br0 inet dhcp
      pre-up /sbin/iw dev wlan0 set 4addr on
      pre-up /sbin/brctl addbr $IFACE || true
      pre-up /sbin/start-stop-daemon --start --pidfile=/var/run/wpa_supplicant.wlan0.pid --exec=/usr/local/sbin/wpa_supplicant --user=root -- -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -C /var/run/wpa_supplicant -P /var/run/wpa_supplicant.wlan0.pid -b $IFACE
      bridge_ports eth0 eth1 wlan0
      post-down /sbin/start-stop-daemon --stop --pidfile=/var/run/wpa_supplicant.wlan0.pid --exec=/usr/local/sbin/wpa_supplicant --user=root
      post-down /sbin/iw dev wlan0 set 4addr off

We use start-stop-daemon because it provides idempotence and safety from stale PID files.

<!--# include file="include/bottom.html" -->
