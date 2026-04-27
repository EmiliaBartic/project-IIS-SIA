----------------------------------------------------------------------------------
--- DS2_Movies_SparkSQL_Views_from_REST.sql - Corectat
----------------------------------------------------------------------------------

-- ===============================================================================
-- PARTEA 1: Raportul Integrat (Ultimate Report)
-- ===============================================================================
CREATE OR REPLACE VIEW ultimate_report_view_rest AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<primaryTitle STRING, genres STRING, averageRating DOUBLE, directors STRING, actorName STRING>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8091/DSA_SQL_JPAService/rest/movies/UltimateReport'
                        ) data
         ) json_raw
)
SELECT inline(json_view.array) FROM json_view;

-- Testam Raportul Integrat
SELECT * FROM ultimate_report_view_rest;

-- ===============================================================================
-- PARTEA 2: Analitica OLAP (Movie Analytics)
-- ===============================================================================
CREATE OR REPLACE VIEW movie_analytics_view_rest AS
WITH json_view AS (
    -- AICI E CHEIA: Numele din STRUCT trebuie sa fie EXACT ca in browser!
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<genres STRING, totalMovies INTEGER, avgRating DOUBLE, maxRating DOUBLE>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8091/DSA_SQL_JPAService/rest/movies/MovieAnalytics'
                        ) data
         ) json_raw
)
SELECT inline(json_view.array) FROM json_view;

-- Testam Analytics
SELECT * FROM movie_analytics_view_rest;