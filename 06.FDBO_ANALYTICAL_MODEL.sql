CREATE OR REPLACE VIEW FDBO.V_ULTIMATE_MOVIE_REPORT AS
SELECT 
    m.tconst,
    m.primaryTitle,
    m.genres,
    r.average_rating,
    c.directors,           -- Din CSV (External Table)
    a.nume AS actor_name,  -- Din MongoDB
    a.profesie AS actor_prof
FROM (SELECT * FROM FDBO.MOVIES_V WHERE ROWNUM <= 10000) m -- LIMITĂ MICĂ PENTRU VITEZĂ
JOIN FDBO.RATINGS_V r ON m.tconst = r.tconst -- Join Oracle + Postgres
LEFT JOIN FDBO.CREW_EXT c ON m.tconst = c.tconst -- Join cu CSV
LEFT JOIN v_actors_mongodb_flat a ON a.movie_id = m.tconst; -- Join cu Mongo

SELECT * FROM FDBO.V_ULTIMATE_MOVIE_REPORT WHERE ROWNUM <= 10;


SELECT 
    genres, 
    directors, 
    ROUND(AVG(average_rating), 2) as rating_mediu,
    COUNT(*) as nr_filme
FROM FDBO.V_ULTIMATE_MOVIE_REPORT
GROUP BY ROLLUP(genres, directors);

