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

-- wHERE IN LIKE 6. DVĚ řešení
SELECT name
FROM czechia_district
WHERE code IN (
		SELECT district_code
		FROM healthcare_provider 
		WHERE CHARACTER_LENGTH(municipality) = 4);

SELECT *
FROM czechia_district
WHERE code IN (
		SELECT district_code
		FROM healthcare_provider 
		WHERE municipality LIKE "____");


-- Pohledy

CREATE OR REPLACE VIEW v_healthcare_provider_subset_tk AS
	SELECT
		provider_id,
		name,
		municipality AS city,
		district_code
	FROM healthcare_provider 
	WHERE
		municipality IN ('Brno', 'Praha', 'Ostrava');
	
SELECT *
FROM v_healthcare_provider_subset_tk;

SELECT *
FROM healthcare_provider 
WHERE provider_id  NOT IN (SELECT provider_id  FROM v_healthcare_provider_subset_tk);

DROP VIEW IF EXISTS v_healthcare_provider_subset_tk;

-- Bonusové cvičení
SELECT national_dish
FROM countries 
WHERE region_in_world = 'Eastern Europe';
-- jsou tam NULLY, JAK PRYČ?

SELECT *
FROM countries
WHERE currency_name LIKE '%Dollar%';

SELECT country, currency_name
FROM countries
WHERE lower(currency_name) LIKE ('%US dollar%');

-- všechny neshodné
SELECT country, abbreviation, domain_tld 
FROM countries
WHERE lower(abbreviation) != substring(domain_tld, 2, 2); 

-- shodné
SELECT country, abbreviation, domain_tld 
FROM countries
WHERE lower(abbreviation) = substring(domain_tld, 2, 2); 

-- Úkol 4: Najděte všechna území, jejichž hlavní město má víceslovný název.
SELECT country, capital_city 
FROM countries
WHERE capital_city LIKE '% %';

/* Úkol 5: Seřaďte všechny křesťanské země podle roku, kdy získaly nezávislost (independence_date). 
 * Seřaďte je od nejstarších po nejmladší.*/
SELECT country, religion, independence_date
FROM countries
WHERE religion = 'Christianity'
ORDER BY independence_date DESC;
-- nebo
SELECT country, independence_date 
FROM countries
WHERE independence_date IS NOT NULL
    AND religion = 'Christianity'
ORDER BY independence_date;

/* Úkol 6: Vyberte země, které splňují alespoň jednu z následujících podmínek:
jejich průměrná nadmořská výška (elevation) je větší než 2000 metrů nad mořem.
průměrná roční teplota (yearly_average_temperature) je nižší než 5 stupňů nebo vyšší než 25 stupňů.
jejich populace je větší než 10 milionů obyvatel a 
zároveň je hustota zalidnění větší než 1000 obyvatel na kilometr čtvereční */
CREATE OR REPLACE VIEW v_tomas_kypta_hostile_countries AS
SELECT country, elevation, yearly_average_temperature, population, population_density
FROM countries 
WHERE elevation > 2000 
	OR yearly_average_temperature < 5 
	OR yearly_average_temperature > 25
	OR (population > 10000000 AND population_density > 1000);

SELECT *
FROM v_tomas_kypta_hostile_countries;
/*Úkol 7: Rozšiřte tabulku s vybranými zeměmi z minulého úkolu. 
 * Pro každou podmínku zadanou v minulém úkolu vytvořte nový sloupec s binární hodnou 1/0. 
 * Hodnota bude 1, pokud daná země splňuje danou podmínku výběru a 0 jinak. 
 * Výslednou tabulku uložte jako pohled s názvem v_{jméno}_{příjmení}_hostile_countries.*/
-- vytvoří pouze jeden sloupec
CREATE OR REPLACE VIEW v_tomas_kypta_hostile_countries AS
SELECT *,
	CASE 
	 WHEN elevation > 2000 THEN 1 
	 WHEN yearly_average_temperature < 5 THEN 1 
	 WHEN yearly_average_temperature > 25 THEN 1 
	 WHEN population > 10000000 AND population_density > 1000 THEN 1
	 ELSE 0
	END AS binar
