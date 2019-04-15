<!--# set var="title" value="Avoid MySQL round trips" -->
<!--# set var="date" value="April 22, 2011" -->

<!--# include file="include/top.html" -->

100ms (e.g. cross-US) latency to your MySQL server? Running 100,000 statements? That's 3 hours of overhead before you even get to your statement runtime on the server. Quick hack:

    mysql> delimiter |
    mysql> select 1;
     -> select 2;
     -> |
    +---+
    | 1 |
    +---+
    | 1 |
    +---+
    1 row in set (0.00 sec)
  
    +---+
    | 2 |
    +---+
    | 2 |
    +---+
    1 row in set (0.00 sec)

<!--# include file="include/bottom.html" -->
