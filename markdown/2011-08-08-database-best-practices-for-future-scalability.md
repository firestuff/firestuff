<!--# set var="title" value="Database best practices for future scalability" -->
<!--# set var="date" value="August 8, 2011" -->

<!--# include file="include/top.html" -->

There’s a perpetual debate about how much effort to put into scalability when first designing and building a modern web application. The opposing arguments are roughly: “Scalability doesn’t matter if your app isn’t successful; features should come first” vs. “When you know that you need to scale, you won’t have time to do it.” Below are some suggestions for scalable MySQL schema design that should get you on the right path, without being onerous enough to slow you down. Let’s start with things that are almost free:

1. Use InnoDB. You’re eventually likely to want transactions, foreign keys, row-level locking or relative crash safety. You can Google and find lots of InnoDB vs. MyISAM comparisons, but if you don’t want to dig too deeply, “just use InnoDB” is a safe place to start.

1. Don’t store data that you don’t intend to use relationally. Using MySQL as a key/value store or to store encoded data (XML, [protocol buffers](http://code.google.com/p/protobuf/), etc.) in BLOB/TEXT may work, but dedicated key/value stores are likely to be more efficient.

1. Try to design your schema with as few hierarchies as possible. For example, take the following table layout, with arrows representing many-to-one relationships:Perhaps A=”Users”, B=”DVDs Owned”, C=”Logins”, D=”Times Watched”, while E=”Administrators” and F=”Changes”. These are two hierarchies, since A and E have no links to each other. Minimizing the number of hierarchies (keeping it to just one is awesome!) makes it easier to shard later. Schemas with cross-links (say F also links to A, or a table records transfers between two different users, linking to A twice) are very difficult to shard.<br>
   <img src="data:image/webp;base64,<!--# include file="images/db-hierarchy.webp.base64" -->" alt="" style="background: white;">

1. Use BIGINT UNSIGNED NOT NULL (64-bit required numeric) primary keys on every table. AUTO\_INCREMENT is fine, at least to start. You can skip this for many-to-many link tables; just put both link columns in the primary key. Having single-column, numeric primary keys makes it easier to do things like drift checking and traversing between tables.

1. Use BIGINT instead of INT for all keys. The cost in space (4 vs. 8 bytes) and compute time is so small that you’ll never notice it, but the cost of a schema change later to increase the field size, or an accidental wraparound, can be enormous. As you expand shards, your key space becomes sparse and grows rapidly, so wide keys are critical.

1. Split off your data access code into an [ORM layer](http://en.wikipedia.org/wiki/Object-relational_mapping), even if it’s very simple to begin with. This will be where your read/write split, shard lookups and change tracking will live later.

1. Don't use [triggers](http://dev.mysql.com/doc/refman/5.1/en/triggers.html) or [stored routines](http://dev.mysql.com/doc/refman/5.1/en/stored-routines.html). Keep this logic in your ORM layer instead, to give yourself a single point of truth and versioning system.

1. [Avoid subselects; use joins instead.](2011-07-12-converting-subselects-to-joins.html)

1. Don’t use [views](http://dev.mysql.com/doc/refman/5.1/en/views.html), unless you’re using a third-party ORM (rails, django) that mandates a schema structure that isn’t ideal.

1. Avoid network round-trips whenever possible. Use the [multi-row insert syntax](http://dev.mysql.com/doc/refman/5.5/en/insert.html) where possible. Enable the [CLIENT\_MULTI\_STATEMENTS](http://dev.mysql.com/doc/refman/5.1/en/mysql-real-connect.htmlhttp://dev.mysql.com/doc/refman/5.1/en/mysql-real-connect.html) flag at connect time, then send groups of statements separated by ";". 

Then, things that cost development time, in increasing order of complexity:

1. Use [foreign keys](http://dev.mysql.com/doc/refman/5.1/en/ansi-diff-foreign-keys.html). Don’t make references nullable; use a flag field to mark whole (sub-)hierarchies deleted instead. Combined with the hierarchy rule above, this means that you guarantee yourself that you’ll never end up with orphaned rows.

1. [Write to masters; read from slaves](http://dev.mysql.com/doc/refman/5.1/en/replication.html). This can be quite complex, since you have to worry about replication delay. For example, you can’t have one web page hit cause a write, then the next hit render the results by reading from the database, because the result might not have replicated. However, this enables significant scaling, because hooking up more slaves is much easier than sharding.

1. Don’t store event-based data as one row per event. If you record page views or clicks in the database, aggregate that data into one row per hour, or per day. You can keep logs of events outside of the database in case you need to change aggregation and re-generate historical data, but don’t keep every event in a hot table.

1. Stop using AUTO\_INCREMENT. Instead, keep a table [IdSequences](http://www.reddit.com/r/mysql/comments/jcw8o/database_best_practices_for_future_scalability/c2b2o4v), and do something like: 

   ```BEGIN;
   UPDATE IdSequences SET LastId=LAST_INSERT_ID(LastId+Increment)
     WHERE TableName='A' AND ColumnName='b';
   INSERT INTO A (b, c) VALUES (LAST_INSERT_ID(), ‘foo’);
   COMMIT;
   ```

   This lets you change IdSequences later to modify your sharding scheme.

1. Create an empty shard (new database, same schema, no data) and add test rows. Teach your application to choose which shard to talk to. This will require some method to look up a shard for the root of each hierarchy; keep all data linked to a particular root on the same shard, so you can JOIN it. At its simplest, the lookup can be (ID mod NumShards). If you have uneven shard growth, you may need an indirection table to map from virtual shard (determined by modular division with a large divisor) to physical database.

<!--# include file="include/bottom.html" -->
