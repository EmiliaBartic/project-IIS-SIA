------ Preparing ---------------------------------------------------------------
--- DSA-SQL-JPAService access to: ORCL Data Source [Sales]
--- DSA-SQL-JDBCService: PostgreSQL Data Source [Customers]
--- DSA-DOC-XLSService: Excel Data Source [Customers Categories, Periods]
--- DSA-DOC-XMLService: XML Data Source [Locations] (OR DSA-NoSQL-MongoDBService)
--------------------------------------------------------------------------------
-- Data Source Remote/External Views -------------------------------------------
-- Oracle DSA-SQL-JPAService
SELECT * FROM PRODUCTS_VIEW;
select * from INVOICES_VIEW;
select * from SALES_VIEW;
--- Excel DSA-DOC-XLSService
SELECT * FROM CTG_CUST_TO_VIEW;
SELECT * FROM CTG_CUST_EMP_VIEW;
select * from Periods_VIEW;
select * from CTG_PROD_VIEW;
--- XML DSA-DOC-XMLService
SELECT * FROM departaments_view;
SELECT * FROM cities_view;
SELECT * FROM departaments_cities_view;
--- PostgreSQL DSA-SQL-JDBCService
SELECT * FROM customers_view;
SELECT * FROM customers_details_view;
SELECT * FROM customers_addresses_view;
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--- Dimensions
--- D1: Customers - Cities - Departaments
DROP VIEW OLAP_DIM_CUSTS_CITIES_DEPTS;
CREATE OR REPLACE VIEW OLAP_DIM_CUSTS_CITIES_DEPTS AS
SELECT 
    C.customerid, C.name as customername, -- L1
    Ct.idcity, Ct.cityname, -- L2
    D.iddepartament, D.departamentname -- L3
FROM customers_view C 
    INNER JOIN customers_details_view CD ON c.customerid = cd.customerid
    INNER JOIN customers_addresses_view CA ON c.customerid = ca.customerid
    INNER JOIN cities_view CT ON upper(Ca.city) = upper(Ct.cityname)
    INNER JOIN departaments_cities_view DCT ON Dct.idcity =  Ct.idcity
    INNER JOIN departaments_view D ON D.iddepartament = Dct.iddepartament
;
SELECT * FROM OLAP_DIM_CUSTS_CITIES_DEPTS;
--- D2: Calendar ---------------------------------------------------------------------------------------------------------------
DROP VIEW OLAP_DIM_DATA_CALENDAR;
CREATE OR REPLACE VIEW OLAP_DIM_DATA_CALENDAR AS
select distinct 
  extract (year from invoicedate)    as year,
  extract (month from invoicedate)   as month,
  i.invoicedate					       as day,
  p.period as t
FROM Periods_View p
INNER JOIN INVOICES_VIEW i ON 
	extract (month from i.invoicedate) 
	BETWEEN extract (month from p.startdate) and extract (month from p.enddate)
order by 3, 2, 1
;
SELECT * FROM olap_dim_data_calendar;
-------------------------------------------------------------------------------
-- CREATE OR REPLACE VIEW OLAP_DIM_DATA_CALENDAR_ALL AS
--- D3: CUST_CTG_TO ------------------------------------------------------------
DROP VIEW OLAP_DIM_CUST_CTG_TO;
CREATE OR REPLACE VIEW OLAP_DIM_CUST_CTG_TO AS
SELECT 
    C.CustomerId, C.Name as customername, -- L1
    T.Categorycode, 
    T.Categoryname
FROM CUSTOMERS_VIEW C  
    INNER JOIN CUSTOMERS_DETAILS_VIEW D ON C.Customerid=D.customerid
    INNER JOIN CTG_CUST_TO_VIEW T ON D.TURNOVER BETWEEN T.LowerBound and T.UpperBound
    ;

