/*
 * Cvičení jsou zaměřená na agregační funkce (například SUM() a MAX()). 
 * Pomocí nich budeme schopni získat z celého souboru dat jednočíselné výsledky
 * jako součty, průměry či maxima nebo minima. Také si představíme klauzuli 
 * GROUP BY pomocí níž budeme schopni datové záznamy rozdělovat do skupin 
 * podle námi určených charakteristik.
 */
-- Funkce COUNT()
-- Úkol 1: Spočítejte počet řádků v tabulce czechia_price.
SELECT count(1)
FROM czechia_price 

SELECT count (region_code)
FROM czechia_price; 

/* Úkol 2: Spočítejte počet řádků v tabulce czechia_payroll s 
konkrétním sloupcem jako argumentem funkce COUNT(). */

SELECT count(id) AS rows_count 
FROM czechia_payroll; 

SELECT count(value) AS rows_count 
FROM czechia_payroll; 

-- Úkol 3: Z kolika záznamů v tabulce czechia_payroll jsme schopni vyvodit průměrné počty zaměstnanců?
SELECT count(id) AS rows_of_known_employees
FROM czechia_payroll 
WHERE value_type_code = 316 AND value IS NOT NULL;
	
-- Úkol 4: Vypište všechny cenové kategorie a počet řádků každé z nich v tabulce czechia_price.
SELECT category_code, count(id)
FROM czechia_price 
GROUP BY category_code;

SELECT count(DISTINCT region_code)
FROM czechia_price; 

-- Úkol 5: Rozšiřte předchozí dotaz o dadatečné rozdělení dle let měření.
SELECT 
	category_code,
	YEAR(date_from) AS year_of_entry, 
	count(id) AS rown_in_category 
FROM czechia_price
GROUP BY category_code, year_of_entry;

-- datum funkce https://mariadb.com/kb/en/date-time-functions/

-- Úkol 1: Sečtěte všechny průměrné počty zaměstnanců v datové sadě průměrných platů v České republice.
select SUM(value) as value_sum
from czechia_payroll 
where value_type_code 

-- Úkol 2: Sečtěte průměrné ceny pro jednotlivé kategorie pouze v Jihomoravském kraji.
select *
from czechia_region;

select category_code,
sum(value) as sum_of_avg_values
FROM czechia_price
WHERE region_code = 'CZ064'
group by category_code;

/* Úkol 3: Sečtěte průměrné ceny potravin za všechny kategorie, 
u kterých měření probíhalo od (date_from) 15. 1. 2018. */
SELECT SUM(VALUE) AS sum_of_avg_VALUES
from czechia_price 
where data_from = '2018-01-05';

/* Úkol 4: Vypište tři sloupce z tabulky czechia_price: 
 * kód kategorie, počet řádků pro ni a sumu hodnot průměrných cen. 
 * To vše pouze pro data v roce 2018. */

SELECT 
	category_code,
	count(1) AS row_count,
	sum (value) AS sum_of_avg_values
FROM czechia_price
WHERE year(date_from) = 2018
GROUP BY category_code;

-- Úkol 1: Vypište maximální hodnotu průměrné mzdy z tabulky czechia_payroll.
SELECT max(value)
FROM czechia_payroll
WHERE value_type_code = 5958;

/* Úkol 2: Na základě údajů v tabulce czechia_price vyberte pro každou kategorii 
potravin její minimum v letech 2015 až 2017. */
SELECT category_code, min(value)
FROM czechia_price
WHERE year(date_from) BETWEEN 2015 AND 2017
GROUP BY category_code;

-- Úkol 3: Vypište kód (případně i název) odvětví s historicky nejvyšší průměrnou mzdou.
SELECT *
FROM czechia_payroll_industry_branch 
WHERE code IN
(SELECT industry_branch_code
FROM czechia_payroll 
WHERE value IN (
SELECT max(value)
FROM czechia_payroll 
WHERE value_type_code = 5958));

