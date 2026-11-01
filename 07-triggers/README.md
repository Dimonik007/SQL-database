
# Work №7: Using Triggers (SQL) /  Работа №7: Использование триггеров

**Objective / Цель работы:**
* **EN:** Create triggers using SQL/MySQL and learn methods to manage them for data validation and automation.
* **RU:** Создание триггеров с использованием языка запросов SQL/MySQL и изучение методов управления ими для валидации данных и автоматизации.

---

## 1. Key Concepts / Краткая теория

**EN:** A **trigger** is a named database object associated with a table that activates automatically when a specific event (`INSERT`, `UPDATE`, or `DELETE`) occurs.
**RU:** **Триггер** — это объект базы данных, привязанный к таблице, который срабатывает автоматически при наступлении определенного события (`INSERT`, `UPDATE` или `DELETE`).

* **Trigger Time (Время срабатывания):** 
  * `BEFORE`: Activates before the row is modified. Used for data validation. / Срабатывает до изменения строки. Удобно для проверки данных.
  * `AFTER`: Activates after the row is successfully modified. Used for calculations or logging. / Срабатывает после успешного изменения. Удобно для расчетов или логов.
---

## 2. Implemented Triggers / Созданные триггеры

**EN:** Based on the `car_dealership` database, the following triggers were implemented for the `sales` table:
**RU:** Для базы данных `car_dealership` были разработаны следующие триггеры для таблицы `sales`:

1. **`trg_sales_before_insert` (`BEFORE INSERT`)**
   * *Task / Задача:* Validates values before insertion. / Проверка значений перед вставкой.
   * *Action / Действие:* If a user attempts to insert a negative price, it forces the `price` to `0`. / Если вводится отрицательная цена, триггер принудительно меняет её на `0`.
2. **`trg_sales_before_update` (`BEFORE UPDATE`)**
   * *Task / Задача:* Validates new values during row modification. / Проверка нового значения при редактировании.
   * *Action / Действие:* If a negative price is set during an update, the trigger rejects the negative value and restores the `OLD.price`. / Если при обновлении вводится минус, триггер отменяет изменение, возвращая старую цену (`OLD.price`).
3. **`trg_sales_after_insert` (`AFTER INSERT`)**
   * *Task / Задача:* Automated calculations based on inserted values. / Автоматические расчеты на основе новых данных.
   * *Action / Действие:* Acts as an accumulator, adding the `NEW.price` of every successful sale to a session variable `@total_revenue`. / Работает как сумматор, прибавляя цену каждой новой сделки к переменной `@total_revenue`.

---

## 3. SQL Implementation / SQL-код триггеров

```sql
USE `car_dealership`;

-- 1
DELIMITER //
CREATE TRIGGER trg_sales_before_insert BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    -- EN: If price is negative, set it to 0
    -- RU: Если цена меньше нуля, устанавливаем ее в 0
    IF NEW.price < 0 THEN 
        SET NEW.price = 0;
    END IF;
END;//
DELIMITER ;


-- 2

DELIMITER //
CREATE TRIGGER trg_sales_before_update BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    -- EN: Revert to OLD.price if the NEW.price is invalid
    -- RU: OLD обращается к существующей строке, NEW - к новой
    IF NEW.price < 0 THEN 
        SET NEW.price = OLD.price;
    END IF;
END;//
DELIMITER ;


-- 3 
-- EN: BEGIN...END is omitted since it's a single statement
-- RU: Блок BEGIN...END не обязателен, так как инструкция всего одна
CREATE TRIGGER trg_sales_after_insert AFTER INSERT ON sales
FOR EACH ROW 
SET @total_revenue = IFNULL(@total_revenue, 0) + NEW.price;
```

---

## 4. Testing / Проверка работоспособности

```sql
-- EN: Reset the revenue accumulator
-- RU: Устанавливаем переменную сумматора в ноль
SET @total_revenue = 0;

-- EN: Test 1: Insert a valid record (Triggers BEFORE and AFTER will fire)
-- RU: Тест 1: Вставка корректной записи (Сработают триггеры BEFORE и AFTER)

INSERT INTO sales (manager_id, car_id, date_of_sale, price)

VALUES (1, 1, '2023-10-10', 45000.00);

-- EN: Check the accumulator variable
-- RU: Проверяем значение накопительной переменной

SELECT @total_revenue AS 'Total revenue inserted';

-- Expected / Ожидается: 45000.00

-- EN: Test 2: Attempt to insert a negative price
-- RU: Тест 2: Попытка вставить отрицательную цену


INSERT INTO sales (manager_id, car_id, date_of_sale, price) 
VALUES (2, 2, '2023-10-11', -1500.00);

-- EN: Check the inserted data. The price should be 0, not -1500.
-- RU: Проверяем вставленные данные. Цена должна стать 0, а не -1500.

SELECT * FROM sales ORDER BY id DESC LIMIT 2;
```
