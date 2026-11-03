
# Salesforce CRM Data Model: MySQL vs. SOQL / Архитектура Salesforce CRM: Сравнение MySQL и SOQL
**Objective / Цель проекта:**
* **EN:** Model the core Salesforce CRM database architecture (`Account`, `Contact`, `Opportunity`, `Case`) and compare how business queries are written in standard **SQL (MySQL)** versus **SOQL (Salesforce Object Query Language)**.
* **RU:** Спроектировать базовую архитектуру Salesforce CRM и наглядно сравнить, как одни и те же бизнес-задачи решаются на стандартном **SQL (MySQL)** и на языке **SOQL**.

## 1. Key Differences: SQL vs. SOQL / Главные отличия SQL от SOQL

| Feature / Особенность | Standard SQL (MySQL) | Salesforce SOQL | 
| ----- | ----- | ----- | 
| **Select all fields / Выбор всех полей** | Allowed via `SELECT *` / Разрешено через `SELECT *` | **Forbidden.** Every field must be listed explicitly / **Запрещено.** Все поля перечисляются вручную | 
| **Joining tables / Связь таблиц (`JOIN`)** | Explicit `JOIN ... ON` / Явный `JOIN ... ON` | **No `JOIN` keyword.** Uses dot notation (`Account.Name`) or relationship subqueries / **Слова `JOIN` нет.** Используется точка или вложенный `SELECT` | 
| **Data Modification / Изменение данных** | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | **Read-only (`SELECT` only).** Modifications use Apex DML / **Только чтение (`SELECT`).** Изменения идут через Apex DML | 

## 2. CRM Data Model / Описание объектов базы данных
* **`Account` (Компании):** B2B client companies (`Id`, `Name`, `Industry`, `Rating`, `AnnualRevenue`).
* **`Contact` (Контакты):** Employees or representatives working at an Account (`FirstName`, `LastName`, `Email`, `AccountId`).
* **`Opportunity` (Сделки):** Potential revenue-generating deals tracked through sales stages (`Name`, `StageName`, `Amount`, `CloseDate`, `AccountId`).
* **`Case` / `Case_` (Тикеты):** Customer support issues linked to an Account and a Contact (`CaseNumber`, `Subject`, `Status`, `Priority`, `AccountId`). *(Named `Case_` in MySQL to avoid keyword conflicts).*

## 3. MySQL Implementation / Реализация на MySQL
**EN:** The following script creates a local relational simulation of the Salesforce schema, populates it with realistic 18-character IDs, and solves 5 business tasks using standard SQL.
**RU:** Скрипт ниже создает локальную реляционную копию структуры Salesforce, заполняет её реалистичными 18-значными ID и решает 5 бизнес-задач с помощью стандартного SQL.

