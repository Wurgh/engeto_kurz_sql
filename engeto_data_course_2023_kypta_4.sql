/*
 * Úkol 1: Spojte tabulky czechia_price a czechia_price_category. Vypište všechny dostupné sloupce.
 */
SELECT *
FROM czechia_price
JOIN czechia_price_category
	ON czechia_price_category.code = czechia_price.category_code;

/*
 * Úkol 2: Předchozí příklad upravte tak, 
 * že vhodně přejmenujete tabulky a vypíšete 
 * ID a jméno kategorie potravin a cenu.
 */
SELECT 
	cp.id, cpc.name, cp.value
FROM czechia_price AS cp
JOIN czechia_price_category AS cpc
	ON cpc.code = cp.category_code;


/*
 * Úkol 3: Přidejte k tabulce cen potravin i 
 * informaci o krajích ČR a vypište informace o cenách společně s názvem kraje.
 */
-- 108249
SELECT *
FROM czechia_price cp
LEFT JOIN czechia_region AS cr 
	ON cr.code = cp.region_code;

-- 101032
SELECT count(1)
FROM czechia_price cp
JOIN czechia_region AS cr 
	ON cp.region_code = cr.code;

SELECT cp.*, cr.name
FROM czechia_price cp
LEFT JOIN czechia_region AS cr 
	ON cr.code = cp.region_code;

-- Úkol 4: Využijte v příkladě z předchozího úkolu RIGHT JOIN s výměnou pořadí tabulek. Jak se změní výsledky?
SELECT *
FROM czechia_region AS cr 
RIGHT JOIN czechia_price AS cp
	ON cr.code = cp.region_code;


/*
 * Úkol 5: K tabulce czechia_payroll připojte všechny okolní tabulky. 
 * Využijte ERD model ke zjištění, které to jsou.
 */
SELECT *
FROM czechia_payroll AS cp 
LEFT JOIN czechia_payroll_calculation AS cpc
	ON cpc.code = cp.calculation_code
LEFT JOIN czechia_payroll_industry_branch AS cpib 
	ON  cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit AS cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type AS cpvt 
	ON cpvt.code = cp.value_type_code;
-- ověřit jak je to naopak


-- Úkol 6: Přepište dotaz z předchozí lekce do varianty, ve které použijete JOIN,
SELECT cpib.*
FROM czechia_payroll_industry_branch AS cpib 
LEFT JOIN czechia_payroll AS cp 
	ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = 5958
ORDER BY cp.value DESC 
LIMIT 1;

/*
 * Úkol 7: Spojte informace z tabulek cen a mezd 
 * (pouze informace o průměrných mzdách). 
 * Vypište z každé z nich základní informace, 
 * celé názvy odvětví a kategorií potravin a datumy měření, 
 * které vhodně naformátujete.
 */
SELECT cpc.name AS food_category,cp.value AS price 
,cpib.name AS industry ,cp2.value AS average_wage
,cp2.payroll_year , YEAR(cp.date_from)
, date_format(cp.date_from, '%Y') -- radeji YEAR funkci
, date_format(cp.date_from, '%e %M %Y', 'cs_CZ') -- do cestiny
FROM czechia_price AS cp 
JOIN czechia_payroll AS cp2 
	ON YEAR(cp.date_from) = cp2.payroll_year -- AND cp2.payroll_year BETWEEN 2006 AND 2018
	AND cp2.value_type_code = 5958
	AND cp.region_code IS NULL
JOIN czechia_price_category AS cpc 
	ON cpc.code = cp.category_code 
JOIN czechia_payroll_industry_branch AS cpib 
	ON cpib.code = cp2.industry_branch_code;
-- https://mariadb.com/kb/en/date_format/

/*
 * Úkol 8: K tabulce healthcare_provider připojte informace 
 * o regionech a vypište celé názvy krajů i okresů pro místa výkonu i sídla.
 */
