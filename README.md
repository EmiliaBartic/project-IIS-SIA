# Arhitectura de Federație a Datelor (Data Federation) cu Apache Spark

Acest repository conține Partea a 2-a (P2) a proiectului, concentrându-se pe integrarea, virtualizarea și expunerea surselor de date eterogene printr-o arhitectură completă pe 3 niveluri (Access, Integration, Web) folosind microservicii Spring Boot și Apache Spark.

## Descrierea Proiectului
Sistemul propune o paradigmă modernă de Virtualizare a Datelor, eliminând necesitatea proceselor tradiționale și costisitoare de tip ETL (Extract, Transform, Load).

Baza arhitecturii este principiul Persistenței Poliglote (Polyglot Persistence). Sistemul nu forțează o schemă unică, ci permite executarea de interogări SQL complexe (JOIN-uri federate) direct peste baze de date SQL, NoSQL și fișiere plate, în timp real, direct în memoria RAM, aplicând conceptul de Schema-on-Read.

---

## Arhitectura pe 3 Niveluri (Microservicii)

Sistemul respectă principiul de Loose Coupling (Cuplaj Slab) și este decuplat în 6 microservicii independente, structurate logic astfel:

### NIVELUL 1: Access Model (Extragerea Datelor Brute)
1. **`DSA-SQL-JPAService` (Port: 8091)**
   - **Baza de date:** Oracle
   - **Tehnologie:** Spring Data JPA / Hibernate
   - **Rol:** Oferă date complexe despre filme (Ultimate Report).
2. **`DSA-SQL-JDBCService` (Port: 8090)**
   - **Baza de date:** PostgreSQL
   - **Tehnologie:** JDBC Native
   - **Rol:** Oferă rating-urile filmelor cu viteză maximă de citire, evitând overhead-ul unui ORM.
3. **`DSA-NoSQL-MongoDBService` (Port: 8093)**
   - **Baza de date:** MongoDB
   - **Tehnologie:** Spring Data MongoDB
   - **Rol:** Gestionează colecțiile de actori (documente JSON nestructurate, biografii).
4. **`DSA-DOC-CSVService` (Port: 8097)**
   - **Sursa:** Fișier local `crew.csv`
   - **Tehnologie:** Apache Commons CSV
   - **Rol:** Virtualizează fișiere plate, implementând un management strict al memoriei pentru a preveni erori de tip `OutOfMemory`.

### NIVELUL 2: Integration and Analytical Model (Procesare Big Data)
5. **`DSA-SparkSQL-Service` (Port: 10000 / 9990)**
   - **Tehnologie:** Apache Spark SQL, Hive Thrift Server
   - **Rol:** "Creierul" central. Agregă datele din Access Model prin HTTP REST, transformă JSON în DataFrames și execută:
     - *Interogări Federate:* JOIN-uri cross-database (ex: PostgreSQL + CSV).
     - *Analitică Multidimensională (OLAP):* Calculează cuburi de date folosind funcții avansate (`CUBE`, `ROLLUP`) pentru rapoarte ierarhice.

### NIVELUL 3: Web Model (Expunerea Datelor)
6. **`DSA-WEB-RESTService` (Port: 8096)**
   - **Tehnologie:** Spring Boot Web, Hive-JDBC Driver
   - **Rol:** Acționează ca un translator. Se conectează la Spark, extrage rezultatele rapoartelor OLAP și le expune ca endpoint-uri REST (JSON), fiind pregătit pentru a fi consumat de orice aplicație Frontend (ex: Dashboard-uri cu grafice).

---

## Instrucțiuni de Rulare

### 1. Pre-rechizite
- Java JDK 17+
- Maven
- Bazele de date (Oracle, PostgreSQL, MongoDB) active și populate.

### 2. Ordinea de Pornire
Pentru ca federația să funcționeze corect, serviciile trebuie pornite "de jos în sus":
1. Porniți cele 4 surse din Nivelul 1 (`JPAService`, `JDBCService`, `MongoDBService`, `CSVService`).
2. Porniți motorul de virtualizare din Nivelul 2 (`SparkSQL-Service`).
3. Porniți interfața REST din Nivelul 3 (`SpringBootWEBService`).

### 3. Autentificare și Securitate (Basic Auth)
Sistemul implementează măsuri de protecție la nivel de endpoint (Spring Security). Accesarea link-urilor Web necesită credențiale:
- **User:** `developer`
- **Parola:** `iis`

---

## Endpoint-uri Analitice Expuse (Web Model)
Prin accesarea `http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/...` se pot vizualiza rezultatele finale în format JSON:
- `/RAW_ORACLE_REPORT` & `/RAW_POSTGRES_RATINGS` (Date Brute)
- `/DIM_MOVIES_ACTORS` & `/DIM_CREW_VOTES` (Dimensiuni Integrate Federate)
- `/ANALYTICS_CUBE` (Analiză încrucișată Genuri vs. Profesii Actori)
- `/ANALYTICS_ROLLUP` (Analiză ierarhică subtotaluri Voturi pe Categorii Echipaj)

---

## Testare Automată (CI/CD Ready)
Arhitectura este validată printr-o suită extinsă de teste JUnit:
- **Sanity Checks:** Verificarea stării serviciilor (Ping HTTP 200 OK).
- **End-to-End Testing (E2E):** Clasa `TestSpringBootWEBService` validează automat întregul flux de date, simulând un client care preia JSON-urile din Web Model, forțând astfel Spark să interogheze în timp real bazele de date fizice.
- **Security Validation:** Autentificare Basic Auth testată programatic și prevenirea erorilor de URL/URI.
