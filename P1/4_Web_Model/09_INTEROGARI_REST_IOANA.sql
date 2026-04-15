
-- Analiza de Piata (The Market Strategist)
-- 2.1. ROLLUP: Analiza de Potential si Dominanta pe Piata
-- Evalueaza volumul de productii, media generala si varful absolut de succes
-- Ierarhia ne arata potentialul fiecarui Gen de film, detaliat apoi pe Profesia actorilor
-- 1. Creare View ROLLUP
CREATE OR REPLACE VIEW V_IOANA_ROLLUP AS
SELECT genres, actor_prof, COUNT(*) as volum_productii, 
ROUND(AVG(average_rating), 2) as rating_mediu_piata, MAX(average_rating) as varf_de_succes
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE actor_prof IS NOT NULL
GROUP BY ROLLUP(genres, actor_prof)
HAVING COUNT(*) > 1;
/* COMENTARIU PENTRU BROWSER: 
   Endpoint de analiză a pieței. Vei vedea pe web rating-ul mediu și vârful de succes
   pentru fiecare categorie de piață definită de genul filmului și profesia implicată. */

-- 2.2. CUBE: Impactul Complexitatii Echipei de Regie asupra Ratingului
-- Analizeaza combinatiile posibile intre numarul de regizori (din CSV) si genul filmului (din Oracle)
-- Obiectiv: Determina daca productiile co-regizate (mai multi regizori per film) obtin note medii mai bune
-- 2. Creare View CUBE
CREATE OR REPLACE VIEW V_IOANA_CUBE AS
SELECT genres, LENGTH(directors) - LENGTH(REPLACE(directors, ',', '')) + 1 as estimare_nr_regizori, 
ROUND(AVG(average_rating), 2) as performanta_medie
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE directors IS NOT NULL
GROUP BY CUBE(genres, LENGTH(directors) - LENGTH(REPLACE(directors, ',', '')) + 1)
HAVING AVG(average_rating) IS NOT NULL;
/* COMENTARIU PENTRU BROWSER: 
   Analiza echipelor complexe. JSON-ul returnat arată cum numărul de regizori 
   influențează performanța pe diverse genuri cinematografice. */

-- 2.3. GROUPING SETS: Profilul de Succes al Pietei
-- Analizeaza performanta paralela: doar pe Gen, doar pe Nivel de Succes si combinat
-- Permite identificarea rapida a segmentelor cu cel mai mare volum de hit-uri
-- 3. Creare View GROUPING SETS
CREATE OR REPLACE VIEW V_IOANA_GSETS AS
SELECT genres, 
    CASE WHEN average_rating >= 8.0 THEN 'HIT' WHEN average_rating >= 6.0 THEN 'MEDIU' ELSE 'FLOP' END AS segment_piata,
    COUNT(*) as numar_productii, ROUND(AVG(average_rating), 2) as rating_segment
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL AND genres IS NOT NULL
GROUP BY GROUPING SETS ((genres), 
    (CASE WHEN average_rating >= 8.0 THEN 'HIT' WHEN average_rating >= 6.0 THEN 'MEDIU' ELSE 'FLOP' END), 
    (genres, CASE WHEN average_rating >= 8.0 THEN 'HIT' WHEN average_rating >= 6.0 THEN 'MEDIU' ELSE 'FLOP' END))
HAVING COUNT(*) > 5;
/* COMENTARIU PENTRU BROWSER: 
   Afișează profile de succes (HIT/MEDIU/FLOP). Web Service-ul returnează volume 
   semnificative (peste 5 producții) segmentate curat pentru dashboard-uri grafice. */

-- EXPUNERE ORDS PENTRU IOANA
BEGIN
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_IOANA_ROLLUP', p_object_type => 'VIEW', p_object_alias => 'ioana_rollup');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_IOANA_CUBE', p_object_type => 'VIEW', p_object_alias => 'ioana_cube');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_IOANA_GSETS', p_object_type => 'VIEW', p_object_alias => 'ioana_gsets');
  COMMIT;
END;
/
