# Laboratory Work №1: Relational Database Design & Normalization (3NF)

**Objective:** Design 3 real-world relational databases, choose optimal data types, define primary (`PK`) and foreign (`FK`) keys, and normalize the schemas to the Third Normal Form (3NF).

---

## Example 1: Car Dealership Database

This database describes car sales handled by dealership managers. To comply with **3NF**, entities are split into three tables: manager and car details are extracted into separate reference catalogs to avoid data duplication during repeated sales.

### 1. Table `managers`
*Primary Key:* `id`

| id (PK) | name | surname | phone |
| :--- | :--- | :--- | :--- |
| **1** | Ivan | Ivanov | +375293467764 |
| **2** | Andrey | Petrov | +375296763436 |
| **3** | Victoria | Aldanova | +375297564457 |

- **Data Types Choice:**
  * `id`: `INT AUTO_INCREMENT` — integer unique identifier.
  * `name`, `surname`: `VARCHAR(50)` — variable-length character strings.
  * `phone`: `VARCHAR(20)` — string (not `INT`, as phone numbers can contain `+`, brackets, or leading zeros).

### 2. Table `cars`
*Primary Key:* `id`

| id (PK) | car_brand | model | body_type | color |
| :--- | :--- | :--- | :--- | :--- |
| **12** | BMW | M3 | sedan | gray |
| **23** | BMW | M5 | sedan | black |
| **34** | Audi | Q7 | SUV | white |

- **Data Types Choice:**
  * `id`: `INT AUTO_INCREMENT` — primary key.
  * `car_brand`, `model`, `body_type`, `color`: `VARCHAR(50)` — vehicle text attributes.

### 3. Table `sales`
*Primary Key:* `id` | *Foreign Keys:* `manager_id` -> `managers(id)`, `car_id` -> `cars(id)`

| id (PK) | manager_id (FK) | car_id (FK) | date_of_sale | price |
| :--- | :--- | :--- | :--- | :--- |
| **112** | 1 | 12 | 2023-03-28 | 70000.00 |
| **223** | 2 | 23 | 2023-03-12 | 95000.00 |
| **334** | 3 | 34 | 2023-02-23 | 45000.00 |

- **Data Types Choice:**
  * `date_of_sale`: `DATE` — specialized type for storing dates in `YYYY-MM-DD` format.
  * `price`: `DECIMAL(10, 2)` — precise financial data type (eliminates floating-point rounding errors).

---

## Example 2: University Structure Database

Models the structure of faculties, academic groups, and deans. Brought to **3NF**: dean details (`s_name`, `s_dob`) are extracted from the group and faculty tables into a separate relation `staff`, which eliminates the transitive dependency `grp -> faculty -> staff`.

### 1. Table `staff` (Faculty Deans / Instructors)
*Primary Key:* `s_id`

| s_id (PK) | s_name | s_dob |
| :--- | :--- | :--- |
| **1** | John Smith | 1974-01-12 |
| **2** | Joe Black | 1984-12-23 |
| **3** | Jane Dow | 1985-05-28 |

### 2. Table `faculty`
*Primary Key:* `f_id` | *Foreign Key:* `f_dean_id` -> `staff(s_id)`

| f_id (PK) | f_name | f_dean_id (FK) |
| :--- | :--- | :--- |
| **1** | Faculty of Computer Systems | 1 |
| **2** | Faculty of Information Technologies | 2 |
| **3** | Faculty of Economics | 3 |

### 3. Table `grp` (Academic Groups)
*Primary Key:* `g_id` | *Foreign Key:* `g_faculty` -> `faculty(f_id)`

| g_id (PK) | g_num | g_start_year | g_faculty (FK) |
| :--- | :--- | :--- | :--- |
| **1** | 080255 | 2020 | 1 |
| **2** | 080555 | 2020 | 2 |
| **3** | 280355 | 2022 | 3 |

- **Data Types Choice:**
  * `s_id`, `f_id`, `g_id`: `INT AUTO_INCREMENT` (Primary keys).
  * `s_dob`: `DATE` (Employee birth date).
  * `g_start_year`: `YEAR` or `SMALLINT` (Group enrollment year).
  * `g_num`: `VARCHAR(10)` (Group number is stored as a string to preserve leading zeros in numbers like `080255`).

---

## Example 3: B2B CRM System (Clients and Deals Tracking)

Describes client companies, their contact persons, and commercial opportunities (deals). The schema is in **3NF**: company profile details are stored exclusively in the `accounts` table, while contacts and opportunities reference it via the `account_id` foreign key.

### 1. Table `accounts` (Client Companies)
*Primary Key:* `account_id`

| account_id (PK) | company_name | industry |
| :--- | :--- | :--- |
| **1** | EPAM Systems | IT |
| **2** | Belinvestbank | Banking |

### 2. Table `contacts` (Contact Persons)
*Primary Key:* `contact_id` | *Foreign Key:* `account_id` -> `accounts(account_id)`

| contact_id (PK) | full_name | email | account_id (FK) |
| :--- | :--- | :--- | :--- |
| **10** | Dmitry Dashinsky | dmitry@epam.com | 1 |
| **20** | Ivan Guk | ivan@belinvest.by | 2 |

### 3. Table `opportunities` (Deals)
*Primary Key:* `opp_id` | *Foreign Key:* `account_id` -> `accounts(account_id)`

| opp_id (PK) | deal_title | amount | close_date | account_id (FK) |
| :--- | :--- | :--- | :--- | :--- |
| **501** | Cloud Migration | 25000.00 | 2026-12-31 | 1 |
| **502** | Security Audit | 15000.00 | 2026-11-15 | 2 |
