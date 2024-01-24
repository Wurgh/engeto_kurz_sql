-- jake mame joiny
-- LEFT JOIN
-- RIGHT JOIN
-- CROSS JOIN
-- INNER JOIN
SELECT *
FROM covid19_basic_differences cbd 
WHERE date = '2020-05-28';
-- 2020-05-28 o kolik nam rostly potvrzene pripady oprotti minulemu dnu
-- V CR
WITH current_day AS (
	SELECT 
		date,
		country,
		confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1 
		AND date = '2020-05-28'
--		AND country = "Czechia"
),
previous_day AS (
	SELECT 
		date,
		country,
		confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1 
		AND date = '2020-05-28' - INTERVAL 1 DAY
--		AND country = "Czechia"
),
joined AS(
	SELECT 
		cd.date,
		cd.country,
		cd.confirmed AS current_confirmed,
		pd.confirmed AS previous_confirmed,
		cd.confirmed - pd.confirmed AS diff
	FROM current_day cd
	LEFT JOIN previous_day pd
		ON cd.country = pd.country
)
SELECT 
	*
FROM joined
ORDER BY diff DESC
LIMIT 10
;

WITH base AS (
	SELECT 
		date,
		country,
		confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1 
		AND date >= '2020-05-28'
		AND country = "Czechia"
)
	SELECT 
		cd.date,
		cd.country,
		cd.confirmed AS current_confirmed,
		pd.confirmed AS previous_confirmed,
		cd.confirmed - pd.confirmed AS diff
	FROM base cd
	LEFT JOIN base pd
		ON cd.country = pd.country
		AND cd.date = pd.date + INTERVAL 1 DAY
WHERE cd.date = '2020-05-28'
;		

		
-- to stejné jako předtím jen pomocí WINDOW FUNCTION 
WITH base AS (
SELECT 
		date,
		country,
		confirmed,
		LAG(confirmed) OVER 
			(PARTITION BY country ORDER BY date) AS lag_confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1 
		AND date >= '2020-05-01'
		AND country = "Czechia"
)
SELECT 
	date,
	country,
	confirmed,
	lag_confirmed,
	confirmed - lag_confirmed AS diff,
	(confirmed - lag_confirmed)/confirmed AS growth_perc
FROM base
;		

-- sales aplikace full join a cross join
CREATE TABLE tmp_pf_car_shop2 (
	datum int,
	product text,
	value int
);
INSERT INTO tmp_pf_car_shop2 VALUES(202201,'car',100000);
INSERT INTO tmp_pf_car_shop2 VALUES(202201,'oil',50000);
INSERT INTO tmp_pf_car_shop2 VALUES(202202,'car',120000);
INSERT INTO tmp_pf_car_shop2 VALUES(202203,'car',150000);
INSERT INTO tmp_pf_car_shop2 VALUES(202203,'oil',50000);
INSERT INTO tmp_pf_car_shop2 VALUES(202204,'car',130000);
INSERT INTO tmp_pf_car_shop2 VALUES(202204,'oil',70000);


WITH datums AS (
	SELECT DISTINCT
		datum
	FROM tmp_pf_car_shop2
),
products AS (
	SELECT DISTINCT
		product
	FROM tmp_pf_car_shop2
),
crossed AS (
SELECT 
	*
FROM datums
	CROSS JOIN products
--	LEFT JOIN product
--		ON 1=1
)
SELECT 
	a.datum,
	a.product,
--	CASE WHEN b.value IS NULL THEN 0 ELSE b.value END
	COALESCE (b.value, 0)
FROM crossed a
LEFT JOIN tmp_pf_car_shop2 b
	ON a.datum = b.datum
	AND a.product = b.product
;

SELECT 
	COALESCE (a.datum, b.datum) AS datum,
	COALESCE (a.product, b.product) AS product,
	COALESCE (a.value,0) AS previous_value,
	COALESCE (b.value,0) AS current_value
FROM tmp_pf_car_shop2 a
LEFT JOIN tmp_pf_car_shop2 b
	ON a.product = b.product
	AND a.datum = b.datum - 1	
UNION 
SELECT 
	COALESCE (a.datum, b.datum) AS datum,
	COALESCE (a.product, b.product) AS product,
	COALESCE (a.value,0) AS previous_value,
	COALESCE (b.value,0) AS current_value
FROM tmp_pf_car_shop2 a
RIGHT JOIN tmp_pf_car_shop2 b
	ON a.product = b.product
	AND a.datum = b.datum - 1
