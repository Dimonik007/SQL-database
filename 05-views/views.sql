CREATE SCHEMA IF NOT EXISTS `car_dealership` DEFAULT CHARACTER SET utf8mb4;
USE `car_dealership`;

 -- 2. DDL
CREATE TABLE IF NOT EXISTS `managers` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `surname` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `cars` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `car_brand` VARCHAR(50) NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `body_type` VARCHAR(30) NOT NULL,
    `color` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sales` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `manager_id` INT NOT NULL,
    `car_id` INT NOT NULL,
    `date_of_sale` DATE NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
    CONSTRAINT `fk_sales_managers`
        FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`),
    CONSTRAINT `fk_sales_cars`
        FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE = InnoDB;

-- 3. DML 

-- Справочник 
INSERT INTO `managers` VALUES (1, 'Ivan', 'Ivanov', '+375293467764');

INSERT INTO `managers` (`name`, `surname`, `phone`) VALUES 
    ('Andrey', 'Petrovich', '+375296769036'),
    ('Victoria', 'Alderanova', '+375297566457');

INSERT INTO `cars` VALUES (12, 'BMW', 'M3', 'Sedan', 'Grey');

INSERT INTO `cars` (`id`, `car_brand`, `model`, `body_type`, `color`) VALUES 
    (23, 'BMW', 'M5', 'Sedan', 'Black'),
    (34, 'Audi', 'Q7', 'SUV', 'White');


INSERT INTO `sales` (`id`, `manager_id`, `car_id`, `date_of_sale`, `price`) VALUES 
    (112, 1, 12, '2023-07-28', 70000.00),
    (203, 2, 23, '2023-03-22', 95000.00),
    (304, 3, 34, '2023-02-23', 45000.00);

USE `car_dealership`;


-- 1.скрываем телефоны менеджеров


CREATE OR REPLACE VIEW v_managers_public AS
SELECT id AS manager_id, name, surname
FROM managers;

SELECT * FROM v_managers_public;


-- 2. Представление-отчет (JOIN 3-х таблиц + уникальные имена колонок)

CREATE OR REPLACE VIEW v_full_sales_report 
    (sale_id, sale_date, manager_surname, brand, model, color, deal_price) 
AS
SELECT 
    s.id, 
    s.date_of_sale, 
    m.surname, 
    c.car_brand, 
    c.model, 
    c.color, 
    s.price
FROM sales s
INNER JOIN managers m ON s.manager_id = m.id
INNER JOIN cars c ON s.car_id = c.id;
SELECT * FROM v_full_sales_report 
WHERE brand = 'BMW' 
ORDER BY deal_price DESC;
 



-- 3. Групповое представление 


CREATE OR REPLACE ALGORITHM = TEMPTABLE VIEW v_manager_kpi AS
SELECT 
    m.id AS manager_id,
    m.surname,
    COUNT(s.id) AS total_deals,
    SUM(s.price) AS total_r
FROM managers m
LEFT JOIN sales s ON m.id = s.manager_id
GROUP BY m.id, m.surname;

-- Проверка: находим максимальную выручку среди менеджеров через представление
SELECT MAX(total_r) AS best_manager FROM v_manager_kpi;



-- 4. Алгоритм MERGE + CHECK OPTION

CREATE OR REPLACE ALGORITHM = MERGE VIEW v_luxury_sales AS
SELECT id, manager_id, car_id, date_of_sale, price
FROM sales
WHERE price >= 60000.00
WITH CASCADED CHECK OPTION;


SELECT * FROM v_luxury_sales;


UPDATE v_luxury_sales SET price = 65000.00 WHERE id = 112;
UPDATE v_luxury_sales SET price = 85000.00 WHERE id = 203;

SELECT * FROM sales WHERE id = 112;
SELECT * FROM sales WHERE id = 203;
