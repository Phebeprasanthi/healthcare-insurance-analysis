create database if not exists project1_healthinsurance;
use project1_healthinsurance;
-- merging the 2 tables
CREATE TABLE MergedData AS
SELECT H.*, M.BMI, M.HBA1C, M.`Heart Issues`, M.`Any Transplants`, 
M.`Cancer history`, M.`NumberOfMajorSurgeries`, M.smoker
FROM project1_healthinsurance.hospitalisation_details AS H
JOIN project1_healthinsurance.medical_examinations AS M ON H.`Customer ID` = M.`Customer ID`;

-- deleting rows with null values
CREATE TABLE MergedData_cleaned AS
SELECT *
FROM MergedData
WHERE `Customer ID` IS NOT NULL
AND `Customer ID` <> ''
AND `year` IS NOT NULL
AND `month` IS NOT NULL
AND `date` IS NOT NULL
AND `charges` IS NOT NULL
AND `Hospital tier` IS NOT NULL
AND `City tier` IS NOT NULL
AND `State ID` IS NOT NULL
AND BMI IS NOT NULL
AND HBA1C IS NOT NULL
AND `Heart Issues` IS NOT NULL
AND `Any Transplants` IS NOT NULL
AND `Cancer history` IS NOT NULL
AND NumberOfMajorSurgeries IS NOT NULL
AND smoker IS NOT NULL;

SELECT * FROM MergedData_cleaned;
-- alter table adding primary key on 'Customer ID'
ALTER TABLE MergedData_cleaned
ADD PRIMARY KEY (`Customer ID`(255));

-- calculate age from  the year, month, date columns
ALTER TABLE MergedData_cleaned
ADD Age int;
SET SQL_SAFE_UPDATES = 0;
UPDATE MergedData_cleaned
SET Age = YEAR(CURRENT_DATE) - year - CASE 
            WHEN MONTH(CURRENT_DATE) < month 
            OR (MONTH(CURRENT_DATE) = month AND DAY(CURRENT_DATE) < date) THEN 1 
            ELSE 0 
          END;
          
SELECT AVG(Age) AS Average_Age,
       AVG(Children) AS Average_Children,
       AVG(BMI) AS Average_BMI,
       AVG(Charges) AS Average_Charges
FROM MergedData_cleaned
WHERE HBA1C > 6 AND `Heart Issues` = 'yes';

-- average charges for hospital tiers
SELECT `Hospital tier`, AVG(Charges) AS Average_Charges_hospital
FROM MergedData_cleaned
GROUP BY `Hospital tier`;

-- average charges for city tiers
SELECT `City tier`, AVG(Charges) AS Average_Charges_city
FROM MergedData_cleaned
GROUP BY `City tier`;

-- count of people who had surgery and cancer history
SELECT 'Cancer history', 'NumberOfMajorSurgeries', COUNT(`Customer ID`) AS COUNT
FROM MergedData_cleaned
WHERE `Cancer history` = 'yes' AND `NumberOfMajorSurgeries` >= 1;

-- count of tier - 1 hospitals across states
SELECT `State ID`, COUNT(*) AS 'Num Of Tier1 Hospitals'
FROM MergedData_cleaned
WHERE `Hospital tier` = 'tier - 1'
GROUP BY `State ID`;
