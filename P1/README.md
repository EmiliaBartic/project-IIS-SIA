# Integrated Movie Analysis System

## Project Overview

This project implements an **Integrated Movie Analysis System** based on a federated data integration architecture.  
Its purpose is to combine movie-related data from multiple heterogeneous sources into a unified analytical environment using **Oracle** as the central integration platform.

The system integrates four distinct data sources:

- **Oracle (Local Relational Source)**  
  Stores the cleaned core movie metadata, including title identifiers, movie titles, release years, runtime, and genres.

- **PostgreSQL (Remote Relational Source)**  
  Stores the ratings dataset, including average ratings and vote counts. This source is later accessed from Oracle through a **Database Link**.

- **Local File System (External File Source)**  
  Stores the crew dataset (directors and writers) as a flat file, accessed in Oracle through an **External Table**.

- **MongoDB / REST API (Document-Oriented Source)**  
  Stores actor-related JSON documents that are fetched dynamically through HTTP requests and transformed into relational form inside Oracle.

The project demonstrates how structured, semi-structured, and external data can be integrated into a single environment for querying, reporting, and analysis without physically centralizing all source data into one database.

---

## System Architecture

The system uses **Oracle** as the central orchestration and integration engine.

### Source Layers

1. **Oracle Source Layer**
   - Contains the main movie metadata
   - Uses staging and cleaned tables
   - Acts as the primary local relational source

2. **PostgreSQL Source Layer**
   - Contains ratings data
   - Uses its own ETL pipeline with staging and cleaned tables
   - Is accessed remotely from Oracle using `PG_LINK`

3. **External File Layer**
   - Contains crew data in CSV format
   - Is exposed in Oracle through an external table without importing the file into the database

4. **MongoDB Document Layer**
   - Contains actor documents in JSON format
   - Is accessed through REST calls from Oracle
   - Is transformed into a flattened relational projection view

### Integration Layers

5. **Federated Relational Views**
   - Oracle integrates local movie data with remote PostgreSQL ratings through SQL views

6. **Extended Integration View**
   - Oracle adds crew data from the external table to build a more complete movie reporting layer

7. **Document Projection Layer**
   - MongoDB actor documents are converted into a relational structure for SQL-based querying

---

## Project Files and Workflow

The project is organized into several SQL scripts, each responsible for a specific stage of the pipeline.

---

### 1. `01.oracle_movies_full_pipeline.sql`

This script prepares the **Oracle source layer** and loads the main movie dataset.

#### Purpose
It creates the Oracle users, staging structures, cleaned tables, and core dataset used as the relational foundation of the project.

#### Main operations
- Switches to the `XEPDB1` pluggable database
- Creates the Oracle users:
  - `MOVIES`
  - `FDBO`
- Creates the staging table for raw movie import
- Creates the final cleaned movie table
- Loads movie data from CSV into staging
- Cleans placeholder values such as `\N`
- Transforms and inserts data into the final typed table
- Grants access from `MOVIES` to `FDBO`

#### Result
After this step, Oracle contains the cleaned core movie metadata used by the rest of the system.

---

### 2. `02.ratings_postgres_full_pipeline.sql`

This script prepares the **PostgreSQL ratings source**.

#### Purpose
It implements a complete ETL pipeline for the IMDb ratings dataset inside PostgreSQL.

#### Main operations
- Creates the PostgreSQL role `movies_pg` if it does not already exist
- Creates the schema `movies_pg`
- Creates a staging table `movies_pg.stg_ratings`
- Loads raw ratings data from `ratings.csv`
- Creates the final cleaned table `movies_pg.ratings`
- Transforms and inserts data from staging into the final table
- Runs verification and data-quality checks
- Grants usage and select permissions on the schema and tables

#### Dataset structure
The source ratings file contains:
- `tconst`
- `averageRating`
- `numVotes`

#### ETL design
The PostgreSQL implementation uses:
- a **staging table** with all columns as `TEXT`
- a **final cleaned table** with proper PostgreSQL data types

This staging-first approach improves transparency, debugging, and data quality control.

#### Result
After this step, PostgreSQL contains:
- `movies_pg.stg_ratings`
- `movies_pg.ratings`

The final `movies_pg.ratings` table becomes the remote relational source later used by Oracle through a Database Link.

---

### 3. `04.FDBO_VIEWS.sql`

This script creates the **Oracle federated integration views** that combine local and remote relational data.

#### Purpose
It defines the SQL views used by the `FDBO` integration user to expose Oracle and PostgreSQL data through a unified relational interface.

#### Main operations
- Creates `FDBO.MOVIES_V`
- Creates `FDBO.RATINGS_V`
- Creates `FDBO.MOVIES_RATINGS_V`

