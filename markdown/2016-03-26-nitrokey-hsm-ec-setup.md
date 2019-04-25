<!--# set var="title" value="Nitrokey HSM EC setup" -->
<!--# set var="date" value="2016-03-26" -->

<!--# include file="include/top.html" -->

Following up from my previous writeup on [creating an EC CA](2016-03-21-elliptic-curve-certificate-authority.html), let’s talk about key security.

[Hardware security modules](https://en.wikipedia.org/wiki/Hardware_security_module) are physical devices that manage keys. Generally, the rule is that they let you use the keys for operations (e.g. signing) given correct authentication, but don’t let you extract the raw key material. This means that if you’re holding the HSM, you know that no one else is currently abusing your key (though they may have done so in the past).

Searching for reasonably-priced options, I found the [Nitrokey HSM](https://shop.nitrokey.com/shop/product/nitrokey-hsm-7). Open source hardware, firmware, and software. Supports EC keys. Supports lots of keys. Supports Linux. Awesome.

<rant>Open source gets a bad rap sometimes, for the same reason PHP does: it has a low barrier to entry (that’s a simplification in pretty much all directions, but roll with it). That means there’s a lot of crap out there, because it’s so easy to start things without a significant audience and not hold to rigorous standards. Open source hardware, however, doesn’t have this excuse. You’re selling it. The fact that you publish the designs and the firmware is secondary; you’re still making money from it, and there’s no excuse for shipping shit that you haven’t actually finished turning into a product.</rant>

Below are the steps to get the Nitrokey HSM to a working state where it can generate an EC key pair, and (self-)sign a cert with it. Hopefully many of these go away in the future, as support percolates into release versions and distribution packages.

### Hardware & setup

These instructions were developed and tested on a Raspberry Pi. Base setup instructions are here. You’ll also need a Nitrokey HSM, obviously.

### Install prerequisites

    sudo apt-get install pcscd libpcsclite-dev libssl-dev libreadline-dev autoconf automake build-essential docbook-xsl xsltproc libtool pkg-config git

### libccid

You’ll need a [newer version of libccid](https://www.nitrokey.com/documentation/frequently-asked-questions#which-gnupg,-opensc-and-libccid-versions-are-required) than currently exists in Raspbian Jessie (1.4.22 > 1.4.18). You can download it for your platform here, or use the commands below for an RPi.

    wget http://http.us.debian.org/debian/pool/main/c/ccid/libccid_1.4.22-1_armhf.deb
    sudo dpkg -i libccid_1.4.22-1_armhf.deb

### Install libp11

engine\_pkcs11 requires >= 0.3.1. Raspbian Jessie has 0.2.8. Debian sid [has a package](https://packages.debian.org/sid/libp11-2), but you need the dev package as well, so you might as well build it.

    git clone https://github.com/OpenSC/libp11.git
    cd libp11
    ./bootstrap
    ./configure
    make
    sudo make install
    cd ..

### Install engine\_pkcs11

EC [requires engine\_pkcs11 >= 0.2.0](https://www.nitrokey.com/forum/viewtopic.php?t=1549). Raspbian Jessie has 0.1.8. Debian [sid also has a package](https://packages.debian.org/sid/libengine-pkcs11-openssl) that I haven’t tested.

    git clone https://github.com/OpenSC/engine_pkcs11.git
    cd engine_pkcs11
    ./bootstrap
    ./configure
    make
    sudo make install
    cd ..

### Install OpenSC

As of writing (2016/Mar/26), working support for the Nitrokey HSM [requires a build of OpenSC](https://www.nitrokey.com/documentation/frequently-asked-questions#which-gnupg,-opensc-and-libccid-versions-are-required) that hasn’t made it into a package yet (0.16.0). They’ve also screwed up their repository branching, so master is behind the release branch and won’t work.

    git clone — branch opensc-0.16.0 https://github.com/OpenSC/OpenSC.git
    cd OpenSC
    ./bootstrap
    ./configure
    make
    sudo make install
    cd ..

### Misc

    sudo ldconfig

### Initialize the device

    /usr/local/bin/sc-hsm-tool --initialize

If this tells you that it can’t find the device, you probably forgot to update libccid, and need to start over. You’ll need to set an SO PIN and PIN the first time. The SO PIN should be 16 characters, and the PIN 6. Both should be all digits. They can technically be hex, but some apps get confused if they see letters.

### Generate a test EC key pair

    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so---login --keypairgen --key-type EC:prime256v1 --label test

### Generate a self-signed cert

    openssl
    OpenSSL> engine -t -pre SO_PATH:/usr/lib/arm-linux-gnueabihf/openssl-1.0.0/engines/libpkcs11.so -pre ID:pkcs11 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/local/lib/pkcs11/opensc-pkcs11.so dynamic
    ...
    OpenSSL> req -engine pkcs11 -new -keyform engine -out cert.pem -text -x509 -days 3640 -key label_test -subj '/CN=test'

If you now have a cert.pem file, you’re golden. If you see “error in req”, you probably have a [bad version of OpenSC](https://www.nitrokey.com/forum/viewtopic.php?t=1549).

Now, delete the file, re-initialize the device, and you’re good to go.

More instructions on various Nitrokey HSM operations can be found [here](https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#init).

Instructions for running a complete certificate authority (CA) with your Nitrokey are [here](2016-03-27-ec-ca-redux-now-with-more-nitrokey.html).

<!--# include file="include/bottom.html" -->