SELECT 
	cr.name AS region_name,
    cr2.name AS residence_region_name,
    hp.name,
    cd.name AS district_name,
    cd2.name AS residence_district_name
FROM healthcare_provider AS hp 
LEFT JOIN czechia_region AS cr 
	ON hp.region_code = cr.code 
LEFT JOIN czechia_district AS cd 
	ON hp.district_code = cd.code
LEFT JOIN czechia_region AS cr2 
	ON hp.residence_region_code = cr2.code 
LEFT JOIN czechia_district AS cd2 
	ON hp.residence_district_code = cd2.code;

/*
 * Úkol 9: Upravte předchozí dotaz tak, aby byli na výpisu pouze takoví poskytovatelé, 
 * kteří mají sídlo v jiném kraji i jiném okrese než místo poskytování služeb.
 */
SELECT 
	cr.name AS region_name,
    cr2.name AS residence_region_name,
    hp.name,
    cd.name AS district_name,
    cd2.name AS residence_district_name
FROM healthcare_provider AS hp
LEFT JOIN czechia_region AS cr 
	ON hp.region_code = cr.code 
LEFT JOIN czechia_district AS cd 
	ON hp.district_code = cd.code
LEFT JOIN czechia_region AS cr2 
	ON hp.residence_region_code = cr2.code 
LEFT JOIN czechia_district AS cd2 
	ON hp.residence_district_code = cd2.code
WHERE hp.region_code != hp.residence_region_code 
	AND hp.district_code != hp.residence_district_code;


-- Kartézský součin
/* Úkol 1: Spojte tabulky czechia_price a czechia_price_category 
 * pomocí kartézského součinu. */
SELECT *
FROM czechia_price AS cp, czechia_price_category AS cpc
WHERE cp.category_code = cpc.code;

-- Úkol 2: Převeďte předchozí příklad do syntaxe s CROSS JOIN.
SELECT *
FROM czechia_price AS cp
CROSS JOIN czechia_price_category AS cpc 
	ON cp.category_code = cpc.code;


/* Úkol 3: Vytvořte všechny kombinace krajů kromě těch případů, 
 * kdy by se v obou sloupcích kraje shodovaly. */
SELECT *
FROM czechia_region AS cr 
CROSS JOIN czechia_region AS cr2 
	ON cr.code != cr2.code;



-- Množinové operace
/* Úkol 1: Přepište následující dotaz na variantu 
 * spojení dvou separátních dotazů se selekcí pro každý kraj zvlášť. */
SELECT category_code ,value
FROM czechia_price AS cp 
WHERE region_code IN ('CZ064', 'CZ010');

SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
UNION ALL -- ALL ZACHOVA DUPLICITY
SELECT category_code ,value 
FROM czechia_price
WHERE region_code = 'CZ010';

-- Úkol 2: Upravte předchozí dotaz tak, aby byly odstraněny duplicitní záznamy.
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
UNION
SELECT category_code ,value 
FROM czechia_price
WHERE region_code = 'CZ010';


/* Úkol 3: Sjednoťe kraje a okresy do jedné množiny.
 * Tu následně seřaďte dle kódu vzestupně. */
SELECT *
FROM (
	SELECT 
		code, 
		name,
		'region' AS country_part
	FROM czechia_region AS cr
	UNION
	SELECT 
		code, 
		name,
		'district' AS country_part
	FROM czechia_district AS cr
	) AS c
ORDER BY c.code;


-- Úkol 4: Vytvořte průnik cen z krajů Hl. město Praha a Jihomoravský kraj.
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
INTERSECT
SELECT category_code ,value 
FROM czechia_price
WHERE region_code = 'CZ010';

/*
 * Úkol 5: Vypište kód a název odvětví, ID záznamu 
 * a hodnotu záznamu průměrných mezd a počtu zaměstnanců. 
 * Vyberte pouze takové záznamy, 
 * které se shodují v uvedené hodnotě a spadají do odvětví s označením A nebo B.
 */