/* Úkol 4: Pro každou kategorii potravin určete 
 * její minimum, maximum a vytvořte nový sloupec s
 * názvem difference, ve kterém budou hodnoty "rozdíl do 10 Kč", 
 * "rozdíl do 40 Kč" a "rozdíl nad 40 Kč" na základě 
 * rozdílu minima a maxima. Podle tohoto rozdílu data seřaďte. */
SELECT category_code, min(value), max(value), max(value) - min(value) AS diff,
CASE 
	WHEN max(value) - min(value) < 10 THEN '10kc diff'
	WHEN max(value) - min(value) < 40 THEN '40kc diff'
	WHEN max(value) - min(value) > 40 THEN 'more kc diff'
END AS difference
FROM czechia_price 
GROUP BY category_code
ORDER BY diff;

/* Úkol 5: Vyberte pro každou kategorii potravin 
 * minimum, maximum a aritmetický průměr (v našem případě průměr z průměrů)
 * zaokrouhlený na dvě desetinná místa. */
SELECT category_code, min(value), max(value), ROUND(AVG(value),2)
FROM czechia_price 
GROUP BY category_code;

/* Úkol 6: Rozšiřte předchozí dotaz tak, 
 * že data budou rozdělena i podle kódu 
 * kraje a seřazena sestupně podle aritmetického průměru */
SELECT region_code, category_code, min(value), max(value), round(avg(value),2) AS average
FROM czechia_price 
GROUP BY category_code, region_code
ORDER BY average DESC;

-- Úkol 1: Vyzkoušejte si následující dotazy. Co vypisují a proč?
SELECT SQRT(-16);
SELECT 10/0;
SELECT FLOOR(1.56);
SELECT FLOOR(-1.56);
SELECT CEIL(1.56);
SELECT CEIL(-1.56);
SELECT ROUND(1.56);
SELECT ROUND(-1.56);

/* Úkol 2: Vypočítejte průměrné ceny kategorií potravin 
 * bez použití funkce AVG() s přesností na dvě desetinná místa. */

SELECT category_code, round(sum(value)/count(value), 2)
FROM czechia_price
GROUP BY category_code;

/*
 * Úkol 3: Jaké datové typy budou mít hodnoty v následujících dotazech?
 */
SELECT 1;
SELECT 1.0;
SELECT 1 + 1;
SELECT 1 + 1.0;
SELECT 1 + '1';
SELECT 1 + 'a';
SELECT 1 + '12tatata';
SELECT 1 + 'a' + '2ta';

-- Úkol 4: Vyzkoušejte si spustit dotazy, jež operují s textovými řetězci.

SELECT CONCAT('Hi, ', 'Engeto lektor here!');
SELECT CONCAT('We have ', COUNT(DISTINCT category_code), ' price categories.') AS info
FROM czechia_price;
SELECT name,
    SUBSTRING(name, 1, 2) AS prefix,
    SUBSTRING(name, -2, 2) AS suffix,
    LENGTH(name)
FROM czechia_price_category;

-- Úkol 5: Vyzkoušejte si operátor modulo (zbytek po celočíselném dělení).

SELECT 5 % 2;
SELECT 14 % 5;
SELECT 15 % 5;
-- Na co se používá dělitelnost jedenácti?
SELECT 123456789874 % 11;
SELECT 123456759874 % 11;

-- Úkol 6: Využijte operátor modulo na zjištění sudosti populace v tabulce economies.
-- Populace - zbytek po dělení dvěma:
SELECT
    country, `year`, population, population % 2 AS division_rest
FROM economies e
WHERE population IS NOT NULL;

-- Populace - flag zda je sudá:
SELECT
    country, `year`, population, NOT population % 2 AS is_even
FROM economies e
WHERE population IS NOT NULL;

-- Populace - flag zda je sudá se selekcí:
SELECT
    country, `year`, population, NOT population % 2 AS is_even
FROM economies e
WHERE population IS NOT NULL
    AND population % 2 = 0;


-- stringy: https://mariadb.com/kb/en/string-functions/


