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

-- 1. Вывести абсолютно все столбцы и строки из таблицы автомобилей
SELECT * FROM cars;

-- 2. Вывести имена и телефоны менеджеров, отсортировав по имени по алфавиту
SELECT name, phone FROM managers ORDER BY name ASC;

-- 3. Найти все автомобили марки 'BMW'
SELECT * FROM cars WHERE car_brand = 'BMW';

-- 4. Найти все продажи, где цена сделки больше 60 000
SELECT * FROM sales WHERE price > 60000.00;

-- 5. Найти продажи, совершенные в марте 2023 года
SELECT * FROM sales WHERE date_of_sale BETWEEN '2023-03-01' AND '2023-03-31';

-- 6. Посчитать общее количество оформленных сделок
SELECT COUNT(*) FROM sales;

-- 7. Вычислить общую сумму денег, заработанную автосалоном со всех продаж
SELECT SUM(price) FROM sales;

-- 8. Найти самую дорогую проданную машину 
SELECT MAX(price) FROM sales;

-- 9. Сгруппировать данные по ID менеджера и вывести сумму продаж для каждого
SELECT manager_id, SUM(price) FROM sales GROUP BY manager_id;

-- 10. Оставить только тех менеджеров, чья суммарная выручка превышает 50 000
SELECT manager_id, SUM(price) FROM sales GROUP BY manager_id HAVING SUM(price) > 50000;

-- 11. Вывести дату продажи, цену и фамилию менеджера 
SELECT sales.date_of_sale, sales.price, managers.surname 
FROM sales 
INNER JOIN managers ON sales.manager_id = managers.id;

-- 12. Вывести цену продажи, марку и цвет проданного автомобиля
SELECT sales.price, cars.car_brand, cars.color 
FROM sales 
INNER JOIN cars ON sales.car_id = cars.id;

-- 13. Полная сводка (соединение трех таблиц): Дата, Фамилия, Марка, Цена
SELECT sales.date_of_sale, managers.surname, cars.car_brand, sales.price 
FROM sales 
INNER JOIN managers ON sales.manager_id = managers.id 
INNER JOIN cars ON sales.car_id = cars.id;

-- 14. Вывести список всех менеджеров и их продажи
SELECT managers.name, managers.surname, sales.price 
FROM managers 
LEFT JOIN sales ON managers.id = sales.manager_id;

-- 15. Вывести все автомобили и привязать к ним продажи
SELECT cars.car_brand, cars.model, sales.price 
FROM sales 
RIGHT JOIN cars ON sales.car_id = cars.id;

-- 16. Добавить новую машину, не указывая ID 
INSERT INTO cars (car_brand, model, body_type, color) 
VALUES ('Mercedes', 'E-Class', 'Sedan', 'Black');

-- 17. Добавить нового менеджера
INSERT INTO managers (name, surname, phone) 
VALUES ('Dmitry', 'Sokolov', '+375291112233');

-- 18. Изменить номер телефона у менеджера с id = 1
UPDATE managers SET phone = '+375290000000' WHERE id = 1;

-- 19. Изменить цвет автомобиля 'Audi' на 'Red'
UPDATE cars SET color = 'Red' WHERE car_brand = 'Audi';

-- 20. Удалить продажу по её ID 
DELETE FROM sales WHERE id = 304;