SELECT 
	cpib.*
	,cp.id
	,cp.value
FROM czechia_payroll AS cp 
JOIN czechia_payroll_industry_branch AS cpib 
	ON cpib.code = cp.industry_branch_code
WHERE value IN (
		SELECT cp.value
		FROM czechia_payroll AS cp 
		WHERE cp.industry_branch_code = 'A'
		INTERSECT
		SELECT cp.value
		FROM czechia_payroll AS cp 
		WHERE cp.industry_branch_code = 'B'
);

/*
 * Úkol 6: Vyberte z tabulky czechia_price takové záznamy,
 *  které jsou v Jihomoravském kraji jiné na sloupcích category_code 
 * a value než v Praze.
 */
SELECT category_code ,value
FROM czechia_price
WHERE region_code = 'CZ064'
EXCEPT
SELECT category_code ,value 
FROM czechia_price
WHERE region_code = 'CZ010';


/*
 * Úkol 7: Upravte předchozí dotaz tak, 
 * abychom získali záznamy, které jsou v Praze 
 * a ne v Jihomoravském kraji. Dále udělejte průnik 
 * těchto dvou disjunktních podmnožin. */
(
		SELECT category_code, value
		FROM czechia_price
		WHERE region_code = 'CZ064'
		EXCEPT
		SELECT category_code ,value 
		FROM czechia_price
		WHERE region_code = 'CZ010'
)
INTERSECT
(
		SELECT category_code, value
		FROM czechia_price
		WHERE region_code = 'CZ010'
		EXCEPT
		SELECT category_code ,value 
		FROM czechia_price
		WHERE region_code = 'CZ064'
);
-- VÝSLEDEK je prázdná množina

-- Common Table Expression
/*
 * Úkol 1: Pomocí operátoru WITH připravte tabulku s 
 * cenami nad 150 Kč. S její pomocí následně vypište 
 * jména takových kategorií potravin, které do této cenové hladiny spadají.
 */
WITH high_price AS (
	SELECT *
	FROM czechia_price as cp 
	WHERE cp.value > 150; 
)
SELECT *
FROM high_price;

-- ekvivalentní dotazy
SELECT * 
FROM (
	SELECT *
	FROM czechia_price as cp 
	WHERE cp.value > 150; 
)


/*
 * Úkol 2: Zjistěte, ve kterých okresech mají všichni praktičtí lékaři 
 * vyplněný telefon, fax, nebo e-mail. Pro tyto účely si připravte dočasnou 
 * tabulku s výčtem okresů, ve kterých tato podmínka naopak splněna není, 
 * pod názvem not_completed_provider_info_district.
 */
WITH not_completed_provider_info_district AS (
	SELECT DISTINCT hp.district_code
	FROM healthcare_provider as hp 
	WHERE 
		hp.phone IS NULL
		AND hp.fax IS NULL
		AND hp.email IS NULL
		AND hp.provider_type = 'Samost. ordinace všeob. prakt. lékaře'
)
SELECT *
FROM czechia_district AS cd
WHERE cd.code NOT IN (
	SELECT *
	FROM not_completed_provider_info_district
	);


-- Úkol 3: Vypište z tabulky economies průměr světových daní, při HDP vyšším než 70 miliard.
WITH large_gdp_area AS (
	SELECT *
	FROM economies as e 
	WHERE e.GDP > 70000000000
)
SELECT avg(taxes) AS taxes_avg
FROM large_gdp_area;


-- Countries: JOIN
/*
 * Úkol 1: K tabulce countries připojte tabulku religions. 
 * Vybere název státu, hlavní město, celkovou populaci, název náboženství 
 * a počet jeho příslušníků. Vyberte pouze rok 2020.
 */
SELECT r.country, c.capital_city, c.population, r.religion, r.population
FROM countries AS c 
JOIN religions AS r 
	ON c.country = r.country
WHERE r.YEAR = 2020;

