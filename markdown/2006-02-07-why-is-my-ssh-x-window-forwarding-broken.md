<!--# set var="title" value="Why is my SSH X Window forwarding broken?" -->
<!--# set var="date" value="2006-02-07" -->

<!--# include file="include/top.html" -->

SSH into your destination:

	ssh -vv -X <hostname>

If you see a line near the end that says “_debug1: Remote: No xauth program; cannot forward with spoofing._“, you need to install xauth and reconnect. In Debian, run:

	apt-get install xbase-clients

Next, ensure that you’re getting a DISPLAY variable through:

	echo $DISPLAY

If that command outputs just a blank line, X forwarding is probably being denied by the server. Edit your sshd\_config (/etc/ssh/sshd\_config on Debian) and change/add the line:

	X11Forwarding yes

If you change this, you’ll need to restart your SSH server:

	/etc/init.d/ssh restart

Once your DISPLAY is being passed correctly, some programs may run but act oddly (”Gdk-error: […] BadAtom”, etc.) SSH uses “SECURITY” extensions by default, and some programs don’t work correctly with them. Try:

	ssh -Y <hostname>

Note that this command may expose your local machine to compromise if someone malicious is in control of the host you’re connecting to.

<!--# include file="include/bottom.html" -->
