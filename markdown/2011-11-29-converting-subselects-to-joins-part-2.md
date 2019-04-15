<!--# set var="title" value="Converting subselects to joins, part 2" -->
<!--# set var="date" value="November 29, 2011" -->

<!--# include file="include/top.html" -->

[I previously discussed this in depth](2011-07-12-converting-subselects-to-joins.html). However, today I saw a case that I didn't cover:

You have a table of Users and a table of Logins, with a row for each user login event. You're looking for users that have logged in within the last 31 days. The initial version of this I saw used a derived table:

    SELECT
        UserId,
        LastLogin
      FROM Users
        JOIN (
          SELECT
              UserId,
              DATEDIFF(NOW(), MAX(TimeStamp)) AS LastLogin
            FROM Logins
            GROUP BY UserId
        ) AS Temp USING (UserId)
      WHERE LastLogin &lt;= 31;

We can convert this to a simple JOIN with the magic of HAVING. HAVING is like WHERE, but applies after aggregation:

    SELECT
        UserId,
        DATEDIFF(NOW(), MAX(TimeStamp)) AS LastLogin
      FROM Users
        JOIN Logins USING (UserId)
      GROUP BY UserId
      HAVING LastLogin &lt;= 31;

<!--# include file="include/bottom.html" -->