#### View roles
- **`MOVIES_V`**  
  Exposes the cleaned Oracle movie dataset

- **`RATINGS_V`**  
  Exposes the PostgreSQL ratings dataset through the database link `PG_LINK`

- **`MOVIES_RATINGS_V`**  
  Joins movie metadata with ratings using the shared IMDb identifier (`tconst`)

#### Result
After this step, Oracle can query both local and remote relational data as part of a single federated query model.

---

### 4. `03.FDBO_FULL_INTEGRATION.sql`

This script extends the Oracle integration layer with **external file data**.

#### Purpose
It integrates the crew dataset (directors and writers) into the Oracle reporting model through an external table.

#### Main operations
- Creates the Oracle directory object used to access the CSV file
- Grants directory access
- Creates the external table `FDBO.CREW_EXT`
- Reads crew data directly from a local CSV file
- Creates the integration view `FDBO.MOVIES_FULL_INTEGRATION_V`

#### Important design note
The crew dataset is not loaded into a normal Oracle table.  
Instead, it is accessed directly from the file system using Oracle External Table functionality.

This approach:
- avoids storing a large flat file inside the database
- keeps the integration lightweight
- allows direct SQL access to external data

#### Result
After this step, Oracle provides a more complete movie integration view that combines:
- movie metadata
- ratings
- crew information

---

### 5. `05.mongodb_integration_setup.sql`

This script prepares the **MongoDB document integration layer**.

#### Purpose
It enables Oracle to fetch JSON actor data from MongoDB through HTTP and transform it into a relational view.

#### Main operations
- Configures Oracle ACL permissions for outbound HTTP access
- Creates a function used to fetch MongoDB JSON documents
- Connects to a REST endpoint (for example through RESTHeart)
- Retrieves actor data in JSON format
- Parses and flattens document content into relational rows
- Creates the view `v_actors_mongodb_flat`

#### Integration strategy
MongoDB data is not stored as a classic relational table.  
Instead, Oracle retrieves JSON dynamically and converts it into a flattened relational projection suitable for SQL analysis.

This makes it possible to:
- query actor data relationally
- join or compare semi-structured data with relational data
- support analytical workflows across heterogeneous technologies

#### Result
After this step, MongoDB actor data becomes queryable from Oracle through a relational SQL view.

---

## Data Flow Summary

The data integration pipeline can be summarized as follows:

1. **Oracle movie metadata** is loaded, cleaned, and stored in `MOVIES_CORE`
2. **PostgreSQL ratings** are loaded into `movies_pg.ratings`
3. Oracle uses a **Database Link** to access PostgreSQL ratings remotely
4. Oracle creates **federated views** that combine movies and ratings
5. Oracle reads **crew data** from CSV through an external table
6. Oracle builds an extended integration view including crew attributes
7. Oracle fetches **MongoDB actor documents** through HTTP and exposes them through a flattened relational view

---

## Security Model

The system uses a multi-user architecture to separate responsibilities between administration, source ownership, and integration logic.

### Oracle Users

#### `SYS`
Administrative user responsible for:
- container and pluggable database management
- directory object creation
- grant management
- network ACL configuration
- general environment setup

#### `MOVIES`
Source data owner responsible for:
- staging tables
- final movie tables
- ownership of the Oracle movie source dataset

#### `FDBO`
Federated database integration user responsible for:
- integration views
- external table definitions
- federated reporting logic
- remote source access
- document integration logic

### PostgreSQL Roles

#### `postgres`
Administrative PostgreSQL role used during initial database setup.

#### `movies_pg`
Application role responsible for:
- ownership of schema `movies_pg`
- staging table `stg_ratings`
- final table `ratings`

This role provides the PostgreSQL-side source used later in Oracle federation.

### MongoDB / REST Access

MongoDB is accessed through a REST interface.  
Oracle uses outbound HTTP calls controlled by:
- ACL permissions
- controlled procedure execution
- Oracle network security configuration

---

## Technologies Used

- **Oracle Database**
- **PostgreSQL**
- **MongoDB**
- **Oracle Database Links**
- **Oracle External Tables**
- **Oracle ACL / UTL_HTTP**
- **REST API**
- **JSON parsing**
- **Federated relational views**
- **ETL pipeline with staging tables**

---

## Key Design Concepts

### 1. Federated Data Integration
The project does not rely on importing every source into a single physical database.  
Instead, it integrates multiple systems while preserving their native storage models.

### 2. Staging-Based ETL
Both Oracle and PostgreSQL use staging tables before loading cleaned final data.  
This improves traceability, validation, and debugging.

