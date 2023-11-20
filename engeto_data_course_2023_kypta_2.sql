/*
 * Úvod
 * V tomto cvičení se budeme postupně zabývat řazením záznamů a tvorbou nových dynamicky vypočítaných sloupců. 
 * Představíme si využití operátorů LIKE a IN v klauzuli WHERE a možnosti vnořených SELECT. 
 * Nezapomeneme ani na tvorbu pohledů.
 */
-- ORDER BY
/*
 * Úkol 1: Vypište od všech poskytovatelů zdravotních služeb jméno a typ. 
 * Záznamy seřaďte podle jména vzestupně.
 */
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

/*
 * Úkol 2: Vypište od všech poskytovatelů zdravotních služeb ID, jméno a typ. 
 * Záznamy seřaďte primárně podle kódu kraje a sekundárně podle kódu okresu.
 */
SELECT provider_id, name, provider_type, region_code, district_code
FROM healthcare_provider 
ORDER BY region_code ASC, district_code ASC;

-- Úkol 3: Seřaďte na výpisu data z tabulky czechia_district sestupně podle kódu okresu.
SELECT *
FROM czechia_district 
ORDER BY code DESC;

-- Úkol 4: Vypište abacedně pět posledních krajů v ČR.
SELECT *
FROM czechia_region 
ORDER BY name DESC
LIMIT 5;

/*
 * Úkol 5: Data z tabulky healthcare_provider vypište 
 * seřazena vzestupně dle typu poskytovatele a sestupně dle jména.
 */
SELECT *
FROM healthcare_provider
ORDER BY provider_type ASC, name DESC;

-- CASE Expression
/*
 * Úkol 1: Přidejte na výpisu k tabulce healthcare_provider nový sloupec 
 * is_from_Prague, který bude obsahovat 1 pro poskytovate z Prahy a 0 pro ty mimo pražské.
 */
SELECT name, region_code,
	CASE
		WHEN region_code = 'CZ010' THEN 1
		ELSE 0
	END AS is_from_prague,
	municipality 
FROM healthcare_provider;

/*
 * Úkol 2: Upravte dotaz z předchozího příkladu tak, 
 * aby obsahoval záznamy, které spadají jenom do Prahy.
 */
SELECT 
	name, 
	region_code,
	CASE
		WHEN region_code = 'CZ010' THEN 'Praha'
		ELSE 'other'
	END AS is_from_prague,
	municipality 
FROM healthcare_provider
WHERE region_code = 'CZ010';

/*
 * Úkol 3: Sestavte dotaz, který na výstupu ukáže název poskytovatele, 
 * město poskytování služeb, zeměpisnou délku a v dynamicky vypočítaném 
 * sloupci slovní informaci, jak moc na západě se poskytovatel nachází 
 * – určete takto čtyři kategorie rozdělení.
 */
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

/*
 * Úkol 4: Vypište název a typ poskytovatele a v novém sloupci 
 * odlište, zda jeho typ je Lékárna nebo Výdejna zdravotnických prostředků.
 */
SELECT name, provider_type,
CASE
	WHEN provider_type = 'Lékárna' 
		OR provider_type = 'Výdejna zdravotnických prostředků' THEN 1
	ELSE 0
END AS is_desired_type
FROM healthcare_provider;

-- Ekvivalentní zápis
SELECT name, provider_type,
CASE
	WHEN provider_type IN ('Lékárna', 'Výdejna zdravotnických prostředků') THEN 1
	ELSE 0
END AS is_desired_type
FROM healthcare_provider;

-- WHERE, IN a LIKE
/*
 * Úkol 1: Vyberte z tabulky healthcare_provider 
 * záznamy o poskytovatelích, kteří mají ve jméně slovo nemocnice.
 */
SELECT *
FROM healthcare_provider 
WHERE name LIKE '%nemocnice%';

-- Lower changes letters to lowercase; can make WHERE more reliable
SELECT name, lower(name)
FROM healthcare_provider 
WHERE lower(name) LIKE '%nemocnice%';

/*
 * Úkol 2: Vyberte z tabulky healthcare_provider jméno poskytovatelů, 
 * kteří v něm mají slovo lékárna. Vytvořte další dynamicky vypsaný sloupec, 
 * který bude obsahovat 1, pokud slovem lékárna název začíná. 
 * V opačném případě bude ve sloupci 0.
 */
SELECT 
	name,
	CASE
		WHEN name LIKE 'lékárna%' THEN 1
		ELSE 0
	END AS starts_with_lekarna
FROM healthcare_provider 
WHERE name LIKE '%lékárna%';

/*
 * Úkol 3: Vypište jméno a město poskytovatelů, jejichž název města poskytování má délku čtyři písmena (znaky).
 */
-- jenom 4 znaky jedno podtrzitko jeden znak
SELECT name, municipality
FROM healthcare_provider 
WHERE municipality LIKE '____';

