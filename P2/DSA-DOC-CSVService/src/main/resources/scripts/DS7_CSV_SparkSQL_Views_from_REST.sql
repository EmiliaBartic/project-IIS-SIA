----------------------------------------------------------------------------------
--- DS7_CSV_SparkSQL_Views_from_REST.sql - Integrare CSV (Metoda Sigura)
----------------------------------------------------------------------------------

-- 1. Ocolim createJSONViewFromREST si cream direct View-ul final folosind extragerea bruta
CREATE OR REPLACE VIEW crew_csv_view_rest AS
WITH json_view AS (
    -- Transformam textul intr-un Array de Structuri (Tabel)
    SELECT from_json(json_raw.data, 'ARRAY<STRUCT<tconst: STRING, category: STRING, job: STRING, characters: STRING>>') as array
    FROM (
             -- Aducem textul JSON pur de la microserviciul CSV
             SELECT java_method(
                            'org.spark.service.rest.QueryRESTDataService',
                            'getRESTDataDocument',
                            'http://localhost:8097/DSA-DOC-CSVService/rest/crew-data/CrewView'
                        ) as data
         ) json_raw
)
-- Desfacem array-ul in randuri individuale
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- 2. Testam rezultatul final
SELECT * FROM crew_csv_view_rest;