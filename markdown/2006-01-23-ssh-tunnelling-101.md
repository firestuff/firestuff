<!--# set var="title" value="SSH Tunnelling 101" -->
<!--# set var="date" value="January 23, 2006" -->

<!--# include file="include/top.html" -->

### The Players

I’ll be referring to 3 hosts:

* A: The server; this machine is behind a firewall that allows outgoing connections but doesn’t allow incoming.
* B: The bounce host; this machine is unfirewalled.
* C: The client.

### Configuring B

Some sshd configuration needs to be done on B before any of this will work. In the sshd\_config file (/etc/ssh/sshd\_config on Debian):

	AllowTcpForwarding yes
	GatewayPorts yes

Remember to restart sshd after making changes (/etc/init.d/ssh restart).

### Building the Tunnel

On A, run:

	ssh -g -n -R <port on B>:127.0.0.1:<port on A> <address of B> sleep 999999

This will hang with no output; that’s the expected result.

You should now be able to connect to the port on B and be talking to A. To get this to restart if the connection dies, run it inside:

	while :; do <command>; done

As with all shell commands, put a “&” on the end to run it in the background.

### Tunnelling FTP

Due to a trick in the FTP protocol, you can use this tunnelling arrangement but have FTP data connections go directly from A to C, without touching B. This only works with so-called “active” FTP (using the PORT command instead of PASV). C must also be unfirewalled for this to work.

The only thing you’ll need to change is the FTP server configuration. In proftpd.conf, add:

	AllowForeignAddress on

For pure-ftpd, run it with the “-w” commandline flag, or with a file named “AllowUserFXP” and a contents of “on” if you’re using pure-ftpd-wrapper.

<!--# include file="include/bottom.html" -->