-- Alternativní řešení
SELECT 
	municipality, 
	length(municipality),
	CHAR_LENGTH(municipality) 
FROM healthcare_provider 
WHERE char_length(municipality) = 4;

/*
 * Úkol 4: Vypište jméno, město a okres místa poskytování u těch poskytovatelů, 
 * kteří jsou z Brna, Prahy nebo Ostravy nebo z okresů Most nebo Děčín.
 */
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

/*
 * Úkol 5: Pomocí vnořeného SELECT vypište kódy krajů pro Jihomoravský 
 * a Středočeský kraj z tabulky czechia_region. Ty použijte pro vypsání ID, 
 * jména a kraje jen těch vyhovujících poskytovatelů z tabulky healthcare_provider.
 */
SELECT provider_id, name, region_code 
FROM healthcare_provider 
WHERE region_code IN (
		SELECT code
		FROM czechia_region
		WHERE name IN ('Jihomoravský kraj', 'Středočeský kraj')
);

/*
 * Úkol 6: Z tabulky czechia_district vypište jenom ty okresy, 
 * ve kterých se vyskytuje název města, které má délku čtyři písmena (znaky).
 */
SELECT name
FROM czechia_district
WHERE code IN (
		SELECT district_code
		FROM healthcare_provider 
		WHERE CHARACTER_LENGTH(municipality) = 4);

-- Ekvivalentní
SELECT name
FROM czechia_district
WHERE code IN (
		SELECT district_code
		FROM healthcare_provider 
		WHERE municipality LIKE "____");


-- Pohledy (VIEW)
/*
 * Úkol 1: Vytvořte pohled (VIEW) s ID, jménem, městem a okresem místa 
 * poskytování u těch poskytovatelů, kteří jsou z Brna, Prahy nebo Ostravy. 
 * Pohled pojmenujte v_healthcare_provider_subset.
 */
CREATE OR REPLACE VIEW v_healthcare_provider_subset_tk AS
	SELECT
		provider_id,
		name,
		municipality AS city,
		district_code
	FROM healthcare_provider 
	WHERE
		municipality IN ('Brno', 'Praha', 'Ostrava');
	
/*
* Úkol 2: Vytvořte dva SELECT nad tímto pohledem. První vybere vše z něj, 
* druhý vybere všechny poskytovatele z tabulky healthcare_provider, 
* kteří se nenacházejí v pohledu v_healthcare_provider_subset.
*/
SELECT *
FROM v_healthcare_provider_subset_tk;
SELECT *
FROM healthcare_provider 
WHERE provider_id  NOT IN (SELECT provider_id  FROM v_healthcare_provider_subset_tk);

-- Úkol 3: Smažte pohled z databáze.
DROP VIEW IF EXISTS v_healthcare_provider_subset_tk;

/*
 * Cvičení v této lekci byla zaměřena primárně na řazení výsledků a základní selekci 
 * datové sady podle definovaných kritérií. 
 * Díky CASE operátoru jsme pak schopni dynamicky vytvořit nový sloupec, 
 * který se naplní námi definovamými hodnotami. Takový sloupec se nikam do databáze 
 * neukládá, je pouze na výstupu stávajícího dotazu. Nakonec pohledy – VIEWS – nám dovolí 
 * uložit předpisy komplexních dotazů a tím výrazně zjednodušit dotazy navazující.
 */

-- Countries: další cvičení
-- Úkol 1: Najděte národní pokrm pro všechny státy východní Evropy.
SELECT country, national_dish
FROM countries 
WHERE region_in_world = 'Eastern Europe' ;
-- jsou tam NULLY, JAK PRYČ?

-- Úkol 2: Najděte všechny státy a území, jejichž měna má v názvu 'dolar'. 
SELECT *
FROM countries
WHERE currency_name LIKE '%Dollar%';

-- Najděte také všechny státy a území, kde se platí americkým dolarem.
SELECT country, currency_name
FROM countries
WHERE lower(currency_name) LIKE ('%US dollar%');

/* 
 * Úkol 3: Ověřte, jestli je mezinárodní zkratka území (abbreviation) 
 * vždy shodná s koncovkou internetové domény (domain_tld).
 * Nápověda: Podívejte se na funkci substring.
 */
-- všechny neshodné
SELECT country, abbreviation, domain_tld 
FROM countries
WHERE lower(abbreviation) != substring(domain_tld, 2, 2); 

-- všechny shodné
SELECT country, abbreviation, domain_tld 
FROM countries
WHERE lower(abbreviation) = substring(domain_tld, 2, 2); 

-- Úkol 4: Najděte všechna území, jejichž hlavní město má víceslovný název.
SELECT country, capital_city 
FROM countries
WHERE capital_city LIKE '% %';

/* Úkol 5: Seřaďte všechny křesťanské země podle roku, kdy získaly nezávislost (independence_date). 
 * Seřaďte je od nejstarších po nejmladší.*/
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

-- Check data
SELECT * FROM v_tomas_kypta_hostile_countries;

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
	END AS is_hostile
