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
