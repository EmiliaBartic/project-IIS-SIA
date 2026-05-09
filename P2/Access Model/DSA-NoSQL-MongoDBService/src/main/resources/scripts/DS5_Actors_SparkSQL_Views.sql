----------------------------------------------------------------------------------
--- DS5_Actors_SparkSQL_Views.sql - Integrare MongoDB (Metoda Sigură)
----------------------------------------------------------------------------------

-- 1. Cream View-ul final folosind metoda de extragere brută + transformare
-- DROP VIEW actors_view_rest;
CREATE OR REPLACE VIEW actors_view_rest AS
WITH json_view AS (
    -- Aici definim exact ce date asteptam de la MongoDB (Schema)
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<primaryName: STRING, birthYear: STRING, deathYear: STRING, primaryProfession: STRING>>') as array
    FROM (
             -- Aducem textul JSON pur de la microserviciul MongoDB
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data/ActorView'
                        ) as data
         ) json_raw
)
-- Desfacem lista de actori in randuri individuale
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- 2. Testam rezultatul final!
SELECT * FROM actors_view_rest;