/*
 * Úkol 2: K tabulce countries připojte tabulku economies. 
 * Pro každý stát vyberte hodnoty HDP v milionech dolarů, gini koeficient a daně za období, 
 * kdy byla země samostatná (independence_date).
 */
SELECT c.country, round(e.GDP / 1000000, 2), e.gini, e.taxes, c.independence_date, e.YEAR, e.population
FROM countries AS c 
JOIN economies AS e 
	ON c.country = e.country
WHERE c.independence_date <= e.YEAR;

/*
 * Úkol 3: Zjistěte, které země se nacházejí v tabulce countries, 
 * ale ne v tabulce economies. Seřaďte je sestupně podle počtu obyvatel.
 */
SELECT country
FROM countries
EXCEPT
SELECT country
FROM economies;

SELECT country
FROM economies AS e 
WHERE country = 'Christmas Island';

SELECT c.country , c.population
FROM countries c 
LEFT JOIN economies e 
    on c.country = e.country 
    and e.year=2018 -- vyberu si jenom jeden rok
WHERE e.country is null
ORDER BY c.population DESC;

/*
 * Úkol 4: Joiny můžeme používat nejenom pro spojování dvou různých tabulek. 
 * Můžeme napojovat i jednu tabulku samu na sebe, abychom z ní zjistili nové informace.
 * Použijte tabulku life_expectancy abyste pro každý stát zjistili podíl doby dožití v roce 2015 a v roce 1970.
 */
SELECT a.country, a.life_exp_2015, b.life_exp_1970, round( a.life_exp_2015 / b.life_exp_1970, 2 ) as life_exp_ratio
FROM (SELECT country, life_expectancy as life_exp_2015 FROM life_expectancy WHERE year = 2015) AS a
JOIN (SELECT country, life_expectancy as life_exp_1970 FROM life_expectancy WHERE year = 1970) AS b
	ON a.country = b.country;

/*
 * Úkol 5: Z tabulky economies spočítejte meziroční procentní nárůst populace a procentní nárůst HDP pro každou zemi.
 * Nápověda: Napojte tabulku samu na sebe pomocí klíče year. Ke klíči pravé tabulky přičtěte 1.
 */
SELECT e.country 
	,e.year
	,e2.year as year_prev
	,round( ( e.GDP - e2.GDP ) / e2.GDP * 100, 2 ) as GDP_growth
    ,round( ( e.population - e2.population ) / e2.population * 100, 2) as pop_growth_percent
FROM economies as e 
JOIN economies as e2 
	ON e.country = e2.country
	AND e.year = e2.year + 1
	AND e.year < 2020;

SELECT
    e.country,
    e.year,
    e.population,
    e.GDP,
    e2.year as next_year,
    ROUND((e2.population - e.population) / e.population * 100, 2) as pop_growth_percent,
    ROUND((e2.GDP - e.GDP) / e.GDP * 100, 2) as GDP_growth_percent
FROM economies as e
JOIN economies as e2 ON e.country = e2.country AND e.year + 1 = e2.year;


/*
 * Úkol 6: Počty věřících v tabulce religions pro rok 2020 přepočítejte na procentní podíl.
 * Nápověda: agregujte tabulku podle jednotlivých zemí. Sečtěte počet obyvatel
 * agregovanou tabulku připojte na původní tabulku
 */
SELECT
	r.country,
	r.religion,
	round((r.population / r2.total_population) * 100, 3) AS religion_2020
FROM
	religions as r
JOIN (
	SELECT
		country,
		sum(population) AS total_population
	FROM
		religions
	WHERE
		year = 2020
	GROUP BY
		country) as r2
	ON
	r.country = r2.country
	AND r.year = 2020;


-- COVID-19: JOIN
-- Úkol 1a: Vytvořte view z lookup_table, kde je sloupec provincie null
CREATE VIEW lookup_table_province AS
SELECT *
FROM lookup_table as lt
WHERE province IS NULL;


