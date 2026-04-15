----------------------------------------------------------------------------------
--- DS7_CSV_SparkSQL_Views.sql - Integrare CSV (Crew Data)
----------------------------------------------------------------------------------

-- 1. Testam ca API-ul raspunde
SELECT java_method(
               'org.spark.service.rest.QueryRESTDataService',
               'getRESTDataDocument',
               'http://localhost:8097/DSA-DOC-CSVService/rest/crew-data/CrewView');

-- Obtinem schema sugerata de Spark
SELECT schema_of_json('[
	{"tconst":"tt0000001","category":"self","job":"\\N","characters":"[\"Self\"]"}
    ]');

----------------------------------------------------------------------------------
-- 2. Cream Remote View
-- DROP VIEW crew_csv_spark_view;

CREATE OR REPLACE VIEW crew_csv_spark_view AS
WITH json_view AS (
    SELECT from_json(json_raw.data,
                     'ARRAY<STRUCT<tconst: STRING, category: STRING, job: STRING, characters: STRING>>') array
    FROM (SELECT java_method('org.spark.service.rest.QueryRESTDataService', 'getRESTDataDocument',
                             'http://localhost:8097/DSA-DOC-CSVService/rest/crew-data/CrewView')
                     as data) json_raw
)
SELECT v.*
FROM json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Testam Remote View (Va afisa tabelul cu echipajul)
SELECT * FROM crew_csv_spark_view;