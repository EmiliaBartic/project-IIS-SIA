----------------------------------------------------------------------------------
--- DS1_Ratings_SparkSQL_Views_from_REST.sql - Metoda Sigura (PostgreSQL)
----------------------------------------------------------------------------------

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
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) v;

-- 2. Testam tabelul virtual adus din Postgres
SELECT * FROM ratings_view_rest;