/*
 * Úkol 1b: Spojte pomocí left join tabulku covid19_basic 
 * s view vytvořeným v předchozím úkolu přes country
 */
SELECT *
FROM covid19_basic as cb 
LEFT JOIN lookup_table_province as ltp 
	ON cb.country = ltp.country;

-- Úkol 2: Spojte tabulky covid19_basic a covid19_basic_difference pomocí left join
SELECT *
FROM covid19_basic as cb 
LEFT JOIN covid19_basic_differences as cbd 
	ON cb.country = cbd.country
	AND cb.`date` = cbd.`date`;
	
/* Úkol 3: Spojte tabulky covid19_detail_us a covid19_detail_us_differences 
 * skrze sloupce date, country, admin2. Z tabulky covid19_detail_us vyberte 
 * všechny sloupce a tabulky covid19_detail_us_differences jen confirmed a 
 * přejmenujte ho na confirmed_diff. Pro spojení použijte left join
 */
SELECT cdu.*, cdud.confirmed AS confirmed_diff
FROM covid19_detail_us as cdu 
LEFT JOIN covid19_detail_us_differences as cdud 
	ON cdu.date = cdud.date
	AND cdu.country = cdud.country
	AND cdu.province = cdud.province
	AND cdu.admin2 = cdud.admin2;

/*
 * Úkol 4: Spojte pomocí left join tabulky covid19_detail_us, 
 * covid19_detail_us_differences a lookup_table
 */
SELECT *
FROM covid19_detail_us as cdu 
LEFT JOIN covid19_detail_us_differences as cdud 
	ON cdu.date = cdud.date
	AND cdu.country = cdud.country
	AND cdu.province = cdud.province
	AND cdu.admin2 = cdud.admin2
LEFT JOIN lookup_table as lt 
	ON cdu.country = lt.country
	AND cdu.province = lt.province
	AND cdu.admin2 = lt.admin2;

/*
 * Úkol 5: Spojte pomocí left join tabulky 
 * covid19_detail_global a covid19_detail_global_differences
 */
SELECT *
FROM covid19_detail_global as cdg 
LEFT JOIN covid19_detail_global_differences as cdgd 
	ON cdg.date = cdgd.date
	AND cdg.country = cdgd.country
	AND cdg.province = cdgd.province;

/*
 * Úkol 6: Spojte pomocí left join tabulky covid19_detail_global, 
 * covid19_detail_global_differences a lookup_table
 */
SELECT *
FROM covid19_detail_global as cdg 
LEFT JOIN covid19_detail_global_differences as cdgd 
	ON cdg.date = cdgd.date
	AND cdg.country = cdgd.country
	AND cdg.province = cdgd.province
LEFT JOIN lookup_table as lt 
	ON cdg.country = lt.country
	AND cdg.province = lt.province;

/*
 * Úkol 7: Jaký je průbeh počtu nakažených na milion obyvatel
 * v Česke republice a v Německu
 */
SELECT
	cb.date
	, cb.country
	, (cb.confirmed / 1000000) / cz.population AS weighted_cz_confirmed
	, cb2.country
	, (cb2.confirmed * 1000000) / ger.population AS weighted_ger_confirmed
FROM
	(SELECT
		*
	FROM
		covid19_basic
	WHERE
		country = 'Czechia') AS cb
LEFT JOIN lookup_table AS cz ON
	cb.country = cz.country
CROSS JOIN (
	SELECT
		*
	FROM
		covid19_basic
	WHERE
		country = 'Germany') AS cb2
LEFT JOIN lookup_table AS ger ON
	cb2.country = ger.country;

-- NEBO
SELECT
	base.date
	, base.country
	, round((base.confirmed * 1000000)/ a.population, 2)
FROM
	(SELECT date
	, country
	, confirmed
	FROM
		covid19_basic cb
	WHERE
		country IN ('Czechia', 'Germany')
         ) base
