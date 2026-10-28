
CREATE SCHEMA IF NOT EXISTS car_dealership;
USE car_dealership;

-- 2. DDL
CREATE TABLE IF NOT EXISTS managers (
    id INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS cars (
    id INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
    car_brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    body_type VARCHAR(30) NOT NULL,
    color VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS sales (
    id INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
    manager_id INT NOT NULL,
    car_id INT NOT NULL,
    date_of_sale DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (manager_id) REFERENCES managers (id),
    FOREIGN KEY (car_id) REFERENCES cars (id)
);

-- 3.  DML

--справочник
INSERT INTO managers VALUES (1, 'Ivan', 'Ivanov', '+375293467764');

INSERT INTO managers (name, surname, phone) VALUES 
    ('Andrey', 'Petrovich', '+375296769036'),
    ('Victoria', 'Alderanova', '+375297566457');

INSERT INTO cars VALUES (12, 'BMW', 'M3', 'Sedan', 'Grey');

INSERT INTO cars (id, car_brand, model, body_type, color) VALUES 
    (23, 'BMW', 'M5', 'Sedan', 'Black'),
    (34, 'Audi', 'Q7', 'SUV', 'White');

INSERT INTO sales (id, manager_id, car_id, date_of_sale, price) VALUES 
    (112, 1, 12, '2023-07-28', 70000.00),
    (203, 2, 23, '2023-03-22', 95000.00),
    (304, 3, 34, '2023-02-23', 45000.00);
