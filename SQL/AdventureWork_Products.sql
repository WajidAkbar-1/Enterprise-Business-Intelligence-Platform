 

--Update ProductSytle Column
UPDATE AdventureWorks_Products$
   SET ProductStyle =
    CASE
        WHEN ProductStyle = 'M' THEN 'Men'
        WHEN ProductStyle = 'W' THEN 'Women'
        WHEN ProductStyle = 'U' THEN 'Unisex'
        WHEN ProductStyle = '0' THEN 'Not Specified'
        ELSE 'Not Specified'
   END

--Update Product Size Column
UPDATE AdventureWorks_Products$
   SET ProductSize = 
    CASE
        WHEN ProductSize = 'S' THEN 'Small'
        WHEN ProductSize = 'M' THEN 'Medium'
        WHEN ProductSize = 'L' THEN 'Large'
        WHEN ProductSize = 'XL' THEN 'Extra Large'
        WHEN ProductSize = '0' THEN 'Not Applicable'
        ELSE ProductSize
    END

--Upate ColorSize Column
UPDATE AdventureWorks_Products$
SET ProductColor = 'Not Specified'
WHERE ProductColor = 'NA'

--Update ProductDescription
UPDATE AdventureWorks_Products$
SET ProductDescription = 'Not Specified'
WHERE ProductDescription = '0'


SELECT * 
FROM AdventureWorks_Products$