<!--# set var="title" value="Home video re-think" -->
<!--# set var="date" value="2010-04-10" -->

<!--# include file="include/top.html" -->

## Choosing a platform

There's no shortage of alternatives to the traditional cable box + TV model, from cable provider DVRs to [TiVo](http://www.tivo.com/) (yes, people actually still own those) to more obscure offerings like [Myka](http://www.myka.tv/), or [MythTV](http://www.mythtv.org/) running on your closest whitebox. However, if you want to combine easy content sourcing, central storage/management with streaming, a nice remote control interface and solid, attractive hardware, there's really only one option: for better or worse, Apple's [iTunes](http://www.apple.com/itunes/)/[Front Row](http://en.wikipedia.org/wiki/Front_Row_(software%29).

## Electronics

I already had an iMac that had ended up at a common-area computer desk in my apartment. This seemed a reasonable choice for a media server, though I suppose I could've shot for something that had a concept of running headless (another [Mac Mini](http://www.apple.com/macmini/)).

Output streams to the TVs had two options: the Mac Mini, or an [Apple TV](http://www.apple.com/appletv/). The Apple TV is smaller and cheaper, but you're locked out of all the real computing functionality (the LAN-party-on-TVs option disappears). It would be nice to be able to control these with just Apple's [media remote](http://store.apple.com/us_smb_78313/product/MC377LL/A), but it's just not practical; OS X is interrupty as hell, with updates and license agreements splattered all over. The [diNovo Mini](http://www.amazon.com/gp/product/B0011FOOI2/ref=oss_product) makes a decent keyboard/mouse combo that you can stuff in a drawer, but don't expect to game on it.

As actual displays, I went with [LED-backlit Samsung LCDs](http://www.samsung.com/us/consumer/tv-video/televisions/led-tv/UN40B7000WFUZA/index.idx?pagetype=prd_detail&returnurl=), for the lower power usage and the light weight for wall hanging. Add in [some](http://www.monoprice.com/products/product.asp?c_id=102&cp_id=10246&cs_id=1024603&p_id=5994&seq=1&format=2) [cables](http://www.monoprice.com/products/product.asp?c_id=102&cp_id=10218&cs_id=1021802&p_id=5576&seq=1&format=2) and we're good to go...except that it's all sitting on the floor.

## Wall mounting

Fortunately, my two TVs were wall mount efforts #6 and 7 for Kacirek, so this went really smoothly. I picked up [wall mount kits](http://www.monoprice.com/products/product.asp?c_id=108&cp_id=10828&cs_id=1082812&p_id=5918&seq=1&format=2) from Monoprice. In short: stud finder, level, pilot holes, lag bolts, bolts to the TV, hang, done. There are even nice [wall mount kits for Mac Minis](http://www.amazon.com/gp/product/B000UWI2LC/ref=oss_product), naturally at more than twice the price of the LCD mounts, since they count as "designer". The Mac Mini power adapter fits really nicely in a cable-management cutout at the back of the TV. Add in an extension cord and some cable management from Fry's, and voila:

[images lost in Picasa shutdown]

## Front Row love and hate

Front Row is, at times, awesome. It remembers pause position across different streaming clients. The interface is simple and useful. Over a fast network, seeking and fast-forward are lightning-quick. It doesn't let you set a default streaming source, but that only adds a couple of clicks.

Sometimes, it's horribly frustrating. It hangs indefinitely and uninterruptably trying to load remote library contents. It forgets pause position, even on the same machine. None of these are repeatable, so trying to solve them seems nigh-impossible.

## Unofficial content

iTunes also doesn't want you using their fancy toys with torrented files; it won't let you add them to your library, and if you change the file type to work around that, it still won't stream them to remote clients. Fortunately, this is pretty simple to work around. You need [Quicktime Pro](http://www.apple.com/quicktime/pro/), which comes with Final Cut Studio, is cheap to buy separately, or can be obtained by whatever means you like. It hides in Utilities once installed, and is easy to confuse with Apple's stripped-down but base-install Quicktime Player. Follow steps 1-4 [here](http://www.apple.com/quicktime/tutorials/hinttracks.html), and your torrented content is now draggable into iTunes and streamable to Front Row clients. It doesn't re-encode unless you do steps 5-8, so it's fast and you don't lose quality.

## Automatic wake-up

I also wanted waking up the Mini clients to automatically wake up the iMac file server, so I didn't have to leave it running all the time. Again, this isn't too hard. First, pick up [SleepWatcher](http://www.bernhard-baehr.de/), clearly written and packaged by someone who's never heard of dmg or a Makefile (but it works). Install [wakeonlan](http://gsd.di.uminho.pt/jpo/software/wakeonlan/), a tiny little PERL script that sends [Wake-on-LAN](http://en.wikipedia.org/wiki/Wake-on-LAN) magic packets. Then, add something to /etc/rc.wakeup like:

    COUNT=0
    while [ ${COUNT} -lt 10 ]; do
      /usr/local/sbin/wakeonlan 00:23:df:fe:c6:6d
      COUNT=$((COUNT + 1))
      sleep 1
    done

Your path to wakeonlan, MAC address (of your fileserver) and packet count (and time) required for your network interface to come online may vary.

## Hello, iPad?

It would be really great to be able to pull a Minority Report-style video transfer, moving streaming video seamlessly from a TV to the iPad and walking away with it. This is a pipe dream, however, until Apple decides to actually support streaming on the iPad. Seriously, Apple, I have to plug this thing in and copy the whole video to it to watch it?

<!--# include file="include/bottom.html" -->
