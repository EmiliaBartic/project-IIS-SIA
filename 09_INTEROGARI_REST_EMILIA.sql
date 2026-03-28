-- Analiza Calitativa (The Quality Lead)
-- 1.1. ROLLUP: Performanta Ierarhica pe Categorii de Calitate
-- Grupeaza filmele dupa Gen si un Nivel de Calitate calculat dinamic
-- Ofera subtotaluri pentru fiecare gen si categorie
-- 1. Creare View ROLLUP
CREATE OR REPLACE VIEW V_EMILIA_ROLLUP AS
SELECT genres, 
    CASE WHEN average_rating >= 8.5 THEN 'CAPODOPERA' WHEN average_rating >= 7.0 THEN 'BUN' ELSE 'MEDIOCRE' END 
    AS categorie_succes,
    COUNT(*) as volum_filme, ROUND(AVG(average_rating), 3) as precizie_rating
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL
GROUP BY ROLLUP(genres, CASE WHEN average_rating >= 8.5 THEN 'CAPODOPERA' WHEN average_rating >= 7.0 THEN 'BUN' 
ELSE 'MEDIOCRE' END);
/* COMENTARIU PENTRU BROWSER: 
   Acest endpoint web afișează performanța calitativă. Browserul îți va arăta
   distribuția filmelor pe categorii de calitate (Capodoperă, Bun, Mediocru) în cadrul fiecărui gen. */


-- 1.2. CUBE: Matricea Interdisciplinara Regizor-Actor (Cu subtotaluri OLAP)
-- Analizeaza combinarile de Regizori (CSV) si Actori (Mongo)
-- si masoara calitatea filmelor in care apar impreuna
-- NVL inlocuieste valorile NULL generate de subtotaluri cu texte explicite
-- 2. Creare View CUBE
CREATE OR REPLACE VIEW V_EMILIA_CUBE AS
SELECT NVL(directors, 'TOTAL REGIZORI') as directors, NVL(actor_name, 'TOTAL ACTORI') as actor_name, 
    MAX(average_rating) as cel_mai_bun_film, MIN(average_rating) as cel_mai_slab_film
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE directors IS NOT NULL AND actor_name IS NOT NULL
GROUP BY CUBE(directors, actor_name)
HAVING COUNT(*) >= 1 AND AVG(average_rating) > 5;
/* COMENTARIU PENTRU BROWSER: 
   Endpoint pentru matricea Regizor-Actor. Vei putea consuma via API extremele calitative
   (cel mai bun / slab film) pentru orice cuplu Regizor-Actor. */


-- 1.3. GROUPING SETS: Identificarea Elitei (MVP Analysis)
-- Compara media regizorilor de top cu media actorilor de top intr-un singur tabel
-- Utila pentru a vedea cine trage nota in sus mai mult
-- (Scor rotunjit la 3 zecimale)
-- 3. Creare View GROUPING SETS
CREATE OR REPLACE VIEW V_EMILIA_GSETS AS
SELECT directors as entitate_nume, 'REGIZOR' as tip, ROUND(AVG(average_rating), 3) as scor
FROM FDBO.V_ULTIMATE_MOVIE_REPORT WHERE directors IS NOT NULL GROUP BY GROUPING SETS ((directors))
UNION ALL
SELECT actor_name as entitate_nume, 'ACTOR' as tip, ROUND(AVG(average_rating), 3) as scor
FROM FDBO.V_ULTIMATE_MOVIE_REPORT WHERE actor_name IS NOT NULL GROUP BY GROUPING SETS ((actor_name));
/* COMENTARIU PENTRU BROWSER: 
   Acest JSON va fi o listă plată de tip dicționar, excelentă pentru topuri web,
   care combină și compară scorurile regizorilor cu ale actorilor. */

-- EXPUNERE ORDS PENTRU EMILIA
BEGIN
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_EMILIA_ROLLUP', p_object_type => 'VIEW', p_object_alias => 'emilia_rollup');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_EMILIA_CUBE', p_object_type => 'VIEW', p_object_alias => 'emilia_cube');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_EMILIA_GSETS', p_object_type => 'VIEW', p_object_alias => 'emilia_gsets');
  COMMIT;
END;
/