```
-- 1 DDL

CREATE TABLE Account (
    Id VARCHAR(18) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Industry VARCHAR(50),
    Rating VARCHAR(20),
    AnnualRevenue DECIMAL(15, 2),
    PRIMARY KEY (Id)
) ENGINE = InnoDB;

CREATE TABLE Contact (
    Id VARCHAR(18) NOT NULL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(30),
    AccountId VARCHAR(18),
    PRIMARY KEY (Id),
    CONSTRAINT fk_contact_account FOREIGN KEY (AccountId) REFERENCES Account (Id)
) ENGINE = InnoDB;

CREATE TABLE Opportunity (
    Id VARCHAR(18) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    StageName VARCHAR(50) NOT NULL,
    Amount DECIMAL(12, 2),
    CloseDate DATE NOT NULL,
    AccountId VARCHAR(18),
    PRIMARY KEY (Id),
    CONSTRAINT fk_opportunity_account FOREIGN KEY (AccountId) REFERENCES Account (Id)
) ENGINE = InnoDB;

CREATE TABLE Case_ (
    Id VARCHAR(18) NOT NULL,
    CaseNumber VARCHAR(20) NOT NULL,
    Subject VARCHAR(150) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    Priority VARCHAR(20) NOT NULL,
    AccountId VARCHAR(18),
    ContactId VARCHAR(18),
    PRIMARY KEY (Id),
    CONSTRAINT fk_case_account FOREIGN KEY (AccountId) REFERENCES Account (Id),
    CONSTRAINT fk_case_contact FOREIGN KEY (ContactId) REFERENCES Contact (Id)
) ENGINE = InnoDB;


-- 2. DML

INSERT INTO Account (Id, Name, Industry, Rating, AnnualRevenue) VALUES
('0018d00000A1b2CAAV', 'DIW Corporation', 'Technology', 'Hot', 7700000.00),
('0018d00000A1b2DAAW', 'GB Media', 'Communications', 'Warm', 3200000.00),
('0018d00000A1b2EAAX', 'Apex WINTER', 'Finance', 'Hot', 8500000.00),
('0018d00000A1b2FAAY', 'ARENA Logistics', 'Transportation', 'Cold', 450000.00);

INSERT INTO Contact (Id, FirstName, LastName, Email, Phone, AccountId) VALUES
('0038d00000B1c2CAAV', 'Joel', 'Smith', 'j.smith@acme.com', '+1-999-0101', '0018d00000A1b2CAAV'),
('0038d00000B1c2DAAW', 'Sarah', 'Connor', 's.connor@acme.com', '+1-888-0102', '0018d00000A1b2CAAV'),
('0038d00000B1c2EAAX', 'Michael', 'Scott', 'm.scott@globalmedia.com', '+1-777-0201', '0018d00000A1b2DAAW'),
('0038d00000B1c2FAAY', 'Elena', 'Rupor', 'e.rupor@arenafintech.com', '+1-666-0301', '0018d00000A1b2EAAX');

INSERT INTO Opportunity (Id, Name, StageName, Amount, CloseDate, AccountId) VALUES
('0068d00000C1d2CAAV', 'Acme Cloud Migration', 'Closed Won', 120000.00, '2025-02-15', '0018d00000A1b2CAAV'),
('0068d00000C1d2DAAW', 'Acme AI Add-on', 'Negotiation/Review', 65000.00, '2025-06-30', '0018d00000A1b2CAAV'),
('0068d00000C1d2EAAX', 'Global Media CRM License', 'Prospecting', 35000.00, '2025-08-10', '0018d00000A1b2DAAW'),
('0068d00000C1d2FAAY', 'Apex Core Banking Upgrade', 'Closed Won', 250000.00, '2025-01-20', '0018d00000A1b2EAAX'),
('0068d00000C1d2GAAZ', 'Nordic Fleet Tracker', 'Closed Lost', 80000.00, '2025-03-01', '0018d00000A1b2FAAY');

INSERT INTO Case_ (Id, CaseNumber, Subject, Status, Priority, AccountId, ContactId) VALUES
('5008d00000D1e2CAAV', '00001001', 'API Rate Limit Exceeded', 'Escalated', 'High', '0018d00000A1b2CAAV', '0038d00000B1c2CAAV'),
('5008d00000D1e2DAAW', '00001002', 'Billing Invoice Question', 'Closed', 'Low', '0018d00000A1b2DAAW', '0038d00000B1c2EAAX'),
('5008d00000D1e2EAAX', '00001003', 'SSO Login Failure in Production', 'Working', 'High', '0018d00000A1b2EAAX', '0038d00000B1c2FAAY');

-- 3. SQL QUERIES

-- 1: Filtering (Active/Won deals > 50,000)

SELECT Id, Name, StageName, Amount, CloseDate
FROM Opportunity
WHERE StageName != 'Closed Lost' AND Amount > 50000
ORDER BY Amount DESC;

-- 2: Child-to-Parent (Contacts and their Account info)
SELECT c.FirstName, c.LastName, c.Email, a.Name AS AccountName, a.Industry
FROM Contact c
LEFT JOIN Account a ON c.AccountId = a.Id;

-- 3: Parent-to-Child (Accounts and their Deals)
SELECT a.Name AS AccountName, a.Industry, o.Name AS OpportunityName, o.StageName, o.Amount
FROM Account a
LEFT JOIN Opportunity o ON a.Id = o.AccountId
ORDER BY a.Name;

-- 4: Total amount per Account > 100,000
SELECT a.Name AS AccountName, COUNT(o.Id) AS DealsCount, SUM(o.Amount) AS TotalAmount
FROM Opportunity o
JOIN Account a ON o.AccountId = a.Id
GROUP BY a.Id, a.Name
HAVING SUM(o.Amount) > 100000;

-- 5: Accounts with open High-priority Cases
SELECT Id, Name, Industry, Rating
FROM Account
WHERE Id IN (
    SELECT AccountId 
    FROM Case_ 
    WHERE Priority = 'High' AND Status != 'Closed'
);


```

## 4. SOQL Implementation / Реализация на SOQL

**EN:** The exact same 5 business tasks written in Salesforce SOQL. Notice the absence of `JOIN` statements and the use of dot-notation (`Account.Name`) and relationship subqueries (`SELECT ... FROM Opportunities`).
**RU:** Те же 5 задач, написанные на Salesforce SOQL. Обратите внимание на полное отсутствие `JOIN` и использование точечной нотации (`Account.Name`) вместе с вложенными подзапросами по имени связей (`SELECT ... FROM Opportunities`).

```
-- 1: Filtering
-- Использование SELECT * запрещено, поля перечисляются явно.
SELECT Id, Name, StageName, Amount, CloseDate
FROM Opportunity
WHERE StageName != 'Closed Lost' AND Amount > 50000
ORDER BY Amount DESC

-- 2: Child-to-Parent
-- Обращение к данным родительской компании идет напрямую через точку (Account.Name).
SELECT FirstName, LastName, Email, Account.Name, Account.Industry
FROM Contact

-- 3: Parent-to-Child
-- Вложенный подзапрос использует системное множественное имя связи (Opportunities).
SELECT Name, Industry, (SELECT Name, StageName, Amount FROM Opportunities)
FROM Account

-- 4: Aggregation
-- Группировка происходит через связь Account.Name без объединения таблиц.
SELECT Account.Name, COUNT(Id) dealsCount, SUM(Amount) totalAmount
FROM Opportunity
GROUP BY Account.Name
HAVING SUM(Amount) > 100000

-- 5: Semi-Join 
-- В SOQL объект называется просто Case. Синтаксис IN идентичен SQL.
SELECT Id, Name, Industry, Rating
FROM Account
WHERE Id IN (
    SELECT AccountId 
    FROM Case 
    WHERE Priority = 'High' AND Status != 'Closed'
)