-- Úkol 1: Spočítejte počet řádků v tabulce czechia_price.
SELECT count(1)
FROM czechia_price;

/* Úkol 2: Spočítejte počet řádků v tabulce czechia_payroll s 
 * konkrétním sloupcem jako argumentem funkce COUNT(). */
SELECT count(id)
FROM czechia_payroll;

-- Úkol 3: Z kolika záznamů v tabulce czechia_payroll jsme schopni vyvodit průměrné počty zaměstnanců?
SELECT count(id)
FROM czechia_payroll 
WHERE 
	value_type_code = 316 AND 
	value IS NOT NULL;


-- Úkol 4: Vypište všechny cenové kategorie a počet řádků každé z nich v tabulce czechia_price.
SELECT category_code, count(id)
FROM czechia_price
GROUP BY category_code;

-- Úkol 5: Rozšiřte předchozí dotaz o dadatečné rozdělení dle let měření.
SELECT category_code, count(id), YEAR(date_from) AS year_of_entry
FROM czechia_price
GROUP BY category_code, year_of_entry
ORDER BY year_of_entry, category_code;

-- Úkol 1: Sečtěte všechny průměrné počty zaměstnanců v datové sadě průměrných platů v České republice.
SELECT SUM(value)
FROM czechia_payroll
WHERE value_type_code = 316;

-- Úkol 2: Sečtěte průměrné ceny pro jednotlivé kategorie pouze v Jihomoravském kraji.
SELECT  category_code, SUM(value)
FROM czechia_price
WHERE region_code = 'CZ064'
GROUP BY category_code;

/* Úkol 3: Sečtěte průměrné ceny potravin za všechny kategorie, 
u kterých měření probíhalo od (date_from) 15. 1. 2018. */
SELECT category_code, SUM(value), date_from
FROM czechia_price 
WHERE date_from LIKE '2018-01-15%'
GROUP BY category_code;

-- správné řešení:
SELECT
    SUM(value) AS sum_of_average_prices
FROM czechia_price
WHERE date_from = CAST('2018-01-15' AS date);

/* Úkol 4: Vypište tři sloupce z tabulky czechia_price: kód kategorie, 
 * počet řádků pro ni a sumu hodnot průměrných cen. 
 * To vše pouze pro data v roce 2018. */
SELECT category_code, COUNT(category_code), sum(value)
FROM czechia_price
WHERE date_from LIKE '2018%' -- nebo WHERE YEAR(date_from) = 2018
GROUP BY category_code;

/*
 * Úkol 1: Vypište maximální hodnotu průměrné mzdy z tabulky czechia_payroll.
 */
SELECT MAX(value)
FROM czechia_payroll 
WHERE value_type_code = 5958;


SELECT category_code, MIN(value)
FROM czechia_price 
WHERE YEAR(date_from) = 2015 OR YEAR(date_from) = 2016 OR  YEAR(date_from) = 2017 
-- nebo WHERE YEAR(date_from) BETWEEN 2015 AND 2017
GROUP BY category_code;
   


/* Úkol 1:
Zjistěte celkovou populaci kontinentů.
Zjistěte průměrnou rozlohu států rozdělených podle kontinentů
Zjistěte počty států podle rozdělených podle hlavního náboženství
Státy vhodně seřaďte.
*/
SELECT continent, SUM(population)
FROM countries 
WHERE continent IS NOT NULL
GROUP BY continent;
SELECT continent, round(AVG(surface_area)) AS avg_surcon
FROM countries
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY avg_surcon DESC;
SELECT religion, count(country)
FROM countries 
WHERE religion IS NOT NULL
GROUP BY religion
ORDER BY count(country) DESC;

/*
 * Úkol 3: Pro každý kontinent zjistěte podíl počtu 
 * vnitrozemských států (sloupec landlocked), 
 * podíl populace žijící ve vnitrozemských státech a podíl rozlohy vnitrozemských států.
 */

