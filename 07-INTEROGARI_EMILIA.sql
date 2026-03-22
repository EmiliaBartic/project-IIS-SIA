-- Analiza Calitativa (The Quality Lead)
-- 1.1. ROLLUP: Performanta Ierarhica pe Categorii de Calitate
-- Grupeaza filmele dupa Gen si un Nivel de Calitate calculat dinamic
-- Ofera subtotaluri pentru fiecare gen si categorie
SELECT 
    genres, 
    CASE 
        WHEN average_rating >= 8.5 THEN 'CAPODOPERA'
        WHEN average_rating >= 7.0 THEN 'BUN'
        ELSE 'MEDIOCRE'
    END AS categorie_succes,
    COUNT(*) as volum_filme,
    ROUND(AVG(average_rating), 3) as precizie_rating
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL -- Eliminam filmele fara nota pentru a nu genera categorii (null)
GROUP BY ROLLUP(genres, 
    CASE 
        WHEN average_rating >= 8.5 THEN 'CAPODOPERA'
        WHEN average_rating >= 7.0 THEN 'BUN'
        ELSE 'MEDIOCRE'
    END);

-- 1.2. CUBE: Matricea Interdisciplinara Regizor-Actor (Cu subtotaluri OLAP)
-- Analizeaza combinarile de Regizori (CSV) si Actori (Mongo)
-- Folosim NVL pentru a evidentia subtotalurile si totalul general generate de CUBE
SELECT 
    NVL(directors, '--- TOTAL TOTI REGIZORII ---') as directors, 
    NVL(actor_name, '--- TOTAL TOTI ACTORII ---') as actor_name, 
    MAX(average_rating) as cel_mai_bun_film,
    MIN(average_rating) as cel_mai_slab_film
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE directors IS NOT NULL AND actor_name IS NOT NULL
GROUP BY CUBE(directors, actor_name)
HAVING COUNT(*) >= 1 
   AND AVG(average_rating) > 5;

-- 1.3. GROUPING SETS: Identificarea Elitei (MVP Analysis)
-- Compara media regizorilor de top cu media actorilor de top intr-un singur tabel
-- Utila pentru a vedea cine "trage" nota in sus mai mult
-- (Scor rotunjit la 3 zecimale)
SELECT 
    directors as entitate_nume, 
    'REGIZOR' as tip,
    ROUND(AVG(average_rating), 3) as scor -- Aplicam rotunjirea aici
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE directors IS NOT NULL
GROUP BY GROUPING SETS ((directors))
UNION ALL
SELECT 
    actor_name as entitate_nume, 
    'ACTOR' as tip,
    ROUND(AVG(average_rating), 3) as scor -- Aplicam rotunjirea si in a doua jumatate a uniunii
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE actor_name IS NOT NULL
GROUP BY GROUPING SETS ((actor_name));