-- =====================================================================
-- File: ratings_postgres_full_pipeline.sql
-- Project: Integrated Movie Analysis System
-- Source: IMDb Ratings Dataset
-- Database: PostgreSQL
-- =====================================================================
--
-- OVERVIEW
-- ---------------------------------------------------------------------
-- This script combines all PostgreSQL steps for the IMDb Ratings dataset
-- into a single executable file.
--
-- The goal of this script is to implement a simple ETL pipeline:
--
--   1. Create a dedicated PostgreSQL role and schema
--   2. Create a staging table for raw CSV import
--   3. Load the raw CSV file into the staging table
--   4. Create the final cleaned table
--   5. Transform and insert data from staging into the final table
--   6. Run verification queries
--
-- WHY THIS STRUCTURE IS USEFUL
-- ---------------------------------------------------------------------
-- Using a staging table is a common data integration practice.
-- It allows us to:
--   - load the raw source file without strict typing constraints
--   - inspect the imported data before transformation
--   - separate raw data loading from data cleaning
--   - keep the ETL process more transparent and easier to debug
--
-- DATASET STRUCTURE
-- ---------------------------------------------------------------------
-- The source CSV file contains the following columns:
--   - tconst          : IMDb title identifier
--   - averageRating   : average user rating
--   - numVotes        : number of votes
--
-- In the PostgreSQL implementation:
--   - the staging table stores all values as TEXT
--   - the final table stores values using proper PostgreSQL data types
-- =====================================================================
-- SECTION 1. CREATE ROLE AND SCHEMA
-- =====================================================================

DO $$
BEGIN
    -- Create the application role only if it does not already exist.
    -- This avoids an error when the script is executed multiple times.
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'movies_pg'
    ) THEN
        CREATE ROLE movies_pg WITH
            LOGIN
            NOSUPERUSER
            NOCREATEDB
            NOCREATEROLE
            INHERIT
            NOREPLICATION
            CONNECTION LIMIT -1
            PASSWORD 'movies_pg';
    END IF;
END $$;

-- Create the dedicated schema used by this dataset.
-- All tables related to the PostgreSQL ratings source will be stored here.
CREATE SCHEMA IF NOT EXISTS movies_pg AUTHORIZATION movies_pg;

-- Verification query: confirm that the schema exists and identify its owner.
SELECT
    n.nspname AS schema_name,
    r.rolname AS owner_name
FROM pg_namespace n
JOIN pg_roles r
    ON r.oid = n.nspowner
WHERE n.nspname = 'movies_pg';

-- =====================================================================
-- SECTION 2. CREATE STAGING TABLE
-- =====================================================================

-- Drop the staging table if it already exists.
-- This keeps the script repeatable and avoids conflicts from prior runs.
DROP TABLE IF EXISTS movies_pg.stg_ratings;

-- Create the staging table for raw CSV import.
-- All columns are intentionally defined as TEXT because the source file
-- should be loaded first without enforcing strict data type validation.
CREATE TABLE movies_pg.stg_ratings (
    tconst          TEXT,
    average_rating  TEXT,
    num_votes       TEXT
);

-- Verification query: confirm that the staging table exists.
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'movies_pg'
  AND table_name = 'stg_ratings';

-- =====================================================================
-- SECTION 3. LOAD RAW CSV DATA INTO STAGING
-- =====================================================================

-- The COPY command loads raw CSV data into the staging table.
-- Update the file path below if needed.
--
-- If you use pgAdmin and the server cannot access this file directly,
-- you can:
--   - use the Import/Export wizard in pgAdmin
--   - or use \copy in psql
--
COPY movies_pg.stg_ratings (tconst, average_rating, num_votes)
FROM 'C:/Users/emili/OneDrive/Desktop/proiect-SII-ORACLE/bd/ratings.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

-- Verification query: check how many rows were loaded into staging.
SELECT COUNT(*) AS staging_row_count
FROM movies_pg.stg_ratings;

