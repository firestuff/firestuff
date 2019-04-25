<!--# set var="title" value="udev is your friend" -->
<!--# set var="date" value="2006-03-02" -->

<!--# include file="include/top.html" -->

Well, not completely. Most of us have had a udev install eat /dev and make the machine unbootable at least once. However, when it works, it’s really neat.

We have cash register machines at CORESense with two touchscreens attached; one facing the cashier and one facing the customer (they work as kiosks when they’re not in use for checkout). The problem is that the touchscreen inputs are USB event interfaces which are sequentially numbered, and the startup order isn’t always the same. This means that you can’t give X a device name, because it changes every bootup. Enter udev.

I put this in /etc/udev/rules.d/coresense.rules:

	KERNEL==”event[0-9]*”, SYSFS{name}==”Elo *”, NAME=”coresense/elo-$sysfs{uniq}”

This matches event interface devices with the given name pattern, and creates device nodes in /dev/coresense with the device serial number in the device name. Poof - repeatable names.

<!--# include file="include/bottom.html" -->