SELECT continent
	,round(SUM(landlocked) / count(country), 2)
	,round(SUM(landlocked * population) / SUM(population), 2) AS landlocked_pop_share
	,round(SUM(landlocked * surface_area) / SUM(surface_area), 2) AS landlocked_area_share
FROM countries 
WHERE continent IS NOT NULL AND landlocked IS NOT NULL
GROUP BY continent;


/*
 * Úkol 4: Zjistěte celkovou populaci ve státech rozdělených 
 * podle kontinentů a regionů (sloupec region_in_world). 
 * Seřaďte je podle kontinentů abecedně a podle populace sestupně.
 */
SELECT continent, region_in_world, sum(population)
FROM countries 
WHERE continent IS NOT NULL AND region_in_world IS NOT NULL
GROUP BY continent, region_in_world
ORDER BY continent ASC, sum(population) DESC;

/*
 * Úkol 5: Zjistěte celkovou populaci a počet států 
 * rozdělených podle kontinentů a podle náboženství. 
 * Kontinenty seřaďte abecedně a náboženství v rámci kontinentů sestupně podle populace.
 */
SELECT continent, religion, SUM(population), COUNT(country)
FROM countries 
WHERE continent IS NOT NULL AND religion IS NOT NULL
GROUP BY continent, religion
ORDER BY continent ASC, sum(population) DESC;

-- Úkol 6: Zjistěte průměrnou roční teplotu v regionech Afriky.
SELECT region_in_world,
round(sum(surface_area*yearly_average_temperature)/sum(surface_area),2) AS average_regional_temperature
FROM countries
WHERE continent = 'Africa' AND yearly_average_temperature IS NOT NULL
GROUP BY region_in_world;

/*
Úkol 1: Vytvořte v tabulce covid19_basic nový sloupec, 
kde od confirmed odečtete polovinu recovered a 
přejmenujete ho jako novy_sloupec. Seřaďte podle data sestupně.*/ 
SELECT *, confirmed - recovered/2 AS novy_sloupec
FROM covid19_basic
ORDER BY date DESC

-- Úkol 2: Kolik lidí se celkem uzdravilo na celém světě k 30.8.2020?
SELECT sum(recovered)
FROM covid19_basic
WHERE date = CAST('2020-08-30' AS date);

-- Úkol 3: Kolik lidí se celkem uzdravilo, a kolik se jich nakazilo na celém světě k 30.8.2020?
SELECT SUM(recovered), SUM (confirmed)
FROM covid19_basic 
WHERE date = CAST('2020-08-30' AS date);

-- Úkol 4: Jaký je rozdíl mezi nakaženými a vyléčenými na celém světě k 30.8.2020?
SELECT SUM(confirmed)-SUM(recovered)
FROM covid19_basic 
WHERE date = CAST('2020-08-30' AS date);

/*
 * Úkol 5: Z tabulky covi19_basic_differences zjistěte, 
 * kolik lidí se celkem nakazilo v České republice k 30.8.2020.
 */
SELECT SUM(confirmed)
FROM covid19_basic_differences
WHERE country = 'Czechia' AND date = CAST('2020-08-30' AS date);


-- Úkol 6: Kolik lidí se nakazilo v jednotlivých zemích během srpna 2020?
SELECT country, SUM(confirmed)
FROM covid19_basic
WHERE date LIKE '2020-08-__'
GROUP BY country;

/* Úkol 7: Kolik lidí se nakazilo v České republice, 
 * na Slovensku a v Rakousku mezi 20.8.2020 a 30.8.2020 včetně? */
SELECT country, SUM(confirmed)
FROM covid19_basic 
WHERE country IN ('Czechia', 'Slovakia', 'Austria') 
AND date >= '2020-08-20' AND date <= '2020-08-30'
GROUP BY country;

-- Úkol 8: Jaký byl největší přírůstek v jednotlivých zemích?
SELECT country, MAX(confirmed)
FROM covid19_basic_differences 
GROUP BY country;

-- Úkol 9: Zjistěte největší přírůstek v zemích začínajících na C.
SELECT country, MAX(confirmed)
FROM covid19_basic_differences 
WHERE country LIKE 'C%'
GROUP BY country;

