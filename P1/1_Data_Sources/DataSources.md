# Data Sources - SIA09

This folder contains the data sources used in the **SIA09** project.

## Overview

The project uses multiple data sources and storage formats in order to support data integration and analysis:

- **Oracle SQL** – movie information
- **PostgreSQL** – movie ratings
- **CSV / MongoDB** – actor-related data
- **JSON** – directors and writers data

## Data Sources

### 1. MOVIES
- **Type:** SQL / Oracle
- **Description:** Main movie dataset imported from IMDb
- **Source:** IMDb title basics dataset  
- **Link:** https://developer.imdb.com/non-commercial-datasets/#titlebasicstsvgz

### 2. Ratings
- **Type:** SQL / PostgreSQL
- **Description:** Movie ratings dataset
- **Source:** IMDb title ratings dataset  
- **Link:** https://developer.imdb.com/non-commercial-datasets/#titleratingstsvgz

### 3. CREW
- **Type:** CSV / MongoDB
- **Description:** Actor-related data used for the non-relational part of the project
- **Link:** https://drive.google.com/file/d/1wIg5gq2f_t6e1s9ti17NTqll6VH4zjD6/view?usp=sharing

### 4. Names
- **Type:** JSON
- **Description:** Directors and writers data
- **Link:** https://drive.google.com/file/d/1H7UF6183MBXSKtsSgty-AdnSNMFr26xg/view?usp=sharing

## Notes

These sources are used as part of a heterogeneous data integration approach, combining relational and non-relational technologies for analytical processing.
