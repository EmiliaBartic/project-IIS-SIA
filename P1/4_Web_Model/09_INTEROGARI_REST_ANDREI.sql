-- 1. Creare View ROLLUP
-- Analiza Corelatiilor Avansate (The Data Scientist)
-- 3.1. ROLLUP: Succesul pe Nise (Gen -> Regizor -> Titlu)
-- O ierarhie pe 3 niveluri care coboara pana la nivel de film individual
-- Permite vizualizarea contributiei fiecarui film la media regizorului
CREATE OR REPLACE VIEW V_ANDREI_ROLLUP AS
SELECT genres, directors, primaryTitle, SUM(average_rating) as suma_puncte
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE ROWNUM <= 5000
GROUP BY ROLLUP(genres, directors, primaryTitle);

/* Acest endpoint expune o ierarhie pe 3 niveluri (Gen -> Regizor -> Titlu). */

-- 3.2. CUBE: Matricea Globala de Succes NoSQL-CSV
-- Cel mai complex query: intrepatrunde Profesie (Mongo), Gen (Oracle) si Rating
-- Identifica nisele neexploatate (ex: actori care sunt si scriitori in filme de groaza)
-- 2. Creare View CUBE
CREATE OR REPLACE VIEW V_ANDREI_CUBE AS
SELECT actor_prof, genres, CASE WHEN average_rating > 8 THEN 'TOP' ELSE 'NORMAL' END as rang, COUNT(*) as frecventa_aparitie
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE actor_prof IS NOT NULL
GROUP BY CUBE(actor_prof, genres, CASE WHEN average_rating > 8 THEN 'TOP' ELSE 'NORMAL' END);
/* COMENTARIU PENTRU BROWSER: 
   Acest endpoint returnează matricea globală. */

-- 3.3. GROUPING SETS: Profilarea de Risc si Performanta (The Data Scientist)
-- Utilizeaza functia GROUPING pentru a eticheta inteligent nivelul de agregare.
-- Introduce deviatia standard (STDDEV) pentru a masura "volatilitatea" sau consistenta calitatii.
-- Combina seturi de date multidimensionale complexe in loc de simple coloane individuale.
-- 3. Creare View GROUPING SETS
CREATE OR REPLACE VIEW V_ANDREI_GSETS AS
SELECT 
    CASE 
        WHEN GROUPING(genres) = 0 AND GROUPING(directors) = 0 THEN 'NISA: GEN + REGIZOR'
        WHEN GROUPING(actor_prof) = 0 AND GROUPING(genres) = 0 THEN 'NISA: PROFESIE + GEN'
        WHEN GROUPING(directors) = 0 THEN 'INDIVIDUAL: REGIZOR'
        ELSE 'MACRO: TOTAL GENERAL'
    END AS tip_analiza,
    genres, actor_prof, directors, COUNT(*) as volum_productii,
    ROUND(AVG(average_rating), 2) as medie_scor, ROUND(STDDEV(average_rating), 2) as volatilitate_note
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL
GROUP BY GROUPING SETS ((genres, directors), (actor_prof, genres), (directors), ())
HAVING COUNT(*) > 1;
/* Acest endpoint oferă profilele de risc. JSON-ul generat va fi deja segmentat curat
   (ex: date doar despre regizori, urmate de date doar despre profesie+gen). */

-- EXPUNERE ORDS PENTRU ANDREI
BEGIN
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_ANDREI_ROLLUP', p_object_type => 'VIEW', p_object_alias => 'andrei_rollup');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_ANDREI_CUBE', p_object_type => 'VIEW', p_object_alias => 'andrei_cube');
  ORDS.ENABLE_OBJECT(p_enabled => TRUE, p_schema => 'FDBO', p_object => 'V_ANDREI_GSETS', p_object_type => 'VIEW', p_object_alias => 'andrei_gsets');
  COMMIT;
END;
/
