
# Work №8: Stored Procedures and Functions (SQL) / Работа №8: Использование хранимых функций и процедур

**Objective / Цель работы:**
* **EN:** Learn how to create, manage, and execute stored procedures, user-defined functions, and scheduled events in MySQL, including input validation and error handling.
* **RU:** Создание и выполнение хранимых процедур, пользовательских функций и событий планировщика на языке SQL/MySQL с проверками входных данных и ограничениями.

---

## 1. Key Concepts / Краткая теория

**EN:** **Stored Routines** are SQL code blocks saved directly on the database server. They are divided into two main types: **Stored Procedures** (for executing actions and modifying data) and **Stored Functions** (for calculating and returning a single value inside SQL queries).
**RU:** **Хранимые подпрограммы** - это блоки SQL-кода, сохраненные на стороне сервера СУБД. Они делятся на два типа: **хранимые процедуры** (для выполнения сложных действий и изменения данных) и **хранимые функции** (для вычисления и возврата значения внутри обычных запросов).

### Procedure   vs   Function / Сравнение процедур и функций

| Feature / Критерий | Stored Procedure / Хранимая процедура | Stored Function / Хранимая функция |
| :--- | :--- | :--- |
| **Return Value / Возврат значения** | Optional (`OUT` parameters) / Не обязана возвращать значение | **Mandatory** (`RETURNS` + `RETURN`) / **Обязана** возвращать значение |
| **How to Call / Способ вызова** | Standalone `CALL proc_name(...)` / Отдельной командой `CALL` | Inside queries (`SELECT`, `WHERE`) / Внутри любого SQL-запроса |
| **Data Modification / Изменение данных** | Full access (`INSERT`, `UPDATE`, `DELETE`) / Любые операции с данными | Read-only (computations) / Только чтение и вычисления |
| **Transactions / Транзакции** | Allowed / Может управлять транзакциями | Not allowed / Не может порождать транзакции |

### Additional Tools / Дополнительные инструменты
* **`EVENT` (Event Scheduler / Планировщик событий):** Runs stored procedures automatically on a schedule (e.g., every midnight or every 30 minutes). Requires `event_scheduler = ON`. / Запускает процедуры автоматически по расписанию (аналог `cron` внутри СУБД).
* **`DETERMINISTIC`:** Indicates that a function always returns the exact same result given the same input parameters. / Указывает, что при одинаковых входных параметрах функция всегда возвращает один и тот же результат.
* **`SIGNAL SQLSTATE '45000'`:** Throws a custom user-defined exception and aborts execution if validation fails. / Выбрасывает пользовательскую ошибку и прерывает выполнение при нарушении условий проверки.

---

## 2. Implemented Stored Routines / Разработанные подпрограммы (`car_dealership`)

**EN:** Based on the `car_dealership` schema (`managers`, `cars`, `sales`), four stored routines were created with built-in validations:
**RU:** Для базы данных автосалона `car_dealership` разработаны 4 хранимые подпрограммы с проверками и ограничениями:

1. **`add_validated_sale` (Stored Procedure / Хранимая процедура)**
   * *Task / Задача:* Safely inserts a new car sale into the `sales` table. / Безопасная регистрация новой продажи в таблице `sales`.
   * *Validations / Проверки:*
     * Rejects `NULL` or non-positive prices (`new_price <= 0`) via `SIGNAL SQLSTATE '45000'`. / Блокирует нулевую или отрицательную цену.
     * Verifies that both `new_manager_id` and `new_car_id` exist in their parent tables. / Проверяет существование менеджера и автомобиля.
     * Replaces `NULL` or future dates with `CURRENT_DATE()`. / Автоматически заменяет пустую дату или дату из будущего на сегодняшнюю.

2. **`clean_archived_sales` (Stored Procedure + Event / Хранимая процедура + Событие)**
   * *Task / Задача:* Deletes outdated sales records older than a specified number of years. Scheduled via `auto_clean_archived_sales` to run daily at midnight. / Удаляет архивные записи о продажах с истекшим сроком хранения (запускается вручную или каждую полночь через `EVENT`).
   * *Validations / Проверки:* Enforces a minimum retention period of `3` years (`years_to_keep < 3` is automatically raised to `3`) to prevent accidental deletion of recent financial records. / Защищает свежие данные: если передан срок меньше 3 лет или `NULL`, принудительно устанавливается порог в 3 года.

3. **`get_manager_status` (Stored Function / Хранимая функция)**
   * *Task / Задача:* Evaluates a manager's rank (`NOVICE`, `EXPERIENCED`, `MASTER` or numeric tier `1`, `2`, `3`) based on the highest achievement between total revenue and number of deals. / Определяет статус менеджера по принципу «большего из достижений» (по выручке или количеству сделок).
   * *Validations / Проверки:* Sanitizes `NULL` and negative inputs to `0`, and normalizes the `return_format` parameter (`'NUMBER'` vs `'TEXT'`). / Заменяет `NULL` и отрицательные значения на `0`, приводит режим вывода к верхнему регистру.

4. **`format_price_unit` (Stored Function / Хранимая функция)**
   * *Task / Задача:* Formats raw monetary amounts into human-readable strings with automatic unit scaling (`K` for thousands, `M` for millions) and currency codes (e.g., `120.00K USD`). / Преобразует сумму в удобный для чтения вид с подстройкой размерности (`K`, `M`) и валютой.
   * *Validations / Проверки:* Handles `NULL` or non-positive amounts safely (`0.00 USD`) and defaults empty currency strings to `'USD'`. / Перехватывает `NULL` и отрицательные суммы, а при пустой валюте подставляет `'USD'`.

