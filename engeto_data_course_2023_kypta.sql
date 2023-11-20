-- linecomment

/*
 * blockcomment
 */ 

-- Úkol 1: Vypište všechna data z tabulky healthcare_provider.
SELECT 
	*
FROM healthcare_provider;

-- Úkol 2: Vypište pouze sloupce se jménem a typem poskytovatele ze stejné tabulky jako v předchozím příkladu.
SELECT 
	name 
	,provider_type 
FROM healthcare_provider;

-- Úkol 3: Předchozí dotaz upravte tak, že vypíše pouze prvních 20 záznamů v tabulce.
SELECT 
	name
	,provider_type
FROM healthcare_provider
ORDER BY name ASC
LIMIT 20;

-- Starts from 21 row.
SELECT
	name,
	provider_type 
FROM healthcare_provider
LIMIT 20 OFFSET 20;

-- Úkol 4: Vypište z tabulky healthcare_provider záznamy seřazené podle kódu kraje vzestupně.
-- default ASC
SELECT *
FROM healthcare_provider 
ORDER BY region_code DESC;

/* Úkol 5: Vypište ze stejné tabulky jako v předchozím příkladě sloupce se 
jménem poskytovatele, kódem kraje a kódem okresu. Data seřaďte podle kódu okresu sestupně. 
Nakonec vyberte pouze prvních 500 záznamů. */
SELECT 
	name,
	region_code,
	district_code
FROM healthcare_provider
ORDER BY district_code DESC
LIMIT 500;

-- WHERE
/* Úkol 1: Vyberte z tabulky healthcare_provider všechny záznamy poskytovatelů 
zdravotních služeb, kteří poskytují služby v Praze (kraj Praha). */
-- Praha
SELECT *
FROM healthcare_provider 
WHERE region_code = 'CZ010';

/* Úkol 2: Vyberte ze stejné tabulky název a kotaktní informace 
poskytovatelů, kteří nemají místo poskytování v Praze (kraj Praha). */
SELECT name, phone, website, fax
FROM healthcare_provider 
WHERE region_code != 'CZ010';

SELECT name, phone, website, fax
FROM healthcare_provider 
WHERE region_code <> 'CZ010'; -- je to ekvivalentní
-- https://mariadb.com/kb/en/comparison-operators/ 

/* Úkol 3: Vypište názvy poskytovatelů, kódy krajů místa poskytování 
a místa sídla u takových poskytovatelů, u kterých se tyto hodnoty rovnají. */
SELECT 
	name,
	region_code,
	residence_region_code
FROM healthcare_provider 
WHERE region_code = residence_region_code;

/* Úkol 4: Vypište název a telefon takových poskytovatelů, 
kteří svůj telefon vyplnili do registru. */
SELECT 
	name,
	phone
FROM healthcare_provider 
WHERE phone IS NOT NULL;

/* Úkol 5: Vypište název poskytovatele a kód okresu u poskytovatelů, 
 * kteří mají místo poskytování služeb v okresech Benešov a Beroun. 
 * Záznamy seřaďte vzestupně podle kódu okresu. */
SELECT
	name,
	district_code
FROM healthcare_provider 
WHERE district_code  = 'CZ0202' OR district_code = 'CZ0201'
ORDER BY district_code DESC;

-- Ekvivalentní
SELECT
	name,
	district_code
FROM healthcare_provider 
WHERE district_code  IN ('CZ0202', 'CZ0201')
ORDER BY district_code DESC;

/* 
 * Úkol 1: Vytvořte tabulku t_{jméno}_{příjmení}_providers_south_moravia 
 * z tabulky healthcare_provider vyberte pouze Jihomoravský kraj.
 */
SELECT *
FROM healthcare_provider 
WHERE region_code = 'CZ064'; -- -- CZ064 Jihomoravský kraj

CREATE TABLE t_tomas_kypta_providers_south_moravia AS
	SELECT *
	FROM healthcare_provider 
	WHERE region_code = 'CZ064';

