----------------------------------------------------------------------------------
--- DS2_Movies_SparkSQL_Views_from_REST.sql - Metoda cu Serviciu Automat
----------------------------------------------------------------------------------

-- ===============================================================================
-- PARTEA 1: Raportul Integrat (Ultimate Report)
-- ===============================================================================
-- 1. Cream JSON View-ul
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'ULTIMATE_REPORT_JSON_VIEW',
               'http://developer:iis@localhost:8091/DSA_SQL_JPAService/rest/movies/UltimateReport');

-- 2. Cream SQL View-ul
CREATE OR REPLACE VIEW ultimate_report_view_rest AS
SELECT v.*
FROM ULTIMATE_REPORT_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Testam
SELECT * FROM ultimate_report_view_rest;

-- ===============================================================================
-- PARTEA 2: Analitica OLAP (Movie Analytics)
-- ===============================================================================
-- 1. Cream JSON View-ul
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'MOVIE_ANALYTICS_JSON_VIEW',
               'http://developer:iis@localhost:8091/DSA_SQL_JPAService/rest/movies/MovieAnalytics');

-- 2. Cream SQL View-ul
CREATE OR REPLACE VIEW movie_analytics_view_rest AS
SELECT v.*
FROM MOVIE_ANALYTICS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Testam
SELECT * FROM movie_analytics_view_rest;