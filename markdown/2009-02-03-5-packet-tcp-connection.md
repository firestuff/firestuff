<!--# set var="title" value="5-packet TCP connection?" -->
<!--# set var="date" value="February 3, 2009" -->

<!--# include file="include/top.html" -->

This seems to be valid:

1. C->S: SYN
1. S->C: SYN/ACK
1. C->S: FIN/ACK
1. S->C: FIN/ACK
1. C->S: ACK

A completely opened and closed TCP connection. Further, 2 and 3 can both contain data? Could you get a whole HTTP request/response in this conversation?

<!--# include file="include/bottom.html" -->
