----------------------------------------------------------------------------------
--- DS7_CSV_SparkSQL_Views_from_REST.sql - Integrare CSV Automata
----------------------------------------------------------------------------------

-- 1. Cream JSON View brut folosind serviciul REST
-- Includem datele de autentificare direct in URL (developer:iis)
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'CREW_CSV_JSON_VIEW',
               'http://developer:iis@localhost:8097/DSA-DOC-CSVService/rest/crew-data/CrewView');

-- Testam daca l-a creat corect
SELECT * FROM CREW_CSV_JSON_VIEW;

----------------------------------------------------------------------------------
-- 2. Cream SQL View-ul final desfacand lista
-- DROP VIEW crew_csv_view_rest;

CREATE OR REPLACE VIEW crew_csv_view_rest AS
SELECT v.*
FROM CREW_CSV_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Testam SQL View-ul final
SELECT * FROM crew_csv_view_rest;