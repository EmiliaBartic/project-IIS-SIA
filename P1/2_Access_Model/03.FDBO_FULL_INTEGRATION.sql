-- =====================================================================
-- File: FDBO_FULL_INTEGRATION.sql
-- Project: Integrated Movie Analysis System
-- Purpose: Implement the final integration layer that combines data
--          from multiple heterogeneous sources:
--          1. Oracle relational tables (Movies dataset)
--          2. PostgreSQL relational tables (Ratings dataset)
--          3. External CSV file (Crew dataset)
-- =====================================================================

-- ---------------------------------------------------------------------
-- SECTION 1: INFRASTRUCTURE (Run as SYS)
-- ---------------------------------------------------------------------
-- This section defines the physical directory inside the Oracle database
-- that maps to a folder on the operating system. Oracle uses DIRECTORY
-- objects to securely access files stored outside the database.
--
-- In this project, the directory contains the large crew dataset
-- (approximately 3GB) stored as a CSV file.
--
-- Granting privileges allows specific database users to access the
-- external files through Oracle SQL.
CREATE OR REPLACE DIRECTORY crew_dir AS 'C:\movies_data';

GRANT READ, WRITE ON DIRECTORY crew_dir TO FDBO;
GRANT READ, WRITE ON DIRECTORY crew_dir TO MOVIES;


-- ---------------------------------------------------------------------
-- SECTION 2: EXTERNAL TABLE (Run as FDBO)
-- ---------------------------------------------------------------------
-- This section creates an Oracle EXTERNAL TABLE that references the
-- crew dataset stored as a CSV file.
--
-- External tables allow Oracle to query large files directly from the
-- file system without importing them into the database storage.
--
-- This approach is particularly useful for very large datasets
-- (such as the 3GB crew dataset used in this project), because it avoids
-- unnecessary duplication of data inside the database.
--
-- Instead of loading the file into a relational table, Oracle reads the
-- file dynamically at query time.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FDBO.CREW_EXT';
EXCEPTION 
    WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE FDBO.CREW_EXT (
    tconst    VARCHAR2(20),
    directors VARCHAR2(4000),
    writers   VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY crew_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE

        -- NOLOGFILE and NOBADFILE prevent Oracle from generating
        -- log or error files on the operating system. This avoids
        -- permission issues on Windows environments.
        NOLOGFILE
        NOBADFILE

        -- The crew dataset is stored as a CSV file.
        -- If the fields appear misaligned during loading, the delimiter
        -- may need to be changed from ',' to '\t'.
        FIELDS TERMINATED BY ',' 

        -- Missing values in the CSV file are interpreted as NULL values.
        MISSING FIELD VALUES ARE NULL
        (
            tconst,
            directors,
            writers
        )
    )

    -- The external data source file.
    LOCATION ('crew4.csv')
)
REJECT LIMIT UNLIMITED;


-- ---------------------------------------------------------------------
-- SECTION 3: THE "MASTER" INTEGRATION VIEW
-- ---------------------------------------------------------------------
-- This view represents the final integration layer of the system.
--
-- It performs a federated join across three heterogeneous data sources:
--
--   1. Oracle relational data
--        FDBO.MOVIES_RATINGS_V
--        (Movies dataset joined with Ratings through PostgreSQL)
--
--   2. PostgreSQL relational data
--        accessed through an Oracle Database Link (PG_LINK)
--
--   3. External CSV file
--        accessed through the Oracle external table CREW_EXT
--
-- The common integration key used across all sources is:
--        tconst (IMDb title identifier)
--
-- This view provides a unified representation of movie information
-- enriched with ratings and crew metadata.
CREATE OR REPLACE VIEW FDBO.MOVIES_FULL_INTEGRATION_V AS
SELECT 
    m.tconst,
    m.primaryTitle,
    m.startYear,
    m.genres,
    m.average_rating,
    m.num_votes,
    c.directors,
    c.writers
FROM FDBO.MOVIES_RATINGS_V m
LEFT JOIN FDBO.CREW_EXT c 
    ON m.tconst = c.tconst;


-- ---------------------------------------------------------------------
-- SECTION 4: FINAL VERIFICATION QUERIES
-- ---------------------------------------------------------------------
-- These queries validate that the integration layer is functioning
-- correctly and that Oracle can successfully retrieve data from all
-- three heterogeneous sources.

-- Preview several movies that contain both rating information and crew data.
SELECT *
FROM FDBO.MOVIES_FULL_INTEGRATION_V 
WHERE directors IS NOT NULL
FETCH FIRST 10 ROWS ONLY;

-- Optional validation query:
-- Count the total number of integrated records.
-- Because the crew dataset is accessed through an external table,
-- this query may take longer to execute.
-- SELECT COUNT(*) FROM FDBO.MOVIES_FULL_INTEGRATION_V;
SELECT 
    primaryTitle AS "Movie Title", 
    startYear AS "Year", 
    average_rating AS "Rating", 
    num_votes AS "Total Votes", 
    directors AS "Director IDs"
FROM FDBO.MOVIES_FULL_INTEGRATION_V
WHERE 
    -- 1. Filters based on Oracle data (Years)
    startYear BETWEEN 1990 AND 2024 
    
    -- 2. Filters based on PostgreSQL data (Popularity/Rating)
    AND num_votes > 100000 
    AND average_rating > 8.0
    
    -- 3. Filters based on Local File data (Ensures we have crew info)
    AND directors IS NOT NULL
ORDER BY average_rating DESC;