SELECT * FROM OLAP_DIM_CUST_CTG_TO;
select * from CUSTOMERS_DETAILS_VIEW;
--- D4: CUST_CTG_EMP -----------------------------------------------------------
DROP VIEW OLAP_DIM_CUST_CTG_EMP;
CREATE OR REPLACE VIEW OLAP_DIM_CUST_CTG_EMP AS
SELECT 
    C.CustomerId, C.name as customername, -- L1
    T.Categorycode, 
    T.Categoryname
FROM CUSTOMERS_VIEW C 
    INNER JOIN CUSTOMERS_DETAILS_VIEW D ON C.CustomerId=D.CustomerId
    INNER JOIN CTG_CUST_EMP_VIEW T ON d.nrofemps BETWEEN T.LowerBound and T.UpperBound
;
SELECT * FROM OLAP_DIM_CUST_CTG_EMP;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- Facts
DROP VIEW OLAP_FACTS_SALES_AMOUNT;
CREATE OR REPLACE VIEW OLAP_FACTS_SALES_AMOUNT AS
SELECT I.CustomerId, P.ProductCode, I.InvoiceDate 
    , SUM(I.Quantity * I.UnitPrice) as SALES_AMOUNT
FROM SALES_VIEW i
    INNER JOIN PRODUCTS_VIEW p ON i.PRODUCTCODE = p.PRODUCTCODE
GROUP BY I.CustomerId, P.ProductCode, I.InvoiceDate
;
SELECT * FROM OLAP_FACTS_SALES_AMOUNT;
--------------------------------------------------------------------------------
--- Analytical Views
--------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_DEP_CIT_CUST;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_DEP_CIT_CUST AS
SELECT D.DepartamentName, D.CityName, D.CustomerName,
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM OLAP_DIM_CUSTS_CITIES_DEPTS D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.customerid = F.CustomerId
GROUP BY ROLLUP (d.DepartamentName, d.CityName, d.CustomerName)
ORDER BY 1 DESC, 2 DESC, 3 DESC;
SELECT * FROM OLAP_VIEW_SALES_DEP_CIT_CUST;
---
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_DEP_CIT_CUST AS
SELECT CASE
    WHEN D.DepartamentName IS NULL THEN '{Total General}'
    ELSE D.DepartamentName END AS DepartamentName,
  CASE 
    WHEN D.DepartamentName  IS NULL THEN ' '
    WHEN D.CityName  IS NULL THEN 'subtotal Departament ' || D.DepartamentName
    ELSE D.CityName END AS CityName,
  CASE 
    WHEN D.DepartamentName IS NULL THEN ' '
    WHEN D.CityName IS NULL THEN ' '
    WHEN D.CustomerName IS NULL THEN 'subtotal city ' || d.CityName
    ELSE D.CustomerName END AS CustomerName,  
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM OLAP_DIM_CUSTS_CITIES_DEPTS D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.customerid = F.customerid
GROUP BY ROLLUP (d.DepartamentName, d.CityName, d.CustomerName)
ORDER BY 1, 2, 3
;
---
SELECT * FROM OLAP_VIEW_SALES_DEP_CIT_CUST;
--------------------------------------------------------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_CALENDAR;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_CALENDAR AS
SELECT 
  CASE
    WHEN d.year IS NULL THEN '{Total General}'
    ELSE to_char(d.year, '9999') END AS year,
  CASE 
    WHEN d.year IS NULL THEN ' '
    WHEN d.month IS NULL THEN 'subtotal year ' || d.year
    ELSE to_char(d.month, '99') END AS month,
  CASE 
    WHEN d.year IS NULL THEN ' '
    WHEN d.month IS NULL THEN ' '
    WHEN d.day IS NULL THEN 'subtotal month ' || d.month
    ELSE date_format(d.day, 'dd/MM/yyyy') END AS day,    
  SUM(NVL(f.sales_amount, 0)) as sales_amount
FROM olap_dim_data_calendar D
  LEFT JOIN OLAP_FACTS_SALES_AMOUNT F ON d.day = f.InvoiceDate
