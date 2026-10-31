[laboratory_work_6_readme (1).md](https://github.com/user-attachments/files/34214532/laboratory_work_6_readme.1.md)
#  Work №6: Indexing and Query Optimization (SQL) /  Работа №6: Индексирование и оптимизация запросов

**Objective / Цель работы:**
* **EN:** Learn methods to accelerate data retrieval using indexes, analyze query execution plans via `EXPLAIN`, and measure real query execution time in MySQL.
* **RU:** Изучить методы ускорения выборки данных с помощью индексов, научиться анализировать план выполнения запросов через `EXPLAIN` и замерять реальное время работы запросов в MySQL.

---

## Database Description / Описание базы данных (`car_dealership`)

**EN:** The work is performed on the car dealership database from previous labs. The schema consists of three related tables using the `InnoDB` engine:
**RU:** Работа выполняется на базе данных автосалона из предыдущих работ. Схема состоит из трех связанных таблиц на движке `InnoDB`:

- **`managers`** — Employee directory / Справочник сотрудников (`id`, `name`, `surname`, `phone`).
- **`cars`** — Car catalog / Каталог автомобилей (`id`, `car_brand`, `model`, `body_type`, `color`).
- **`sales`** — Sales ledger / Журнал продаж (`id`, `manager_id`, `car_id`, `date_of_sale`, `price`), linked by foreign keys to managers and cars.

---

## Task 1. Test Data Preparation / Задание 1. Подготовка тестовых данных

### 1.1–1.2. Chosen population method / Выбранный способ заполнения

**EN:** For mass data generation, **Method 2** (Stored procedure with a `WHILE` loop in MySQL) was used. To prevent performance degradation from auto-committing 5000 single `INSERT` operations, the loop is wrapped in a single transaction (`START TRANSACTION ... COMMIT`).
**RU:** Для генерации тестовой выборки использован **Способ 2** (Хранимая процедура с циклом `WHILE` в MySQL). Чтобы 5000 одиночных операций `INSERT` не тормозили из-за автокоммита после каждой строки, цикл обернут в единую транзакцию.

**Result / В результате создано:**
- `50` records in `managers` / записей в таблице менеджеров
- `100` records in `cars` / записей в таблице машин
- `5000` records in `sales` / записей в таблице продаж

### 1.3. SQL Script / SQL-скрипт создания таблиц и заполнения

```sql
CREATE TABLE IF NOT EXISTS managers (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS cars (
    id INT NOT NULL AUTO_INCREMENT,
    car_brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    body_type VARCHAR(30) NOT NULL,
    color VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS sales (
    id INT NOT NULL AUTO_INCREMENT,
    manager_id INT NOT NULL,
    car_id INT NOT NULL,
    date_of_sale DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE,
    CONSTRAINT fk_sales_managers FOREIGN KEY (manager_id) REFERENCES managers (id),
    CONSTRAINT fk_sales_cars FOREIGN KEY (car_id) REFERENCES cars (id)
) ENGINE = InnoDB;

-- EN: Procedure for mass data generation
-- RU: Процедура массовой генерации данных
CREATE PROCEDURE insert_5000_sales()
BEGIN
    DECLARE i INT DEFAULT 1;
    START TRANSACTION;

    WHILE i <= 50 DO
        INSERT INTO managers (name, surname, phone)
        VALUES (
            CONCAT('ManagerName_', i),
            CONCAT('ManagerSurname_', i),
            CONCAT('+37529100', LPAD(i, 4, '0'))
        );
        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 100 DO
        INSERT INTO cars (car_brand, model, body_type, color)
        VALUES (
            ELT(FLOOR(1 + RAND() * 4), 'BMW', 'Audi', 'Mercedes', 'Toyota'),
            CONCAT('Model_', i),
            'Sedan',
            ELT(FLOOR(1 + RAND() * 3), 'Black', 'White', 'Grey')
        );
        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 5000 DO
        INSERT INTO sales (manager_id, car_id, date_of_sale, price)
        VALUES (
            FLOOR(1 + RAND() * 50),
            FLOOR(1 + RAND() * 100),
            DATE_ADD('2022-01-01', INTERVAL FLOOR(RAND() * 730) DAY),
            ROUND(15000 + RAND() * 85000, 2)
        );
        SET i = i + 1;
    END WHILE;

    COMMIT;
END;

CALL insert_5000_sales();

SELECT COUNT(*) AS total_sales FROM sales;
```

**EN:** Execution time for 5150 rows: `0.18 sec` (thanks to batching via a single transaction).
**RU:** Время выполнения заполнения 5150 строк: `0.18 сек` (благодаря объединению в одну транзакцию).

---

## Task 2. Analyzing Queries Without Indexes / Задание 2. Анализ запросов без индексов

### 2.1. Test Queries / Тестовые запросы

```sql
SET profiling = 1;

-- 1. Exact match and less-than condition / Точное совпадение (=) и условие меньше (<)
SELECT * FROM sales 
WHERE date_of_sale = '2023-05-15' AND price < 80000.00;

-- 2. Date range, price filter, and sorting / Диапазон (BETWEEN), фильтр (>) и сортировка (ORDER BY)
SELECT id, manager_id, car_id, date_of_sale, price 
FROM sales 
WHERE date_of_sale BETWEEN '2023-01-01' AND '2023-03-31' 
  AND price > 60000.00
ORDER BY date_of_sale;

-- 3. Prefix search / Поиск по префиксу (LIKE)
SELECT id, name, surname, phone 
FROM managers 
WHERE surname LIKE 'ManagerSurname_4%';

-- 4. Aggregation and grouping / Агрегация и группировка (GROUP BY)
SELECT date_of_sale, COUNT(id) AS deals_count, SUM(price) AS daily_revenue 
FROM sales 
WHERE date_of_sale BETWEEN '2023-06-01' AND '2023-06-30'
GROUP BY date_of_sale;

-- 5. Multi-table JOIN with filters / Соединение таблиц (JOIN) с фильтрацией
SELECT s.id, c.car_brand, c.model, c.color, s.date_of_sale, s.price
FROM sales s
JOIN cars c ON s.car_id = c.id
WHERE c.car_brand = 'BMW' AND c.color = 'Black'
ORDER BY s.price DESC;

SHOW PROFILES;
```

### 2.2–2.4. `EXPLAIN` Results BEFORE Indexing / Результаты ДО создания индексов

**EN:** Without indexes, the optimizer performs a full table scan (`type = ALL`) for every query.
**RU:** Без индексов оптимизатор вынужден делать полное сканирование таблиц (`type = ALL`).

| Query / Запрос | Table | `type` | `possible_keys` | `key` | `rows` | `Extra` | Time (sec) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Query 1** | `sales` | `ALL` | `NULL` | `NULL` | `5000` | `Using where` | `0.0042` |
| **Query 2** | `sales` | `ALL` | `NULL` | `NULL` | `5000` | `Using where; Using filesort` | `0.0058` |
| **Query 3** | `managers` | `ALL` | `NULL` | `NULL` | `50` | `Using where` | `0.0009` |
| **Query 4** | `sales` | `ALL` | `NULL` | `NULL` | `5000` | `Using where; Using temporary` | `0.0064` |
| **Query 5** | `c` (`cars`) | `ALL` | `PRIMARY, id_UNIQUE` | `NULL` | `100` | `Using where; temp; filesort` | `0.0051` |

---

## Task 3. Index Creation and Testing / Задание 3. Создание и тестирование индексов

### 3.1–3.2. Created Indexes / Созданные индексы

```sql
-- 1. Composite index on date and price / Составной индекс по дате и цене
CREATE INDEX idx_sales_date_price ON sales(date_of_sale, price);

-- 2. Regular index on surname / Обычный индекс по фамилии
CREATE INDEX idx_managers_surname ON managers(surname);

-- 3. Unique index on phone number / Уникальный индекс по телефону
CREATE UNIQUE INDEX idx_managers_phone ON managers(phone);

-- 4. Composite index on car brand and color / Составной индекс по марке и цвету
CREATE INDEX idx_cars_brand_color ON cars(car_brand, color);
```

| Index Name / Имя индекса | Type / Тип | Columns / Столбцы | Justification / Обоснование (EN / RU) |
| :--- | :--- | :--- | :--- |
| `idx_sales_date_price` | Composite (`INDEX`) | `date_of_sale, price` | Accelerates **Queries 1, 2, 4**. Removes `filesort` penalty. / Ускоряет Запросы 1, 2 и 4. Убирает лишнюю сортировку `filesort`. |
| `idx_managers_surname` | Regular (`INDEX`) | `surname` | Accelerates **Query 3** (`LIKE '...'`). / Ускоряет Запрос 3 при поиске по префиксу. |
| `idx_managers_phone` | Unique (`UNIQUE`) | `phone` | Ensures DB-level data integrity and speeds up exact lookups. / Гарантирует уникальность и ускоряет точечный поиск. |
| `idx_cars_brand_color` | Composite (`INDEX`) | `car_brand, color` | Accelerates **Query 5** (`JOIN`), filtering rows early. / Ускоряет Запрос 5, отсекая машины до слияния. |

### 3.3. `EXPLAIN` Results AFTER Indexing / Результаты ПОСЛЕ создания индексов

| Query / Запрос | Table | `type` | `key` | `rows` | `Extra` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Query 1** | `sales` | `range` | `idx_sales_date_price` | `7` | `Using index condition` |
| **Query 2** | `sales` | `range` | `idx_sales_date_price` | `615` | `Using index condition` |
| **Query 3** | `managers` | `range` | `idx_managers_surname` | `11` | `Using index condition` |
| **Query 4** | `sales` | `range` | `idx_sales_date_price` | `210` | `Using where; Using index` |
| **Query 5** | `c` (`cars`) | `ref` | `idx_cars_brand_color` | `8` | `Using index condition` |

### 3.4–3.6. Performance Comparison / Таблица сравнения производительности

| Query / Запрос | Rows Before | Rows After | Time Before (sec) | Time After (sec) | Speedup / Ускорение |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q1** (`=`, `<`) | `5000` | `7` | `0.0042` | `0.0005` | **8.4x** |
| **Q2** (`BETWEEN`, `ORDER`) | `5000` | `615` | `0.0058` | `0.0012` | **4.8x** |
| **Q3** (`LIKE`) | `50` | `11` | `0.0009` | `0.0004` | **2.25x** |
| **Q4** (`GROUP BY`) | `5000` | `210` | `0.0064` | `0.0011` | **5.8x** |
| **Q5** (`JOIN`) | `100` | `8` | `0.0051` | `0.0014` | **3.6x** |

---

## Task 4. Analysis and Conclusions / Задание 4. Анализ и выводы

### 4.1–4.2. Q&A / Ответы на вопросы

**1. Which queries got the biggest speedup and why? / Какие запросы получили наибольшее ускорение и почему?**
* **EN:** Queries 1 and 4. The composite index replaced full table scans (`ALL`) with index range scans (`range`). Query 4 utilized a *covering index* (`Using index`), meaning the DB retrieved all required data directly from the index tree without reading the actual table rows.
* **RU:** Запросы 1 и 4. Вместо чтения всех записей (`type = ALL`) СУБД перешла к чтению узлов B-Tree индекса (`type = range`). В Запросе 4 сработал *покрывающий индекс* (`Using index`) — все нужные поля уже были в индексе.

**2. Which queries saw the lowest improvement? / Были ли запросы, которые ускорились слабее других?**
* **EN:** Query 3 (`LIKE`). The `managers` table only has 50 rows. A full table scan in RAM takes less than a millisecond, so the index overhead makes the absolute time improvement minimal.
* **RU:** Запрос 3. В таблице `managers` всего 50 строк. Полное сканирование крошечной таблицы в ОЗУ занимает миллисекунды, поэтому выигрыш от индекса минимален.

**3. Memory footprint of the new indexes? / Какой объем занимают новые индексы?**
* **EN:** 4 new indexes were created. For 5,000 rows, they consume approx. 160–220 KB on disk.
* **RU:** Создано 4 дополнительных индекса. Для 5000 записей они занимают около 160–220 КБ на диске (данные `SHOW TABLE STATUS`).

**4. What are the trade-offs of indexing? / Какие компромиссы при создании индексов?**
* **EN:** Read speed vs. Write speed. Indexes drastically speed up `SELECT` statements but slow down `INSERT`, `UPDATE`, and `DELETE` operations because the B-Tree structures must be rebuilt. They also consume additional RAM (Buffer Pool) and disk space.
* **RU:** Скорость чтения против скорости записи. Индексы ускоряют `SELECT`, но замедляют `INSERT`, `UPDATE` и `DELETE`, так как серверу нужно перестраивать дерево. Также они требуют дополнительной памяти.

### 4.3. Final Conclusion / Общий вывод
* **EN:** Indexing is critical for tables with thousands or millions of rows. Properly designed composite indexes eliminated full table scans (`ALL`), temporary tables (`Using temporary`), and file sorts (`Using filesort`), speeding up data retrieval by **3.5x to 8.4x**.
* **RU:** Индексирование критически важно для объемных таблиц. Грамотный подбор составных индексов убрал полное сканирование (`ALL`), временные таблицы (`Using temporary`) и файловую сортировку (`Using filesort`), ускорив выборку в **3.5–8.4 раза**.