LEFT JOIN (
	SELECT country, population
	FROM
		lookup_table lt
	WHERE
		country IN ('Czechia', 'Germany')
			AND province IS NULL
         ) a
ON base.country = a.country
ORDER BY date, country;

/*
 * Úkol 8: Seřaďte státy podle počtu celkově nakažených na milion obyvatel k 30.8.2020?
 */
SELECT cb.country, date, round((cb.confirmed * 1000000) / lt.population) AS weighted_confirmed, lt.population
FROM  covid19_basic AS cb
LEFT JOIN lookup_table AS lt 
	ON cb.country = lt.country
	AND lt.province IS NULL
WHERE cb.date = '2020-08-30'
ORDER BY weighted_confirmed DESC;

/*
 * Úkol 9: Ukaž celosvětový průběh celkově nakaženych na milion obyvatel
 */

SELECT date, round((sum(cb.confirmed) * 1000000) / sum(lt.population)) AS weighted_confirmed
FROM  covid19_basic AS cb
LEFT JOIN lookup_table AS lt 
	ON cb.country = lt.country
	AND lt.province IS NULL
GROUP BY cb.date;

/*
 * Úkol 10: Z tabulky lookup_table vyberte pouze země s populací menší než milion 
 * a připojte k této tabulce průběh jejich nakažených. (Použijte inner join)
 */
SELECT cb.*, lt_small.population
FROM (SELECT country, population FROM lookup_table AS lt WHERE population < 1000000) AS lt_small
INNER JOIN covid19_basic AS cb 
	ON lt_small.country = cb.country;

/* Úkol 11: Udělejte seznam všech zemí pro všechny datumy z tabulky covid19_basic */
SELECT dates.date,
    countries.country
FROM (SELECT DISTINCT date FROM covid19_basic) dates
CROSS JOIN (SELECT DISTINCT country FROM covid19_basic) countries;
-- Both lists of all dates for every country?
SELECT cb.date, cb2.country
FROM (SELECT DISTINCT date FROM covid19_basic) AS cb
CROSS JOIN covid19_basic AS cb2 
	ON cb.date = cb2.date;


/* Úkol 12: Udělejte seznam všech zemí pro všechny datumy z tabulky covid19_basic. 
 * K této tabulce připojte přírůstky a kde nejsou data vložte 0.
 */
SELECT dates.date, countries.country, CASE WHEN cbd.confirmed IS NULL THEN 0 ELSE cbd.confirmed END AS confirmed
FROM (SELECT DISTINCT date FROM covid19_basic) dates
CROSS JOIN (SELECT DISTINCT country FROM covid19_basic) countries
LEFT JOIN covid19_basic_differences AS cbd
	ON dates.date = cbd.date
	AND countries.country = cbd.country 
	

-- COVID-19: pokračování JOIN
/* Úkol 1: K tabulce covid19_detail_global_differences připojte tabulku lookup_table. 
 * Zjistěte počty nakažených na milion obyvatel v Anglii, Walesu, Skotsku a Severním Irsku. 
 * Podívejte se, jestli se počty významně liší o víkendu a ve všedních dnech. */
SELECT base.date, lt. population, base.province, base.confirmed
	, round((1000000/lt.population)*base.confirmed) AS conf_per_mil
	, CASE WHEN weekday(base.date) IN (5,6) THEN 1 ELSE 0 END AS is_weekend
FROM (SELECT * FROM covid19_detail_global_differences AS cdgd  WHERE country = 'United Kingdom' 
				AND province IN ('Wales', 'Northern Ireland', 'Scotland', 'England') AND confirmed IS NOT NULL) AS base 
LEFT JOIN lookup_table AS lt 
	ON base.country = lt.country
	AND base.province = lt.province
	
/*
 * Úkol 2: Srovnejte počty nově nakažených na sto tisíc obyvatel v České republice 
 * a ve Skotsku za posledních 14 dní. Výsledná tabulka bude mít 4 sloupce: 
 * datum, počet v ČR, počet ve Skotsku a binární proměnnou pro víkend.
 */
