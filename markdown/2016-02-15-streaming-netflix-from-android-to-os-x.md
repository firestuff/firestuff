<!--# set var="title" value="Streaming Netflix from Android to OS X" -->
<!--# set var="date" value="2016-02-15" -->

<!--# include file="include/top.html" -->

Among other excitement, having a baby leads to a lot of time spent bored but not wanting to move for fear of waking the kraken. The phone is usually in reach, but unless you’re good at planning, often nothing else is. We’re cord cutters, and there’s no TV in our living room. There is an iMac, great for watching media, if you can get it playing the right thing.

This is an ideal case for Chromecast: Netflix support, remote control from a simple Android UI, etc. Great, so how do I Chromecast to a computer? Of course, not so easy.

There’s a Python app called [Leapcast](https://github.com/dz0ny/leapcast) that tried to implement just this. As with many attempts to keep up with proprietary protocols, it’s currently (2016/Feb) broken after a Chromecast change, and appears to have been for some time. No luck there.

What about HDMI capture of a real Chromecast? Stop me if you’ve heard this before: that perfectly reasonable use case is broken because of fear of piracy. Specifically in this case, broken by [HDCP](https://en.wikipedia.org/wiki/High-bandwidth_Digital_Content_Protection). For the umpteenth time in my life, I find myself bypassing copy protection for a purpose that isn’t piracy. And it’s not that hard; certainly not hard enough to stop an actual pirate. I would know.

Go buy:

* A [Chromecast](https://www.google.com/intl/en_us/chromecast/buy-tv/). You can’t buy them from Amazon anymore because they’re trying to prop up their disaster of a media platform.
* An [HDMI capture device](http://www.amazon.com/Elgato-Capture-PlayStation-gameplay-1080p/dp/B00MIQ40JQ). Chromecast supports 1080p60, so consider getting a capture device that does too.
* An HDMI splitter that conveniently forgets to use HDCP on its outputs, aka an [HDCP stripper](https://www.amazon.com/gp/aw/d/B004F9LVXC).

Plug them into each other and into your computer, start the capture software, enable 60fps input, full screen it, then wait a moment for the UI to hide. Set up the Chromecast as normal. Enjoy.

<!--# include file="include/bottom.html" -->
