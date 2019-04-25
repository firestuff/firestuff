<!--# set var="title" value="Raspbian setup notes" -->
<!--# set var="date" value="2016-03-13" -->

<!--# include file="include/top.html" -->

I’ve been growing a document of setup notes for a new Raspberry Pi running Raspbian for awhile. Raspberry Pis are a problem for me, because it’s easy to have lots of them doing lots of tasks, so I do, everywhere. I thought I’d publish these notes, glommed together from various sources, in case they’re useful for others.

While many of these may work on other hardware and software, they’re regularly tested on [Raspberry Pi 2 Model B](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/) with Raspbian Lite Jessie.

I should really script this.

Start with [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/). NOOBS has an extra boot step, and Raspbian full version has a GUI and stuff like Wolfram Engine that you probably don’t want.

### Log in

Use console, or grab the IP from your router’s DHCP client list and:

    ssh pi@<ip address>
    # password "raspberry"

### Expand filesystem

    sudo raspi-config --expand-rootfs
    sudo reboot

Wait for reboot. Reconnect as above.

### Update

    sudo apt-get -y update
    sudo apt-get -y dist-upgrade

### Update firmware

    sudo apt-get -y install rpi-update
    sudo rpi-update

### Enable overclock (optional)

Pis seem to be relatively stable overclocked, even without a heatsink.

    sudo raspi-config
    # Select "8 Overclock"
    # Select "<Ok>"
    # Select "High"
    # Select "<Ok>"
    # Select "<Finish>"
    # Select "<No>"

### Disable swap

    sudo dphys-swapfile uninstall

### Create a new user

    sudo adduser <username>
    # Follow prompts
    sudo usermod --append --groups sudo <username>

### SSH in as the new user

    # ON YOUR PI
    # Find your Pi's current IP, you don't know it
    ifconfig
    # ON ANOTHER MACHINE
    # If you don't already have an SSH key pair
    ssh-keygen -t ed25519
    cat ~/.ssh/id_ed25519.pub
    # Copy your key to your Pi
    ssh <username>@<ip> mkdir .ssh
    # Enter password
    scp ~/.ssh/id_ed25519.pub <username>@<ip>:.ssh/authorized_keys
    # Enter password
    # Connect to your Pi; this should NOT ask for a password
    ssh <username>@<ip>

### Lock down sshd

The SSH server has a lot of options turned on by default for compatibility with a wide range of clients. If you’re connecting only from modern machines, and you’ve gotten public key authentication working as described above (and tested it!), then you can turn off lots of the legacy options.

    sudo tee /etc/ssh/sshd_config <<END
    Port 22
    Protocol 2
    HostKey /etc/ssh/ssh_host_ed25519_key
    UsePrivilegeSeparation sandbox
    # Logging
    SyslogFacility AUTH
    LogLevel INFO
    # Authentication:
    LoginGraceTime 120
    PermitRootLogin no
    StrictModes yes
    AuthenticationMethods publickey
    RSAAuthentication no
    PubkeyAuthentication yes
    IgnoreRhosts yes
    RhostsRSAAuthentication no
    HostbasedAuthentication no
    PermitEmptyPasswords no
    ChallengeResponseAuthentication no
    PasswordAuthentication no
    X11Forwarding no
    X11DisplayOffset 10
    PrintMotd no
    PrintLastLog yes
    TCPKeepAlive yes
    AcceptEnv LANG LC_*
    UsePAM yes
    KexAlgorithms curve25519-sha256@libssh.org
    Ciphers chacha20-poly1305@openssh.com
    MACs hmac-sha2-512-etm@openssh.com
    END
    # Enter password for sudo

### Enable the hardware random number generator

Note that hardware random number generators [are controversial](https://en.wikipedia.org/wiki/RdRand#Reception).

    sudo modprobe bcm2835_rng
    echo bcm2835_rng | sudo tee --append /etc/modules
    sudo apt-get -y install rng-tools

### Enable the hardware watchdog

This has false negatives (failures to reboot when it should) for me, but never false positives.

    sudo apt-get -y install watchdog
    sudo tee --append /etc/watchdog.conf <<END
    watchdog-device = /dev/watchdog
    END

### Enable automatic updates

    sudo apt-get -y install unattended-upgrades
    sudo dpkg-reconfigure -plow unattended-upgrades
    # Choose "<Yes>"

### Disable avahi

You didn’t need mdns, did you?

    sudo systemctl disable avahi-daemon.service

### Disable triggerhappy

You didn’t need volume buttons, did you?

    sudo systemctl disable triggerhappy.service

### Disable frequency scaling

If you’re not planning to run on battery; this thing is slow enough anyway.

    sudo apt-get -y install cpufrequtils
    sudo tee --append /etc/default/cpufrequtils <<END
    GOVERNOR="performance"
    END

### Enable lldpd

This allows you to observe network topology if you have managed switches.

    sudo apt-get -y install lldpd
    sudo tee --append /etc/default/lldp <<END
    DAEMON_ARGS="-c"
    END

### Remove the pi user

Well-known username, well-known password, no thank you.

    sudo deluser pi

### Install busybox-syslogd

You give up persistent syslogs, but you reduce SD writes. You can still run “logread” to read logs since boot from RAM.

    sudo apt-get -y install busybox-syslogd

### Reboot

Test that changes work, and have some (disabling auto-login) take effect.

    sudo reboot

### After reboot

Note that ssh may scream “REMOTE HOST IDENTIFICATION HAS CHANGED!”; that’s a symptom of the sshd\_config changes above. Just remove the line from the known\_hosts file and reconnect.

<!--# include file="include/bottom.html" -->
