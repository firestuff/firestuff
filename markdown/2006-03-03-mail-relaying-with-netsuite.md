<!--# set var="title" value="Mail relaying with NetSuite" -->
<!--# set var="date" value="2006-03-03" -->

<!--# include file="include/top.html" -->

When sending a reply to a valid “message.<msgid>@messages.netsuite.com” address, I discovered something interesting. [NetSuite](http://netsuite.com/) uses these addresses to store a copy of the message with the order, then forwards the message along to the real destination. However, the forwarding method is busted.

It translates the headers in the original message. I sent:

	From: Ian Gulliver <ian@penguinhosting.net>
	To: “George Sasson (PAA)” <messages.<msgid>@messages.netsuite.com>
	Cc: ian-djmart@penguinhosting.net

It internally translated this to:

	From: ian@penguinhosting.net
	To: george@proaudioamerica.com
	Cc: ian-djmart@penguinhosting.net

It then passed the message to its outgoing mail program, which __reparsed the headers__. In this case, it means that I got two copies of the message; one from my local MTA because of the CC, and one back from NetSuite because of the CC.

[prox](http://prolixium.com/) helped me test this; it works when the CC isn’t coming back to the same host. That means it’s a valid relay method.

<!--# include file="include/bottom.html" -->