---

## 3. Standard MySQL / Стандартный SQL-код (с `DELIMITER`)

```sql
USE `car_dealership`;

-- 1

DROP PROCEDURE IF EXISTS add_validated_sale;
DELIMITER $$
CREATE PROCEDURE add_validated_sale(
    IN new_manager_id INT,
    IN new_car_id INT,
    IN new_date DATE,
    IN new_price DECIMAL(10, 2)
)
BEGIN
    DECLARE corrected_date DATE;

    -- Price must be strictly greater than 0

    IF new_price IS NULL OR new_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error / Ошибка: Sale price must be greater than 0';
    END IF;

    --  Check if manager exists

    IF NOT EXISTS (SELECT 1 FROM managers WHERE id = new_manager_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error / Ошибка: Specified manager does not exist';
    END IF;

    --  Check if car exists

    IF NOT EXISTS (SELECT 1 FROM cars WHERE id = new_car_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error / Ошибка: Specified car does not exist';
    END IF;

    -- Date cannot be NULL or in the future

    IF new_date IS NULL OR new_date > CURRENT_DATE() THEN
        SET corrected_date = CURRENT_DATE();
    ELSE
        SET corrected_date = new_date;
    END IF;

    INSERT INTO sales (manager_id, car_id, date_of_sale, price)
    VALUES (new_manager_id, new_car_id, corrected_date, new_price);
END$$
DELIMITER ;

-- 2. 
DROP PROCEDURE IF EXISTS clean_archived_sales;
DELIMITER $$
CREATE PROCEDURE clean_archived_sales(IN years_to_keep INT)
BEGIN
    DECLARE safe_years_to_keep INT;

    -- keep at least 3 years of records
    IF years_to_keep IS NULL OR years_to_keep < 3 THEN
        SET safe_years_to_keep = 3;
    ELSE
        SET safe_years_to_keep = years_to_keep;
    END IF;

    DELETE FROM sales
    WHERE date_of_sale < DATE_SUB(CURRENT_DATE(), INTERVAL safe_years_to_keep YEAR);
END$$
DELIMITER ;

-- Scheduled event to run cleanup daily at midnight

CREATE EVENT IF NOT EXISTS auto_clean_archived_sales
ON SCHEDULE EVERY 1 DAY
STARTS '2023-01-01 00:00:00' ON COMPLETION PRESERVE ENABLE
DO
    CALL clean_archived_sales(5);


-- 3
DROP FUNCTION IF EXISTS get_manager_status;
DELIMITER $$
CREATE FUNCTION get_manager_status(
    total_revenue DECIMAL(15, 2),
    sales_count INT,
    return_format VARCHAR(10)
)
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
    DECLARE safe_revenue DECIMAL(15, 2);
    DECLARE safe_sales_count INT;
    DECLARE revenue_level INT DEFAULT 1;
    DECLARE sales_count_level INT DEFAULT 1;
    DECLARE final_level INT;

    -- Sanitize NULL and negative values

    SET safe_revenue = IF(total_revenue IS NULL OR total_revenue < 0, 0, total_revenue);
    SET safe_sales_count = IF(sales_count IS NULL OR sales_count < 0, 0, sales_count);

    -- Tier by revenue


    CASE
        WHEN safe_revenue < 100000 THEN SET revenue_level = 1;
        WHEN safe_revenue >= 100000 AND safe_revenue <= 500000 THEN SET revenue_level = 2;
        WHEN safe_revenue > 500000 THEN SET revenue_level = 3;
    END CASE;

    -- EN: Tier by deal count

    CASE
        WHEN safe_sales_count < 5 THEN SET sales_count_level = 1;
        WHEN safe_sales_count >= 5 AND safe_sales_count <= 20 THEN SET sales_count_level = 2;
        WHEN safe_sales_count > 20 THEN SET sales_count_level = 3;
    END CASE;

    -- Pick the highest achievement

    SET final_level = GREATEST(revenue_level, sales_count_level);

    IF UPPER(IFNULL(return_format, 'TEXT')) = 'NUMBER' THEN
        RETURN CONCAT(final_level, '');
    ELSE
        CASE final_level
            WHEN 1 THEN RETURN 'NOVICE';
            WHEN 2 THEN RETURN 'EXPERIENCED';
            WHEN 3 THEN RETURN 'MASTER';
        END CASE;
    END IF;
END$$
DELIMITER ;


-- 4

DROP FUNCTION IF EXISTS format_price_unit;
DELIMITER $$
CREATE FUNCTION format_price_unit(
    money_amount DECIMAL(15, 2),
    currency_name VARCHAR(10)
)
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
    DECLARE safe_currency_name VARCHAR(10);

    -- Default to USD if currency is NULL or empty


    SET safe_currency_name = IF(currency_name IS NULL OR TRIM(currency_name) = '', 'USD', UPPER(TRIM(currency_name)));

    -- Format amount with K (thousands) or M (millions)
    IF money_amount IS NULL OR money_amount <= 0 THEN
        RETURN CONCAT('0.00 ', safe_currency_name);
    ELSEIF money_amount >= 1000000 THEN
        RETURN CONCAT(ROUND(money_amount / 1000000, 2), 'M ', safe_currency_name);
    ELSEIF money_amount >= 1000 THEN
        RETURN CONCAT(ROUND(money_amount / 1000, 2), 'K ', safe_currency_name);
    ELSE
        RETURN CONCAT(ROUND(money_amount, 2), ' ', safe_currency_name);
    END IF;
END$$
DELIMITER ;
```