-- Výpis z nové tabulky:
SELECT * 
FROM t_tomas_kypta_providers_south_moravia; 

-- Smazání tabulky: 
DROP TABLE t_tomas_kypta_providers_south_moravia;

/* Úkol 2: Vytvořte tabulku t_{jméno}_{příjmení}_resume, 
 * kde budou sloupce date_start, date_end, job, education. 
 * Sloupcům definujte vhodné datové typy. */
-- https://mariadb.com/kb/en/data-types/
CREATE TABLE t_tomas_kypta_providers_resume 
(	
	date_start date, 
	date_end date,
	job varchar(255),
	education varchar(255)
);

-- Úkol 1: Vložte do tabulky popis_tabulek pod svým jménem popis tabulky.
/*
 * Úkol 2: Do tabulky t_{jméno}_{příjmení}_resume, 
 * kterou jste vytvořili v minulé části, 
 * vložte záznam se svým současným zaměstnáním nebo studiem.
 * Nápověda: Pole date_end bude v tomto případě prázdná hodnota. 
 * Tu zaznamenáme jako null.
 */
INSERT INTO t_tomas_kypta_providers_resume 
VALUES ('2023-10-26', NULL, NULL, 'DATA');
/*
 * Úkol 3: Do tabulky t_{jméno}_{příjmení}_resume vložte další záznamy. 
 * Zkuste použít více způsobů vkládání.
 */
INSERT INTO t_tomas_kypta_providers_resume 
VALUES 
	('2016-08-24', '2023-04-20', 'Stagehand', 'masters'),
	('2016-08-24', '2023-04-20', 'Stagehand', 'masters'),
	('2016-08-24', '2023-04-20', 'Stagehadn', 'masters');

-- zmena
UPDATE t_tomas_kypta_providers_resume 
SET education = 'master'
WHERE education = 'masters';

-- check
SELECT *
FROM t_tomas_kypta_providers_resume;
/*
 * Úkol 1: K tabulce t_{jméno}_{příjmení}_resume 
 * přidejte dva sloupce: institution a role, 
 * které budou typu VARCHAR(255).
 */
ALTER TABLE t_tomas_kypta_providers_resume 
ADD COLUMN institution varchar (255);
ALTER TABLE t_tomas_kypta_providers_resume
ADD COLUMN `role` VARCHAR(255);


/* Úkol 2: Do tabulky t_{jméno}_{příjmení}_resume doplňte 
 * informace o tom, v jaké firmě nebo škole jste v daný čas 
 * působili (sloupec institution) a na jaké pozici (sloupec role). */
UPDATE t_tomas_kypta_providers_resume 
SET institution = 'UPOL'
WHERE date_start = '2016-08-24';
UPDATE t_tomas_kypta_providers_resume 
SET institution = 'ENGETO ACADEMY'
WHERE date_start = '2023-10-26';
UPDATE t_tomas_kypta_providers_resume 
SET role = 'student'
WHERE date_start = '2016-08-24';
UPDATE t_tomas_kypta_providers_resume 
SET ROLE = 'student'
WHERE date_start = '2023-10-26';

-- Úkol 3: Z tabulky t_{jméno}_{příjmení}_resume vymažte sloupce education a job.
ALTER TABLE t_tomas_kypta_providers_resume DROP COLUMN education;
ALTER TABLE t_tomas_kypta_providers_resume DROP COLUMN job;

-- Smazání tabulky.
DROP TABLE t_tomas_kypta_providers_resume;

-- COVID-19: SELECT, ORDER BY a LIMIT
-- Úkol 1: Ukažte všechny záznamy z tabulky covid19_basic.
SELECT *
FROM covid19_basic;

-- Úkol 2: Ukažte jen prvních 20 záznamů z tabulky covid19_basic.
SELECT *
FROM covid19_basic
LIMIT 20;

-- Úkol 3: Seřaďte celou tabulku covid19_basic vzestupně podle sloupce date.
SELECT *
FROM covid19_basic
ORDER BY date ASC;

