-- 1
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
    CONSTRAINT fk_sales_managers
        FOREIGN KEY (manager_id) REFERENCES managers (id),
    CONSTRAINT fk_sales_cars
        FOREIGN KEY (car_id) REFERENCES cars (id)
) ENGINE = InnoDB;

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


 -- 2
SET profiling = 1;

EXPLAIN SELECT * FROM sales WHERE date_of_sale = '2023-05-15' AND price < 80000.00;

EXPLAIN SELECT id, manager_id, car_id, date_of_sale, price FROM sales 
WHERE date_of_sale BETWEEN '2023-01-01' AND '2023-03-31' AND price > 60000.00 ORDER BY date_of_sale;

EXPLAIN SELECT id, name, surname, phone FROM managers WHERE surname LIKE 'ManagerSurname_4%';

EXPLAIN SELECT date_of_sale, COUNT(id) AS deals_count, SUM(price) AS daily_revenue 
FROM sales WHERE date_of_sale BETWEEN '2023-06-01' AND '2023-06-30' GROUP BY date_of_sale;

EXPLAIN SELECT s.id, c.car_brand, c.model, c.color, s.date_of_sale, s.price
FROM sales s JOIN cars c ON s.car_id = c.id
WHERE c.car_brand = 'BMW' AND c.color = 'Black' ORDER BY s.price DESC;

SELECT * FROM sales WHERE date_of_sale = '2023-05-15' AND price < 80000.00;
SELECT id, manager_id, car_id, date_of_sale, price FROM sales WHERE date_of_sale BETWEEN '2023-01-01' AND '2023-03-31' AND price > 60000.00 ORDER BY date_of_sale;
SELECT id, name, surname, phone FROM managers WHERE surname LIKE 'ManagerSurname_4%';
SELECT date_of_sale, COUNT(id) AS deals_count, SUM(price) AS daily_revenue FROM sales WHERE date_of_sale BETWEEN '2023-06-01' AND '2023-06-30' GROUP BY date_of_sale;
SELECT s.id, c.car_brand, c.model, c.color, s.date_of_sale, s.price FROM sales s JOIN cars c ON s.car_id = c.id WHERE c.car_brand = 'BMW' AND c.color = 'Black' ORDER BY s.price DESC;

-- 3

CREATE INDEX idx_sales_date_price ON sales(date_of_sale, price);
CREATE INDEX idx_managers_surname ON managers(surname);
CREATE UNIQUE INDEX idx_managers_phone ON managers(phone);
CREATE INDEX idx_cars_brand_color ON cars(car_brand, color);

EXPLAIN SELECT * FROM sales WHERE date_of_sale = '2023-05-15' AND price < 80000.00;

EXPLAIN SELECT id, manager_id, car_id, date_of_sale, price FROM sales 
WHERE date_of_sale BETWEEN '2023-01-01' AND '2023-03-31' AND price > 60000.00 ORDER BY date_of_sale;

EXPLAIN SELECT id, name, surname, phone FROM managers WHERE surname LIKE 'ManagerSurname_4%';

EXPLAIN SELECT date_of_sale, COUNT(id) AS deals_count, SUM(price) AS daily_revenue 
FROM sales WHERE date_of_sale BETWEEN '2023-06-01' AND '2023-06-30' GROUP BY date_of_sale;

EXPLAIN SELECT s.id, c.car_brand, c.model, c.color, s.date_of_sale, s.price
FROM sales s JOIN cars c ON s.car_id = c.id
WHERE c.car_brand = 'BMW' AND c.color = 'Black' ORDER BY s.price DESC;

SELECT * FROM sales WHERE date_of_sale = '2023-05-15' AND price < 80000.00;
SELECT id, manager_id, car_id, date_of_sale, price FROM sales WHERE date_of_sale BETWEEN '2023-01-01' AND '2023-03-31' AND price > 60000.00 ORDER BY date_of_sale;
SELECT id, name, surname, phone FROM managers WHERE surname LIKE 'ManagerSurname_4%';
SELECT date_of_sale, COUNT(id) AS deals_count, SUM(price) AS daily_revenue FROM sales WHERE date_of_sale BETWEEN '2023-06-01' AND '2023-06-30' GROUP BY date_of_sale;
SELECT s.id, c.car_brand, c.model, c.color, s.date_of_sale, s.price FROM sales s JOIN cars c ON s.car_id = c.id WHERE c.car_brand = 'BMW' AND c.color = 'Black' ORDER BY s.price DESC;

SHOW PROFILES;
