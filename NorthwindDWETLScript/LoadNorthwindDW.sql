USE [NorthwindDW]
GO
-- DimDate
exec insert_DIM_DATE

-- DimEmployee
TRUNCATE TABLE DimEmployee
GO
INSERT INTO DimEmployee
SELECT E1.[EmployeeID]
      , 'EmployeeName' = CONCAT(E1.LastName,' ', E1.FirstName)
      , 'EmployeeTitle' = E1.title
      , 'ManagerName' = CONCAT(E2.LastName,' ', E2.FirstName)
  FROM Northwind.[dbo].[Employees] E1
  LEFT JOIN Northwind.[dbo].[Employees] E2
  ON E1.ReportsTo = E2.EmployeeID
GO

---- DimCustomers
TRUNCATE TABLE DimCustomers
GO

INSERT INTO DimCustomers
SELECT [CustomerID]
      ,[CompanyName]
      ,[ContactName]
      ,[City]
      ,[Region]
      ,[PostalCode]
      ,[Country]
  FROM Northwind.[dbo].[Customers]
GO

-- DimProduct
TRUNCATE TABLE DimProduct
GO
INSERT INTO DimProduct
SELECT [ProductID]
      ,[ProductName]
      ,[UnitPrice]
      , Products.[CategoryID]
      ,[CategoryName]
  FROM Northwind.[dbo].[Products] Products
  INNER JOIN Northwind.[dbo].[Categories] Categories
  ON Products.CategoryID = Categories.CategoryID

-- FactOrder

TRUNCATE TABLE FactOrder
GO

INSERT INTO [dbo].[FactOrder]
SELECT Orders.[OrderID]
	, 'PostalCode' = ShipPostalCode
	,	CustomerID
      ,[ProductID]
      ,[EmployeeId]
      , 'ShipperId' = NULL
      , 'Total Sales' = UnitPrice * Quantity
      ,[Discount]
      , 'Unit Sales' = [Quantity]
      ,[TimeKey] = dimdate.datekey
  FROM Northwind.[dbo].[Orders] Orders INNER JOIN Northwind.[dbo].[Order Details] OrderDetails
  ON Orders.OrderID = orderdetails.OrderID
  INNER JOIN DimDate
  ON Orders.OrderDate = dimdate.[date]
GO