-- Úkol 4: Seřaďte celou tabulku covid19_basic sestupně podle sloupce date.
SELECT * 
FROM covid19_basic
ORDER BY date DESC;

-- Úkol 5: Vyberte jen sloupec country z tabulky covid19_basic.
SELECT country
FROM covid19_basic;

-- Úkol 6: Vyberte jen sloupce country a date z tabulky covid19_basic.
SELECT country, date
FROM covid19_basic;

-- COVID-19: WHERE
-- Úkol 1: Vyberte z tabulky covid19_basic jen záznamy s Rakouskem (Austria).
SELECT *
FROM covid19_basic
WHERE country = 'Austria';

-- Úkol 2: Vyberte jen sloupce country, date a confirmed pro Rakousko z tabulky covid19_basic.
SELECT country, date, confirmed
FROM covid19_basic 
WHERE country = 'Austria';

-- Úkol 3: Vyberte všechny sloupce k datu 30. 8. 2020 z tabulky covid19_basic.
SELECT *
FROM covid19_basic 
WHERE date = '2020-08-30';

-- Úkol 4: Vyberte všechny sloupce k datu 30. 8. 2020 v České republice z tabulky covid19_basic.
SELECT *
FROM covid19_basic 
WHERE date = '2020-08-30' AND country = 'Czechia';

-- Úkol 5: Vyberte všechny sloupce pro Českou republiku a Rakousko z tabulky covid19_basic.
SELECT *
FROM covid19_basic 
WHERE country = 'Austria' OR country = 'Czechia';

-- Úkol 6: Vyberte všechny sloupce z covid19_basic, kde počet nakažených je roven 1 000, nebo 100 000.
SELECT *
FROM covid19_basic 
WHERE confirmed = 1000 OR confirmed = 100000;

/* Úkol 7: Vyberte všechny sloupce z tabulky covid19_basic, 
 * ve kterých je počet nakažených mezi 10 a 20 a navíc pouze v den 30. 8. 2020. */
SELECT *
FROM covid19_basic 
WHERE confirmed >= 10 AND confirmed <= 20 AND date = '2020-08-30';

/* Úkol 8: Vyberte všechny sloupce z covid19_basic, 
 * u kterých je počet nakažených větší než jeden milion dne 15. 8. 2020. */
SELECT *
FROM covid19_basic 
WHERE confirmed > 1000000 AND date = '2020-08-15';

/* Úkol 9: Vyberte sloupce date, country a confirmed v Anglii 
 * a Francii z tabulky covid19_basic a seřaďte je sestupně podle data. */
SELECT date, country, confirmed
FROM covid19_basic 
WHERE country = 'France' OR country = 'United Kingdom'
ORDER BY date DESC;

/*
 * Úkol 10: Vyberte z tabuky covid19_basic_differences 
 * přírůstky nakažených v České republice v září 2020.
 */
SELECT *
FROM covid19_basic_differences 
WHERE country = 'Czechia' AND date >= '2020-09-01' AND date <= '2020-09-30';

-- Úkol 11: Z tabulky lookup_table zjistěte počet obyvatel Rakouska.
SELECT population
FROM lookup_table 
WHERE country = 'Austria';

-- Úkol 12: Z tabulky lookup_table vyberte jen země, které mají počet obyvatel větší než 500 milionů.
SELECT country
FROM lookup_table 
WHERE population > 500000000;

-- Úkol 13: Zjistěte počet nakažených v Indii dne 30. srpna 2020 z tabulky covid19_basic.
SELECT confirmed
FROM covid19_basic 
WHERE country = 'India' AND date = '2020-08-30';

-- Úkol 14: Zjistěte počet nakažených na Floridě z tabulky covid19_detail_us dne 30. srpna 2020.
SELECT admin2, confirmed
FROM covid19_detail_us
WHERE province = 'Florida' AND date = '2020-08-30';
