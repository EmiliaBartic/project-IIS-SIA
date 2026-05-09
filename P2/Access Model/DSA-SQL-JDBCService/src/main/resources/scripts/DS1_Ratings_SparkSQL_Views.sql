--------------------------------------------------------------------------------
--- DS1_Ratings_SparkSQL_Views_from_REST.sql - Metoda cu Serviciu Automat
--------------------------------------------------------------------------------

-- 1. Cream view-ul brut (JSON) folosind serviciul profesorului (include AUTENTIFICARE in URL)
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'RATINGS_JSON_VIEW',
               'http://developer:iis@localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/RatingView');

-- Testam daca l-a creat
SELECT * FROM RATINGS_JSON_VIEW;

--------------------------------------------------------------------------------
-- 2. Cream View-ul Final
-- DROP VIEW ratings_view_rest;

CREATE OR REPLACE VIEW ratings_view_rest AS
SELECT v.tconst, v.averageRating, v.numVotes
FROM RATINGS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

--------------------------------------------------------------------------------
-- 3. Testam View-ul Final
SELECT * FROM ratings_view_rest;