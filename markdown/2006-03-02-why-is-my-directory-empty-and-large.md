<!--# set var="title" value="Why is my directory empty and large?" -->
<!--# set var="date" value="2006-03-02" -->

<!--# include file="include/top.html" -->

This is more a curiosity question than a problem. Try this:

	mkdir temp
	cd temp
	seq 1 30000 | xargs touch
	ls -lhd .
	find . -type f | xargs rm
	ls -lhd .

Doing this on ext3 shows a 432k directory that stays that size even after the files are removed. It appears that ext3 practices lazy deletion, leaving the directory structures intact. It probably assumes that a directory that was large once will be large again, so it can save the allocation expense in the future.

<!--# include file="include/bottom.html" -->
