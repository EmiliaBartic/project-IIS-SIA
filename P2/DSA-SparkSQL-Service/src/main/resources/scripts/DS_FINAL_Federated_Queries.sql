----------------------------------------------------------------------------------
--- DS_FINAL_Federated_Queries.sql - Rapoarte Analytics Inter-Sisteme
----------------------------------------------------------------------------------

-- ===============================================================================
-- RAPORT 1: PostgreSQL + CSV (Rating-uri si Personaje)
-- Scop: Aflam ce note (din Postgres) au primit filmele in functie personajele jucate (din CSV)
-- ===============================================================================
SELECT
    c.tconst AS ID_Film,
    c.category AS Rol_Echipaj,
    c.characters AS Nume_Personaj,
    r.averageRating AS Nota_Film,
    r.numVotes AS Numar_Voturi
FROM crew_csv_view_rest c
         INNER JOIN ratings_view_rest r ON c.tconst = r.tconst
WHERE r.numVotes > 1000 AND c.characters != 'N/A'
ORDER BY r.averageRating DESC
    LIMIT 50;


-- ===============================================================================
-- RAPORT 2: Oracle JPA + MongoDB (Filme si Date Biografice)
-- Scop: Imbogatirea datelor - aducem anul nasterii si profesia (Mongo)
--       pentru actorii din raportul principal de filme (Oracle).
-- ===============================================================================
SELECT
    o.primaryTitle AS Titlu_Film,
    o.genres AS Gen_Film,
    o.actorName AS Nume_Actor,
    m.birthYear AS An_Nastere_Actor,
    m.primaryProfession AS Profesie_Actor
FROM ultimate_report_view_rest o
         INNER JOIN actors_view_rest m ON o.actorName = m.primaryName
WHERE m.birthYear != 'N/A'
    LIMIT 50;


-- ===============================================================================
-- RAPORT 3: AGREGARE GLOBALA (Statistici pe categorii)
-- Scop: Calculam nota medie generala si numarul de participari pentru fiecare
--       categorie de echipa (actor, regizor, compozitor, etc.)
-- ===============================================================================
SELECT
    c.category AS Categorie_Echipaj,
    COUNT(c.tconst) AS Numar_Aparitii,
    ROUND(AVG(r.averageRating), 2) AS Nota_Medie_Globala
FROM crew_csv_view_rest c
         JOIN ratings_view_rest r ON c.tconst = r.tconst
GROUP BY c.category
ORDER BY Nota_Medie_Globala DESC;