# Federated IMDb Data Integration System
## Project Overview

This project implements a **Federated Database System** designed to analyze IMDb data across three distinct storage layers.

Using **Oracle as the central integration hub**, the system unifies data from multiple heterogeneous sources:

1. **Oracle (Relational / CSV)**  
   Core movie metadata such as titles, release years, runtime and genres.

2. **PostgreSQL (Relational / ODBC)**  
   Movie ratings dataset containing more than **1.6 million rows**.

3. **Local File System (External File)**  
   A large **3GB crew dataset** containing directors and writers.

 ## System Architecture & Workflow

The integration process follows a structured **four-step pipeline** designed to ensure data consistency and system stability.

## System Architecture & Workflow

The integration process follows a structured **four-step pipeline** designed to ensure data consistency and system stability.

### 2. PostgreSQL Source Setup  
**Script:** `ratings_postgres_full_pipeline.sql`

**Purpose:**  
Prepares the remote ratings dataset stored in PostgreSQL.

**Process:**
- Creates schema `movies_pg`
- Creates role `movies_pg`
- Imports `ratings.csv` into PostgreSQL tables

**Note:**  
This dataset is accessed from Oracle using an **ODBC Gateway** and a **Database Link (PG)**.

### 2. PostgreSQL Source Setup  
**Script:** `ratings_postgres_full_pipeline.sql`

**Purpose:**  
Prepares the remote ratings dataset stored in PostgreSQL.

**Process:**
- Creates schema `movies_pg`
- Creates role `movies_pg`
- Imports `ratings.csv` into PostgreSQL tables

**Note:**  
This dataset is accessed from Oracle using an **ODBC Gateway** and a **Database Link (PG)**.

### 4. Triple Integration Layer  
**Script:** `FDBO_FULL_INTEGRATION.sql`

**Purpose:**  
Integrates the third data source: the large crew dataset.

**Process:**
- Creates an Oracle **External Table** (`CREW_EXT`)
- Reads data directly from the file:
  `C:\movies_data\crew4.csv`

**Important:**  
The crew dataset is not imported into the database to avoid storing a 3GB file internally.

### 4. Triple Integration Layer  
**Script:** `FDBO_FULL_INTEGRATION.sql`

**Purpose:**  
Integrates the third data source: the large crew dataset.

**Process:**
- Creates an Oracle **External Table** (`CREW_EXT`)
- Reads data directly from the file:
  `C:\movies_data\crew4.csv`

**Important:**  
The crew dataset is not imported into the database to avoid storing a 3GB file internally.

## Security Model

The system uses a **multi-user architecture** to separate responsibilities between data ownership, transformation logic and integration.

### Oracle Users (XEPDB1)

**SYS**  
Administrative superuser responsible for system-level configuration such as:
- container management
- directory creation
- user provisioning

**MOVIES**  
Source data owner responsible for:
- staging tables
- the final `MOVIES_CORE` dataset

**FDBO**  
Federated integration user responsible for:
- the PostgreSQL database link
- the external crew table
- all integration views

### PostgreSQL Roles

**postgres**  
Administrative role used during initial system setup.

**movies_pg**  
Remote data owner responsible for:
- the `movies_pg` schema
- ratings dataset

This user also provides the credentials used by Oracle's **Database Link (PG)**.
