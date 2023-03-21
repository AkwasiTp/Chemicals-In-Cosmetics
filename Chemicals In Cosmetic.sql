---------------------------------------------------------------------------------- 
--DATA EXPLORATION
SELECT * FROM ProjectsPortfolio..ChemicalsInCosmetic

SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ChemicalsInCosmetic'

SELECT DISTINCT(BrandName) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY BrandName

SELECT * FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE BrandName IS NULL

SELECT DISTINCT(PrimaryCategory) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY PrimaryCategory

SELECT * FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE BrandName LIKE '%Rimmel%'

SELECT DISTINCT(MostRecentDateReported) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY MostRecentDateReported

SELECT DISTINCT(InitialDateReported) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY InitialDateReported

SELECT DISTINCT(DiscontinuedDate) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY DiscontinuedDate

SELECT DISTINCT(ChemicalDateRemoved) FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY ChemicalDateRemoved

SELECT DISTINCT(CompanyName), CompanyId FROM ProjectsPortfolio..ChemicalsInCosmetic
GROUP BY CompanyName, CompanyId
ORDER BY CompanyName

SELECT * FROM ProjectsPortfolio..ChemicalsInCosmetic
where CompanyName like '%added extras%' -- Same Company Name but different Company IDs


---------------------------------------------------------------------------------- 
-- DATA CLEANING
-- CONVERTING DATE COLUMNS TO DATE DATA TYPE

SELECT MostRecentDateReported, CONVERT(DATE,MostRecentDateReported) AS DATE 
FROM ProjectsPortfolio..ChemicalsInCosmetic

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN MostRecentDateReported DATE

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN InitialDateReported DATE

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN DiscontinuedDate DATE

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN ChemicalCreatedAt DATE

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN ChemicalUpdatedAt DATE

ALTER TABLE ProjectsPortfolio..ChemicalsInCosmetic
ALTER COLUMN ChemicalDateRemoved DATE

SELECT * FROM ProjectsPortfolio..ChemicalsInCosmetic

SELECT DISTINCT(BrandName),CDPHId,CSFId,SubCategoryId,ChemicalId
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE BrandName IS NULL
GROUP BY CDPHId,CSFId,SubCategoryId,ChemicalId,BrandName

-- CLEANING CHARACTERS '�' FROM PRODUCTNAME, COMPANY NAME AND BRANDNAME
SELECT DISTINCT ProductName, REPLACE(ProductName, '�', '') AS ProductNameUpdated
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE ProductName LIKE '%�%'

SELECT DISTINCT BrandName, REPLACE(BrandName, '�', '') AS BrandNameUpdated
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE BrandName LIKE '%�%'

SELECT DISTINCT CompanyName, REPLACE(CompanyName, '�', '') AS CompanyNameUpdated
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE CompanyName LIKE '%�%'

UPDATE ProjectsPortfolio..ChemicalsInCosmetic
SET ProductName = REPLACE(ProductName, '�', '')

UPDATE ProjectsPortfolio..ChemicalsInCosmetic
SET BrandName = REPLACE(BrandName, '�', '')

UPDATE ProjectsPortfolio..ChemicalsInCosmetic
SET CompanyName = REPLACE(CompanyName, '�', '')

-- CORRECTING ERRORS IN COMPANY NAME
SELECT DISTINCT(CompanyName)
FROM ProjectsPortfolio..ChemicalsInCosmetic
ORDER BY CompanyName DESC

UPDATE ProjectsPortfolio..ChemicalsInCosmetic
SET CompanyName = CASE 
						WHEN CompanyName LIKE '%Vi-Jon%' THEN 'Vi-Jon, Inc.'
						WHEN CompanyName LIKE '%Stila Style%' THEN 'Stilla Styles LLC'
						WHEN CompanyName LIKE '%Shiseido%' THEN 'Shiseido Americas Corporation'
						WHEN CompanyName LIKE '%Neostrata%' THEN 'Neostrata Company Inc.'
						WHEN CompanyName LIKE '%LVMH%' THEN 'LVMH Fragrance Brands LLC'
						WHEN CompanyName LIKE '%Lush%' THEN 'Lush Manufacturing Ltd'
						WHEN CompanyName LIKE '%PAYOT%' THEN 'Laboratories Dr N.G. Payot'
						WHEN CompanyName LIKE '%Interparfums%' THEN 'Inter Parfums, Inc.'
						WHEN CompanyName LIKE '%Fresh%' THEN 'Fresh Inc.'
						WHEN CompanyName LIKE '%Cover FX%' THEN 'Cover FX Skin Care Inc.'
						WHEN CompanyName LIKE '%Arcadia Beauty%' THEN 'Arcadia Beauty Labs LLC'
						WHEN CompanyName LIKE '%Apollo Health%' THEN 'Apollo Health and Beauty Care Inc.'
						WHEN CompanyName LIKE '%American Consumer%' THEN 'American Consumer Products LLC'
						ELSE CompanyName
					END