-- Preview a few raw rows from the staging table.
SELECT *
FROM movies_pg.stg_ratings
ORDER BY tconst
LIMIT 20;

-- =====================================================================
-- SECTION 4. CREATE FINAL CLEANED TABLE
-- =====================================================================

-- Drop the final table if it already exists.
-- This ensures the script can be rerun cleanly during development.
DROP TABLE IF EXISTS movies_pg.ratings;

-- Create the final cleaned table using appropriate PostgreSQL types.
-- Data type choices:
--   - tconst          : VARCHAR(12), because IMDb identifiers are short
--   - average_rating  : NUMERIC(3,1), because values look like 5.7, 8.2
--   - num_votes       : INTEGER, because vote counts are whole numbers
CREATE TABLE movies_pg.ratings (
    tconst          VARCHAR(12) PRIMARY KEY,
    average_rating  NUMERIC(3,1) NOT NULL,
    num_votes       INTEGER NOT NULL
);

-- Verification query: inspect the final table metadata.
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'movies_pg'
  AND table_name = 'ratings'
ORDER BY ordinal_position;

-- =====================================================================
-- SECTION 5. TRANSFORM AND LOAD DATA INTO FINAL TABLE
-- =====================================================================

-- Insert transformed rows from staging into the final table.
-- The TRIM() calls are used as a small cleanup step.
-- The CAST() operations convert raw text values into their final types.
INSERT INTO movies_pg.ratings (
    tconst,
    average_rating,
    num_votes
)
SELECT
    TRIM(tconst)                                AS tconst,
    CAST(TRIM(average_rating) AS NUMERIC(3,1))  AS average_rating,
    CAST(TRIM(num_votes) AS INTEGER)            AS num_votes
FROM movies_pg.stg_ratings
WHERE tconst IS NOT NULL
  AND average_rating IS NOT NULL
  AND num_votes IS NOT NULL;

-- =====================================================================
-- SECTION 6. VERIFICATION AND DATA QUALITY CHECKS
-- =====================================================================

-- Verify total number of rows in the final table.
SELECT COUNT(*) AS final_row_count
FROM movies_pg.ratings;

-- Preview the first 20 rows ordered by IMDb identifier.
SELECT *
FROM movies_pg.ratings
ORDER BY tconst
LIMIT 20;

-- Optional data quality check:
-- find rows that would have been filtered out because of NULL values.
SELECT *
FROM movies_pg.stg_ratings
WHERE tconst IS NULL
   OR average_rating IS NULL
   OR num_votes IS NULL;

-- Optional analytical query:
-- show the titles with the highest number of votes.
SELECT *
FROM movies_pg.ratings
ORDER BY num_votes DESC
LIMIT 20;

-- Optional analytical query:
-- show the highest-rated titles among items with at least 1000 votes.
SELECT *
FROM movies_pg.ratings
WHERE num_votes >= 1000
ORDER BY average_rating DESC, num_votes DESC
LIMIT 20;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
-- After running this file successfully, the PostgreSQL source side of
-- the project will contain:
--
--   Schema:
--     movies_pg
--
--   Tables:
--     movies_pg.stg_ratings   -> raw imported data
--     movies_pg.ratings       -> cleaned final dataset
--
-- This final table will later be used as the PostgreSQL relational
-- source for integration with:
--   - Oracle Movies source
--   - JSON Crew source
-- within the larger integrated movie analysis project.
-- =====================================================================

-- 1. Give the user permission to "see" the schema
GRANT USAGE ON SCHEMA movies_pg TO movies_pg;

-- 2. Give the user permission to read the ratings table
GRANT SELECT ON movies_pg.ratings TO movies_pg;

-- 3. (Optional but recommended) Give permission for any other tables in that schema
GRANT SELECT ON ALL TABLES IN SCHEMA movies_pg TO movies_pg;

