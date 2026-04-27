----------------------------------------------------------------------------------
--- DS2_Movies_SparkSQL_Views_from_REST.sql
-- --------------------------------------------------------------------------------

-- ===============================================================================
-- PARTEA 1: Raportul Integrat (Ultimate Report)
-- ===============================================================================
-- 1. Cream View-ul Remote pentru Raportul Final (Virtualizare)
-- 1. Cream View-ul Remote pentru Rating-uri (Virtualizare)
CREATE OR REPLACE VIEW ratings_view_rest AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<tconst STRING, averageRating DOUBLE, numVotes INTEGER>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/RatingView'
                        ) data
         ) json_raw
)
-- Folosim inline() pentru a garanta ca tconst, averageRating si numVotes devin coloane separate
SELECT inline(json_view.array) FROM json_view;

-- 2. Testam
SELECT * FROM ultimate_report_view_rest;

-- ===============================================================================
-- PARTEA 2: Analitica OLAP (Movie Analytics)
-- ===============================================================================
-- 1. Cream View-ul Remote pentru Analitica
CREATE OR REPLACE VIEW movie_analytics_view_rest AS
WITH json_view AS (
    -- Extragem exact coloanele pe care le expune endpoint-ul de Analytics
    SELECT from_json(json_raw.data,
                     'ARRAY<STRUCT<genres STRING, totalMovies INTEGER, avgRating DOUBLE, maxRating DOUBLE>>') as array
    FROM (SELECT java_method('org.spark.service.rest.QueryRESTDataService', 'getRESTDataDocument',
                             'http://localhost:8091/DSA_SQL_JPAService/rest/movies/MovieAnalytics')
                     as data) json_raw
)
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- 2. Testam
SELECT * FROM movie_analytics_view_rest;