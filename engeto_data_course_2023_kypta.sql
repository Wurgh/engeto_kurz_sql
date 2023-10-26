SELECT 
	* 
FROM healthcare_provider;

SELECT
	name,
	provider_type 
FROM healthcare_provider;

-- linecomment

/*
 * blockcomment
 */ 

SELECT
	name,
	provider_type 
FROM healthcare_provider
LIMIT 20;

SELECT
	name,
	provider_type 
FROM healthcare_provider
LIMIT 20 OFFSET 20;

-- defaultně ASC
SELECT *
FROM healthcare_provider 
ORDER BY region_code DESC;

-- snakecase
SELECT 
	name,
	region_code,
	district_code
FROM healthcare_provider
ORDER BY district_code DESC
LIMIT 500;

-- Praha
SELECT *
FROM healthcare_provider 
WHERE region_code = 'CZ010';

-- ne praha
SELECT *
FROM healthcare_provider 
WHERE region_code != 'CZ010';

SELECT name, phone, website, fax
FROM healthcare_provider 
WHERE region_code != 'CZ010'; -- WHERE region_code <> 'CZ010'; je to ekvivalentní
-- https://mariadb.com/kb/en/comparison-operators/ 

SELECT 
	name,
	region_code,
	residence_region_code
FROM healthcare_provider 
WHERE region_code = residence_region_code;

SELECT 
	name,
	phone
FROM healthcare_provider 
WHERE phone IS NOT NULL;

SELECT
	name,
	district_code
FROM healthcare_provider 
WHERE district_code  = 'CZ0202' OR district_code = 'CZ0201'
ORDER BY district_code DESC;

SELECT
	name,
	district_code
FROM healthcare_provider 
WHERE district_code  IN ('CZ0202', 'CZ0201')
ORDER BY district_code DESC;

-- t_{jméno}_{příjmení}_providers_south_moravia
-- CZ064 Jihomoravský kraj

SELECT *
FROM healthcare_provider 
WHERE region_code = 'CZ064';

CREATE TABLE t_tomas_kypta_providers_south_moravia AS
	SELECT *
	FROM healthcare_provider 
	WHERE region_code = 'CZ064';

SELECT * 
FROM t_tomas_kypta_providers_south_moravia; 

--DROP TABLE t_tomas_kypta_providers_south_moravia;

-- https://mariadb.com/kb/en/data-types/

CREATE TABLE t_tomas_kypta_providers_resume (
	date_start date, 
	date_end date,
	job varchar(255),
	education varchar(255)
);

SELECT *
FROM t_tomas_kypta_providers_resume;

INSERT INTO t_tomas_kypta_providers_resume 
VALUES ('2020-05-01', '2022-04-20', 'UPOL', 'master');

INSERT INTO t_tomas_kypta_providers_resume 
VALUES 
	('2020-05-01', '2022-04-20', 'UPOL', 'master'),
	('2020-05-01', '2022-04-20', 'UPOL', 'master'),
	('2020-05-01', '2022-04-20', 'UPOL', 'master');

-- zmena
UPDATE t_tomas_kypta_providers_resume 
SET education = 'master'
WHERE education = 'masters';
	
ALTER TABLE t_tomas_kypta_providers_resume 
ADD COLUMN institution varchar (255);

SELECT *
FROM t_tomas_kypta_providers_resume;

ALTER TABLE t_tomas_kypta_providers_resume 
DROP COLUMN institution;






