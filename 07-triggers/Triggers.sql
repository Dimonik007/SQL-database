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
USE `car_dealership`;

DELIMITER //
CREATE TRIGGER trg_sales_before_insert BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN 
        SET NEW.price = 0;
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_sales_before_update BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN 
        SET NEW.price = OLD.price;
    END IF;
END;//
DELIMITER ;

CREATE TRIGGER trg_sales_after_insert AFTER INSERT ON sales
FOR EACH ROW 
SET @total_revenue = IFNULL(@total_revenue, 0) + NEW.price;

SET @total_revenue = 0;

INSERT INTO sales (manager_id, car_id, date_of_sale, price) 
VALUES (1, 1, '2023-10-10', 45000.00);

SELECT @total_revenue AS 'Total revenue inserted';
