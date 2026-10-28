# Work №2: Database Modeling & EER Diagram

**Objective:** Recreate the normalized relational schema from Laboratory Work №1 as an Enhanced Entity-Relationship (EER) diagram, specifying exact data types, constraints (`NOT NULL`, `UNIQUE`), and `1:N` (One-to-Many) relationships.

---

## 1. Visual EER Diagram (Car Dealership)

<img width="1028" height="629" alt="Opera Снимок_2026-10-28_131811_dbdiagram io" src="https://github.com/user-attachments/assets/456565cc-b5b8-46bd-91e7-2c249acc015a" />


### Interactive Mermaid ER Schema
```mermaid
erDiagram
    MANAGERS ||--o{ SALES : "processes (1:N)"
    CARS ||--o{ SALES : "is sold in (1:N)"

    MANAGERS {
        int id PK "NOT NULL, AUTO_INCREMENT"
        varchar(50) name "NOT NULL"
        varchar(50) surname "NOT NULL"
        varchar(20) phone "NOT NULL, UNIQUE"
    }

    CARS {
        int id PK "NOT NULL, AUTO_INCREMENT"
        varchar(50) car_brand "NOT NULL"
        varchar(50) model "NOT NULL"
        varchar(30) body_type "NOT NULL"
        varchar(30) color "NOT NULL"
    }

    SALES {
        int id PK "NOT NULL, AUTO_INCREMENT"
        int manager_id FK "NOT NULL -> managers(id)"
        int car_id FK "NOT NULL -> cars(id)"
        date date_of_sale "NOT NULL"
        decimal(10_2) price "NOT NULL, CHECK (price > 0)"
    }
