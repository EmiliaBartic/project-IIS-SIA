----------------------------------------------------------------------------------
--- DS5_Actors_SparkSQL_Views_from_REST.sql - Metoda Sigura (Fara Parametri)
----------------------------------------------------------------------------------

-- ===============================================================================
-- 1. VIEW PENTRU DEPARTAMENTE
-- ===============================================================================
CREATE OR REPLACE VIEW departaments_view AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<idDepartament STRING, departamentName STRING, departamentCode STRING, countryName STRING, cities ARRAY<STRUCT<idCity STRING, cityName STRING>>>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/DepartamentView'
                        ) as data
         ) json_raw
)
SELECT v.idDepartament, v.departamentName, v.departamentCode, v.countryName
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- Testam View-ul de Departamente
SELECT * FROM departaments_view;


-- ===============================================================================
-- 2. VIEW PENTRU ORASE (CITIES)
-- ===============================================================================
CREATE OR REPLACE VIEW cities_view AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<idCity STRING, cityName STRING, countryName STRING>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/CityView'
                        ) as data
         ) json_raw
)
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- Testam View-ul de Orase
SELECT * FROM cities_view;


-- ===============================================================================
-- 3. VIEW COMBINAT: DEPARTAMENTE + ORASELE LOR (Doar ID-uri)
-- ===============================================================================
CREATE OR REPLACE VIEW departaments_cities_view AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<idDepartament STRING, cities ARRAY<STRUCT<idCity STRING>>>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/DepartamentView'
                        ) as data
         ) json_raw
)
SELECT v.idDepartament, explode(v.cities.idCity) as idCity
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- Testam
SELECT * FROM departaments_cities_view;


-- ===============================================================================
-- 4. VIEW COMBINAT COMPLET (Inline)
-- ===============================================================================
CREATE OR REPLACE VIEW departaments_cities_view_all AS
WITH json_view AS (
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<idDepartament STRING, departamentName STRING, departamentCode STRING, countryName STRING, cities ARRAY<STRUCT<idCity STRING, cityName STRING>>>>') as array
    FROM (
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/DepartamentView'
                        ) as data
         ) json_raw
)
SELECT v.idDepartament, v.departamentName, v.departamentCode, v.countryName, inline(v.cities)
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- Testam View-ul final complex
SELECT * FROM departaments_cities_view_all;