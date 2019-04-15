<!--# set var="title" value="Raspberry Pi 3 + Serial Console" -->
<!--# set var="date" value="March 17, 2016" -->

<!--# include file="include/top.html" -->

Got my new RPi 3s. So exciting! Connect to my [serial cable](https://www.adafruit.com/products/954https://www.adafruit.com/products/954), fire up [Serial](https://itunes.apple.com/us/app/serial/id877615577?mt=12) on the Mac, ready to install my normal way, and….garbled garbage.

Turns out some winner in Piland re-used GPIO pins necessary to make serial work for Bluetooth. I guess they figured that no one used serial console?

To fix, you’ll need a monitor & keyboard. First follow the instructions [here](2016-03-13-raspbian-setup-notes.html) up through “Update firmware” (rpi-update). Then edit /boot/config.txt and add the line:

    dtoverlay=pi3-disable-bt

Reboot, and your serial console will work again.

<!--# include file="include/bottom.html" -->
