/* k2final is a table with various performance indicators for the key stage 2 of the schools in 
England. Average scaled score in reading (MAT_AVERAGE), Average scaled score in grammar, 
punctuation and spelling (GPS_AVERAGE) and Average scaled score in maths (READ_AVERAGE) are the 
indicators to be merged with the main table, namely school_info. There are various record type for 
ks2final table, including Mainstream schools, Special schools, Local Authority, National 
average (all schools) and National average (state-funded schools only) */

-- Only rows concerning mainstream schools (i.e. RECTYPE = 1) are needed
DELETE FROM Portfolio.dbo.ks2final
WHERE RECTYPE <> 1

-- There are no independent schools released their KS2 performance
SELECT c.MINORGROUP, c.SCHNAME
FROM
(SELECT a.MINORGROUP, b.SCHNAME
FROM Portfolio.dbo.school_info a, Portfolio.dbo.ks2final b
WHERE a.URN = b.URN) c
ORDER by MINORGROUP

/* k4final is a table with various performance indicators for the key stage 4 of 
the schools in England. Average Attainment 8 score per pupil (ATT8SCR), % of pupils achieving 
strong 9-5 passes in both English and mathematics GCSEs (PTL2BASICS_95) and Percentage of pupils 
achieving the English Baccalaureate with 9-5 passes (PTEBACC_95) are the indicators
to be merged with the main table, namely school_info. There are various record type for 
ks2final table, including Mainstream schools, Special schools, Local Authority, National 
average (all schools) and National average (state-funded schools only) */

-- Only rows concerning mainstream schools (i.e. RECTYPE = 1) are needed
DELETE FROM Portfolio.dbo.ks4final
WHERE RECTYPE <> 1

/* GSCE performance are not applicable to colleges as they are for 6th form, which show NA for the 
indicators. Independent schools also did not release the related info in the table, showing NA for 
the indicators. NULL values happen for certain Academy schools. We do not intend to replace
any NA values for independent schools by the mean of the indicators, as the performance of 
state schools and independent schools can be quite different. */
SELECT MINORGROUP, SCHNAME, ATT8SCR, PTEBACC_95, PTL2BASICS_95
FROM
(SELECT a.MINORGROUP, a.SCHNAME, b.ATT8SCR, b.PTL2BASICS_95, b.PTEBACC_95
FROM Portfolio.dbo.school_info a, Portfolio.dbo.ks4final b
WHERE a.URN = b.URN) c
WHERE ISNUMERIC(ATT8SCR) = 0
ORDER by 1

/* school_info table contains the ofsted rating and other basic info for all schools in England
including primary, secondary and all-through schools */

-- Data cleaning for the school_info table

-- Add a column for recording primary/ secondary/ all-through/ sixth form 
ALTER Table Portfolio.dbo.school_info
Add SCHOOL_LEVEL nvarchar(255)

UPDATE Portfolio.dbo.school_info
SET SCHOOL_LEVEL =
CASE WHEN ISPRIMARY = 1 and ISSECONDARY = 0 THEN 'Primary'
	WHEN ISPRIMARY = 1 and ISSECONDARY = 1 THEN 'All-through'
	WHEN ISPRIMARY = 0 and ISSECONDARY = 1 THEN 'Secondary'
	WHEN ISPRIMARY = 0 and ISSECONDARY = 0 and ISPOST16 = 1 THEN 'Sixth form'
	ELSE 'NA'
	END

-- Create a new table namely school_performance, which record the ofsted ratings, school basic info,
-- ks2 indicators and ks4 indicators for all mainstream schools in England. Corresponding 
-- region names are mapped after joining with region_codes table.
DROP Table if exists Portfolio.dbo.school_performance
SELECT
	a.URN, 
	a.LA,
	e.[ONS LA code],
	a.LANAME, 
	b.[REGION NAME],
	a.SCHNAME, 
	a.POSTCODE,
	a.MINORGROUP as SCHOOL_TYPE, 
	a.SCHOOL_LEVEL,
	a.GENDER, 
	a.AGELOW,
	a.AGEHIGH,
	a.OFSTEDRATING,
	c.MAT_AVERAGE,
	c.GPS_AVERAGE,
	c.READ_AVERAGE,
	d.ATT8SCR,
	d.PTL2BASICS_95,
	d.PTEBACC_95
