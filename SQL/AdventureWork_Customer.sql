SELECT * 
FROM AdventureWorks_Customer$

--Update MaritalStatus
ALTER Table AdventureWorks_Customer$
ADD Marital VARCHAR(50)

UPDATE AdventureWorks_Customer$
SET Marital = CASE	
				WHEN MaritalStatus = 'M' THEN 'Married'
				WHEN MaritalStatus = 'S' THEN 'Singal'
			END

ALTER TABLE AdventureWorks_Customer$
DROP COLUMN MaritalStatus

--Update Gender Column
UPDATE AdventureWorks_Customer$
SET Gender = CASE
				WHEN Gender = 'M' THEN 'Male'
				WHEN Gender = 'F' Then 'Female'
				ELSE Gender
			END
--Update HomeOwner
UPDATE AdventureWorks_Customer$
SET HomeOwner = CASE
				WHEN HomeOwner = 'Y' THEN 'Yes'
				WHEN HomeOwner = 'NO' THEN 'No'
				ELSE HomeOwner
				END

--Fixing null in Prefix colum
UPDATE AdventureWorks_Customer$
SET Prefix = 'Unknown'
WHERE Prefix IS NULL

--Fixing null in Gender Colum
UPDATE AdventureWorks_Customer$
SET Gender = 'Unknown'
WHERE Gender = 'NA'

--Adding Age colum
ALTER TABLE AdventureWorks_Customer$
ADD Age INT
UPDATE AdventureWorks_Customer$
SET Age = DATEDIFF(YEAR, BirthDate, GETDATE())

--Adding AgeGroup column
ALTER TABLE AdventureWorks_Customer$
ADD AgeGroup VARCHAR(50)

UPDATE AdventureWorks_Customer$
SET AgeGroup = CASE
					WHEN Age BETWEEN 46 AND 55 THEN 'Middle-Aged'
					WHEN Age BETWEEN 56 AND 65 THEN 'Older Adults'
					WHEN Age BETWEEN 66 AND 75 THEN 'Senior Adults'
					WHEN Age BETWEEN 76 AND 85 THEN 'Elderly'
					WHEN Age BETWEEN 86 AND 95 THEN 'Advanced Age'
					WHEN Age BETWEEN 96 AND 105 THEN 'Centenarian Range'
					WHEN Age > 105 THEN 'Supercentenarian Range'
				END

--Analysis
--Counting Customer in EducationalLevel
SELECT EducationLevel, COUNT(*) AS TotalCustomers 
FROM AdventureWorks_Customer$
GROUP BY EducationLevel
ORDER BY TotalCustomers DESC

--COUNT Customer By Professional 
SELECT Occupation, COUNT(*) AS TotalCustomers 
FROM AdventureWorks_Customer$
GROUP BY Occupation
ORDER BY TotalCustomers DESC

--How Much Customer Have House
SELECT HomeOwner, COUNT(*) AS TotalCustomers 
FROM AdventureWorks_Customer$
GROUP BY HomeOwner
ORDER BY TotalCustomers DESC

--How Much Married or Not
SELECT Marital, COUNT(*) AS TotalCustomers
FROM AdventureWorks_Customer$
GROUP BY Marital
ORDER BY TotalCustomers

--Count Prefix
SELECT Prefix, COUNT(*) AS TotalCustomers
FROM AdventureWorks_Customer$
GROUP BY Prefix
ORDER BY TotalCustomers

--Couting Male and Female
SELECT Gender, COUNT(*) AS TotalCustomers
FROM AdventureWorks_Customer$
GROUP BY Gender
ORDER BY TotalCustomers

--Counting Customers By AnnualIncome
SELECT AnnualIncome, COUNT(*) AS TotalCustomers
FROM AdventureWorks_Customer$
GROUP BY AnnualIncome
ORDER BY TotalCustomers

--Customer have Children
SELECT TotalChildren, COUNT(*) AS TotalCustomers
FROM AdventureWorks_Customer$
GROUP BY TotalChildren
ORDER BY TotalCustomers

SELECT * From AdventureWorks_Customer$



