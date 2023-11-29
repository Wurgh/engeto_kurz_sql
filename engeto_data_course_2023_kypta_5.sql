-- Klauzule HAVING
/*
 * Úkol 1: Vypište z tabulky covid19_basic_differences země s více než 
 * 5 000 000 potvrzenými případy COVID-19 (data jsou za rok 2020 a část roku 2021).
 */
-- nevalidní dotaz
SELECT cbd.country
		,sum(cbd.confirmed) AS total_confirmed
FROM covid19_basic_differences as cbd 
WHERE sum(cbd.confirmed) > 5000000
GROUP BY country;
-- validní dotaz
SELECT cbd.country
		,sum(cbd.confirmed) AS total_confirmed
FROM covid19_basic_differences as cbd 
GROUP BY country
HAVING sum(cbd.confirmed) > 5000000;
-- ekvivalentní
SELECT cbd.country
		,sum(cbd.confirmed) AS total_confirmed
FROM covid19_basic_differences as cbd 
GROUP BY country
HAVING total_confirmed > 5000000;
-- ekvivalentní s CTE
WITH cbd as (
		SELECT cbd.country
				,sum(cbd.confirmed) AS total_confirmed
		FROM covid19_basic_differences as cbd 
		GROUP BY country
		)
SELECT *
FROM cbd
WHERE total_confirmed > 5000000;

-- Úkol 2: Vyberte z tabulky economies roky a oblasti s populací nad 4 miliardy.
SELECT e.country, e.year, sum(e.population) AS overall_population
FROM economies as e 
GROUP BY e.country, e.`year` 
HAVING overall_population > 4000000000
ORDER BY overall_population DESC;

/*
 * Úkol 3: Vypište 20 nejbližších poskytovatelů zdravotních služeb 
 * v okruhu 10 km od místa na souřadnicích 42°0'0"N 15°0'0"E.
 */
-- 6371 = km, 3959 = miles
SELECT 
    name,
    (6371 * ACOS( COS( RADIANS(49)) * COS( RADIANS( latitude )) 
    * COS( RADIANS( longitude ) - RADIANS(15)) 
    + SIN( RADIANS(49)) * SIN( RADIANS(latitude)))) AS distance 
FROM healthcare_provider
HAVING distance < 10
ORDER BY distance 
LIMIT 0, 20;




