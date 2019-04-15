<!--# set var="title" value="Hall of 2.4 GHz Shame, 2016 Edition" -->
<!--# set var="date" value="February 1, 2016" -->

<!--# include file="include/top.html" -->

We finally mostly live in the WiFi future. Dual band access points are more common than not, and there are [cloud managed consumer models](https://on.google.com/hub/). [802.11ac](https://en.m.wikipedia.org/wiki/IEEE_802.11ac) is de rigueur and flavors of [MIMO](https://en.m.wikipedia.org/wiki/MIMO) are in abundance. [DFS](https://en.m.wikipedia.org/wiki/IEEE_802.11h-2003) counterbalances the ever expanding channel width issues in 5 GHz with more available channel space.

The 2.4 GHz disaster area, however, lives on. Its wall penetrating abilities, once a selling point, now terrorize apartment complexes. Even in my detached house, a WiFi scanner left open overnight has a list of 2.4 GHz BSSIDs that requires scrolling, stomping over each other on the three effective channels. There’s even a [2.4 GHz 40 MHz](http://www.smallnetbuilder.com/wireless/wireless-features/31743-bye-bye-40-mhz-mode-in-24-ghz-part-1) BSSID in there, to my horror (and it’s a printer!).

Why can’t we have nice things? Access points let you turn off 2.4 GHz and leave all this behind, right? [Beamforming](https://en.m.wikipedia.org/wiki/Beamforming) and other fanciness gets us range in 5 GHz, right? Worst case, [mesh access points](https://www.eero.com/) are becoming a consumer thing, and we can get stations close to every client, right?

Wrong. Unfortunately, there are still device manufacturers out there who think that dual band is only for fancy people, not for their devices. The extra dollar for the better chip and antenna would blow their margins.

Let’s start with the good news: those who have recently learned their lessons.

* The [Chromecast 2](https://www.google.com/intl/en_us/chromecast/tv/) adds 802.11ac support, where the previous version only supported 2.4 GHz. Unfortunately, its antennas are still tiny, so sandwiching it behind a wall-mount TV is style over substance. It also has a [strange problem with 802.11r](https://code.google.com/p/google-cast-sdk/issues/detail?id=676).
* The [FireTV Stick](http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG) supports 5 GHz 802.11n, but amazingly not the DFS channels. The [FireTV](http://www.amazon.com/gp/product/B00U3FPN4U) adds 802.11ac, but is still broken for DFS.
* The [third generation](http://www.amazon.com/Nest-Learning-Thermostat-3rd-Generation/dp/B0131RG6VK) of the Nest Thermostat adds 5 GHz support, though 802.11n only.
Google’s Nexus line has supported 802.11ac for awhile now. However, at least the Nexus 9 was [quirky](https://productforums.google.com/forum/#!topic/nexus/_dOk9Jfv9CA) in 5 GHz. The [Pixel C](https://pixel.google.com/pixel-c/) seems to be fine.

On to the ugly:

* The [Nest Protect](https://nest.com/support/article/Nest-Protect-2nd-generation-system-requirements-and-technical-specifications), while cool, is 2.4 GHz only. Presumably, this is because the wired and battery-only models need to communicate and saving battery is critical on the latter.
* Chamberlain’s [connected garage door gear](http://chamberlain.custhelp.com/app/answers/detail/a_id/6067/~/why-wont-the-wi-fi-garage-door-opener-or-myq-garage-%28wi-fi-hub%29-connect-to-my) is 2.4 GHz only. This is a bit more sad, since it’s all wired power.
* The [DragonBoard 410c](https://developer.qualcomm.com/hardware/dragonboard-410c), the new hotness in the Raspberry Pi-like world, is 2.4 GHz only. More power budget problems?
* [Amazon Dash Buttons](https://www.amazon.com/oc/dash-button) seem to be yet another low-power case; 2.4 GHz only.

It’s nice to see this list getting shorter. It’s sad to see brand new devices or top-of-product-line devices shipping with 2.4 GHz only.

<!--# include file="include/bottom.html" -->