FROM countries;

-- vytvoří sloupec pro každou z podmínek
CREATE OR REPLACE VIEW v_tomas_kypta_hostile_countries AS
SELECT country, elevation , yearly_average_temperature , population , population_density ,
    IF ( elevation > 2000, 1, 0 ) AS mountainous,
    IF ( yearly_average_temperature < 5, 1, 0 ) AS cold_weather,
    IF ( yearly_average_temperature > 25, 1, 0 ) AS hot_weather,
    IF ( population > 10000000 AND population_density > 1000 , 1 , 0 ) AS overpopulated
FROM countries c
WHERE elevation > 2000
    OR yearly_average_temperature < 5
    OR yearly_average_temperature > 25
    OR (population > 10000000 AND population_density > 1000);

-- kontrola
SELECT * FROM v_tomas_kypta_hostile_countries;

-- Úkol 8: Načtěte pohled z minulého úkolu. Vyberte všechny země, které splňují více než jednu podmínku.
SELECT *
FROM v_tomas_kypta_hostile_countries 
WHERE mountainous + cold_weather + hot_weather + overpopulated > 1;

-- Úkol 9: Seřaďte tabulku countries podle očekávané délky života (life_expectancy) vzestupně.
SELECT country, life_expectancy 
FROM countries
WHERE life_expectancy IS NOT NUll
ORDER BY life_expectancy DESC;

-- DODĚLAT 10
SELECT v_life_expectancy *

-- Úkol 11: Vyberte všechny země, kde je hlavním náboženstvím buddhismus.
SELECT country, religion
FROM countries 
WHERE religion = 'buddhism';

-- Úkol 12: Vyberte země, které získaly samostatnost před rokem 1500.
SELECT country, independence_date 
FROM countries
WHERE independence_date < 1500;

-- Úkol 13: Vyberte země s průměrnou nadmořskou výškou přes 2000 metrů nad mořem.
SELECT country, elevation
FROM countries 
WHERE elevation > 2000;

-- Úkol 14: Vyberte země, jejichž národním symbolem není zvíře.
SELECT country, national_symbol
FROM countries 
WHERE national_symbol != 'Animal';

SELECT country, religion
FROM countries 
WHERE religion NOT IN('Christianity', 'Islam');

SELECT country, religion, currency_name 
FROM countries 
WHERE currency_code = 'EUR'
AND religion != 'Christianity';

-- Úkol 17: Vyberte země, jejichž průměrná roční teplota je menší než 0 stupňů nebo větší než 30 stupňů.
SELECT country, yearly_average_temperature 
FROM countries 
WHERE yearly_average_temperature < 0 AND yearly_average_temperature > 30; 

SELECT country, independence_date  
FROM countries 
WHERE independence_date >= 1800
    AND independence_date < 1900;

/* Úkol 19: Spočítejte hustotu zalidnění pomocí sloupců population a surface_area. 
Porovnejte jej se sloupcem population_density. */
SELECT country, round(population/surface_area, 2) AS population_density_calculated,
round(population_density, 2) AS population_density,
abs ( round( population / surface_area , 2 ) - round( population_density , 2 ) ) AS diff
FROM countries;
--  WTF

-- Úkol 20: Zjistěte průměrnou roční teplotu ve Fahrenheitech (9/5 * Celsius + 32).
SELECT country, (9/5*yearly_average_temperature +32) AS temp_fahrenheit
FROM countries;

-- Úkol 21: Vytvořte novou proměnnou climate podle průměrné roční teploty.
SELECT country, yearly_average_temperature,
CASE
	WHEN yearly_average_temperature < 0 THEN 'freezing'
	WHEN yearly_average_temperature <= 10 THEN 'chilly'
	WHEN yearly_average_temperature <= 20 THEN 'mild'
	WHEN yearly_average_temperature <= 30 THEN 'warm'
	WHEN yearly_average_temperature > 30 THEN 'scorching'
END AS climate
FROM countries
WHERE yearly_average_temperature IS NOT NULL;

/* Úkol 22: Tj. vytvořte sloupec N_S_hemisphere, který bude mít hodnotu north, 
 * pokud se země nachází na severní polokouli, south, 
 * pokud se země nachází na jižní polokouli a equator, pokud zemí prochází rovník */