-- řešení které vyplivne 14 posledních dní v tabulce
SELECT czechs.date, czechs.czech_confirmed, scots.scot_confirmed, CASE WHEN weekday(czechs.date) IN (5,6) THEN 1 ELSE 0 END AS is_weekend 
	FROM	(
		SELECT cbd.date, round((100000/lt.population)*cbd.confirmed) AS czech_confirmed
		FROM (SELECT * FROM covid19_basic_differences WHERE country = 'Czechia' AND confirmed IS NOT NULL) AS cbd
		LEFT JOIN lookup_table AS lt
			ON cbd.country = lt.country) AS czechs
JOIN (
		SELECT scotland.date, round((100000/lt.population)*scotland.confirmed) AS scot_confirmed 
		FROM (SELECT * FROM covid19_detail_global_differences WHERE country = 'United Kingdom' AND province = 'Scotland' AND confirmed IS NOT NULL) AS scotland
		LEFT JOIN lookup_table AS lt
			ON scotland.country = lt.country AND scotland.province = lt.province
		) AS scots
	ON czechs.date = scots.date
WHERE scot_confirmed IS NOT NULL
ORDER BY czechs.date DESC
LIMIT 14;

-- řešení, které počítá se současným časem a posledními 14 dny
SELECT cz.date , case when weekday(cz.date) in (5,6) then 1 else 0 end as weekend,
    round( cz.confirmed_czech / cz.pop_czech * 100000 ) as confirmed_czech,
    round( sc.confirmed_scot / sc.pop_scot * 100000 ) as confirmed_scot
FROM (
        SELECT a.country , a.date , a.confirmed as confirmed_czech , lt.population as pop_czech
        FROM covid19_basic_differences a 
        JOIN lookup_table lt 
            on a.country = lt.country 
        WHERE a.country = 'Czechia' 
            and a.date >= DATE_ADD(CURRENT_DATE(), INTERVAL - 14 day) 
    ) cz JOIN ( 
        SELECT b.province , b.date , b.confirmed as confirmed_scot , lt2.population as pop_scot
        FROM covid19_detail_global_differences b
        JOIN lookup_table lt2
            on b.province = lt2.province 
        WHERE b.province = 'Scotland'
    ) sc on cz.date = sc.date
ORDER BY cz.date desc;

	
/*
 * Úkol 3: Z tabulky covid19_basic vyberte počty nově nakažených pro Českou republiku v říjnu. 
 * K této tabulce připojte maximální denní teplotu z tabulky weather.
 */
SELECT  cb.country, cb.date, cb.confirmed , lt.iso3 , c.capital_city , w.max_temp
FROM (SELECT country, date, confirmed FROM covid19_basic WHERE country = 'Czechia' AND date LIKE '%-10-%') AS cb 
LEFT JOIN lookup_table AS lt 
	ON cb.country = lt.country
LEFT JOIN countries AS c 
	ON lt.iso3 = c.iso3
	AND c.capital_city = 'Praha'
LEFT JOIN (SELECT city , date , max(temp) as max_temp
        FROM weather  
        WHERE date LIKE '%-10-%' AND city = 'Prague'
        GROUP BY city, date) AS w
	ON cb.date = w.date;


SELECT *
FROM weather
WHERE date LIKE '2020-10-02%' AND city = 'Prague';



SELECT c.country, c.date, c.confirmed , lt.iso3 , c2.capital_city , w.max_temp
FROM covid19_basic as c
JOIN lookup_table lt 
    on c.country = lt.country 
    and c.country = 'Czechia'
    and month(c.date) = 10
JOIN countries c2
    on lt.iso3 = c2.iso3
JOIN (  SELECT w.city , w.date , max(w.temp) as max_temp
        FROM weather w 
        GROUP BY w.city, w.date) w
    on c2.capital_city = w.city 
    and c.date = w.date
ORDER BY c.date desc;