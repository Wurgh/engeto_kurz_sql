SELECT name, provider_type 
FROM healthcare_provider
ORDER BY name ASC;


-- https://mariadb.com/kb/en/trim/ - očišťuje od znaků přičemž select je nedestruktivní

SELECT 
	name, 
	trim(name) 
FROM healthcare_provider
ORDER BY trim(name);

-- nastavení co trimovat LTRIM, RTRIM zleva zprava
SELECT trim (LEADING ' ' FROM '    rct'); 

SELECT provider_id, name, provider_type, region_code, district_code
FROM healthcare_provider 
ORDER BY region_code ASC, district_code ASC;

SELECT *
FROM czechia_district 
ORDER BY code DESC;

SELECT *
FROM czechia_region 
ORDER BY name DESC
LIMIT 5;

SELECT *
FROM healthcare_provider
ORDER BY provider_type ASC, name DESC;

-- CASE Expression
SELECT name, region_code,
	CASE
		WHEN region_code = 'CZ010' THEN 1
		ELSE 0
	END AS is_from_prague,
	municipality 
FROM healthcare_provider;

SELECT name, region_code,
	CASE
		WHEN region_code = 'CZ010' THEN 1
		WHEN region_code = 'CZ080' THEN 2
		ELSE 0
	END AS is_from_prague,
	municipality 
FROM healthcare_provider;

SELECT 
	name, 
	region_code,
	CASE
		WHEN region_code = 'CZ010' THEN 'praha'
		ELSE 'other'
	END AS is_from_prague,
	municipality 
FROM healthcare_provider
WHERE region_code = 'CZ010';

-- MIN hodnota 12, max 18, obsahuje null
SELECT
	name, 
	municipality,
	longitude,
	CASE 
		WHEN longitude IS NULL THEN 'unknown'
		WHEN longitude < 14 THEN 'nejvice na zapade'
		WHEN longitude < 16 THEN 'mene na zapade'
		WHEN longitude < 18 THEN 'vice na vychode'
		WHEN longitude >= 18 THEN 'nejvice na vychode'
	END AS in_czechia_position
FROM healthcare_provider
ORDER BY longitude DESC;

SELECT name, provider_type,
CASE
	WHEN provider_type = 'Lékárna' 
		OR provider_type = 'Výdejna zdravotnických prostředků' THEN 1
	ELSE 0
END AS is_desired_type
FROM healthcare_provider;

SELECT name, provider_type,
CASE
	WHEN provider_type IN ('Lékárna', 'Výdejna zdravotnických prostředků') THEN 1
	ELSE 0
END AS is_desired_type
FROM healthcare_provider;

/*
 * WHERE, IN, LIKE
 */

SELECT *
FROM healthcare_provider 
WHERE name LIKE '%nemocnice%';

SELECT name, lower(name)
FROM healthcare_provider 
WHERE lower(name) LIKE '%nemocnice%';

SELECT 
	name,
	CASE
		WHEN name LIKE 'lékárna%' THEN 1
		ELSE 0
	END AS starts_with_lekarna
FROM healthcare_provider 
WHERE name LIKE '%lékárna%';

-- jenom 4 znaky jedno podtrzitko jeden znak
SELECT name, municipality
FROM healthcare_provider 
WHERE municipality LIKE '____';

SELECT 
	municipality, 
	length(municipality),
	CHAR_LENGTH(municipality) 
FROM healthcare_provider 
WHERE char_length(municipality) = 4;

SELECT 
	name, municipality, district_code 
FROM healthcare_provider 
WHERE municipality IN ('Brno', 'Praha', 'Ostrava') 
	OR district_code IN ('CZ0421', 'CZ0425'); 

SELECT *
FROM czechia_district  
WHERE name IN ('Most', 'Děčín');

-- ekvivalentní zápis se subselectem
SELECT 
	name, municipality, district_code 
FROM healthcare_provider 
WHERE municipality IN ('Brno', 'Praha', 'Ostrava') 
	OR district_code IN (
		SELECT code
		FROM czechia_district  
		WHERE name IN ('Most', 'Děčín')
);

SELECT provider_id, name, region_code 
FROM healthcare_provider 
WHERE region_code IN (
		SELECT code
		FROM czechia_region
		WHERE name IN ('Jihomoravský kraj', 'Středočeský kraj')
);

-- DODĚLAT ŠESTÝ ÚKOL


-- Pohledy

CREATE OR REPLACE VIEW v_healthcare_provider_subset_tk AS
	SELECT
		name,
		municipality AS city,
		district_code
	FROM healthcare_provider 
	WHERE
		municipality IN ('Brno', 'Praha', 'Ostrava');
	
SELECT *
FROM v_healthcare_provider_subset_tk;


-- DODĚLA ÚKOL 2

DROP VIEW IF EXISTS v_healthcare_provider_subset_tk;