SELECT country, south, north,
CASE
	WHEN north < 0 THEN 'south'
	WHEN south > 0 THEN 'north'
	ELSE 'equator'
END AS N_S_hemisphere
FROM countries
WHERE north IS NOT NULL AND south IS NOT NULL;


/* Úkol 1: Vyberte sloupec country, date a confirmed z tabulky covid19_basic pro Rakousko. 
Seřaďte sestupně podle sloupce date. */
SELECT country, date, confirmed
FROM covid19_basic 
WHERE country = 'Austria'
ORDER BY date DESC;

-- Úkol 2: Vyberte pouze sloupec deaths v České republice.
SELECT deaths 
FROM covid19_basic
WHERE country = 'Czechia';

-- Úkol 3: Vyberte pouze sloupec deaths v České republice. Seřaďte sestupně podle sloupce date.
SELECT deaths 
FROM covid19_basic 
WHERE country = 'Czechia'
ORDER BY date DESC;

/* Úkol 4: Zjistěte, kolik nakažených bylo k poslednímu srpnu 2020 po celém světě.
Nápověda: Podívejte se na agregační funkci SUM(). */
SELECT SUM(confirmed)
FROM covid19_basic 
WHERE date = '2020-08-31';
-- taky
SELECT 
    SUM(confirmed)
FROM covid19_basic
WHERE date = CAST('2020-08-31' AS date);

-- Úkol 5: Vyberte seznam provincií v US a seřadte jej podle názvu.
SELECT DISTINCT province
FROM covid19_detail_us 
ORDER BY province;

/* Úkol 6: Vyberte pouze Českou republiku, seřaďte podle datumu a 
vytvořte nový sloupec udávající rozdíl mezi recovered a confirmed. */
SELECT *, 
	(confirmed - recovered) AS difference
FROM covid19_basic 
WHERE country = 'Czechia'
ORDER BY date;

-- Úkol 7: Vyberte 10 zemí s největším přírůstkem k 1.7.2020 a seřaďte je od největšího nárůstů k nejmenšímu.
SELECT country, date, confirmed
FROM covid19_basic_differences  
WHERE date = '2020-07-01'
ORDER BY confirmed DESC
LIMIT 10;

/* Úkol 8: Vytvořte sloupec, kde přiřadíte 1 těm zemím, 
 * které mají přírůstek nakažených vetši než 10000 k 30.8.2020. 
 * Seřaďte je sestupně podle velikosti přírůstku nakažených. */
SELECT country, confirmed,
CASE WHEN confirmed > 10000 THEN 1 END AS more_than_10k
FROM covid19_basic_differences 
WHERE date = '2020-08-30'
ORDER BY confirmed DESC;

-- Úkol 9: Zjistěte, kterým datumem začíná a končí tabulka covid19_detail_us.
SELECT country, date
FROM covid19_detail_us 
WHERE date IS NOT NULL
LIMIT 1;
SELECT country, date
FROM covid19_detail_us 
WHERE date IS NOT NULL
ORDER BY date DESC
LIMIT 1;

-- Úkol 10: Seřaďte tabulku covid19_basic podle států od A po Z a podle data sestupně.
SELECT *
FROM covid19_basic 
ORDER BY country ASC, date DESC;

/* Úkol 1 Vytvořte nový sloupec flag_vic_nez_10000. 
 * Zemím, které měly dne 30. 8. 2020 denní přírůstek nakažených vyšší než 10000, 
 * přiřaďte hodnotu 1, ostatním hodnotu 0. Seřaďte země sestupně 
 * podle počtu nově potvrzených případů. */
SELECT *, 
CASE WHEN confirmed > 10000 THEN 1 ELSE 0 END AS more_than_10k
FROM covid19_basic_differences
WHERE date = '2020-08-30' AND confirmed IS NOT NULL
ORDER BY confirmed DESC;

/* Úkol 2 Vytvořte nový sloupec flag_evropa a označte slovem Evropa země Německo, Francie, Španělsko. 
Zbytek zemí označte slovem Ostatni. */
SELECT country, 
CASE 
	WHEN country IN ('Germany','France','Spain') THEN 'Europe'
	ELSE 'Others'
