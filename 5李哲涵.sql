


---------------------------------------------------------------------
-- Set Operations
---------------------------------------------------------------------

---------------------------------------------------------------------
-- UNION
---------------------------------------------------------------------

---------------------------------------------------------------------
-- UNION DISTINCT
---------------------------------------------------------------------

-- UNION DISTINCT
USE InsideTSQL2008;

SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- UNION ALL
---------------------------------------------------------------------

-- UNION ALL
SELECT country, region, city FROM HR.Employees
UNION ALL
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- EXCEPT
---------------------------------------------------------------------

---------------------------------------------------------------------
-- EXCEPT DISTINCT
---------------------------------------------------------------------

-- EXCEPT DISTINCT, Employees EXCEPT Customers
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country, region, city FROM Sales.Customers;

-- EXCEPT DISTINCT, Customers EXCEPT Employees
SELECT country, region, city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;

---------------------------------------------------------------------
-- EXCEPT ALL
---------------------------------------------------------------------

WITH EXCEPT_ALL
AS
(
  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
    FROM HR.Employees

  EXCEPT

  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
  FROM Sales.Customers
)
SELECT country, region, city
FROM EXCEPT_ALL;

---------------------------------------------------------------------
-- INTERSCET
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INTERSECT DISTINCT
---------------------------------------------------------------------

SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- INTERSECT ALL
---------------------------------------------------------------------

WITH INTERSECT_ALL
AS
(
  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
  FROM HR.Employees

  INTERSECT

  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
    FROM Sales.Customers
)
SELECT country, region, city
FROM INTERSECT_ALL;

---------------------------------------------------------------------
-- Precedence
---------------------------------------------------------------------

-- INTERSECT Precedes EXCEPT
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using Parenthesis
(SELECT country, region, city FROM Production.Suppliers
 EXCEPT
 SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using INTO with Set Operations
SELECT country, region, city INTO #T FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Cleanup
DROP TABLE #T;
GO
