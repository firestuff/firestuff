<!--# set var="title" value="A new generation of Google MySQL tools" -->
<!--# set var="date" value="April 1, 2011" -->

<!--# include file="include/top.html" -->

When I started at Google, the MySQL team had a moderate open source presence. The largest part was the Google server patches for 4.0, 5.0 and some starter work on 5.1. There was also a small set of tools: mypgrep, mstat and some others. Chip Turner, who did the tools releases, had already moved to another team, and we haven't released new tools since.

I'm now happy to announce a new round of tool releases. We're just getting started, but here's what's available so far:

* [db.py](http://code.google.com/p/google-mysql-tools/source/browse/trunk/pylib/db.py): Easily execute queries in parallel on a sharded database
* [sql.py](http://code.google.com/p/google-mysql-tools/source/browse/trunk/sql.py): Interactive shell to db.py
* [permissions.py](http://code.google.com/p/google-mysql-tools/source/browse/trunk/permissions.py): Manage MySQL permissions in a Python-based format
* [validate.py](http://code.google.com/p/google-mysql-tools/source/browse/trunk/validate.py): Parse SQL using pyparsing and apply rules with live DB data

These are the actual tools being used to run MySQL at scale inside Google, not one-time sanitized copies. You can get them at [http://code.google.com/p/google-mysql-tools/](http://code.google.com/p/google-mysql-tools/). The old tools and patches are still available in [old/](http://code.google.com/p/google-mysql-tools/source/browse/#svn%2Ftrunk%2Fold).

Thanks to the whole team for their work on these tools and especially to Razvan Musaloiu-E. for handling release code reviews. Watch/subscribe to this blog or subscribe to [the google-mysql-tools mailing list](http://groups.google.com/group/google-mysql-tools) for future updates. If you'll be at the [2011 MySQL conference](http://en.oreilly.com/mysql2011/), stop by my talk with [Eric Rollins](http://en.oreilly.com/mysql2011/public/schedule/speaker/8129) on [automatic failover](http://en.oreilly.com/mysql2011/public/schedule/detail/17137) and [Mikey Dickerson](http://en.oreilly.com/mysql2011/public/schedule/speaker/57828)'s on [detecting data drift](http://en.oreilly.com/mysql2011/public/schedule/detail/17138).

<!--# include file="include/bottom.html" -->