END AS flag_evropa
FROM covid19_basic;

/* Úkol 3 Vytvořte nový sloupec s názvem flag_ge. Do něj uložte pro všechny země, 
 * začínající písmeny "Ge", heslo GE zeme, ostatní země označte slovem Ostatni. */
SELECT country, 
CASE 
	WHEN country LIKE 'Ge%' THEN 'GE countries'
	ELSE 'Others'
END AS flag_ge
FROM covid19_basic_differences;

/* Úkol 4 Využijte tabulku covid19_basic_differences a 
 * vytvořte nový sloupec category. Ten bude obsahovat 
 * tři kategorie podle počtu nově potvrzených případů: 
 * 0-1000, 1000-10000 a >10000. Výslednou tabulku seřaďte podle data sestupně. 
 * Vhodně také ošetřete možnost chybějících nebo chybně zadaných dat. */
SELECT *,
CASE 
	WHEN confirmed IS NULL OR confirmed <= 1000 THEN '0 - 1000'
	WHEN confirmed <= 10000 THEN '1000 - 10000'
	WHEN confirmed > 10000 THEN 'more'
	ELSE 'missing'
END AS category
FROM covid19_basic_differences
ORDER BY date DESC;

/* Úkol 5 Vytvořte nový sloupec do tabulky covid19_basic_differences a označte hodnotou 1 ty řádky, 
 * které popisují Čínu, USA nebo Indii a zároveň mají více než 10 tisíc nově nakažených v daném dni.*/
SELECT *,
CASE 
	WHEN country IN ('China','US','India') AND confirmed > 10000 THEN 1
	ELSE 0
END AS china_us_india
FROM covid19_basic_differences;

/* Úkol 6 Vytvořte nový sloupec flag_end_a, 
 * kde označíte heslem A zeme ty země, jejichž název končí písmenem A. 
 * Ostatní země označte jako ne A zeme. */
SELECT country,
CASE WHEN country like '%a' THEN 'fucking-A'
ELSE 'no-A'
END AS flag_end_a
FROM covid19_basic_differences;

-- COVID-19: WHERE, IN a LIKE
/* Úkol 1 Vytvořte view obsahující kumulativní průběh jen ve 
Spojených státech, Číně a Indii. Použijte syntaxi s IN. */
CREATE VIEW tomas_kypta_USCHINAINDIA AS
SELECT *
FROM covid19_basic 
WHERE country IN ('US', 'China', 'India');

DROP VIEW tomas_kypta_USCHINAINDIA

-- Úkol 2 Vyfiltrujte z tabulky covid19_basic pouze země, které mají populaci větší než 100 milionů.
SELECT *
FROM covid19_basic 
WHERE country IN (SELECT DISTINCT country
FROM lookup_table 
WHERE population > 100000000);

/* Úkol 3 Vyfiltrujte z tabulky covid19_basic pouze země, 
 * které jsou zároveň obsaženy v tabulce covid19_detail_us. */
SELECT *
FROM covid19_basic 
WHERE country IN (SELECT DISTINCT country
FROM covid19_detail_us);

/* Úkol 4 Vyfiltrujte z tabulky covid19_basic seznam zemí, 
 * které měly alespoň jednou denní nárůst větší než 10 tisíc nově nakažených.*/
SELECT DISTINCT country
FROM covid19_basic 
WHERE country IN
(SELECT DISTINCT country
FROM covid19_basic_differences  
WHERE confirmed > 10000);

/* Úkol 5 Vyfiltrujte z tabulky covid19_basic seznam zemí, 
 * které nikdy neměly denní nárůst počtu nakažených větší než 1000. */
SELECT DISTINCT country
FROM covid19_basic 
WHERE country NOT IN (SELECT DISTINCT country
FROM covid19_basic_differences
WHERE confirmed > 1000);

-- Úkol 6 Vyfiltrujte z tabulky covid19_basic seznam zemí, které nezačínají písmenem A.
SELECT DISTINCT country
FROM covid19_basic 
WHERE country not like 'A%';

