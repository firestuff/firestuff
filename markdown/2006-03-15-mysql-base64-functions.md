<!--# set var="title" value="MySQL base64 functions" -->
<!--# set var="date" value="2006-03-15" -->

<!--# include file="include/top.html" -->

This one hardly seemed worth a project page. MySQL lacks base64 encode/decode functions, and I needed them, so [here](files/base64.sql) they are in procedural SQL. You’ll need MySQL 5.0.19/5.1.8 if you don’t want it to segfault under you when you run them ([bug #16887](http://bugs.mysql.com/bug.php?id=16887)).

<!--# include file="include/bottom.html" -->
