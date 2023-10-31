-----------------------
-- Tabelite ühendamine
-----------------------

-- Loome andmebaasi
CREATE DATABASE TestDB;
go

-- Muudame uue baasi aktiivseks
USE TestDB;
go

-- Loome testimiseks kaks tabelit
CREATE TABLE Toys
(
    ID Int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Toy varchar(50) NOT NULL
);

CREATE TABLE Boys
(
    ID Int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Boy varchar(50) NOT NULL
);

-- Lisame neile tabelitele andmed
INSERT INTO Toys (Toy) 
  VALUES ('Hularõngas'), ('Mängupüss'), ('Mängukaardid'), ('Suupill'), ('Jalgpall');
INSERT INTO Boys (Boy) 
  VALUES ('Madis'), ('Karl'), ('Saamuel'), ('Siim'), ('Juss');


-- Tagastame kontrolliks neis sisalduvad andmed
SELECT * FROM Toys;
SELECT * FROM Boys;


-- CROSS JOIN
SELECT t.Toy, b.Boy
  FROM Toys t CROSS JOIN
       Boys b;

-- CROSS JOIN sama tabeliga
SELECT b1.Boy, b2.Boy
  FROM Boys AS b1 CROSS JOIN
       Boys AS b2;



-- INNER JOIN
ALTER TABLE Boys
  ADD ToyID Int NULL CONSTRAINT FK_Boy_Toy
      FOREIGN KEY (ToyID) REFERENCES Toys(ID);

UPDATE Boys SET ToyID = 3 WHERE ID = 1;
UPDATE Boys SET ToyID = 5 WHERE ID = 2;
UPDATE Boys SET ToyID = 1 WHERE ID = 3;
UPDATE Boys SET ToyID = 4 WHERE ID = 4;

SELECT Boys.Boy, Toys.Toy
  FROM Boys INNER JOIN
       Toys ON Boys.ToyID = Toys.ID; -- and Boys.ID > 1 ;

SELECT Boys.Boy, Toys.Toy
  FROM Boys INNER JOIN
       Toys ON Boys.ToyID <> Toys.ID;

SELECT Boys.Boy, Toys.Toy
  FROM Boys, Toys 

--SELECT Boys.Boy, Toys.Toy
--  FROM Boys NATURAL JOIN Toys -- ON Boys.ToyID = Toys.ToyID;

-----------------------
-- Välised seosed
-----------------------
SELECT Boys.Boy, Toys.Toy
  FROM Boys INNER JOIN
       Toys ON Boys.ToyID = Toys.ID;


SELECT Boys.Boy, Toys.Toy
  FROM Boys LEFT OUTER JOIN Toys ON Boys.ToyID = Toys.ID; 

SELECT Boys.Boy, Toys.Toy
  FROM Boys RIGHT OUTER JOIN Toys ON Boys.ToyID = Toys.ID;

SELECT Boys.Boy, Toys.Toy
  FROM Boys FULL OUTER JOIN
       Toys ON Boys.ToyID = Toys.ID;

SELECT Boys.Boy, Toys.Toy
  FROM Toys LEFT OUTER JOIN Boys ON Boys.ToyID = Toys.ID; 

SELECT Boys.Boy, Toys.Toy
  FROM Boys LEFT OUTER JOIN Toys ON Boys.ToyID = Toys.ID 
UNION
SELECT Boys.Boy, Toys.Toy
  FROM Toys LEFT OUTER JOIN Boys ON Boys.ToyID = Toys.ID; 

SELECT Boys.Boy, Toys.Toy 
  FROM Boys LEFT OUTER JOIN
       Toys ON Boys.ToyID = Toys.ID
UNION
SELECT Boys.Boy, Toys.Toy 
  FROM Toys LEFT OUTER JOIN Boys ON Boys.ToyID = Toys.ID;
--  FROM Boys RIGHT OUTER JOIN Toys ON Boys.ToyID = Toys.ID;


-- Self-joins
CREATE TABLE Employee
(
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name nvarchar(100) NOT NULL
);

--CREATE TABLE Boss
--(
--   EmployeeID Int,
--   BossID int
--);

ALTER TABLE Employee
  ADD  BossID Int NULL CONSTRAINT FK_Employee_Boss
      FOREIGN KEY (BossID) REFERENCES Employee(ID);

INSERT INTO Employee (Name, BossID) VALUES 
  ('Madis', NULL),
  ('Karla', NULL),
  ('Justine', NULL),
  ('Jüri', 1),
  ('Silver', 1),
  ('Saara', 2),
  ('Kristjan', 2),
  ('Christine', NULL),
  ('Torvalds', 6),
  ('Madis', 3),
  ('Tiiu', 9)
  ;      

select * from Employee;

SELECT T.Name AS TootajaNimi, B.Name AS BossiNimi
  FROM Employee AS T LEFT OUTER JOIN
       Employee AS B ON T.BossID = B.ID;



-----------------------
-- Alampäringud
-----------------------

CREATE TABLE Contact 
(
  ID Int NOT NULL IDENTITY(1,1) PRIMARY KEY,
  FullName nvarchar(200) NOT NULL,
  FirstName nvarchar(100) NOT NULL,
  LastName nvarchar(100) NOT NULL
);

