-- ===============================================================================
-- PARTEA 2: Analitica OLAP (Movie Analytics)
-- ===============================================================================
CREATE OR REPLACE VIEW movie_analytics_view_rest AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<genres STRING, actorProf STRING, volumProductii INTEGER, ratingMediuPiata DOUBLE, varfDeSucces DOUBLE>>') as array
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