DROP TABLE IF EXISTS #Temp
SELECT 
	sal.OrderDate, sal.StockDate, sal.OrderNumber, sal.ProductKey, sal.CustomerKey, sal.TerritoryKey, sal.OrderLineItem, sal.OrderQuantity,
	pro.ProductSubcategoryKey, pro.ProductSKU, pro.ProductName, pro.ModelName, pro.ProductDescription, pro.ProductColor, pro.ProductSize, pro.ProductStyle, pro.ProductCost, pro.ProductPrice,
	ter.Region, ter.Country, ter.Continent,
	prosub.SubcategoryName,
	procat.CategoryName, procat.ProductCategoryKey,
	cus.Prefix, cus.FirstName, cus.LastName, cus.BirthDate, cus.Age, cus.AgeGroup, cus.Marital, cus.Gender, cus.EmailAddress, cus.AnnualIncome, cus.TotalChildren, cus.Occupation,cus.EducationLevel, cus.HomeOwner
INTO #Temp
FROM Sales sal
LEFT JOIN AdventureWorks_Products$ pro
	ON sal.ProductKey = pro.ProductKey
LEFT JOIN AdventureWorks_Territories$ ter
	ON sal.TerritoryKey = ter.SalesTerritoryKey
LEFT JOIN AdventureWorks_Product_Subcateg$ prosub
	ON pro.ProductSubcategoryKey = prosub.ProductSubcategoryKey
LEFT JOIN AdventureWorks_Customer$ cus
	ON sal.CustomerKey = cus.CustomerKey
LEFT JOIN AdventureWorks_Product_Categori$ procat
	ON prosub.ProductCategoryKey = procat.ProductCategoryKey

SELECT * FROM #Temp


--Dataset Overview
SELECT COUNT(*) AS TotalSales 
FROM #Temp

SELECT 
	MIN(OrderDate) AS FirstOrder,
	MAX(OrderDate) AS LastOrder
FROM #Temp



--Sales KPIs
--Total Sales
SELECT SUM(OrderQuantity * ProductPrice) AS TotalSales
FROM #Temp
--Total Profit
WITH ProfitCTE AS ( 
SELECT OrderQuantity, ProductCost, ProductPrice, 
		(OrderQuantity * ProductCost) AS Cost,
		(OrderQuantity * ProductPrice) AS Revenue
FROM #Temp )
SELECT ROUND(SUM(Revenue - Cost), 2) AS TotalProfit
FROM ProfitCTE
--Total Orders
SELECT COUNT(DISTINCT OrderNumber) AS TotalOrders
FROM #Temp
--Total Quantity Sold
SELECT SUM(OrderQuantity) AS TotalQuantity
FROM #Temp
--Average Order Value
WITH OrderTotals AS
(
    SELECT
        OrderNumber,
        SUM(OrderQuantity * ProductPrice) AS OrderValue
    FROM #Temp
    GROUP BY OrderNumber
)
SELECT ROUND(AVG(OrderValue),2) AverageOrderValue
FROM OrderTotals


--Customers Analysis
--How many unique customers?
SELECT COUNT(CustomerKey)
FROM AdventureWorks_Customer$
--Top 10 customers by sales.
SELECT TOP 10 FirstName+ ' ' +LastName AS Name, ROUND(SUM(OrderQuantity * ProductPrice), 2) AS Sale
FROM #Temp
GROUP BY FirstName, LastName
ORDER BY Sale DESC
--Sales by gender.
SELECT Gender, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Gender
ORDER BY Sale
--Sales by age group.
SELECT AgeGroup, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY AgeGroup
ORDER BY Sale
--Sales by occupation.
SELECT Occupation, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Occupation
ORDER BY Sale
--Sales by income level.
SELECT AnnualIncome, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY AnnualIncome
ORDER BY Sale



--Product Analysis
--Questions:
--Top-selling products.
SELECT TOP 5 ProductName, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY ProductName
ORDER BY Sale DESC
--Lowest-selling products.
SELECT TOP 5 ProductName, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY ProductName
ORDER BY Sale
--Sales by category.
SELECT TOP 5 CategoryName, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY CategoryName
ORDER BY Sale DESC
--Sales by subcategory.
SELECT TOP 5 SubcategoryName, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY SubcategoryName
ORDER BY Sale DESC
--Sales by product color.
SELECT TOP 5 ProductColor, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY ProductColor
ORDER BY Sale DESC
--Sales by product style.
SELECT TOP 5 ProductStyle, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY ProductStyle
ORDER BY Sale DESC
--Sales by product size.
SELECT TOP 5 ProductSize, SUM(OrderQuantity) AS Sale
FROM #Temp
GROUP BY ProductSize
ORDER BY Sale DESC



--5. Geographic Analysis
--Questions:
--Sales by country.
SELECT Country, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Country
ORDER BY Sale DESC
--Sales by region.
SELECT Region, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Region
ORDER BY Sale DESC
--Sales by territory.
SELECT TerritoryKey, Region, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY TerritoryKey, Region
ORDER BY Sale DESC
--Top-performing territories.
SELECT TOP 5 TerritoryKey, Region, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY TerritoryKey, Region
ORDER BY Sale DESC



--6. Time Analysis
--Questions:
--Sales by year.
SELECT DATENAME(YEAR, OrderDate) AS Year, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY DATENAME(YEAR, OrderDate)
ORDER BY Sale DESC
--Sales by quarter.
SELECT DATENAME(YEAR, OrderDate) AS Year, DATEPART(QUARTER, OrderDate) AS Quarter, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY DATENAME(YEAR, OrderDate), DATEPART(QUARTER, OrderDate)
ORDER BY Year
--Sales by month.
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS MonthNo,
        DATENAME(MONTH, OrderDate) AS MonthName,
        SUM(OrderQuantity * ProductPrice) AS Sales
    FROM #Temp
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate),
        DATENAME(MONTH, OrderDate)
)

