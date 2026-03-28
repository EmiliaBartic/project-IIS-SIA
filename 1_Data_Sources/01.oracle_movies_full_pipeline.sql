-- =====================================================================
-- File: oracle_movies_full_pipeline.sql
-- Project: Integrated Movie Analysis System
-- Source: IMDb Movies Core Dataset
-- Database: Oracle (XE / XEPDB1)
-- =====================================================================
--
-- OVERVIEW
-- ---------------------------------------------------------------------
-- This master script sets up the entire Oracle environment for the 
-- Integrated Movie Analysis System.
--
-- Steps performed:
--   1. Container switch (XEPDB1)
--   2. Integration User Creation (FDBO)
--   3. Source User Creation (MOVIES)
--   4. Staging and Final Table Creation
--   5. Data Transformation and Loading
--   6. Cross-User Permission Grants
--   7. Data Quality Verification
-- =====================================================================

-- =====================================================================
-- SECTION 1. SWITCH TO THE CORRECT CONTAINER
-- =====================================================================
SHOW CON_NAME;
ALTER SESSION SET CONTAINER = XEPDB1;
SHOW CON_NAME;

-- =====================================================================
-- SECTION 2. CREATE THE INTEGRATION USER (FDBO)
-- Run this section as SYS on XEPDB1.
-- =====================================================================
BEGIN
  EXECUTE IMMEDIATE 'DROP USER FDBO CASCADE';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE USER FDBO IDENTIFIED BY fdbo
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO FDBO;
GRANT CREATE VIEW TO FDBO;
GRANT CREATE DATABASE LINK TO FDBO;
GRANT CREATE ANY DIRECTORY TO FDBO;
GRANT EXECUTE ON UTL_HTTP TO FDBO;
GRANT EXECUTE ON DBMS_LOB TO FDBO;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO FDBO;

-- Allow network access for FDBO if needed for external integrations
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
      host       => '*',
      lower_port => NULL,
      upper_port => NULL,
      ace        => XS$ACE_TYPE(
                      privilege_list => XS$NAME_LIST('http'),
                      principal_name => 'FDBO',
                      principal_type => XS_ACL.PTYPE_DB
                    )
  );
END;
/
COMMIT;

-- =====================================================================
-- SECTION 3. CREATE THE SOURCE USER (MOVIES)
-- Run this section as SYS on XEPDB1.
-- =====================================================================
BEGIN
  EXECUTE IMMEDIATE 'DROP USER MOVIES CASCADE';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE USER MOVIES IDENTIFIED BY movies
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO MOVIES;

-- =====================================================================
-- SECTION 4. DATA STRUCTURES (TABLES)
-- Run this section as MOVIES user.
-- =====================================================================

-- 4.1 Create the STAGING table (for raw CSV import)
CREATE TABLE MOVIES.MOVIES_CORE_STG (
    tconst          VARCHAR2(20),
    primaryTitle    VARCHAR2(1000),
    startYear       VARCHAR2(20),
    runtimeMinutes  VARCHAR2(20),
    genres          VARCHAR2(500)
);

-- 4.2 Create the FINAL (cleaned/typed) table
CREATE TABLE MOVIES.MOVIES_CORE (
    tconst          VARCHAR2(12) NOT NULL,
    primaryTitle    VARCHAR2(1000),
    startYear       NUMBER(4),
    runtimeMinutes  NUMBER(5),
    genres          VARCHAR2(500),
    CONSTRAINT PK_MOVIES_CORE PRIMARY KEY (tconst)
);

-- =====================================================================
-- SECTION 5. IMPORT RAW CSV DATA
-- =====================================================================
-- IMPORTANT: Before continuing, use the Oracle SQL Developer Import Wizard 
-- to load your 'Movies.csv' into MOVIES.MOVIES_CORE_STG.
-- =====================================================================

-- =====================================================================
-- SECTION 6. TRANSFORM AND LOAD DATA
-- Run this section as MOVIES user after CSV import is complete.
-- =====================================================================

-- Clean strings, handle NULLs (\N), and convert types
INSERT INTO MOVIES.MOVIES_CORE (
    tconst,
    primaryTitle,
    startYear,
    runtimeMinutes,
    genres
)
SELECT
    TRIM(tconst) AS tconst,
    CASE WHEN TRIM(primaryTitle) = '\N' THEN NULL ELSE TRIM(primaryTitle) END,
    CASE WHEN TRIM(startYear) = '\N' THEN NULL ELSE TO_NUMBER(TRIM(startYear)) END,
    CASE WHEN TRIM(runtimeMinutes) = '\N' THEN NULL ELSE TO_NUMBER(TRIM(runtimeMinutes)) END,
    CASE WHEN TRIM(genres) = '\N' THEN NULL ELSE TRIM(genres) END
FROM MOVIES.MOVIES_CORE_STG
WHERE tconst IS NOT NULL;

COMMIT;

-- =====================================================================
-- SECTION 7. GRANT ACCESS TO THE INTEGRATION USER
-- =====================================================================
GRANT SELECT ON MOVIES.MOVIES_CORE TO FDBO;
GRANT SELECT ON MOVIES.MOVIES_CORE_STG TO FDBO;

-- =====================================================================
-- SECTION 8. VERIFICATION QUERIES
-- =====================================================================

-- Verify the migration from Staging to Final
SELECT 
    (SELECT COUNT(*) FROM MOVIES.MOVIES_CORE_STG) as stg_count,
    (SELECT COUNT(*) FROM MOVIES.MOVIES_CORE) as final_count
FROM DUAL;

-- Preview the cleaned data
SELECT * FROM MOVIES.MOVIES_CORE FETCH FIRST 20 ROWS ONLY;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
