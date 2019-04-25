<!--# set var="title" value="Convert all tables to InnoDB" -->
<!--# set var="date" value="2006-02-09" -->

<!--# include file="include/top.html" -->

[Here](files/convert_to_innodb.sql)’s a little bit of SQL to convert all tables in the current database to the InnoDB storage engine. It’s written for MySQL 5.0, and relies on the column count of SHOW TABLE STATUS, so it might take tweaking to work on other versions.

<!--# include file="include/bottom.html" -->
