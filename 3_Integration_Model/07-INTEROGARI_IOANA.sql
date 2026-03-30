-- Analiza de Piata (The Market Strategist)
-- 2.1. ROLLUP: Analiza de Potential si Dominanta pe Piata
-- Evalueaza volumul de productii, media generala si varful absolut de succes
-- Ierarhia ne arata potentialul fiecarui Gen de film, detaliat apoi pe Profesia actorilor
SELECT 
    genres, 
    actor_prof, 
    COUNT(*) as volum_productii,
    ROUND(AVG(average_rating), 2) as rating_mediu_piata,
    MAX(average_rating) as varf_de_succes -- Cel mai bun rating atins in aceasta categorie
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE actor_prof IS NOT NULL
GROUP BY ROLLUP(genres, actor_prof)
HAVING COUNT(*) > 1; -- Eliminam "zgomotul": pastram doar segmentele cu macar 2 filme

-- 2.2. CUBE: Impactul Complexitatii Echipei de Regie asupra Ratingului
-- Analizeaza combinatiile posibile intre numarul de regizori (din CSV) si genul filmului (din Oracle)
-- Obiectiv: Determina daca productiile co-regizate (mai multi regizori per film) obtin note medii mai bune
SELECT 
    genres, 
    -- Numaram cate virgule sunt in sirul text + 1 pentru a afla cati regizori au lucrat la film
    LENGTH(directors) - LENGTH(REPLACE(directors, ',', '')) + 1 as estimare_nr_regizori,
    ROUND(AVG(average_rating), 2) as performanta_medie
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE directors IS NOT NULL
GROUP BY CUBE(genres, LENGTH(directors) - LENGTH(REPLACE(directors, ',', '')) + 1)
HAVING AVG(average_rating) IS NOT NULL;

-- 2.3. GROUPING SETS: Profilul de Succes al Pietei
-- Analizeaza performanta paralela: doar pe Gen, doar pe Nivel de Succes si combinat
-- Permite identificarea rapida a segmentelor cu cel mai mare volum de hit-uri
SELECT 
    genres, 
    CASE 
        WHEN average_rating >= 8.0 THEN 'HIT'
        WHEN average_rating >= 6.0 THEN 'MEDIU'
        ELSE 'FLOP'
    END AS segment_piata,
    COUNT(*) as numar_productii,
    ROUND(AVG(average_rating), 2) as rating_segment
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
WHERE average_rating IS NOT NULL AND genres IS NOT NULL
GROUP BY GROUPING SETS (
    (genres), -- Performanta generala pe fiecare gen
    (CASE 
        WHEN average_rating >= 8.0 THEN 'HIT'
        WHEN average_rating >= 6.0 THEN 'MEDIU'
        ELSE 'FLOP'
    END), -- Performanta pe nivel de succes, indiferent de gen
    (genres, CASE 
        WHEN average_rating >= 8.0 THEN 'HIT'
        WHEN average_rating >= 6.0 THEN 'MEDIU'
        ELSE 'FLOP'
    END) -- Detalierea pe ambele dimensiuni (Ex: Cate 'HIT'-uri are genul Drama?)
)
HAVING COUNT(*) > 5; -- Filtru pentru relevanta (minim 5 productii pe segment)