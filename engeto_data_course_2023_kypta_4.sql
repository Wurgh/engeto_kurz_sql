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


--- 8 a 9 dodělat 

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
SELECT category_code, value
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


-- příští lekce