### 3. Heterogeneous Source Support
The system combines:
- relational data
- external flat-file data
- document-oriented JSON data

### 4. Logical Unification Through Views
Rather than forcing all data into one physical schema, Oracle uses views and integration logic to create a unified analytical layer.

### 5. Storage Efficiency
Large external files such as the crew dataset are not imported into internal tables, reducing database storage overhead.

---

## Main Database Objects

### Oracle Objects
- `MOVIES_CORE_STG`
- `MOVIES_CORE`
- `FDBO.MOVIES_V`
- `FDBO.RATINGS_V`
- `FDBO.MOVIES_RATINGS_V`
- `FDBO.CREW_EXT`
- `FDBO.MOVIES_FULL_INTEGRATION_V`
- `v_actors_mongodb_flat`

### PostgreSQL Objects
- `movies_pg.stg_ratings`
- `movies_pg.ratings`

---

## Analytical and Presentation Layers

This project includes a complete analytical and presentation stack that transforms integrated raw data into meaningful business intelligence, exposes the results through REST services, and delivers them in a user-friendly web interface.

### 1. ROLAP Analytical Model

The system moves from raw, integrated data to decision-support analytics through a dedicated **ROLAP (Relational OLAP)** layer.

#### Fact View: `V_ULTIMATE_MOVIE_REPORT`
At the core of the analytical layer is the `V_ULTIMATE_MOVIE_REPORT` view, designed as a **wide fact view** that consolidates data from all integrated sources into a single structure.  
This view acts as the **main source of truth** for analytical queries and reporting.

#### Multi-Dimensional Analysis
To support advanced analysis from multiple business perspectives, the project implements several SQL analytical operators:

- **ROLLUP**  
  Used for hierarchical aggregations, such as analyzing performance across levels like:
  - **Genre → Director → Movie**

- **CUBE**  
  Used for cross-dimensional analysis and matrix-style summaries, for example:
  - **Director × Actor quality matrix**

- **GROUPING SETS**  
  Used for custom aggregation scenarios, allowing targeted summaries for:
  - **MVP identification**
  - **risk profiling**
  - other specialized business views

This approach enables the platform to provide both detailed and aggregated insights, depending on the analytical need.

### 2. Web Services with ORDS

All analytical views have been exposed as RESTful services using **Oracle REST Data Services (ORDS)**.

This allows external systems, browser-based clients, or other applications to access the analytical results in **JSON format**, making the platform easier to integrate with modern web and reporting tools.

Main benefits:
- easy access to analytical data through HTTP endpoints
- JSON-based responses for interoperability
- seamless integration with dashboards or third-party applications

### 3. Oracle APEX Application

To make the integrated and analytical data easier to explore, a **low-code web application** was developed using **Oracle APEX**.

#### Interactive Reports
The application includes interactive reports built on top of the `MOVIES_FULL_INTEGRATION_V` view, allowing users to:
- filter data dynamically
- search and sort records
- explore the integrated dataset without writing SQL queries

#### Analytical Dashboards
The APEX application also provides visual dashboards based on the analytical views generated through `ROLLUP`, `CUBE`, and related SQL models.

The dashboards include:
- **Bar Charts**
- **Pie Charts**
- **Stacked Bar Charts**

These visualizations help identify:
- market trends
- top-performing categories
- quality outliers
- distribution patterns across the integrated movie dataset

---

Together, these layers form the final stage of the platform, where integrated data is transformed into accessible analytics, exposed through REST services, and presented through an interactive web application.


## Notes

- The PostgreSQL ratings source is expected to be reachable from Oracle through a configured database link such as `PG_LINK`.
- The crew dataset is accessed through an Oracle external table and remains outside the internal database storage.
- The MongoDB actor integration is implemented as a separate relational projection view.
- Depending on the current SQL implementation, MongoDB data may be queryable separately and may not yet be fully merged into the main full integration view.
- Script execution order matters and should follow the pipeline described in this README.

---

## Recommended Execution Order

Run the scripts in the following order:

1. `01.oracle_movies_full_pipeline.sql`
2. `02.ratings_postgres_full_pipeline.sql`
3. `04.FDBO_VIEWS.sql`
4. `03.FDBO_FULL_INTEGRATION.sql`
5. `05.mongodb_integration_setup.sql`

---

## Final Outcome

After all scripts are executed successfully, the project provides a federated analytical environment in which Oracle can:

- query local movie metadata
- access remote PostgreSQL ratings
- read crew data from external CSV files
- fetch actor data from MongoDB through REST
- expose these heterogeneous sources through a common SQL-oriented integration model

This project demonstrates a practical implementation of a **federated data integration system** for movie analytics using relational, semi-structured, and file-based sources.
