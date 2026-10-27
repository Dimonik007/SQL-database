# SQL & Relational Database Engineering Portfolio

Практикум по проектированию, оптимизации и программированию реляционных баз данных в **MySQL 8.0**, а также по интеграции с объектно-ориентированной архитектурой **Salesforce (SOQL)**.

Repository covers the complete development lifecycle of relational databases: from conceptual design and normalization to query execution plan analysis (`EXPLAIN`), triggers, stored routines, and CRM architecture mapping.


##  Project Structure (Структура проекта)

| Folder (Папка) | Topic ) | Core Technologies & Concepts (Ключевые концепции) |
| :--- | :--- | :--- |
| 📁 `01-normalization` | ** 1.** Relational Model & Normalization | Primary/Foreign Keys (`PK`, `FK`), Schema reduction to `1NF`, `2NF`, `3NF`, `BCNF` |
| 📁 `02-eer-diagram` | ** 2.** Database Modeling in MySQL Workbench | EER Diagram creation, data types configuration, `1:N` relationships |
| 📁 `03-schema-and-seed` | ** 3.** Schema Generation & Data Seeding | `CREATE SCHEMA`, `CREATE TABLE`, `AUTO_INCREMENT`, `FOREIGN KEY`, batch `INSERT INTO` |
| 📁 `04-dml-and-joins` | ** 4.** Data Retrieval & Modification (20 Queries) | `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `UPDATE`, `DELETE`, `INNER/LEFT/RIGHT/CROSS JOIN`, `UNION ALL` |
| 📁 `05-views` | ** 5.** Using Database Views (`VIEW`) | `CREATE OR REPLACE VIEW`, `MERGE` & `TEMPTABLE` algorithms, updatable views with `WITH CHECK OPTION` |
| 📁 `06-indexing-and-explain` | ** 6.** Indexing & Query Optimization | Generating 5000+ rows, `CREATE INDEX` (simple & composite), profiling and analysis via `EXPLAIN` (`ALL` vs `ref`/`const`) |
| 📁 `07-triggers` | ** 7.** Database Triggers | Automation & Audit: `BEFORE/AFTER INSERT`, `UPDATE`, `DELETE`, working with `OLD` and `NEW` aliases |
| 📁 `08-stored-programs` | ** 8.** Stored Routines & Events | `CREATE PROCEDURE`, `CREATE FUNCTION` (`DETERMINISTIC`), scheduled task automation via `CREATE EVENT` |
| 📁 `09-salesforce-crm-and-soql` | ** 9.** Salesforce Architecture & SOQL | Relational mapping to CRM objects (`Account`, `Contact`, `Opportunity`), comparison of SQL `JOIN` vs SOQL dot-notation and subqueries |


##  Technology Stack (Стек технологий)

* **Relational DBMS:** MySQL Server 8.0, MS SQL Server (T-SQL)
* **Design & Modeling Tools:** MySQL Workbench (EER Modeling), DBeaver, dbfiddle
* **Query Languages:** Standard SQL (DDL, DML, DQL), MySQL Procedural Extensions
* **CRM Ecosystem:** Salesforce Platform, Developer Console, **SOQL** (Salesforce Object Query Language), Object-Oriented Relationships (`Parent-to-Child`, `Child-to-Parent`)
