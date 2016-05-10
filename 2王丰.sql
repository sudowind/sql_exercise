---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

-- Customers from Spain that made orders
-- Using EXISTS
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

---------------------------------------------------------------------
-- EXISTS vs. IN
---------------------------------------------------------------------

-- Customers from Spain that made orders
-- Using IN
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid IN(SELECT custid FROM Sales.Orders);

---------------------------------------------------------------------
-- NOT EXISTS vs. NOT IN
---------------------------------------------------------------------

-- Customers from Spain who made no Orders
-- Using EXISTS
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

-- Customers from Spain who made no Orders
-- Using IN, try 1
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid NOT IN(SELECT custid FROM Sales.Orders);

-- Add a row to Orders with a NULL customer id
INSERT INTO Sales.Orders
  (custid, empid, orderdate, requireddate, shippeddate, shipperid,
   freight, shipname, shipaddress, shipcity, shipregion,
   shippostalcode, shipcountry)
  VALUES(NULL, 1, '20090212', '20090212',
         '20090212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');

-- Customers from Spain that made no Orders
-- Using IN, try 2
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid NOT IN(SELECT custid FROM Sales.Orders
                    WHERE custid IS NOT NULL);

-- Remove the row from Orders with the NULL customer id
DELETE FROM Sales.Orders WHERE custid IS NULL;
DBCC CHECKIDENT('Sales.Orders', RESEED, 11077);
GO



---------------------------------------------------------------------
-- Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- CROSS
---------------------------------------------------------------------

SET NOCOUNT ON;
USE InsideTSQL2008;
GO

-- Get all Possible Combinations, ANSI SQL:1992
SELECT E1.firstname, E1.lastname AS emp1,
  E2.firstname, E2.lastname AS emp2
FROM HR.Employees AS E1
  CROSS JOIN HR.Employees AS E2;

-- Get all Possible Combinations, ANSI SQL:1989
SELECT E1.firstname, E1.lastname AS emp1,
  E2.firstname, E2.lastname AS emp2
FROM HR.Employees AS E1, HR.Employees AS E2;
GO

-- Generate Copies, using a Literal
SELECT custid, empid,
  DATEADD(day, n-1, '20090101') AS orderdate
FROM Sales.Customers
  CROSS JOIN HR.Employees
  CROSS JOIN dbo.Nums
WHERE n <= 31;
GO

-- Make Sure MyOrders does not Exist
IF OBJECT_ID('dbo.MyOrders') IS NOT NULL
  DROP TABLE dbo.MyOrders;
GO

-- Generate Copies, using Arguments
DECLARE
  @fromdate AS DATE = '20090101',
  @todate   AS DATE = '20090131';

WITH Orders
AS
( 
  SELECT custid, empid,
    DATEADD(day, n-1, @fromdate) AS orderdate
  FROM Sales.Customers
    CROSS JOIN HR.Employees
    CROSS JOIN dbo.Nums
  WHERE n <= DATEDIFF(day, @fromdate, @todate) + 1
)
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS orderid,
  custid, empid, orderdate
INTO dbo.MyOrders
FROM Orders;
GO

-- Cleanup
DROP TABLE dbo.MyOrders;
GO

-- Avoiding Multiple Subqueries
IF OBJECT_ID('dbo.MyOrderValues', 'U') IS NOT NULL
  DROP TABLE dbo.MyOrderValues;
GO

SELECT *
INTO dbo.MyOrderValues
FROM Sales.OrderValues;

ALTER TABLE dbo.MyOrderValues
  ADD CONSTRAINT PK_MyOrderValues PRIMARY KEY(orderid);

CREATE INDEX idx_val ON dbo.MyOrderValues(val);
GO

-- Listing 7-1 Query obtaining aggregates with subqueries
SELECT orderid, custid, val,
  CAST(val / (SELECT SUM(val) FROM dbo.MyOrderValues) * 100.
       AS NUMERIC(5, 2)) AS pct,
  CAST(val - (SELECT AVG(val) FROM dbo.MyOrderValues)
       AS NUMERIC(12, 2)) AS diff
FROM dbo.MyOrderValues;

-- Listing 7-2 Query obtaining aggregates with a cross join
WITH Aggs AS
(
  SELECT SUM(val) AS sumval, AVG(val) AS avgval
  FROM dbo.MyOrderValues
)
SELECT orderid, custid, val,
  CAST(val / sumval * 100. AS NUMERIC(5, 2)) AS pct,
  CAST(val - avgval AS NUMERIC(12, 2)) AS diff
FROM dbo.MyOrderValues
  CROSS JOIN Aggs;

-- Cleanup
IF OBJECT_ID('dbo.MyOrderValues', 'U') IS NOT NULL
  DROP TABLE dbo.MyOrderValues;
GO