INTO Portfolio.dbo.school_performance
FROM Portfolio.dbo.school_info a
INNER JOIN Portfolio.dbo.region_codes b ON a.LA = b.LEA
INNER JOIN Portfolio.dbo.EnglishLaNameCodes e ON a.LA = e.[GIAS LA code]
LEFT JOIN Portfolio.dbo.ks2final c ON a.URN = c.URN
LEFT JOIN Portfolio.dbo.ks4final d ON a.URN = d.URN
WHERE (MINORGROUP = 'Academy' or MINORGROUP = 'College' or MINORGROUP = 'Independent school' or MINORGROUP = 'Maintained school') and a.SCHSTATUS = 'Open'

-- Check if any no duplicate school records
With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY URN,
				 LA,
				 SCHNAME
				 ORDER BY
					URN
					) row_num
FROM Portfolio.dbo.school_performance
)

Select * 
FROM RowNumCTE
WHERE row_num <> 1
ORDER BY URN

/* Check and replace NULL values for KS2 performance indicators */

-- There exist NULL values for MAT_AVERAGE column.
SELECT DISTINCT(MAT_AVERAGE)
From Portfolio.dbo.school_performance
Order by 1

-- Check null values of MAT_AVERAGE and replace any null values by the national average
UPDATE Portfolio.dbo.school_performance
SET MAT_AVERAGE = (SELECT ROUND(AVG(MAT_AVERAGE), 0) as MAT_AVERAGE_ALL
					FROM Portfolio.dbo.school_performance)
FROM Portfolio.dbo.school_performance a
WHERE MAT_AVERAGE is NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Primary' or SCHOOL_LEVEL = 'All-through')

-- There exist NULL values for GPS_AVERAGE column.
SELECT DISTINCT(GPS_AVERAGE)
From Portfolio.dbo.school_performance
Order by 1

-- Check null values of GPS_AVERAGE and replace any null values by the national average
UPDATE Portfolio.dbo.school_performance
SET GPS_AVERAGE = (SELECT ROUND(AVG(GPS_AVERAGE), 0) as GPS_AVERAGE_ALL
					FROM Portfolio.dbo.school_performance)
FROM Portfolio.dbo.school_performance a
WHERE GPS_AVERAGE is NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Primary' or SCHOOL_LEVEL = 'All-through')

-- There exist NULL values for READ_AVERAGE column.
SELECT DISTINCT(READ_AVERAGE)
From Portfolio.dbo.school_performance
Order by 1

-- Check null values of READ_AVERAGE and replace any null values by the national average
UPDATE Portfolio.dbo.school_performance
SET READ_AVERAGE = (SELECT ROUND(AVG(READ_AVERAGE), 0) as READ_AVERAGE_ALL
					FROM Portfolio.dbo.school_performance)
FROM Portfolio.dbo.school_performance a
WHERE READ_AVERAGE is NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Primary' or SCHOOL_LEVEL = 'All-through')

/* Check and replace NULL values for KS4 performance indicators */

-- check null values of ATT8SCR and replace any null values by the national average
UPDATE Portfolio.dbo.school_performance
SET ATT8SCR = (SELECT ROUND(AVG(CONVERT(float, ATT8SCR)), 0) 
				FROM Portfolio.dbo.school_performance
				WHERE ISNUMERIC(ATT8SCR) = 1)
FROM Portfolio.dbo.school_performance
WHERE ATT8SCR IS NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Secondary' or SCHOOL_LEVEL = 'All-through')

-- check null values of PTL2BASICS_95 and replace any null values by the national average
-- Firstly, convert the percentage to a numerical number
UPDATE Portfolio.dbo.school_performance
SET PTL2BASICS_95 = 
CASE WHEN CHARINDEX('%', PTL2BASICS_95) > 1 THEN SUBSTRING(PTL2BASICS_95, 1, CHARINDEX('%', PTL2BASICS_95)-1)
ELSE PTL2BASICS_95
END

UPDATE Portfolio.dbo.school_performance
SET PTL2BASICS_95 = (SELECT AVG(CONVERT(int, PTL2BASICS_95))
					FROM Portfolio.dbo.school_performance
					WHERE ISNUMERIC(PTL2BASICS_95) = 1)
FROM Portfolio.dbo.school_performance
WHERE PTL2BASICS_95 IS NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Secondary' or SCHOOL_LEVEL = 'All-through')

-- check null values of PTEBACC_95 and replace any null values by the national average
-- Firstly, convert the percentage to a numerical number
UPDATE Portfolio.dbo.school_performance
SET PTEBACC_95 = 
CASE WHEN CHARINDEX('%', PTEBACC_95) > 1 THEN SUBSTRING(PTEBACC_95, 1, CHARINDEX('%', PTEBACC_95)-1)
ELSE PTEBACC_95
END

UPDATE Portfolio.dbo.school_performance
SET PTEBACC_95 = (SELECT AVG(CONVERT(int, PTEBACC_95))
					FROM Portfolio.dbo.school_performance
					WHERE ISNUMERIC(PTEBACC_95) = 1)