---------------------------------------------------------------------------------- 
-- DATA ANALYSIS (SOLUTION TO QUESTIONS)

-- Q1 Find out which chemicals were used the most in cosmetics and personal care products.
SELECT TOP 10 ChemicalName, COUNT(ChemicalName) as TotalChemicals
FROM ProjectsPortfolio..ChemicalsInCosmetic
GROUP BY ChemicalName
ORDER BY TotalChemicals DESC

-- Q2 Find out which companies used the most reported chemicals in their cosmetics and personal care products.
SELECT CompanyName, COUNT(CompanyName) as ReportCount
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE MostRecentDateReported IS NOT NULL
GROUP BY CompanyName
ORDER BY ReportCount DESC

-- Q3 Which brands had chemicals that were removed and discontinued? Identify the chemicals
SELECT BrandName, ChemicalName, COUNT(BrandName) as TotalCount
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE ChemicalDateRemoved IS NOT NULL 
AND	  DiscontinuedDate IS NOT NULL
GROUP BY BrandName, ChemicalName
ORDER BY TotalCount DESC

-- Q4 Identify the brands that had chemicals which were mostly reported in 2018
SELECT BrandName, COUNT(MostRecentDateReported) AS TimesReported
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE YEAR(MostRecentDateReported) = 2018
GROUP BY BrandName
ORDER BY TimesReported DESC


-- Q5 Which brands had chemicals discontinued and removed?
SELECT BrandName, COUNT(BrandName) as TotalCount
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE DiscontinuedDate IS NOT NULL 
AND	 ChemicalDateRemoved IS NOT NULL
GROUP BY BrandName
ORDER BY TotalCount DESC

-- Q6 Identify the period between the creation of the removed chemicals and when they were actually removed.
SELECT ChemicalName, MIN(YEAR(ChemicalCreatedAt)) AS FirstYearCreated, 
					 MAX(YEAR(ChemicalDateRemoved)) AS LastestYearRemoved, 
					 MAX(DATEDIFF(DAY, ChemicalCreatedAt, ChemicalDateRemoved)) AS DaysBetween
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE ChemicalDateRemoved IS NOT NULL
GROUP BY ChemicalName
ORDER BY DaysBetween DESC

-- Q7 Can you tell if discontinued chemicals in bath products were removed
SELECT PrimaryCategory, ChemicalName, 
		MAX(DiscontinuedDate) AS LatestDateDiscontinued, 
		MAX(ChemicalDateRemoved) AS LatestDateRemoved
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE PrimaryCategory LIKE '%Bath Products%'
	 AND DiscontinuedDate IS NOT NULL
GROUP BY PrimaryCategory, ChemicalName
ORDER BY 2

-- Q8 How long were removed chemicals in baby products used? (Tip: Use creation date to tell)
SELECT PrimaryCategory, ChemicalName, ChemicalCreatedAt, ChemicalDateRemoved,
			MAX(DATEDIFF(DAY, ChemicalCreatedAt, ChemicalDateRemoved)) AS DaysBetween
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE PrimaryCategory LIKE '%Baby Products%'
	 AND ChemicalDateRemoved IS NOT NULL
GROUP BY PrimaryCategory, ChemicalName, ChemicalCreatedAt, ChemicalDateRemoved
ORDER BY DaysBetween DESC

-- Q9 Identify the relationship between chemicals that were mostly recently reported and discontinued. (Does most recently reported chemicals equal discontinuation of such chemicals?)
SELECT ChemicalName, COUNT(MostRecentDateReported) AS TotalReported, 
					 MIN(MostRecentDateReported) EarliestDateReported, 
					 MAX(DiscontinuedDate) AS LatestDateDiscontinued
FROM ProjectsPortfolio..ChemicalsInCosmetic
WHERE MostRecentDateReported IS NOT NULL
GROUP BY ChemicalName
ORDER BY TotalReported DESC

-- Q10 Identify the relationship between CSF and chemicals used in the most manufactured sub categories. (Tip: Which chemicals gave a certain type of CSF in sub categories?)
SELECT ChemicalName, CSF, SubCategory, COUNT(SubCategory) AS MostManufacturedSubcategories
FROM ProjectsPortfolio..ChemicalsInCosmetic
GROUP BY ChemicalName, CSF, SubCategory
ORDER BY MostManufacturedSubcategories DESC

