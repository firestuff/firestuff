<!--# set var="title" value="The dangers of max_connections" -->
<!--# set var="date" value="2011-12-09" -->

<!--# include file="include/top.html" -->

We have a database that's drastically scaling up its query rate from many different clients. This typically means more client jobs and more parallelization across connections, so the first limit we hit is max\_user\_connections (in the mysql.user table), which we use to provide isolation between runaway users/jobs. We increase that, and we eventually start hitting server-level max\_connection limits. We increased that in an emergency push last night, and several hours later performance fell off a cliff.

SHOW PROCESSLIST showed tons of processes in "Opening tables" and "closing tables" state. Our InnoDB IO stats had dropped dramatically; we clearly weren't making significant progress actually answering queries. A quick search turned up a [Percona post](http://www.mysqlperformanceblog.com/2006/11/21/opening-tables-scalability/) about this, which pointed to [table\_cache](http://dev.mysql.com/doc/refman/5.0/en/table-cache.html). A quick look at SHOW VARIABLES LIKE 'table\_cache' showed 91. Our config has this set to 2048; something had clearly gone wrong.

One hint was the error log message:

    111209 11:08:21 [Warning] Changed limits: max_open_files: 8192  max_connections: 8000  table_cache: 91

It turns out that MySQL tries to be smart about table\_cache, based on the open file rlimit. The formula is (max\_open\_files - max\_connections - 10) / 2, which in this case is (8192 - 8000 - 10) = 182 / 2 = 91. 91 active tables is smaller than the hot set in this database, and when query rate crossed a line, the global open/close table lock and underlying syscalls couldn't keep up, and performance death-spiraled from there. We run-time set the limit higher with:

    SET GLOBAL table_cache = 2048;

This overrides the automatic setting but opens the possibility of hitting the rlimit when opening tables. The real fix is to increase the rlimit to accommodate both pools of file descriptors.

<!--# include file="include/bottom.html" -->
