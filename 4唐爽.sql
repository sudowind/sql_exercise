

---------------------------------------------------------------------
-- Non-Supported Join Types
---------------------------------------------------------------------

---------------------------------------------------------------------
-- NATURAL, UNION Joins
---------------------------------------------------------------------
USE InsideTSQL2008;
GO

-- NATURAL Join
/*
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C NATURAL JOIN Sales.Orders AS O;
*/

-- Logically Equivalent Inner Join
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = O.custid;
GO

---------------------------------------------------------------------
-- Further Examples of Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Self Joins
---------------------------------------------------------------------
USE InsideTSQL2008;
GO

SELECT E.firstname, E.lastname AS emp,
  M.firstname, M.lastname AS mgr
FROM HR.Employees AS E
  LEFT OUTER JOIN HR.Employees AS M
    ON E.mgrid = M.empid;
GO

---------------------------------------------------------------------
-- Non-Equi-Joins
---------------------------------------------------------------------

-- Cross without Mirrored Pairs and without Self
SELECT E1.empid, E1.lastname, E1.firstname,
  E2.empid, E2.lastname, E2.firstname
FROM HR.Employees AS E1
  JOIN HR.Employees AS E2
    ON E1.empid < E2.empid;

-- Calculating Row Numbers using a Join
SELECT O1.orderid, O1.custid, O1.empid, COUNT(*) AS rn
FROM Sales.Orders AS O1
  JOIN Sales.Orders AS O2
    ON O2.orderid <= O1.orderid
GROUP BY O1.orderid, O1.custid, O1.empid;

---------------------------------------------------------------------
-- Multi-Join Queries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Controlling the Physical Join Evaluation Order 
---------------------------------------------------------------------

-- Listing 7-3 Multi-join query
-- Suppliers that Supplied Products to Customers
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Listing 7-4 Multi-join query, forcing order
-- Controlling the Physical Join Evaluation Order 
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
OPTION (FORCE ORDER);

---------------------------------------------------------------------
-- Controlling the Logical Join Evaluation Order
---------------------------------------------------------------------

-- Including Customers with no Orders, Attempt with Left Join
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Multiple Left Joins
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
  LEFT OUTER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  LEFT OUTER JOIN Production.Products AS P
    ON P.productid = OD.productid
  LEFT OUTER JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Right Join Performed Last
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
  RIGHT OUTER JOIN Sales.Customers AS C
    ON O.custid = C.custid;

-- Using Parenthesis
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN 
    (     Sales.Orders AS O
     JOIN Sales.OrderDetails AS OD
       ON OD.orderid = O.orderid
     JOIN Production.Products AS P
       ON P.productid = OD.productid
     JOIN Production.Suppliers AS S
       ON S.supplierid = P.supplierid)
    ON O.custid = C.custid;

-- Changing ON Clause Order
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN 
          Sales.Orders AS O
     JOIN Sales.OrderDetails AS OD
       ON OD.orderid = O.orderid
     JOIN Production.Products AS P
       ON P.productid = OD.productid
     JOIN Production.Suppliers AS S
       ON S.supplierid = P.supplierid
    ON O.custid = C.custid;

SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
  JOIN Production.Products AS P
  JOIN Sales.OrderDetails AS OD
    ON P.productid = OD.productid
    ON OD.orderid = O.orderid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
    ON O.custid = C.custid;

SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
  JOIN Production.Products AS P
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
    ON P.productid = OD.productid
    ON OD.orderid = O.orderid
    ON O.custid = C.custid;
GO