#  Work №2: Database Modeling & EER Diagram

**Objective:** Recreate the normalized relational schema from Laboratory Work №1 as an Enhanced Entity-Relationship (EER) diagram, specifying exact data types, constraints (`NOT NULL`, `UNIQUE`), and `1:N` (One-to-Many) relationships.

(Воссоздать нормализованную реляционную схему из Лабораторной работы №1 в виде расширенной сущностно-связной диаграммы (EER), указать точные типы данных, ограничения (`NOT NULL`, `UNIQUE`) и связи типа «один ко многим» (`1:N`))

EER (Enhanced Entity-Relationship, или Расширенная модель «сущность-связь») - это продвинутая версия классической ER-диаграммы, которая используется для детального проектирования сложных баз данных.

Главное отличие EER от классической ER
Обычная ER-модель показывает только базу - сами таблицы, их колонки и простые связи между ними. EER добавляет в схемы концепции из объектно-ориентированного программирования, приближая рисунок к реальной физической архитектуре базы.


---

## 1. Visual EER Diagram (Car Dealership)

<img width="1028" height="629" alt="Opera Снимок_2026-10-28_131811_dbdiagram io" src="https://github.com/user-attachments/assets/35f8f413-cd07-489e-a8c2-0d0741d13a27" />

---

## 2. Relationships & Cardinality Explanation

* **`managers (1) ───< sales (N)` (One-to-Many):** One dealership manager can process multiple car sales over time, while each specific sale record in `sales` is linked to exactly one manager via the `manager_id` foreign key.
* **`cars (1) ───< sales (N)` (One-to-Many):** Each vehicle model/unit in the `cars` catalog can be referenced in the `sales` history via the `car_id` foreign key.
* **Referential Integrity:** Foreign keys (`manager_id`, `car_id`) are marked as `NOT NULL`, meaning a sale cannot exist in the database without a valid existing manager and car.
