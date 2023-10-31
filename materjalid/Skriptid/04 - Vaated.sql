-----------------------
-- Vaated
-----------------------

USE TestDB;

-- Loome abitabeli

CREATE TABLE Job
(
    ID Int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ContactID Int NOT NULL,
    Company nvarchar(50) NOT NULL DEFAULT '',
    Position nvarchar(50) NOT NULL DEFAULT '',
    CONSTRAINT FK_Contact_Job
      FOREIGN KEY (ContactID) REFERENCES Contact(ID)
);

INSERT INTO Job (ContactID, Company, Position) VALUES
  (1, 'Klouniklubi', 'President'),
  (2, 'MTÜ Tsirkusekool', 'Kloun'),
  (3, 'Kodumarjad', 'Turundaja'),
  (4, 'Metsaviljad MTÜ', 'Varustaja'),
  (5, 'Self-employed', 'Singer'),
  (6, 'USA', 'President'),
  (7, '', 'Teadlane'),
  (8, 'Tesla, Inc', 'CEO and Product Architect'),
  (8, 'Space X', 'CEO & CTO');


-- Päring, mida me sooviks andmebaasi sisse panna

SELECT C.*, J.Company, J.Position
  FROM Contact C INNER JOIN
       Job J ON C.ID = J.ContactID

GO
-- Vaate loomine
CREATE OR ALTER VIEW ContactJobs AS
  SELECT C.*, J.Company, J.Position
    FROM Contact C INNER JOIN
         Job J ON C.ID = J.ContactID
GO

-- Pärime andmeid sarnaselt tabelitele
SELECT * FROM ContactJobs;

-- Vaated kui alampäringute variant
SELECT * FROM 
(
  SELECT C.*, J.Company, J.Position
    FROM Contact C INNER JOIN
         Job J ON C.ID = J.ContactID
) AS ContactJobs;

GO
-- Vaate loomine
CREATE VIEW ContactJobsSorted AS
  SELECT TOP 100 PERCENT C.ID, C.FullName, C.FirstName, C.LastName, J.Company, J.Position
    FROM Contact C INNER JOIN
         Job J ON C.ID = J.ContactID
   ORDER BY C.FullName, J.Company
GO

select * from ContactJobsSorted 
order by FullName, Company