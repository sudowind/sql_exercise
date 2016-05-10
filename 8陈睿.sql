


---------------------------------------------------------------------
-- GROUPING_ID Function
---------------------------------------------------------------------

SELECT 
  GROUPING_ID(
    custid, empid,
    YEAR(orderdate), MONTH(orderdate), DAY(orderdate) ) AS grp_id,
  custid, empid,
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS qty
FROM dbo.Orders
GROUP BY
  CUBE(custid, empid),
  ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

SELECT
  GROUPING_ID(e, d, c, b, a) as n,
  COALESCE(e, 1) as [16],
  COALESCE(d, 1) as [8],
  COALESCE(c, 1) as [4],
  COALESCE(b, 1) as [2],
  COALESCE(a, 1) as [1]
FROM (VALUES(0, 0, 0, 0, 0)) AS D(a, b, c, d, e)
GROUP BY CUBE (a, b, c, d, e)
ORDER BY n;

-- Pre-2008, Identifying Grouping Set
SELECT
  GROUPING(custid)          * 4 +
  GROUPING(empid)           * 2 +
  GROUPING(YEAR(orderdate)) * 1 AS grp_id,
  custid, empid, YEAR(orderdate) AS orderyear,
  SUM(qty) AS totalqty
FROM dbo.Orders
GROUP BY custid, empid, YEAR(orderdate)
WITH CUBE;

