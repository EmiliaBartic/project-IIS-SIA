----------------------------------------------------------------------------------
--- DS5_Actors_SparkSQL_Views_from_REST.sql - Metoda cu Serviciu Automat
----------------------------------------------------------------------------------

-- 1. Cream View-ul JSON brut folosind clasa profesorului
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'ACTORS_JSON_VIEW',
               'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data/ActorView');

-- Testam daca l-a creat
SELECT * FROM ACTORS_JSON_VIEW;

-- 2. Cream Remote View-ul final (desfacem lista cu explode)
-- DROP VIEW actors_view_rest;
CREATE OR REPLACE VIEW actors_view_rest AS
select v.*
FROM ACTORS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Testam Remote View-ul final
select * FROM actors_view_rest;