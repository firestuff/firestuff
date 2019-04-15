<!--# set var="title" value="Converting subselects to joins" -->
<!--# set var="date" value="July 12, 2011" -->

<!--# include file="include/top.html" -->

    mysql> SELECT Title
        ->   FROM Articles
        ->   WHERE ArticleId IN (
        ->     SELECT ArticleId
        ->     FROM Views
        ->   );
    +-------------------------+
    | Title                   |
    +-------------------------+
    | Interesting things      |
    | More interesting things |
    +-------------------------+
    2 rows in set (0.00 sec)

What's wrong with this statement? It looks like it's trying to get a list of article names that have been viewed, and it seems to be doing its job. It's easy to read and to tell what's going on, even for someone with limited SQL experience. So what's there to fix?

Notice that there are two SELECT statements above. The latter is called a subselect or subquery. Just like parentheses in mathematical expressions ("5 * (2 + 8)"), you're walling off part of your statement and asking for it to be completely executed first. If that inner statement produces a huge data set (imagine this is views of, say, reddit articles), it's bad if you have to store that entire result before moving on to finding the associated articles. In reality, database engines can optimize this and be smarter than storing the whole result set, but there are no guarantees.

Fortunately, most subselects can be converted directly to joins. Let's look at a few simple examples. Given the tables:

    CREATE TABLE Articles (
      ArticleId bigint(20) unsigned NOT NULL AUTO_INCREMENT,
      Title varchar(255) NOT NULL,
      PRIMARY KEY (ArticleId)
    ) ENGINE=InnoDB;

    CREATE TABLE Views (
      ArticleId bigint(20) unsigned NOT NULL,
      ViewedAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      KEY ArticleId (ArticleId),
      CONSTRAINT Views_ibfk_1 FOREIGN KEY (ArticleId) REFERENCES Articles (ArticleId)
    ) ENGINE=InnoDB;

We'll start with a simple query:

    SELECT Title
      FROM Articles
      WHERE ArticleId IN (
        SELECT ArticleId
        FROM Views
      );

This is easy because it's a positive relationship: "IN" as opposed to "NOT IN". As a join, it looks like:

    SELECT DISTINCT Title
      FROM Articles
        JOIN Views USING (ArticleId);

"DISTINCT" is required because Views -> Articles is many -> one, and we only want each article title once. We can use "USING" instead of "ON" because the column name is the same in both tables.

So, what if we have a negative query? Say we're looking for unviewed articles:

    SELECT Title
      FROM Articles
      WHERE ArticleId NOT IN (
        SELECT ArticleId
        FROM Views
      );

We can turn this into a join by using something called an outer join. Outer joins give us back all the rows in one table, then matching rows from another, or NULLs if they don't exist. An outer join between these two tables would look like:

    mysql> SELECT Title, ViewedAt
        ->   FROM Articles
        ->     LEFT JOIN Views USING (ArticleId);
    +-------------------------+---------------------+
    | Title                   | ViewedAt            |
    +-------------------------+---------------------+
    | Interesting things      | 2011-07-12 14:09:28 |
    | More interesting things | 2011-07-12 14:09:29 |
    | More interesting things | 2011-07-12 14:09:31 |
    | Rather boring things    |                NULL |
    +-------------------------+---------------------+
    4 rows in set (0.00 sec)

We can then filter back down to just unread articles. We'll also avoid referencing any columns but the ones we're already joining on:

    mysql> SELECT Title
        ->   FROM Articles
        ->     LEFT JOIN Views USING (ArticleId)
        ->   WHERE Views.ArticleId IS NULL;
    +----------------------+
    | Title                |
    +----------------------+
    | Rather boring things |
    +----------------------+
    1 row in set (0.00 sec)

Take an example query that is looking for all articles that have not been read since a certain timestamp:

    mysql> SELECT Title
        ->   FROM Articles
        ->   WHERE ArticleId NOT IN (
        ->     SELECT ArticleId
        ->       FROM Views
        ->       WHERE ViewedAt > '2011-07-12 14:09:30'
        ->   );
    +----------------------+
    | Title                |
    +----------------------+
    | Interesting things   |
    | Rather boring things |
    +----------------------+
    2 rows in set (0.00 sec)

This is slightly more complex to convert, because the naive conversion returns the wrong answer:

    mysql> SELECT Title
        ->   FROM Articles
        ->     LEFT JOIN Views USING (ArticleId)
        ->   WHERE ViewedAt > '2011-07-12 14:09:30'
        ->     AND Views.ArticleId IS NULL;
    Empty set (0.00 sec)

To solve this, we have to remember that we want the ViewedAt condition to be before the join, while the Views.ArticleId condition should be after. We can rewrite this to:

    mysql> SELECT Title
        ->   FROM Articles
        ->     LEFT JOIN Views ON (Articles.ArticleId = Views.ArticleId
        ->                         AND ViewedAt > '2011-07-12 14:09:30')
        ->   WHERE Views.ArticleId IS NULL;
    +----------------------+
    | Title                |
    +----------------------+
    | Interesting things   |
    | Rather boring things |
    +----------------------+
    2 rows in set (0.00 sec)

<!--# include file="include/bottom.html" -->
