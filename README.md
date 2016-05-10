# sql_exercise
对一个查询，按照以下格式进行注释：  

    -- Multivalued subquery 选出Sales.Customers中所有出现在Sales.Orders中的custid和companyname  
    SELECT custid, companyname  
    FROM Sales.Customers  
    WHERE custid IN (SELECT custid FROM Sales.Orders);  
    
    -- 1 Customer NRZBB  
    -- 2 Customer MLTDN  
    -- 3 Customer KBUDE  

原注释后写我们对查询的注释
空一行之后粘贴前三行查询结果
