


---------------------------------------------------------------------
-- INNER
---------------------------------------------------------------------

-- Inner Join, ANSI SQL:1992
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE country = N'USA';

-- Inner Join, ANSI SQL:1989
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid = O.custid
  AND country = N'USA';
GO

-- Forgetting to Specify Join Condition, ANSI SQL:1989
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O;
GO

-- Forgetting to Specify Join Condition, ANSI SQL:1989
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C JOIN Sales.Orders AS O;
GO

---------------------------------------------------------------------
-- OUTER
---------------------------------------------------------------------

-- Outer Join, ANSI SQL:1992
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid;
GO

-- Changing the Database Compatibility Level to 2000
ALTER DATABASE InsideTSQL2008 SET COMPATIBILITY_LEVEL = 80;
GO

-- Outer Join, Old-Style Non-ANSI
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid *= O.custid;
GO

-- Outer Join with Filter, ANSI SQL:1992
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.custid IS NULL;

-- Outer Join with Filter, Old-Style Non-ANSI
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid *= O.custid
  AND O.custid IS NULL;

-- Changing the Database Compatibility Level Back to 2008
ALTER DATABASE InsideTSQL2008 SET COMPATIBILITY_LEVEL = 100;
GO

-- Creating and Populating the Table T1
USE tempdb;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);
GO

INSERT INTO dbo.T1(keycol, datacol) VALUES
  (1, 'e'),
  (2, 'f'),
  (3, 'a'),
  (4, 'b'),
  (6, 'c'),
  (7, 'd');

-- Using Correlated Subquery to Find Minimum Missing Value
SELECT MIN(A.keycol) + 1
FROM dbo.T1 AS A
WHERE NOT EXISTS
  (SELECT * FROM dbo.T1 AS B
   WHERE B.keycol = A.keycol + 1);

-- Using Outer Join to Find Minimum Missing Value
SELECT MIN(A.keycol) + 1
FROM dbo.T1 AS A
  LEFT OUTER JOIN dbo.T1 AS B
    ON B.keycol = A.keycol + 1
WHERE B.keycol IS NULL;
GO