/* 
 * Úkol 10: Zjistěte celkový přírůstek všech zemí s populací nad 50 milionů. 
 * Tabulku seřaďte podle datumu od srpna 2020.
 */

SELECT country, sum(confirmed), date
FROM covid19_basic_differences
WHERE country IN (
		SELECT DISTINCT country
		FROM lookup_table  
		WHERE population > 50000000)
		AND date >= '2020-08-01'
GROUP BY date, country
ORDER BY date;


/* Úkol 11: Zjistěte celkový počet nakažených v Arkansasu 
 * (použijte tabulku covid19_detail_us_differences). */
SELECT SUM(confirmed)
FROM covid19_detail_us_differences 
WHERE province = 'Arkansas';

-- Úkol 12: Zjistětě nejlidnatější provincii v Brazílii.
SELECT province, population 
FROM lookup_table
WHERE country = 'Brazil' AND province IS NOT NULL
ORDER BY population DESC 
LIMIT 1;

/*
 * Úkol 13: Zjistěte celkový a průměrný počet nakažených denně po dnech a 
 * seřaďte podle data sestupně (průměr zaokrouhlete na dvě desetinná čísla)
*/ 
SELECT date, sum(confirmed), round(avg(confirmed),2)
FROM covid19_basic 
GROUP BY date
ORDER BY date DESC;

/*
 * Úkol 14: Zjistěte celkový počet nakažených lidí 
 * v jednotlivých provinciích USA dne 30.08.2020 
 * (použijte tabulku covid19_detail_us).
 */
SELECT province, sum(confirmed)
FROM covid19_detail_us 
WHERE date = '2020-08-30'
GROUP BY province;

-- Úkol 15: Zjistěte celkový přírůstek podle datumu a země.
SELECT country, date, SUM(confirmed)
FROM covid19_basic
GROUP BY date, country;

-- COVID-19: funkce AVG() a COUNT()
-- Úkol 1: Zjistěte průměrnou populaci ve státech ležících severně od 60 rovnoběžky.
SELECT AVG(population)
FROM lookup_table 
WHERE lat >= 60 AND province IS NULL;

/* 
 * Úkol 2: Zjistěte průměrnou, nejvyšší a nejnižší populaci 
 * v zemích ležících severně od 60 rovnoběžky. 
 * Spočítejte, kolik takových zemích je.
 * Vytvořte sloupec max_min_ratio, ve kterém nejvyšší populaci vydělíte nejnižší.*/

SELECT round(AVG(population),2)
		, MAX(population)
		, MIN(population)
		, COUNT(DISTINCT country)
		, MAX(population) / MIN(population) AS max_min_ratio
FROM lookup_table 
WHERE lat >= 60;

/* 
 * Úkol 3: Zjistěte průměrnou populaci a rozlohu v zemích seskupených podle náboženství. 
 * Zjistěte také počet zemí pro každé náboženství.
 * Nápověda: Sloupce religion, population, surface_area
 */
SELECT religion, round(AVG(population)), round(AVG(surface_area)), COUNT(country)
FROM countries
WHERE religion IS NOT NULL
GROUP BY religion

/*
 * Úkol 4: Zjistěte počet zemí, kde se platí dolarem (jakoukoli měnou, která má v názvu dolar). 
 * Zjistěte nejvyšší a nejnižší populaci mezi těmito zeměmi.
 * Nápověda: Sloupec currency_name.
 */
SELECT count(country), min(population), max (population)
FROM countries
WHERE LOWER(currency_name) LIKE LOWER('%dollar%');
-- NEBO 
SELECT count(country), max(population), min(population)
FROM countries c 
WHERE LOWER(currency_name) LIKE LOWER('%dollar%') OR currency_code = 'USD';

-- Úkol 5: Zjistěte, kolik zemí platících Eurem leží v Evropě a kolik na jiných kontinentech.
SELECT continent, count(country)
FROM countries 
WHERE currency_code = 'EUR'
GROUP BY continent;

