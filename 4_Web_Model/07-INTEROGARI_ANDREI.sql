-- Analiza Corelatiilor Avansate (The Data Scientist)
-- 3.1. ROLLUP: Succesul pe Nise (Gen -> Regizor -> Titlu)
-- O ierarhie pe 3 niveluri care coboara pana la nivel de film individual
-- Permite vizualizarea contributiei fiecarui film la media regizorului
SELECT 
    genres, 
    directors, 
    primaryTitle, 
    SUM(average_rating) as suma_puncte
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE ROWNUM <= 5000
GROUP BY ROLLUP(genres, directors, primaryTitle);

-- 3.2. CUBE: Matricea Globala de Succes NoSQL-CSV
-- Cel mai complex query: intrepatrunde Profesie (Mongo), Gen (Oracle) si Rating
-- Identifica nisele neexploatate (ex: actori care sunt si scriitori in filme de groaza)
SELECT 
    actor_prof, 
    genres, 
    CASE WHEN average_rating > 8 THEN 'TOP' ELSE 'NORMAL' END as rang,
    COUNT(*) as frecventa_aparitie
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE actor_prof IS NOT NULL
GROUP BY CUBE(actor_prof, genres, CASE WHEN average_rating > 8 THEN 'TOP' ELSE 'NORMAL' END);

-- 3.3. GROUPING SETS: Profilarea de Risc si Performanta (The Data Scientist)
-- Utilizeaza functia GROUPING pentru a eticheta inteligent nivelul de agregare.
-- Introduce deviatia standard (STDDEV) pentru a masura "volatilitatea" sau consistenta calitatii.
-- Combina seturi de date multidimensionale complexe in loc de simple coloane individuale.
SELECT 
    CASE 
        WHEN GROUPING(genres) = 0 AND GROUPING(directors) = 0 THEN 'NISA: GEN + REGIZOR'
        WHEN GROUPING(actor_prof) = 0 AND GROUPING(genres) = 0 THEN 'NISA: PROFESIE + GEN'
        WHEN GROUPING(directors) = 0 THEN 'INDIVIDUAL: REGIZOR'
        ELSE 'MACRO: TOTAL GENERAL'
    END AS tip_analiza,
    genres, 
    actor_prof, 
    directors, 
    COUNT(*) as volum_productii,
    ROUND(AVG(average_rating), 2) as medie_scor,
    ROUND(STDDEV(average_rating), 2) as volatilitate_note -- O valoare mica = calitate constanta
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL
GROUP BY GROUPING SETS (
    (genres, directors),  -- Analiza de nisa 1 (Ce genuri stapaneste un regizor?)
    (actor_prof, genres), -- Analiza de nisa 2 (Ce profesii domina anumite genuri?)
    (directors),          -- Performanta individuala a regizorilor
    ()                    -- Benchmark-ul global (Total General)
)
HAVING COUNT(*) > 1; -- Eliminam extremele singuratice pentru a putea calcula deviatia standard
