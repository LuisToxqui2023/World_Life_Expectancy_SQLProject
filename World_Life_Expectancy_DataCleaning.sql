-- World Life Expectancy Project (Data Cleaning)

SELECT *
FROM world_life_expectancy;

-- Finding duplicates 
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;


-- Finding the duplicates Row_ID to delete
SELECT *
FROM(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
;
    
DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
)
;


-- Finding blanks 
SELECT *
FROM world_life_expectancy
WHERE Status = '';  


-- Finding out what values goes in Status 
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';


-- Finding out which countries are 'Developing' in Status 
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'; 


-- Updating (first attempted: failed)
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
				FROM world_life_expectancy
				WHERE Status = 'Developing'); 
                

-- Updating specfic blanks into 'Developing' Status (second attempted: Successful)
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country 
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'; 


-- Updating specific blanks into 'Developed' Status
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country 
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';


-- Finding NULL (none)
SELECT *
FROM world_life_expectancy
WHERE Status IS NULL;


-- Finding blanks in Life Expectancy column
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';


-- Finding the average for the blanks 
SELECT  Country, Year, `Life expectancy` 
FROM world_life_expectancy;


SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1 
WHERE t1.`Life expectancy` = '';



-- Updating the blanks in the Life expentancy column with the average value 
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1  
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;