CREATE TABLE DesiredJob
(
    ContactID Int NOT NULL,
    Position nvarchar(50) NOT NULL,
    MinSalary money NOT NULL DEFAULT 0,
    MaxSalary money NOT NULL DEFAULT 0,
    IsAvailable bit NOT NULL DEFAULT 0,
    WorkingExperienceInYears int NOT NULL DEFAULT 0
);

CREATE TABLE JobOffer
(
    ID Int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Position varchar(50) NOT NULL,
    Salary money NOT NULL,
    Region nvarchar(50) NOT NULL,
    Description nvarchar(3000) NOT NULL DEFAULT ''
);

INSERT INTO Contact (FullName, FirstName, LastName)
  VALUES ('Nipi tiri', 'Nipi', 'Tiri'),
         ('Pann', '', 'Pann'),
         ('Mari Maasikas', 'Mari', 'Maasikas'),
         ('Jüri Juurikas', 'Jüri', 'Juurikas'),
         ('Sinéad O''Connor', 'Sinéad', 'O''Connor'),
         ('Donald Trump', 'Donald', 'Trump'),
         ('Albert Einstein', 'Albert', 'Einstein'),
         ('Elon Musk', 'Elon', 'Musk');


INSERT INTO DesiredJob (ContactID, Position, MinSalary, MaxSalary, IsAvailable, WorkingExperienceInYears) 
  VALUES (2, 'Vanemkloun', 2000, 4000, 0, 5);
INSERT INTO DesiredJob (ContactID, Position, MinSalary, MaxSalary, IsAvailable, WorkingExperienceInYears)
  VALUES (3, 'Dirigent', 1500, 6000, 1, 3);
INSERT INTO DesiredJob (ContactID, Position, MinSalary, MaxSalary, IsAvailable, WorkingExperienceInYears) 
  VALUES (4, 'CEO', 1000, 2200, 0, 1);
INSERT INTO DesiredJob (ContactID, Position, MinSalary, MaxSalary, IsAvailable, WorkingExperienceInYears) 
  VALUES (6, 'Presdent', 25000, 250000, 1, 20);
INSERT INTO DesiredJob (ContactID, Position, MinSalary, MaxSalary, IsAvailable, WorkingExperienceInYears) 
  VALUES (8, 'Insener', 1800, 7000, 1, 8);


INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
 ('Koorijuht', 1200, 'Pärnu', 'Peab saabuva laulupeo jaoks koore juhendama');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('CEO', 7000, 'Narva', 'Uus kollektiiv vajab energilist juhti');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Insener', 2100, 'Tartu', 'Värske startup soovib leida kogemustega arendajat');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Autojuht', 1000, 'Tartu', 'Transpordifirma otsib head autojuhti');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Pagar', 1500, 'Viljandi', 'Eriti ekstravagantsele pagarile hea väljakutse');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Sekretär', 900, 'Lääne', 'Rõõmus kollektiiv otsib toredat abilist');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Insener', 3000, 'Harju', 'Tuntud firma pakub tööd insenerile');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('President', 30000, 'Rootsi', 'Välisfirma otsib omale presidenti');
INSERT INTO JobOffer (Position, Salary, Region, Description) VALUES 
  ('Diktor', 1400, 'Harju', 'Raadio pakub võimalust uudiseid lugeda');


SELECT Position 
  FROM JobOffer
 GROUP BY Position
 ORDER BY Position;


SELECT Contact.FullName
  FROM Contact INNER JOIN
       DesiredJob ON Contact.ID = DesiredJob.ContactID
 WHERE DesiredJob.Position = 'CEO' AND DesiredJob.MinSalary < 8000;

	   
SELECT Contact.FullName, DesiredJob.Position
  FROM Contact INNER JOIN
       DesiredJob ON Contact.ID = DesiredJob.ContactID
 WHERE DesiredJob.Position in ('Autojuht', 'CEO', 'Diktor', 'Insener', 'Koorijuht', 'Pagar', 'President', 'Sekretär');



SELECT Contact.FullName, DesiredJob.Position
  FROM Contact INNER JOIN
       DesiredJob ON Contact.ID = DesiredJob.ContactID
 WHERE DesiredJob.Position in (
	 SELECT Position 
	  FROM JobOffer
	 GROUP BY Position
  );

SELECT Contact.FullName, DesiredJob.Position
  FROM Contact INNER JOIN
       DesiredJob ON Contact.ID = DesiredJob.ContactID INNER JOIN
       JobOffer ON DesiredJob.Position = JobOffer.Position
 GROUP BY Contact.FullName, DesiredJob.Position

SELECT Contact.FullName, DesiredJob.Position
  FROM Contact INNER JOIN
       DesiredJob ON Contact.ID = DesiredJob.ContactID INNER JOIN
       (
           SELECT Position 
	         FROM JobOffer
	        GROUP BY Position
       ) Offer ON DesiredJob.Position = Offer.Position
 GROUP BY Contact.FullName, DesiredJob.Position


SELECT Contact.FullName,
       (SELECT Min(MaxSalary) 
          FROM DesiredJob 
         WHERE ContactID = Contact.ID) AS MinMaxSalary
   FROM Contact;


SELECT Contact.FullName
  FROM Contact 
 WHERE NOT EXISTS ( 
       SELECT * FROM DesiredJob WHERE Contact.ID = DesiredJob.ContactID
  );






