----------------------------------------------------------------------------------
--- DS_FINAL_OLAP_Movies.sql
----------------------------------------------------------------------------------

-- ===============================================================================
-- 1. PREGATIRE DIMENSIUNI (Dimensions)
-- ===============================================================================

DROP VIEW IF EXISTS OLAP_DIM_MOVIES_ACTORS;
CREATE OR REPLACE VIEW OLAP_DIM_MOVIES_ACTORS AS
SELECT
    o.primaryTitle AS movieTitle,
    o.genres AS movieGenres,
    m.primaryName AS actorName,
    m.primaryProfession AS actorProfession,
    o.averageRating AS avgRating
FROM ultimate_report_view_rest o
         INNER JOIN actors_view_rest m ON o.actorName = m.primaryName;


DROP VIEW IF EXISTS OLAP_DIM_CREW_VOTES;
CREATE OR REPLACE VIEW OLAP_DIM_CREW_VOTES AS
SELECT
    c.tconst AS movieId,
    c.category AS jobCategory,
    r.averageRating,
    r.numVotes,
    CASE
        WHEN r.averageRating >= 8.0 THEN 'Excelent'
        WHEN r.averageRating >= 6.0 AND r.averageRating < 8.0 THEN 'Bun'
        ELSE 'Slab'
        END AS ratingCategory
FROM crew_csv_view_rest c
         INNER JOIN ratings_view_rest r ON c.tconst = r.tconst;


-- ===============================================================================
-- 2. VEDERI ANALITICE OLAP (ROLLUP & CUBE)
-- ===============================================================================

DROP VIEW IF EXISTS OLAP_VIEW_ACTORS_CUBE;
CREATE OR REPLACE VIEW OLAP_VIEW_ACTORS_CUBE AS
SELECT
    COALESCE(movieGenres, '{Orice Gen}') AS movieGenres,
    COALESCE(actorProfession, '{Orice Profesie}') AS actorProfession,
    ROUND(AVG(avgRating), 2) AS ratingMediu,
    COUNT(movieTitle) AS numarFilme
FROM OLAP_DIM_MOVIES_ACTORS
GROUP BY CUBE (movieGenres, actorProfession)
ORDER BY 1 DESC, 2 DESC;


DROP VIEW IF EXISTS OLAP_VIEW_VOTES_ROLLUP;
CREATE OR REPLACE VIEW OLAP_VIEW_VOTES_ROLLUP AS
SELECT
    CASE WHEN jobCategory IS NULL THEN '{Total General}' ELSE jobCategory END AS jobCategory,
    CASE
        WHEN jobCategory IS NULL THEN ' '
        WHEN ratingCategory IS NULL THEN 'Subtotal Categorie ' || jobCategory
        ELSE ratingCategory
        END AS ratingCategory,
    SUM(numVotes) AS totalVotes
FROM OLAP_DIM_CREW_VOTES
GROUP BY ROLLUP (jobCategory, ratingCategory)
ORDER BY 1, 2;

-- TESTAM REZULTATELE FINALE:
SELECT * FROM OLAP_VIEW_ACTORS_CUBE;
SELECT * FROM OLAP_VIEW_VOTES_ROLLUP;