;


-- ---------------------------------------------------------------------
-- WINDOW FUNCTION
-- ---------------------------------------------------------------------
-- jak vyrobit z kumulativnich hodnot denni prirustky
-- zakladni window functions MAX MIN LAG LEAD SUM AVG

WITH base AS (
SELECT 
		date,
		country,
		confirmed,
		LAG(confirmed) OVER 
			(PARTITION BY country ORDER BY date) AS lag_confirmed
	FROM covid19_basic cbd 
	WHERE 1=1 
		AND date >= '2020-05-01'
		AND country = "Czechia"
)
SELECT 
	date,
	country,
	confirmed,
	lag_confirmed,
	confirmed - lag_confirmed AS diff,
	(confirmed - lag_confirmed)/confirmed AS growth_perc
FROM base
;		


-- jak vyrobit z dennich prirustku kumulativni hodnoty
SELECT 
		date,
		country,
		confirmed,
		SUM(confirmed) OVER 
			(PARTITION BY country ORDER BY date
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS lag_confirmed
	FROM covid19_basic_differences
	WHERE 1=1 
		AND date >= '2020-05-01'
--		AND country = "Czechia"
;

-- MOVING AVERAGE - trend vycistit casovou radu od extremnich hodnot
SELECT 
		date,
		country,
		confirmed,
		AVG(confirmed) OVER 
			(PARTITION BY country ORDER BY date
			ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING 
			) AS moving_average
	FROM covid19_basic_differences
	WHERE 1=1 
		AND date >= '2020-05-01'
		AND country = "Czechia"
;

-- ctvrtleti staci zmenit datum
WITH BASE AS (
	SELECT 
		YEAR(date)*100+MONTH(date) AS period,
		YEAR(date)*100+WEEK(date) AS week,
		CONCAT(YEAR(date), 'q', quarter(date)) AS quarter,
		country,
		confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1
	AND date >= '2020-05-01'
	AND country = 'Czechia'
)
SELECT quarter, avg(confirmed) FROM base
GROUP BY quarter
;

-- chceme prvni a posledni hodnotu ve ctvrtleti
WITH base AS (
	SELECT 
		date,
		YEAR(date)*100+MONTH(date) AS period,
		YEAR(date)*100+WEEK(date) AS week,
		CONCAT(YEAR(date), 'q', quarter(date)) AS quarter,
		country,
		confirmed
	FROM covid19_basic_differences cbd 
	WHERE 1=1
	AND date >= '2020-05-01'
	AND country = 'Czechia'
),
window_fcs AS(
	SELECT
		quarter,
		date,
		country,
		confirmed,
		RANK() OVER (PARTITION BY country, quarter ORDER BY date) AS rnk,
		RANK() OVER (PARTITION BY country, quarter ORDER BY date DESC) AS reversed_rnk
	FROM base
)
	SELECT 
	quarter, 
	date,
	country,
	confirmed,
	rnk,
	reversed_rnk
	FROM window_fcs
WHERE 1=1
-- AND rnk = 1
	AND reversed_rnk = 2



-- spocitej kolik zemi melo confirmed vic jak 10000
WITH base AS (
	SELECT	
		country,
		CASE WHEN confirmed > 10000 THEN 1 ELSE 0 END flag,
		count(DISTINCT CASE WHEN confirmed > 10000 THEN country ELSE null END) AS aaaa
	FROM covid19_basic_differences cbd 
)
SELECT count(DISTINCT country) 
FROM base WHERE flag = 1


-- spocitej kolik zemi melo confirmed vic jak 10000
SELECT	
	sum(CASE WHEN confirmed > 1000 THEN 1 ELSE 0 END) AS more_than_1000,
	sum(CASE WHEN confirmed > 5000 THEN 1 ELSE 0 END) AS more_than_5000,
	sum(CASE WHEN confirmed > 7000 THEN 1 ELSE 0 END) AS more_than_7000,
	sum(CASE WHEN confirmed > 10000 THEN 1 ELSE 0 END) AS more_than_10000
FROM covid19_basic_differences cbd 
WHERE date = '2021-01-15'
;

SELECT
	'more_than_1000' AS dsc
	, count(country)
FROM covid19_basic_differences cbd 
WHERE date = '2021-01-15'
	AND confirmed > 1000
UNION
	SELECT
	'more_than_5000' AS dsc
	, count(country)
FROM covid19_basic_differences cbd2 
WHERE date = '2021-01-15'
	AND confirmed > 5000;