FROM countries;

-- vytvoří sloupec pro každou z podmínek
CREATE OR REPLACE VIEW v_tomas_kypta_hostile_countries AS
SELECT country, elevation , yearly_average_temperature , population , population_density ,
    IF ( elevation > 2000, 1, 0 ) AS mountainous,
    IF ( yearly_average_temperature < 5, 1, 0 ) AS cold_weather,
    IF ( yearly_average_temperature > 25, 1, 0 ) AS hot_weather,
    IF ( population > 10000000 AND population_density > 1000 , 1 , 0 ) AS overpopulated
FROM countries
WHERE elevation > 2000
    OR yearly_average_temperature < 5
    OR yearly_average_temperature > 25
    OR (population > 10000000 AND population_density > 1000);

-- Check data
SELECT * FROM v_tomas_kypta_hostile_countries;

-- Úkol 8: Načtěte pohled z minulého úkolu. Vyberte všechny země, které splňují více než jednu podmínku.
SELECT *
FROM v_tomas_kypta_hostile_countries 
WHERE mountainous + cold_weather + hot_weather + overpopulated > 1;

-- Úkol 9: Seřaďte tabulku countries podle očekávané délky života (life_expectancy) vzestupně.
SELECT country, life_expectancy 
FROM countries
WHERE life_expectancy IS NOT NUll
ORDER BY life_expectancy;

/*
 * Úkol 10: V minulém úkolu jsme zjistili, že některé státy mají velmi nízké hodnoty. 
 * Mimo jiné to může to být tím, že data pocházejí z dřívějších let a skutečnost se mohla změnit.
 * Načtěte pohled v_life_expectancy_comparison, který kombinuje data z tabulky countries a 
 * z tabulky life_expectancy (zdrojem těchto panelových dat je web Our World in Data, odkaz ZDE). 
 * V dalších lekcích si ukážeme, jak takový pohled vytvořit.
 * Vytvořte nový sloupec, ve kterém odečtete očekávanou dobu dožití v roce 2019 od očekávané doby 
 * dožití v roce 1950. Seřaďte tabulku podle tohoto nového sloupce sestupně abyste zjistili, 
 * ve kterých zemích doba dožití vzrostla nejvíce za posledních 70 let.
 * Můžete se podívat i na změnu doby dožití v zemích, které byly na prvních místech tabulky v předchozím úkolu.
 */
CREATE VIEW life_expectancy_2019 AS;
SELECT *
FROM life_expectancy AS le 
WHERE year = 2019;

CREATE VIEW life_expectancy_1950 AS;
SELECT *
FROM life_expectancy AS le 
WHERE year = 1950;

DROP VIEW life_expectancy_comparison;

CREATE TABLE life_expectancy_comparison AS
SELECT le.country, le.life_expectancy AS life_expectancy_1950,
le2.life_expectancy AS life_expectancy_2019
FROM life_expectancy_1950 AS le 
JOIN life_expectancy_2019 AS le2 
	ON le2.country = le.country;


CREATE TABLE life_expectancy_comparison_counted AS
SELECT *, life_expectancy_2019 - life_expectancy_1950 AS life_expectancy_2019_1950
FROM life_expectancy_comparison
ORDER BY life_expectancy_2019_1950 DESC;

SELECT * 
FROM life_expectancy_comparison_counted;

DROP TABLE life_expectancy_comparison;
DROP TABLE life_expectancy_comparison_counted;

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

-- Úkol 15: Vyberte země, jejichž hlavním náboženstvím není ani křesťanství ani islám.
SELECT country, religion
FROM countries 
WHERE religion NOT IN('Christianity', 'Islam');

-- Úkol 16: Vyberte země platící Eurem, jejichž hlavním náboženstvím není křesťanství.
SELECT country, religion, currency_name 
FROM countries 
WHERE currency_code = 'EUR'
AND religion != 'Christianity';

-- Úkol 17: Vyberte země, jejichž průměrná roční teplota je menší než 0 stupňů nebo větší než 30 stupňů.
SELECT country, yearly_average_temperature 
FROM countries 
WHERE yearly_average_temperature < 0 AND yearly_average_temperature > 30; 

-- Úkol 18: Vyberte země, které získaly nezávislost v devatenáctém století.
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

/* 
 * Úkol 22: Tj. vytvořte sloupec N_S_hemisphere, který bude mít hodnotu north, 
 * pokud se země nachází na severní polokouli, south, 
 * pokud se země nachází na jižní polokouli a equator, pokud zemí prochází rovník
 */

SELECT country, south, north,
CASE
	WHEN north < 0 THEN 'south'
	WHEN south > 0 THEN 'north'
	ELSE 'equator'
END AS N_S_hemisphere
FROM countries
WHERE north IS NOT NULL AND south IS NOT NULL;

-- COVID-19: ORDER BY
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
-- Alternativní zápis
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

-- COVID-19: CASE Expression
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