FROM Portfolio.dbo.school_performance
WHERE PTEBACC_95 IS NULL and (SCHOOL_TYPE = 'Maintained school' or SCHOOL_TYPE = 'Academy') and (SCHOOL_LEVEL = 'Secondary' or SCHOOL_LEVEL = 'All-through')


/* Since there are some schools neither release ofsted rating nor its KS2/ KS4 performance,
they are not very meaningful in the analysis and are to be removed */
--SELECT *
--FROM Portfolio.dbo.school_performance
DELETE FROM Portfolio.dbo.school_performance
WHERE OFSTEDRATING is NULL and ISNUMERIC(MAT_AVERAGE) = 0 and ISNUMERIC(ATT8SCR) = 0

-- Remove the rows with too few records which may bias the comparison among the local authorities
DELETE FROM Portfolio.dbo.school_performance
WHERE LA IN (SELECT LA
				From Portfolio.dbo.school_performance
				Group by LA
				Having COUNT(*) < 3)

/* We found there are 4 schools (Hartpury College, Wimborne Primary School, St John Henry Newman 
Catholic VA Primary School and Dixons Croxteth Academy) have missing data of GENDER field. */
-- update the GENDER fields after checking their websites
SELECT *
From Portfolio.dbo.school_performance
WHERE Gender is NULL

UPDATE Portfolio.dbo.school_performance
SET GENDER = 'Mixed'
WHERE URN = '146555'

UPDATE Portfolio.dbo.school_performance
SET GENDER = 'Mixed'
WHERE URN = '148078'

UPDATE Portfolio.dbo.school_performance
SET GENDER = 'Mixed'
WHERE URN = '149159'

UPDATE Portfolio.dbo.school_performance
SET GENDER = 'Mixed'
WHERE URN = '149530'

-- Add a new column which shows a particular school has numerical values of KS2 indicators (=1)
ALTER Table Portfolio.dbo.school_performance
Add KS2 BIT

UPDATE Portfolio.dbo.school_performance
SET KS2 =
CASE WHEN ISNUMERIC(MAT_AVERAGE) = 1 or ISNUMERIC(GPS_AVERAGE) = 1 or ISNUMERIC(READ_AVERAGE) = 1 THEN 1
	ELSE 0
	END

-- Add a new column which shows a particular school has numerical values of KS4 indicators (=1)
ALTER Table Portfolio.dbo.school_performance
Add KS4 BIT

UPDATE Portfolio.dbo.school_performance
SET KS4 =
CASE WHEN ISNUMERIC(ATT8SCR) = 1 or ISNUMERIC(PTL2BASICS_95) = 1 or ISNUMERIC(PTEBACC_95) = 1 THEN 1
	ELSE 0
	END


ALTER Table Portfolio.dbo.school_performance
Add KS2_Avg float

UPDATE Portfolio.dbo.school_performance
SET KS2_Avg = 
CASE WHEN KS2 = 1 THEN (MAT_AVERAGE + GPS_AVERAGE + READ_AVERAGE)/ 3
	ELSE 0
END

ALTER Table Portfolio.dbo.school_performance
Add KS4_Avg float

UPDATE Portfolio.dbo.school_performance
SET KS4_Avg = 
CASE WHEN KS4 = 1 THEN ((CONVERT(float, ATT8SCR) + CONVERT(float, PTL2BASICS_95) + CONVERT(float, PTEBACC_95)))/ 3
	ELSE 0
END

--SELECT DISTINCT([REGION NAME])
--From Portfolio.dbo.school_performance
--ORDER By 1

-- Remove ambiguity of region names in a consistent ways of official presentation as other datasets  
UPDATE Portfolio.dbo.school_performance
SET [REGION NAME] = 
CASE WHEN [REGION NAME] LIKE '%A'THEN REPLACE([REGION NAME], ' A', '')
	WHEN [REGION NAME] LIKE '%B'THEN REPLACE([REGION NAME], ' B', '')
	WHEN [REGION NAME] LIKE '%C'THEN REPLACE([REGION NAME], ' C', '')
	WHEN [REGION NAME] LIKE '%D'THEN REPLACE([REGION NAME], ' D', '')
	WHEN [REGION NAME] LIKE 'London East'THEN 'London'
	WHEN [REGION NAME] LIKE 'London North'THEN 'London'
	WHEN [REGION NAME] LIKE 'London South'THEN 'London'
	WHEN [REGION NAME] LIKE 'London West'THEN 'London'
	WHEN [REGION NAME] LIKE 'London Central'THEN 'London'
ELSE [REGION NAME]
END
