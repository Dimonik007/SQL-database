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