SELECT
    SalesYear,
    MonthName,
    ROUND(Sales, 2) AS Sales
FROM MonthlySales
ORDER BY
    SalesYear,
    MonthNo;
--Monthly growth.
WITH MonthlyGrowth AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS MonthNo,
        DATENAME(MONTH, OrderDate) AS MonthName,
        SUM(OrderQuantity * ProductPrice) AS Sales
    FROM #Temp
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate),
        DATENAME(MONTH, OrderDate)
)
SELECT
    SalesYear,
    MonthName,
    ROUND(Sales,2),
    ROUND(LAG(Sales) OVER(ORDER BY SalesYear, MonthName),2) AS PreviousMonth,
    ROUND(
    (
    (Sales - LAG(Sales) OVER(ORDER BY SalesYear, MonthName)) * 100)/
    LAG(Sales) OVER(ORDER BY SalesYear, MonthName),2) AS MonthGrowthPercentage
FROM MonthlyGrowth
--Year-over-year growth.
WITH YearGrowth AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(OrderQuantity * ProductPrice) AS Sales
    FROM #Temp
    GROUP BY
        YEAR(OrderDate)
)
SELECT
    SalesYear,
    ROUND(Sales,2),
    ROUND(LAG(Sales) OVER(ORDER BY SalesYear),2) AS PreviousYear,
    ROUND(
    (
    (Sales - LAG(Sales) OVER(ORDER BY SalesYear)) * 100)/
    LAG(Sales) OVER(ORDER BY SalesYear),2) AS YearGrowthPercentage
FROM YearGrowth



--Profit Analysis
--Most profitable products.
SELECT TOP 5
    ProductName,
    ROUND(SUM(OrderQuantity * (ProductPrice - ProductCost)), 2) AS Profit
FROM #Temp
GROUP BY ProductName
ORDER BY Profit DESC
--Least profitable products.
SELECT TOP 5
    ProductName,
    ROUND(SUM(OrderQuantity * (ProductPrice - ProductCost)), 2) AS Profit
FROM #Temp
GROUP BY ProductName
ORDER BY Profit
--Profit by category.
SELECT
    CategoryName,
    ROUND(SUM(OrderQuantity * (ProductPrice - ProductCost)), 2) AS Profit
FROM #Temp
GROUP BY CategoryName
ORDER BY Profit DESC



--Customer Segmentation
--Analyze sales by:
--Gender
SELECT Gender, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Gender
ORDER BY Sale DESC
--Age Group
SELECT AgeGroup, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY AgeGroup
ORDER BY Sale DESC
--Marital Status
SELECT Marital, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Marital
ORDER BY Sale DESC
--Education
SELECT EducationLevel, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY EducationLevel
ORDER BY Sale DESC
--Occupation
SELECT Occupation, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY Occupation
ORDER BY Sale DESC



--Product Performance
--Identify:
--Top 10 products by revenue.
SELECT TOP 10 ProductName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY ProductName
ORDER BY Sale DESC
--Bottom 10 products.
SELECT TOP 10 ProductName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY ProductName
ORDER BY Sale
--Best categories.
SELECT TOP 5 CategoryName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY CategoryName
ORDER BY Sale DESC
--Best subcategories.
SELECT TOP 5 SubcategoryName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
FROM #Temp
GROUP BY SubcategoryName
ORDER BY Sale DESC



--Rank Product By Sale
WITH RankProduct AS 
(
    SELECT ProductName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
    FROM #Temp
    GROUP BY ProductName
)
SELECT TOP 5 *, RANK() OVER(ORDER BY Sale DESC) AS RankNo
FROM RankProduct

--Find the top customer in each territory.
WITH TopCustomer AS 
(
    SELECT TerritoryKey, Region, FirstName + ' ' + LastName as Name, ROUND(SUM(OrderQuantity * ProductPrice),2) AS Sale
    FROM #Temp
    GROUP BY TerritoryKey, Region, FirstName, LastName
),
    RankCustomer AS 
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY TerritoryKey ORDER BY Sale DESC) AS RN
        FROM TopCustomer
    )
SELECT *
FROM RankCustomer
WHERE RN = 1
ORDER BY TerritoryKey


--Calculate each product's contribution to total sales
SELECT ProductName, ROUND(SUM(OrderQuantity * ProductPrice),2) AS ProductSale, 
    ROUND(SUM(OrderQuantity * ProductPrice) * 100.0 / SUM(SUM(OrderQuantity * ProductPrice)) OVER(),2) AS ContributionPercent
FROM #Temp
GROUP BY ProductName
ORDER BY ProductSale DESC

--Profit Margin
SELECT
    ProductName,
    ROUND(SUM(OrderQuantity * ProductPrice), 2) AS Sales,
    ROUND(SUM(OrderQuantity * ProductCost), 2) AS Cost,
    ROUND(SUM(OrderQuantity * (ProductPrice - ProductCost)), 2) AS Profit,
    ROUND(
        SUM(OrderQuantity * (ProductPrice - ProductCost)) * 100.0
        / SUM(OrderQuantity * ProductPrice),
        2
    ) AS ProfitMargin
FROM #Temp
GROUP BY ProductName
ORDER BY ProfitMargin DESC;