-- Úkol 6: Zjistěte, pro kolik zemí známe průměrnou výšku jejích obyvatel.
SELECT count(country)
FROM countries 
WHERE avg_height IS NOT NULL;

-- Úkol 7: Zjistěte průměrnou výšku obyvatel na jednotlivých kontinentech.
SELECT continent, round(sum(population*avg_height)/sum(population),2)
FROM countries 
WHERE avg_height IS NOT NULL
GROUP BY continent;

/*
 * Úkol 8: Zjistěte průměrnou hustotu zalidnění pro světový region (region_in_world). 
 * Srovnejte obyčejný a vážený průměr. Váhou bude v tomto případě rozloha státu (surface_area). 
 * Výslednou tabulku uložte jako v_{jméno}_{příjmení}_population_density. 
 * Poznámka: V tomto případě nepočítáme 'průměr průměrů', ale průměr zlomků 
 * (hustota zalidnění = populace / rozloha). 
 * Vyzkoušejte si, co by se stalo, pokud bychom jako váhu použili nikoli rozlohu 
 * (jmenovatel), ale populaci (čitatel). Jaká varianta Vám přijde vhodnější?
 */
CREATE OR REPLACE VIEW v_tomas_kypta_population_density AS 
SELECT region_in_world ,round(avg(population_density)) AS simple_avg 
,round(sum(population_density*surface_area)/sum(surface_area)) AS weighted_avg_density
FROM countries
WHERE population_density IS NOT NULL AND region_in_world IS NOT NULL
GROUP BY region_in_world;

/*
 * Úkol 9: Načtěte tabulku (lépe řečeno pohled), 
 * který jste vytvořili v minulém úkolu. Vytvořte nový sloupec diff_avg_density, 
 * který bude absolutní hodnotou (funkce abs) rozdílu mezi obyčejným a váženým průměrem. 
 * Tabulku seřaďte podle tohoto nového sloupce sestupně. 
 * Zdaleka největší rozdíl mezi průměry je ve východní Asii a Západní Evropě. 
 * V dalším úkolu se na jeden z těchto regionů podíváme blíže, 
 * abychom si lépe ukázali rozdíl mezi obyčejným a váženým průměrem.
 */
SELECT *, abs(simple_avg-weighted_avg_density) AS diff_avg_density
FROM v_tomas_kypta_population_density
ORDER BY diff_avg_density DESC;

/*
 * Úkol 10: Vyberte název, hustotu zalidnění a rozlohu zemí v západní Evropě. 
 * Najděte stát s nejvyšší hustotou zalidnění. 
 * Spočítejte obyčejný a vážený průměr hustoty zalidnění v západní Evropě 
 * kromě státu s nejvyšší hustotou. Výsledky srovnejte s oběma průměry spočítanými ze všech zemí.*/
SELECT country, population_density, surface_area 
FROM countries
WHERE region_in_world = 'Western Europe'
ORDER BY population_density DESC
LIMIT 1;

SELECT 
0 AS 'Monaco_included'
,round(avg(population_density)) AS simple_avg 
,round(sum(population_density*surface_area)/sum(surface_area)) AS weighted_avg_density
FROM countries
WHERE region_in_world = 'Western Europe' AND country != 'Monaco'
UNION
SELECT
    1 AS 'Monaco_included',
    simple_avg, 
    weighted_avg_density
FROM v_tomas_kypta_population_density 
WHERE region_in_world = 'Western Europe';
-- The used SELECT statements have a different number of columns PROČ?


SELECT 
0 AS 'Monaco_included'
,round(avg(population_density)) AS simple_avg
,round(avg(CASE WHEN region_in_world = 'Western Europe' AND country != 'Monaco' THEN population_density END),2) AS xxx
,round(sum(population_density*surface_area)/sum(surface_area)) AS weighted_avg_density
FROM countries
WHERE region_in_world = 'Western Europe' AND country != 'Monaco';
