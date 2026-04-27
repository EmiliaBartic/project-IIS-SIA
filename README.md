# Arhitectura de Federatie a Datelor (Data Federation) cu Apache Spark

Acest repository contine Partea a 2-a (P2) a proiectului, concentrandu-se pe integrarea si virtualizarea surselor de date eterogene printr-o arhitectura de tip microservicii (Spring Boot) si Apache Spark.

## Descrierea Proiectului
Sistemul propune o paradigma moderna de Virtualizare a Datelor, eliminand necesitatea proceselor traditionale si costisitoare de tip ETL (Extract, Transform, Load).

Baza arhitecturii este principiul Persistentei Poliglote (Polyglot Persistence). Sistemul nu forteaza o schema unica, ci permite executarea de interogari SQL complexe (JOIN-uri federate) direct peste baze de date SQL, NoSQL si fisiere plate, in timp real, direct in memoria RAM, aplicand conceptul de Schema-on-Read.

---

## Componentele Arhitecturii (Microservicii)

Sistemul respecta principiul de Loose Coupling (Cuplaj Slab) si este decuplat in 5 microservicii independente:

### 1. `DSA-SparkSQL-Service` (Nivelul de Virtualizare)
- **Port:** `9990`
- **Tehnologie:** Apache Spark SQL, Thrift Server
- **Rol:** Nodul central care agrega datele din celelalte servicii prin HTTP REST, transforma raspunsurile JSON in tabele virtuale (DataFrames) si executa interogarile globale.

### 2. `DSA-SQL-JPAService` (Sursa Principala / Analitica)
- **Port:** `8091`
- **Baza de date:** Oracle
- **Tehnologie:** Spring Data JPA / Hibernate
- **Rol:** Ofera date complexe despre filme si rapoarte integrate analitice (OLAP).

### 3. `DSA-SQL-JDBCService` (Sursa de Performanta)
- **Port:** `8090`
- **Baza de date:** PostgreSQL
- **Tehnologie:** JDBC Native
- **Rol:** Ofera rating-urile filmelor. Utilizeaza acces low-level (JDBC) pentru a asigura o viteza maxima de citire, evitand overhead-ul unui ORM.

### 4. `DSA-NoSQL-MongoDBService` (Sursa Flexibila)
- **Port:** `8093`
- **Baza de date:** MongoDB
- **Tehnologie:** Spring Data MongoDB
- **Rol:** Gestioneaza colectiile de actori (date orientate pe documente, JSON nestructurat).

### 5. `DSA-DOC-CSVService` (Sursa Fisier / Document)
- **Port:** `8097`
- **Sursa:** Fisier local `crew.csv` (3.45 GB)
- **Tehnologie:** Apache Commons CSV
- **Rol:** Demonstreaza virtualizarea fisierelor plate. Implementeaza un mecanism de management al memoriei (limitare la 500 de randuri) pentru a preveni erorile de tip `OutOfMemory` la procesarea datelor masive.

---

## Instructiuni de Rulare

### 1. Pre-rechizite
- Java JDK 17+
- Maven
- Bazele de date (Oracle, PostgreSQL, MongoDB) active si populate cu datele initiale
- Fisierul `crew.csv` trebuie sa fie prezent in locatia fizica mapata in fisierul `application.properties` al serviciului CSV

### 2. Ordinea de Pornire
Pentru ca federatia sa functioneze corect, serviciile trebuie pornite astfel:
1. Porniti cele 4 surse de date: `JPAService`, `JDBCService`, `MongoDBService` si `CSVService`
2. Dupa ce acestea ruleaza pe porturile aferente, porniti serviciul de virtualizare: `SparkSQL-Service`

### 3. Autentificare si Securitate (Basic Auth)
Sistemul implementeaza masuri de protectie la nivel de endpoint. Accesarea datelor necesita credentiale:
- **User:** `developer`
- **Parola:** `iis`

Nota: SparkService extrage, parseaza si trimite automat aceste credentiale prin retea catre microserviciile securizate folosind arhitectura REST.

---

## Testare Automata (CI/CD Ready)
Arhitectura este validata printr-o suita de teste JUnit.

Fiecare microserviciu contine clase de test specifice in `src/test/java/...` care valideaza:
- Sanatatea serviciilor (Ping): verificare HTTP 200 OK si Content Negotiation (Text vs JSON)
- Extractia de date: preluarea cu succes a datelor statice, dinamice si analitice cu autentificare activa
- Securitatea datelor: validarea si filtrarea defensiva a adreselor URL impotriva injectiilor de date malformate (ex: testarea `URISyntaxException` in Spark)
