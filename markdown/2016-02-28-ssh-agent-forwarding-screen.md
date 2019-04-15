<!--# set var="title" value="SSH agent forwarding & screen" -->
<!--# set var="date" value="February 28, 2016" -->

<!--# include file="include/top.html" -->

ssh-agent forwarding and screen not playing nicely is one of those things that I’ve dealt with so long that it just became routine. Resume a screen from a previous connection? Outgoing SSH won’t work, and that’s just the way it is. One day this week, I finally decided to see if I can fix it, and fortunately the Internet [provides](https://gist.github.com/martijnvermaat/8070533). That doc has a bunch of complexity about X forwarding, which I haven’t cared about in years, so here’s the distilled version. You’ll need to have already [set up agent forwarding](https://developer.github.com/guides/using-ssh-agent-forwarding/). On the host with your screen session:

    tee ~/.ssh/rc <<'END'
    if test "$SSH_AUTH_SOCK"; then
      ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    fi
    END
	
    tee -a ~/.screenrc <<END
    setenv SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
    END

Reconnect, restart screen once, never worry about it again. Changing my life.

<!--# include file="include/bottom.html" -->
