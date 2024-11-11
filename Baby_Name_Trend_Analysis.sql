SELECT *
FROM baby_names_db.names; 

/*Find the overall most popular girl and boy names and show how they have changed in popularity 
rankings over the years */ 

SELECT Name, sum(Births) AS num_babies
FROM names 
WHERE Gender='F'
GROUP BY name 
ORDER BY num_babies DESC
LIMIT 1; -- Jessica


SELECT Name, sum(Births) AS num_babies
FROM names 
WHERE Gender='M'
GROUP BY name 
ORDER BY num_babies DESC
LIMIT 1; -- Micheal 

SELECT * FROM
(WITH girl_names AS (SELECT Year, Name , sum(births) AS num_babies 
FROM names
where gender='F' 
Group by Year, Name) 
SELECT Year, Name,
row_number() over (partition by year order by num_babies DESC) AS popularity  
FROM girl_names ) AS popular_girl_names
WHERE name='Jessica' ;


-- Boys 
SELECT * FROM
(WITH boy_names AS (SELECT Year, Name , sum(births) AS num_babies 
FROM names
where gender='M' 
Group by Year, Name) 
SELECT Year, Name,
row_number() over (partition by year order by num_babies DESC) AS popularity  
FROM boy_names ) AS popular_boys_names
WHERE name='Micheal' ;
/*Find the names with the biggest jumps in popularity from the first
 year of the data set to the last year*/
 
 WITH names_1980 AS (
	 WITH all_names AS (
	 SELECT year, name, sum(births) as num_babies
	 FROM names 
	 GROUP by year, name)
	 SELECT year, name ,
	 row_number() OVER (partition by year order by num_babies DESC) AS popularity 
	 FROM all_names 
     WHERE year=1980
	 ) ,   
names_2009 AS(
	 WITH all_names AS (
	 SELECT year, name, sum(births) as num_babies
	 FROM names 
	 GROUP by year, name)
	 SELECT year, name ,
	 row_number() OVER (partition by year order by num_babies DESC) AS popularity
     FROM all_names 
	 WHERE year=2009) 
SELECT t1.year, t1.name, t1.popularity, t2.year, t2.name, t2.popularity, 
CAST(t2.popularity AS SIGNED) - CAST(t1.popularity AS SIGNED) AS diff
FROM names_1980 t1 INNER JOIN names_2009 t2 
ON t1.name=t2.name
ORDER BY diff ;
-- Objective 2 
-- For each year, return the 3 most popular girl names and 3 most popular boy names 
-- Most popular girls
-- Personal Trial
SELECT Name, sum(Births) AS num_babies
FROM names 
WHERE Gender='F'
GROUP BY name 
ORDER BY num_babies DESC
LIMIT 3; -- Jessica/ Ashely /Jennifer
-- Most popular boys
SELECT Name, sum(Births) AS num_babies
FROM names 
WHERE Gender='M'
GROUP BY name 
ORDER BY num_babies DESC
LIMIT 3; -- Michael/ Christopher /Mathew 

-- For each decade, return the 3 most popular girl names and 3 most popular boy names 

-- For each year
SELECT * 
FROM 
(WITH babies_by_year AS (SELECT Year, Gender, Name, sum(births) AS num_babies
FROM names 
GROUP by year, Gender, Name ) 
SELECT year, Gender, Name, num_babies, 
row_number() OVER (PARTITION BY year, gender ORDER BY num_babies DESC) AS popularity 
FROM babies_by_year ) AS Top_three
WHERE popularity <4;

-- For each decade 

SELECT * 
FROM 
(WITH babies_by_decade AS (SELECT (CASE WHEN year between 1980 AND 1989 THEN 'Eighties'
                                WHEN year between 1990 AND 1999 THEN 'Nineties' 
                                WHEN year between 2000 AND 2010 THEN 'Two thousands'
                                ELSE 'None' END ) AS decade , 
Gender, Name, sum(births) AS num_babies
FROM names 
GROUP by decade, Gender, Name ) 
SELECT decade, Gender, Name, num_babies, 
row_number() OVER (PARTITION BY decade, gender ORDER BY num_babies DESC) AS popularity 
FROM babies_by_decade ) AS Top_three
WHERE popularity <4;
-- Objective 3
-- Return the number of babies born in each of the six regions (NOTE: The state of MI should be in the Midwest region) 

WITH clean_regions AS ( SELECT State , 
CASE when Region='New England' THEN 'New_England' ELSE Region END AS clean_region
FROM regions 
UNION 
SELECT 'MI' AS State , 'Midwest' AS Region)
SELECT clean_region, SUM(Births) AS num_babies
FROM names n LEFT Join clean_regions cr
ON n.State=cr.State 
GROUP BY clean_region ;
-- Return the 3 most popular girl names and 3 most popular boy names within each region

SELECT *
FROM
(WITH babies_by_regions AS (
	WITH clean_regions AS ( SELECT State , 
	CASE when Region='New England' THEN 'New_England' ELSE Region END AS clean_region
	FROM regions 
	UNION 
	SELECT 'MI' AS State , 'Midwest' AS Region)
	SELECT cr.clean_region,n.gender, n.name, SUM(Births) AS num_babies
	FROM names n LEFT Join clean_regions cr
	ON n.State=cr.State 
	GROUP BY cr.clean_region, n.gender, n.name ) 
SELECT clean_region, Gender, Name, num_babies, 
row_number() OVER (PARTITION BY clean_region, gender ORDER BY num_babies DESC) AS popularity 
FROM babies_by_regions ) AS region_popularity
WHERE popularity <4;

