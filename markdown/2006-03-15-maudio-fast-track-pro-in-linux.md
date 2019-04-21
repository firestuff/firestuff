<!--# set var="title" value="M-Audio Fast Track Pro in Linux" -->
<!--# set var="date" value="March 15, 2006" -->

<!--# include file="include/top.html" -->

Guitar Center had [these](http://www.musiciansfriend.com/product?sku=241710) on sale cheap, and I couldn’t resist. It claimed to be “class compliant” on the box for 2 channel input and 4 channel output at 16-bit/48khz, so I figured it was worth a try.

Much to my amazement, it actually works. At least, mostly. I get the following in /sys/class/sound:

	adsp
	audio
	controlC0
	dmmidi
	dsp
	midi
	midiC0D0
	mixer
	pcmC0D0p
	pcmC0D1c
	pcmC0D1p

mplayer can play to both stereo output channels on the device, but only at 16-bit/44.1khz, as far as I can tell:

	mplayer -ao alsa:device=hw=0.0

	mplayer -ao alsa:device=hw=0.1

Both streams work at once (the headphone stream switch button on the front is really nice), and it sounds great!

<!--# include file="include/bottom.html" -->
