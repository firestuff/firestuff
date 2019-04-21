<!--# set var="title" value="New MySQL toys" -->
<!--# set var="date" value="January 25, 2006" -->

<!--# include file="include/top.html" -->

In 5.1.5:

	SELECT ExtractValue(’<a>foo<b>bar</b></a>’, ‘//b’);

		bar

	SELECT UpdateXML(’<a>foo<b>bar</b></a>’, ‘//b’, ‘zig’);

		<a>foozig</a>

XSLT implementation on its way, maybe? :)

In 5.1.6:

	CREATE EVENT e
	ON SCHEDULE EVERY 1 DAY
	ON COMPLETION PRESERVE
	DO INSERT INTO log VALUES (1);

_(think cron)_

And:

	CREATE EVENT e
	ON SCHEDULE AT ‘2006-01-01 03:00:00′
	ON COMPLETION NOT PRESERVE
	DO OPTIMIZE TABLE foo;

_(think at)_

The server variable “event\_scheduler” has to be set to 1 for these to work.

<!--# include file="include/bottom.html" -->
