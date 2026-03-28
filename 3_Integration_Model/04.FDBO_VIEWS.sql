-- =====================================================================
-- File: FDBO_VIEWS.sql
-- Project: Integrated Movie Analysis System
-- Purpose: Define the Oracle integration layer through a set of views
--          that unify data from heterogeneous sources.
-- =====================================================================

-- ---------------------------------------------------------------------
-- SECTION 1: Local Oracle View (Movies Dataset)
-- ---------------------------------------------------------------------
-- This view exposes the relational Movies dataset stored in the Oracle
-- schema MOVIES. The underlying table MOVIES.MOVIES_CORE contains the
-- cleaned and structured movie metadata loaded from the IMDb dataset.
--
-- Creating this view allows the integration layer (FDBO schema) to
-- access the movies dataset without directly referencing the base table.
-- This abstraction simplifies query design and improves modularity.
CREATE OR REPLACE VIEW FDBO.MOVIES_V AS
SELECT
    tconst,
    primaryTitle,
    startYear,
    runtimeMinutes,
    genres
FROM MOVIES.MOVIES_CORE;


-- ---------------------------------------------------------------------
-- SECTION 2: Remote PostgreSQL View (Ratings Dataset)
-- ---------------------------------------------------------------------
-- This view provides access to the movie ratings dataset stored in a
-- PostgreSQL database. The connection between Oracle and PostgreSQL is
-- established through an Oracle Database Link (PG_LINK).
--
-- Oracle retrieves the remote data using Oracle Heterogeneous Services,
-- which allows cross-database queries between different database systems.
--
-- The remote table "movies_pg"."ratings" contains the rating metrics
-- associated with each movie, including:
--   - average_rating
--   - num_votes
--
-- These attributes enrich the local movie metadata with rating
-- information obtained from a different relational database system.
CREATE OR REPLACE VIEW FDBO.RATINGS_V AS
SELECT
    "tconst"         AS tconst,
    "average_rating" AS average_rating,
    "num_votes"      AS num_votes
FROM "movies_pg"."ratings"@PG_LINK;


-- ---------------------------------------------------------------------
-- SECTION 3: Federated Integration View
-- ---------------------------------------------------------------------
-- This view represents the core integration component of the system.
--
-- It performs a federated join between:
--
--   1. Oracle relational data
--        FDBO.MOVIES_V
--
--   2. PostgreSQL relational data
--        FDBO.RATINGS_V (accessed through the PG_LINK database link)
--
-- The integration key used to combine both datasets is:
--        tconst (IMDb unique movie identifier).
--
-- The resulting view provides a unified dataset that combines movie
-- metadata with rating statistics, enabling cross-source analytical
-- queries without requiring data replication.
CREATE OR REPLACE VIEW FDBO.MOVIES_RATINGS_V AS
SELECT
    m.tconst,
    m.primaryTitle,
    m.startYear,
    m.runtimeMinutes,
    m.genres,
    r.average_rating,
    r.num_votes
FROM FDBO.MOVIES_V m
JOIN FDBO.RATINGS_V r
  ON r.tconst = m.tconst;


-- ---------------------------------------------------------------------
-- SECTION 4: Validation Queries
-- ---------------------------------------------------------------------
-- The following queries validate that the integration layer has been
-- created successfully and that Oracle can access both the local and
-- remote data sources.

-- Verify the number of records in the local Oracle Movies dataset.
SELECT COUNT(*) FROM FDBO.MOVIES_V;

-- Verify the number of records retrieved from the PostgreSQL Ratings dataset.
SELECT COUNT(*) FROM FDBO.RATINGS_V;


-- ---------------------------------------------------------------------
-- SECTION 5: Final Verification of the Integrated View
-- ---------------------------------------------------------------------
-- This query previews a subset of the integrated dataset produced by
-- the federated join between Oracle and PostgreSQL sources.
SELECT *
FROM FDBO.MOVIES_RATINGS_V
FETCH FIRST 20 ROWS ONLY;
