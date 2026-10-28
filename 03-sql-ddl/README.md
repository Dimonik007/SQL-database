#  Work №3: Database Generation & Data Population (SQL)

**Objective:** Recreate the Car Dealership database from the previous laboratory work using SQL (`CREATE SCHEMA`, `CREATE TABLE`) and populate it with data using different `INSERT INTO` syntax variations.

(Воссоздать базу данных автосалона из предыдущей лабораторной работы с помощью SQL-запросов (`CREATE SCHEMA`, `CREATE TABLE`) и заполнить её данными, используя различные варианты синтаксиса `INSERT INTO`)
---


<img width="399" height="386" alt="Opera Снимок_2026-10-28_140018_dbfiddle uk" src="https://github.com/user-attachments/assets/bbf6ec86-b1fe-4c29-af7f-4a951a270dbe" />


## 1. Key SQL 

* **Schema Initialization:** Created the database workspace using `CREATE SCHEMA IF NOT EXISTS car_dealership;` and switched context via `USE car_dealership;`.
* **Table Creation & Constraints:** Defined `PRIMARY KEY`, `AUTO_INCREMENT`, and `NOT NULL` attributes alongside `FOREIGN KEY` relationships linking `sales` to `managers` and `cars`.
* **Two Variants of `INSERT INTO`:**
  1. **Full-row insert:** Passing values for all columns explicitly, including the primary key (`INSERT INTO managers VALUES (1, ...)`).
  2. **Column-specific & batch insert:** Omitting the `AUTO_INCREMENT` primary key column so the DBMS generates the ID automatically, and inserting multiple rows in a single query separated by commas.
* **Foreign Key Integrity Check (`Error Code: 1452`):** Attempting to insert a sale with a non-existent `manager_id` (e.g., `99`) triggers `Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails`, confirming that referential integrity is enforced by the server.
  
(
* **Инициализация схемы:** Создано рабочее пространство базы данных с помощью команды `CREATE SCHEMA IF NOT EXISTS car_dealership;`, контекст переключен с помощью `USE car_dealership;`.
* **Создание таблиц и ограничения:** Определены атрибуты `PRIMARY KEY`, `AUTO_INCREMENT` и `NOT NULL`, а также связи внешних ключей (`FOREIGN KEY`), связывающие таблицу транзакций `sales` со справочниками `managers` и `cars`.
* **Два варианта использования `INSERT INTO`:**
  1. **Вставка полной строки:** Явная передача значений для абсолютно всех столбцов, включая первичный ключ (`INSERT INTO managers VALUES (1, ...)`).
  2. **Вставка в конкретные столбцы и пакетная вставка:** Пропуск столбца первичного ключа (чтобы СУБД сгенерировала `AUTO_INCREMENT` ID автоматически) и вставка сразу нескольких строк в одном запросе через запятую.
* **Проверка целостности внешнего ключа (`Error Code: 1452`):** Попытка вставить запись о продаже с несуществующим `manager_id` (например, `99`) вызывает ошибку сервера `Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails`. Это подтверждает, что механизм ссылочной целостности (Referential Integrity) успешно работает и защищает базу данных.)