GROUP BY ROLLUP (d.year, d.month, d.day)
ORDER BY 1, 2, 3
;
---
SELECT * FROM OLAP_FACTS_SALES_AMOUNT;
SELECT * FROM OLAP_DIM_DATA_CALENDAR;
SELECT * FROM OLAP_VIEW_SALES_CALENDAR;
--------------------------------------------------------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_CTG_CUST_TO;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_CTG_CUST_TO AS
SELECT 
CASE
    WHEN D.CategoryName IS NULL THEN '{Total General}'
    ELSE D.CategoryName END AS CategoryName,
  CASE 
    WHEN D.CategoryName IS NULL THEN ' '
    WHEN D.CustomerName IS NULL THEN 'subtotal category ' || D.CategoryName
    ELSE D.CustomerName END AS CustomerName,
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM OLAP_DIM_CUST_CTG_TO D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.customerid = F.customerid
GROUP BY ROLLUP (d.CategoryName, d.CustomerName)
ORDER BY 1,2;
---
SELECT * FROM OLAP_VIEW_SALES_CTG_CUST_TO;
-------
SELECT * FROM CTG_CUST_TO_VIEW;
SELECT * FROM OLAP_DIM_CUST_CTG_TO;
SELECT * FROM OLAP_FACTS_SALES_AMOUNT;
--------------------------------------------------------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_CTG_CUST_EMP;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_CTG_CUST_EMP AS
SELECT 
CASE
    WHEN D.CategoryName IS NULL THEN '{Total General}'
    ELSE D.CategoryName END AS CategoryName,
  CASE 
    WHEN D.CategoryName IS NULL THEN ' '
    WHEN D.CustomerName IS NULL THEN 'subtotal category ' || D.CategoryName
    ELSE D.CustomerName END AS CustomerName,
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM OLAP_DIM_CUST_CTG_EMP D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.customerid = F.customerid
GROUP BY ROLLUP (d.CategoryName, d.CustomerName)
ORDER BY 1,2;
---
SELECT * FROM OLAP_VIEW_SALES_CTG_CUST_EMP;
-------
SELECT * FROM CTG_CUST_EMP_VIEW;
SELECT * FROM OLAP_DIM_CUST_CTG_EMP;
SELECT * FROM OLAP_FACTS_SALES_AMOUNT;
--------------------------------------------------------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_CTG_PROD;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_CTG_PROD AS
SELECT 
  CASE
    WHEN D.prodcategory IS NULL THEN '{Total General}'
    ELSE D.prodcategory END AS prodcategory,
  CASE 
    WHEN D.prodcategory IS NULL THEN ' '
    WHEN D.prodName IS NULL THEN 'subtotal category ' || D.prodcategory
    ELSE D.prodName END AS prodName,
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM PRODUCTS_VIEW D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.productcode = F.productcode
GROUP BY ROLLUP (d.prodcategory, d.prodName)
ORDER BY 1,2;

SELECT * FROM PRODUCTS_VIEW;
SELECT * FROM OLAP_FACTS_SALES_AMOUNT;
SELECT * FROM OLAP_VIEW_SALES_CTG_PROD;

--------------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_SALES_CTG_PROD_CITIES;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_CTG_PROD_CITIES AS
SELECT D.prodcategory, c.cityname,
  SUM(NVL(f.SALES_AMOUNT, 0)) as SALES_AMOUNT    
FROM PRODUCTS_VIEW D
    INNER JOIN OLAP_FACTS_SALES_AMOUNT F ON D.productcode = F.productcode
    INNER JOIN olap_dim_custs_cities_depts C ON c.customerid = F.customerid
GROUP BY CUBE(d.prodcategory, c.cityname)
ORDER BY 1 desc, 2 desc;

SELECT * FROM OLAP_VIEW_SALES_CTG_PROD_CITIES;
--------------------------------------------------------------------------------
--REST Service URL:
--	http://localhost:9990/DSA-SparkSQL-Service/rest/view/{VIEW_NAME}
--	http://localhost:9990/DSA-SparkSQL-Service/rest/STRUCT/{VIEW_NAME}

-- http://localhost:9990/DSA-SparkSQL-Service/rest/view/OLAP_VIEW_SALES_CTG_PROD_CITIES

