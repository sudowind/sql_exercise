---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Querying (MSPress, 2009)
-- Chapter 06 - Subqueries, Table Expressions and Ranking Functions
-- Copyright Itzik Ben-Gan, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Subqueries
---------------------------------------------------------------------

-- Scalar subquery
SET NOCOUNT ON;
USE InsideTSQL2008;

SELECT orderid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(orderid) FROM Sales.Orders);

-- Correlated subquery
SELECT orderid, custid
FROM Sales.Orders AS O1
WHERE orderid = (SELECT MAX(O2.orderid)
                 FROM Sales.Orders AS O2
                 WHERE O2.custid = O1.custid);

-- Multivalued subquery
SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (SELECT custid FROM Sales.Orders);

-- Table subquery
SELECT orderyear, MAX(orderid) AS max_orderid
FROM (SELECT orderid, YEAR(orderdate) AS orderyear
      FROM Sales.Orders) AS D
GROUP BY orderyear;

---------------------------------------------------------------------
-- Self-Contained Subqueries
---------------------------------------------------------------------

-- Scalar subquery example
SELECT orderid FROM Sales.Orders
WHERE empid = 
  (SELECT empid FROM HR.Employees
   -- also try with N'Kollar' and N'D%'
   WHERE lastname LIKE N'Davis');

-- Customers with orders handled by all employees from the USA
-- using literals
SELECT custid
FROM Sales.Orders
WHERE empid IN(1, 2, 3, 4, 8)
GROUP BY custid
HAVING COUNT(DISTINCT empid) = 5;

-- Customers with orders handled by all employees from the USA
-- using subqueries
SELECT custid
FROM Sales.Orders
WHERE empid IN
  (SELECT empid FROM HR.Employees
   WHERE country = N'USA')
GROUP BY custid
HAVING COUNT(DISTINCT empid) =
  (SELECT COUNT(*) FROM HR.Employees
   WHERE country = N'USA');

-- Orders placed on last actual order date of the month
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate IN
  (SELECT MAX(orderdate)
   FROM Sales.Orders
   GROUP BY YEAR(orderdate), MONTH(orderdate));
GO

---------------------------------------------------------------------
-- Correlated Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Tiebreaker
---------------------------------------------------------------------

-- Index for tiebreaker problems
CREATE UNIQUE INDEX idx_eid_od_oid 
  ON Sales.Orders(empid, orderdate, orderid);
CREATE UNIQUE INDEX idx_eid_od_rd_oid 
  ON Sales.Orders(empid, orderdate, requireddate, orderid);
GO

-- Orders with the maximum orderdate for each employee
-- Incorrect solution
SELECT orderid, custid, empid, orderdate, requireddate 
FROM Sales.Orders
WHERE orderdate IN
  (SELECT MAX(orderdate) FROM Sales.Orders
   GROUP BY empid);

-- Orders with maximum orderdate for each employee
SELECT orderid, custid, empid, orderdate, requireddate 
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid);

-- Most recent order for each employee
-- Tiebreaker: max order id
SELECT orderid, custid, empid, orderdate, requireddate 
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid)
  AND orderid =
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate);

-- Most recent order for each employee, nesting subqueries
-- Tiebreaker: max order id
SELECT orderid, custid, empid, orderdate, requireddate 
FROM Sales.Orders AS O1
WHERE orderid = 
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = 
       (SELECT MAX(orderdate)
        FROM Sales.Orders AS O3
        WHERE O3.empid = O1.empid));

-- Most recent order for each employee
-- Tiebreaker: max requireddate, max orderid
SELECT orderid, custid, empid, orderdate, requireddate 
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid)
  AND requireddate =
  (SELECT MAX(requireddate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate)
  AND orderid =
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate
     AND O2.requireddate = O1.requireddate);

-- Cleanup
DROP INDEX Sales.Orders.idx_eid_od_oid;
DROP INDEX Sales.Orders.idx_eid_od_rd_oid;
GO