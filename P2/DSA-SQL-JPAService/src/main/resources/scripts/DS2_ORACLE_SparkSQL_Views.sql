----------------------------------------------------------------------------------
--- DS2_Movies_SparkSQL_Views.sql - Integrare Oracle JPA
----------------------------------------------------------------------------------

-- 1. Testam conexiunea API pentru Raportul Final
SELECT java_method(
               'org.spark.service.rest.QueryRESTDataService',
               'getRESTDataDocument',
               'http://localhost:8091/DSA_SQL_JPAService/rest/movies/UltimateReport');

-- 2. Cream View-ul Remote pentru Raportul Final (Virtualizare)
CREATE OR REPLACE VIEW ultimate_report_spark_view AS
WITH json_view AS (
    SELECT from_json(json_raw.data,
                     'ARRAY<STRUCT<primaryTitle STRING, genres STRING, averageRating DOUBLE, directors STRING, actorName STRING>>') as array
    FROM (SELECT java_method('org.spark.service.rest.QueryRESTDataService', 'getRESTDataDocument',
                             'http://localhost:8091/DSA_SQL_JPAService/rest/movies/UltimateReport')
                     as data) json_raw
)
SELECT inline(json_view.array) FROM json_view;

-- 3. Testam tabelul virtual
SELECT * FROM ultimate_report_spark_view;