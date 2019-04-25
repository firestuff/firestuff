<!--# set var="title" value="Fixing your home/SOHO network" -->
<!--# set var="date" value="2006-12-05" -->

<!--# include file="include/top.html" -->

This post is going to stray a bit from my usual geeky fare. I’m being asking far too much to help sort out haphazard home network designs that are causing real problems for their users. I decided to collect all the answers that I’ve given together in a single place that I can point to when asked.

## General Principles

Simplicity

> Rule #1 in any network design is simplicity. Most of the instructions here are built on this rule. At it’s simplest: if you don’t need a device, take it out. If a device does more things than you’re using it for, replace it with something that does less or turn those functions off.

You get what you pay for

> A Cisco Aironet is going to crash less than a Linksys access point. A Cisco switch is going to provide better throughput than a NetGear one. This isn’t a hard-and-fast rule; there are certainly decent, cheap network devices out there. However, generally, if a device has a plastic case and an external power supply and you’ve got more than 3 people depending on it, you’re going to regret the decision.

## Sorting out the devices

1. Diagram your network. Knowing what you have and how it’s all connected together is a critical first step toward fixing any of it. A complete diagram looks like:<br>
   <img src="data:image/webp;base64,<!--# include file="images/sample-network.webp.base64" -->" alt=""><br>
   (the diagram above was made with [dia](http://dia-installer.sourceforge.net/), a free diagramming software)
1. Count up devices doing Network Address Translation (NAT; sometimes referred to as PNAT). These are usually marketed as routers or firewalls. It’s common (and completely acceptable) to have __one__ such device, directly connected to the Internet and “in front” of all other devices. There should never be more than one; doing multiple translations will cause nothing but problems. The one such is device is also the most likely failure point; this is the place to spend real money. However, avoid anything labeled “firewall” unless you really know that you need some feature that it offers. NAT alone is enough to keep out any attacks that connect in from the Internet.
1. Repeating myself form the previous step: look __hard__ at your diagram. Do you see any routers that could be replaced with switches? Do you see any wireless routers that could be replaced with wireless access points?
1. Remove any hubs, replacing them with switches. Hubs have been obsolete for years, but they still seem to exist in many installations.
1. Have everyone close the applications on their computers (but not log out) for a moment. Watch the activity lights on your switches/routers/access points. They should be mostly solid, with perhaps one or two blinks per second. Got a light that’s still flashing like mad? You might have a virus infection and a computer spewing out spam or virus attacks. Use the activity lights to trace down the source and figure out what’s causing it. Remember: virus scanners don’t work. Reinstall the machine, give the user a Limited account (as opposed to “Computer Administrator”), and refuse to install any software for them unless it’s critical to their job.
1. Make sure that you only have one DHCP server on your network. More than one will likely cause some machines to get incorrect IP addresses and be unable to go anywhere. Testing for this is a little difficult. First, burn an Ubuntu CD. Reboot with the new CD in your drive, and your system should boot into the Ubuntu environment. Open a terminal window (Applications -> Accessories -> Terminal) and type:

   ```sudo ifdown eth0
   sudo dhclient eth0
   ```

   You should see one or more lines starting with DHCPOFFER and telling you where the offer came from. If you see more than one source of offers, you need to eliminate extra DHCP servers.

## Troubleshooting slowness

By far the most common network issue seems to be nebulous “slowness”. We’ll try to eliminate possibilities one by one.

1. You’ll need the exact hostname of the service you’re trying to access. For example, if it’s slow when you try to visit http://firestuff.org/ in a web browser, then firestuff.org is the hostname. Pull out your Ubuntu CD again, and in a terminal, type:

   ```host firestuff.org```

   (obviously, replace firestuff.org with the hostname you’re concerned with)

   This converts firestuff.org into an IP address using DNS. It should take less than a second to complete. If it takes much longer, either your ISP’s DNS servers or those that provide the firestuff.org data may have problems. To narrow it down, try:

   ```host www.google.com```

   If that returns instantly, then it’s the firestuff.org DNS servers that have problems; contact the administrator there. If the Google test also takes a long time, your ISP has a DNS server problem, or you have the wrong DNS servers configured in your DHCP server. Type:

   ```cat /etc/resolv.conf```

   then call your ISP and read it to them. If the numbers aren’t what your ISP says they should be, reconfigure your DHCP server. If they are, ask what the holdup is.
1. Try the same thing from other computers on your network.
1. Try similar things from the same computer. If an Internet-based application from company X is slow, try another part of the application. Then try company X’s website. Then try Google. The combination of answers should give you a good idea who’s at fault.
1. Try plugging the same computer into different points in the network. Generally, it helps to move it up to where it has to traverse less devices (i.e. towards the “Internet”) until the problem stops. Then move it back down again, to make sure that the issue wasn’t temporary and your solution a fluke.
1. Open your Ubuntu terminal and run:

   ```mtr firestuff.org```

   You’ll want to make the window a bit bigger. This application gives you real time timing data following the route from your network to firestuff.org. Watch the average times and loss percentages. Nothing above 0% is really acceptable loss; your ISP will probably claim that it is, but they’re lying. Remember that the numbers are cumulative; if hop 3 is dropping packets, those drops will effect hop 3 and everything beyond it. However, it’s really hop 3’s problem, and if hop 6 has a problem, it’ll be hard to see until you get the closer issue cleared up.

## Troubleshooting idle disconnects

Do you have long-running connections (SSH, telnet, MySQL, etc.) that get disconnected when they’re not doing anything? It’s your NAT device’s fault. Period. If it doesn’t have a setting to change the maximum idle time for a connection, throw it out and buy one that does.

## Troubleshooting wireless problems

1. Does rebooting your wireless router/access point fix it? Throw it out and buy a real one (I kept buying new Linksys/NetGear products until I gave up and started buying Cisco. Oddly, since then, things work).
1. Are you in an area with a lot of access points? Time to switch to 802.11a; the hardware’s more expensive and less often included by default in laptops, but there are many more distinct channels (802.11b/g only has 3) and fewer other users.

I’m rather hoping that the geek readers will contribute a few of the complaints that they regularly hear from family members et al and their solutions below.

<!--# include file="include/bottom.html" -->
