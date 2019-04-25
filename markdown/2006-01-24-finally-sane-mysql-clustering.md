<!--# set var="title" value="Finally, sane MySQL clustering" -->
<!--# set var="date" value="2006-01-24" -->

<!--# include file="include/top.html" -->

As of MySQL 5.1.5, we’ve finally got [row-based replication](http://dev.mysql.com/doc/refman/5.1/en/replication-row-based.html). This is the last piece of the puzzle to make circular replication usable. Here’s how:

I’m assuming two MySQL servers, A and B. You can, however, use as many as you want, as long as they all somehow pull the logs from all the others.

Set the following config variables on both servers:

	server-id=<unique number per server>
	log-bin=<hostname>-bin
	relay-log=<hostname>-bin
	log-slave-updates # really only necessary in circular replication > 2 servers
	binlog-format=row

Using the MySQL client, create replication users on both servers:

	GRANT REPLICATION SLAVE ON *.* TO repl@’%’ IDENTIFIED BY ‘<password>’;

Then set master information on both servers, start replication and check that it’s working:

	CHANGE MASTER TO MASTER_HOST=’<address of other server>‘, MASTER_USER=’repl’, MASTER_PASSWORD=’<password>‘;
	START SLAVE;
	SHOW SLAVE STATUS\G

You should now be able to see multi-master replication in action:

On A:

	CREATE DATABASE repl_test;
	SHOW DATABASES;

On B:

	SHOW DATABASES;
	DROP DATABASE repl_test;
	SHOW DATABASES;

On A:

	SHOW DATABASES;

## The AUTO\_INCREMENT problem

AUTO\_INCREMENT-type columns get used in just about every MySQL table. They’re a quick way to build primary keys without thinking. However, there are obvious problems in a multi-master setup (if inserts happen on both servers at the same time, they’ll both get the same ID). The official MySQL solution (start the IDs on both servers at numbers significantly different from each other) is a nasty hack.

However, we’ve had [triggers](http://dev.mysql.com/doc/refman/5.1/en/triggers.html) in InnoDB tables since MySQL 5.0, and with row-level replication, handy functions like [UUID()](http://dev.mysql.com/doc/refman/5.1/en/miscellaneous-functions.html#id2906147) now replicate properly. This gives us a neat solution. On A:

	CREATE DATABASE IF NOT EXISTS test;
	USE test;
	CREATE TABLE repl_test (id CHAR(36) BINARY, test INT) ENGINE=InnoDB;

	delimiter //

	CREATE TRIGGER repl_test_before_insert BEFORE INSERT ON repl_test FOR EACH ROW
	BEGIN
	IF NEW.id IS NULL THEN
	SET NEW.id = UUID();
	END IF;
	SET @repl_test_last_insert_id = NEW.id;
	END
	//

	delimiter ;

	INSERT INTO repl_test SET test=5;
	SELECT * FROM repl_test;
	SELECT @repl_test_last_insert_id;

On B:

	SELECT * FROM repl_test;
	INSERT INTO repl_test SET test=6;
	SELECT * FROM repl_test;

On A:

	SELECT * FROM repl_test;

<!--# include file="include/bottom.html" -->
