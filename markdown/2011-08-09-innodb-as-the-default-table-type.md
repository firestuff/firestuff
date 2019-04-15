<!--# set var="title" value="InnoDB as the default table type" -->
<!--# set var="date" value="August 9, 2011" -->

<!--# include file="include/top.html" -->

We recently switched from MyISAM to InnoDB as the default table type. This affects CREATE TABLE without an explicit ENGINE=, as well as implicitly-created tables for sorting and such. Mark had previously discussed issues with this [here](http://mysqlha.blogspot.com/2009/06/what-could-possibly-go-wrong.html), but we thought it was worth giving another try.

We've found a far more basic problem: KILL takes a long time. Consider the following:

    CREATE TABLE scratch.MyShortLivedTable 
      SELECT * FROM A JOIN B JOIN C....;

There's no ENGINE= there, so it uses the default table type. It seems to run at about the same speed as it did with MyISAM, but then you kill it. If it's MyISAM, the KILL takes effect immediately. If it's InnoDB, the CREATE is non-transactional and stays, but the implicit INSERTs have to be rolled back. If that query took 10 minutes, it may take 10 minutes to roll back, during which time the query is unkillable and MySQL won't shut down cleanly.

Our failovers rely on being able to kill all connections to a slave that they're promoting to master. Our backups rely on being able to shut down MySQL. We don't have a good answer for this, short of hardwiring ENGINE=MyISAM onto writes we know are going to be large.

<!--# include file="include/bottom.html" -->
