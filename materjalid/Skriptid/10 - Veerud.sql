USE TestDB;
GO
------------------------------------
-- Tabeli veergude erivõimalused
------------------------------------

CREATE TABLE dbo.Gender
(
	ID Int PRIMARY KEY,
	Name nvarchar(20) NOT NULL
)

INSERT INTO Gender VALUES (1, 'Unknown'), (2, 'Male'), (3, 'Female'), (4, 'Undecided')

CREATE TABLE dbo.Person
(
	ID Int PRIMARY KEY IDENTITY(100, 1),
	FirstName nvarchar(100) NOT NULL, 
	LastName nvarchar(100) NOT NULL, 
	FullName AS (FirstName + ' ' + LastName), -- kalkuleeritud veerg
	GenderID Int NOT NULL DEFAULT 1 FOREIGN KEY REFERENCES Gender(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	PersonalCode nvarchar(20) NULL UNIQUE, -- unikaalsuse nõue
	Age int NULL CHECK (Age BETWEEN 0 AND 110) -- kontrolliga veerg
)


INSERT INTO Person (FirstName, LastName, Age)
  VALUES ('Karl', 'Noor', 12)
INSERT INTO Person (FirstName, LastName, Age, PersonalCode)
  VALUES ('Mats', 'Keskmine', 20, '123456')
INSERT INTO Person (FirstName, LastName, Age, PersonalCode)
  VALUES ('Siim', 'Vanem', 28, '123456')
INSERT INTO Person (ID, FirstName, LastName, Age)
  VALUES (7, 'Siim', 'Vanem', 28)

select * from Person

delete from Gender where ID = 1


select NewID()
select NewID()
select NewID()
select NewSequentialID()

CREATE TABLE dbo.Posting
(
	ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NewSequentialID(),
	PersonID Int NOT NULL REFERENCES Person(ID)
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	Text nText NULL DEFAULT N''
)
GO

INSERT INTO Posting (PersonID, Text)
  VALUES (102, 'Mingi tekst')
INSERT INTO Posting (PersonID, Text)
  VALUES (102, 'Mingi muu tekst')
INSERT INTO Posting (ID, PersonID, Text)
  VALUES ('AE42763C-72F6-4C6D-986F-E697604A0749', 
          103, 'Mingi muu tekst')

select * from Posting

delete from Person where ID = 102

------------------------------------
-- Järjestused - SEQUENCES
------------------------------------
CREATE SEQUENCE dbo.TestIdSequence AS Int
  START WITH 100
  INCREMENT BY 1
  ;

CREATE SEQUENCE dbo.TestNegativeCounter 
  START WITH 100 
  INCREMENT BY -1
  ;

SELECT * 
  FROM sys.sequences 
 WHERE name = 'TestNegativeCounter' ;  

SELECT NEXT VALUE FOR TestIdSequence AS NextVal, 
       NEXT VALUE FOR dbo.TestNegativeCounter AS PrevVal;
	   

CREATE TABLE dbo.WeatherEvent
(
	ID Int NOT NULL PRIMARY KEY DEFAULT (NEXT VALUE FOR TestIdSequence),
	Temperature Int NOT NULL
)

INSERT INTO dbo.WeatherEvent (Temperature) VALUES (3), (7), (5)
INSERT INTO dbo.WeatherEvent (ID, Temperature) VALUES (56, 8)

SELECT * FROM dbo.WeatherEvent


-- Lisame veeru lisamise aja salvestamiseks

ALTER TABLE dbo.WeatherEvent
  ADD EventTime DateTime2 NOT NULL DEFAULT SYSDATETIME();
GO

INSERT INTO dbo.WeatherEvent (Temperature) VALUES (6)

UPDATE WeatherEvent
   SET Temperature = 6,
       EventTime = SYSDATETIME()
 WHERE ID = 107

-- Rowversion variant
ALTER TABLE dbo.WeatherEvent
  ADD Ver ROWVERSION NOT NULL;
GO


UPDATE WeatherEvent
   SET Temperature = 6,
       EventTime = SYSDATETIME()
 WHERE ID = 107 AND Ver = 0x0000000000002719

SELECT @@ROWCOUNT

SELECT * FROM dbo.WeatherEvent
order by Ver desc

------------------------------------
-- Binaarsed andmed
------------------------------------

SELECT 0x41

SELECT CAST(0x07 as char(1))

SELECT CAST(0x41 as char(1))
SELECT CAST('A' AS binary(1))
SELECT CAST('Tekst binaarsel kujul' as varbinary(max))
SELECT CAST(0x54656B73742062696E61617273656C206B756A756C as varchar(50))

-- Convert lubab vajadusel ära määrata ka konversiooni stiili
SELECT CONVERT(char(1), 0x41)
SELECT CONVERT(binary(1), 'A')
SELECT CONVERT(varbinary(max), 'Tekst binaarsel kujul')
SELECT CONVERT(varchar(50), 0x54656B73742062696E61617273656C206B756A756C)

-- Convert lubab vajadusel ära määrata ka konversiooni stiili
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
DECLARE @s varchar(100)='0x48656C6C6F';
SELECT CONVERT(varbinary(max), @s);     --- 0x307834383635364336433646
GO
-- Näiteks saame string-binary konversiooni juures määrata selle, et algne andmetüüp on hex väärtusi sisaldav string
DECLARE @s varchar(100)='0x48656C6C6F';
SELECT CONVERT(varbinary(max), @s, 1);  --- 0x48656C6C6F
GO

SELECT CAST(0x54657265 AS BigInt)     --- 1415934565
SELECT CAST(1415934565 AS varbinary(max))  --- 0x54657265

-- Sarnane asi formaadist, mis on kasutusel ROWVERSION tüübi puhul
SELECT @@DBTS                         --- 0x000000000001DC93
SELECT CAST(0x000000000001DC93 AS BigInt)     --- 122003
SELECT CAST(122003 AS varbinary(max))

SELECT CAST(@@DBTS AS BigInt)     --- 122003

-- Konverteerime teksti ASCII sümboliteks ning seejärel kümnendsüsteemi
SELECT CAST('Tere' AS varbinary(max))     --- 0x54657265
SELECT CAST(CAST('Tere' AS varbinary(max)) as bigint) --- 1415934565

--DECLARE @dt DateTime = GetDate()
DECLARE @dt DateTimeOffset = SysDateTime()
SELECT CONVERT(varchar(50), @dt, 127)
GO

------------------------------------
-- Failide lisamine andmebaasi
------------------------------------
CREATE TABLE [dbo].[Document](
    ID Int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FileName nvarchar(200) NULL,
    FileExtension nvarchar(50) NULL,
    Content varbinary(max) NULL
)

-- Loeme andmed tabelisse
INSERT [dbo].[Document] (FileName, FileExtension, Content)
SELECT 'ECMA-335.pdf', 'pdf', FileContent.*
FROM OPENROWSET
    (BULK 'C:\SQL\ECMA-335.pdf', SINGLE_BLOB) FileContent
 
INSERT[dbo].[Document] (FileName, FileExtension, Content)
SELECT 'Saturn - Wikipedia.html','html', FileContent.*
FROM OPENROWSET
    (BULK 'C:\SQL\Saturn - Wikipedia.html', SINGLE_BLOB) FileContent

SELECT *, Len(Content) AS Length FROM dbo.Document

------------------------------------
-- FILESTREAM
------------------------------------
-- Lisame andmebaasile FILESTREAM failigrupi
CREATE DATABASE FilestreamDB
ON
	PRIMARY ( NAME = FS1,
		FILENAME = 'c:\SQL\Data\Filestream1.mdf'),
	FILEGROUP FileStreamGroup1 CONTAINS FILESTREAM (NAME = FS2,
		FILENAME = 'c:\SQL\Data\filestream1')
	LOG ON  ( NAME = FSlog1,
		FILENAME = 'c:\SQL\Logs\Filestream1log.ldf')
GO

USE FilestreamDB;
GO

CREATE TABLE dbo.Document
(
	ID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE DEFAULT (NewSequentialID()), 
    FileName nvarchar(200) NULL,
    FileExtension nvarchar(50) NULL,
    Content varbinary(max) FILESTREAM NULL
)
GO

-- Lisame ridu
INSERT [dbo].[Document] (FileName, FileExtension, Content)
VALUES ('Test 1', '000', null)

INSERT [dbo].[Document] (FileName, FileExtension, Content)
VALUES ('Stringi sisu', '000', CAST ('' as varbinary(max)));

INSERT [dbo].[Document] (FileName, FileExtension, Content)
VALUES ('Faili sisu', 'FFF', CAST ('Seismic Data' as varbinary(max)));


INSERT [dbo].[Document] (FileName, FileExtension, Content)
SELECT 'ECMA-335.pdf', 'pdf', FileContent.*
FROM OPENROWSET
    (BULK 'C:\SQL\ECMA-335.pdf', SINGLE_BLOB) FileContent
 
INSERT[dbo].[Document] (FileName, FileExtension, Content)
SELECT 'Saturn - Wikipedia.html','html', FileContent.*
FROM OPENROWSET
    (BULK 'C:\SQL\Saturn - Wikipedia.html', SINGLE_BLOB) FileContent

GO

SELECT *, Len(content) AS Length FROM dbo.Document
GO

UPDATE dbo.Document
   SET Content = CAST('Xray 1' as varbinary(max))
 WHERE ID = '363C28A8-FD49-ED11-A239-2C33587BBF19';


DELETE dbo.Document 
 WHERE ID = '7EB954AF-FD49-ED11-A239-2C33587BBF19'

GO

-- USE master;
-- DROP DATABASE FilestreamDB;
GO

-- FileTables


------------------------------------
-- Kuupäevad ja ajavööndid
------------------------------------
/*  
    Suveajale üleminek "Central European Standard Time" ajavööndis: 
    nihe muutub +01:00 -> +02:00   
    Muutus ise toimub 26. märtsil 2017 at 02:00:00.   
    Kohendatud kohalik aeg suli siis 2017-03-26 03:00:00.  
*/  

-- Euroopa aeg enne suveajale üle minekut (+01:00)
SELECT CONVERT(datetime2(0), '2017-03-26T01:01:00', 126)     
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-03-29 01:01:00 +01:00   

/*
  Kella 02:00 ja 03:00 vaheline ülemineku aeg liigutab 
  nihke ühe tunni võrra edasi ning esitab suveajana
*/
SELECT CONVERT(datetime2(0), '2017-03-26T02:01:00', 126)   
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-03-29 03:01:00 +02:00

-- Peale kella 03:00 esitatakse ajad suveaja nihkega (+02:00)
SELECT CONVERT(datetime2(0), '2017-03-26T03:01:00', 126)   
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-03-29 03:01:00 +02:00  

/*  
    Tagasi talveajale liikumine  
    "Central European Standard Time" tsoonis: 
    Nihe muutub +02:00 -> +01:00.  
    Üleminek toimub 29. Oktoobril 2017 at 03:00:00.   
    Kohendatud kohalik aeg tuleb 2017-10-29 03:00:00   
*/  

-- Aeg enne muutust on suveaja nihkega (+02:00)
SELECT CONVERT(datetime2(0), '2017-10-29T01:01:00', 126)      
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-10-25 01:01:00 +02:00  

/*
  Ülemineku intervalli esitatakse talveaja järgi    
*/
SELECT CONVERT(datetime2(0), '2017-10-29T02:00:00', 126)   
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-10-25 02:00:00 +02:00  

-- Ajad peale kella 3:00 esitatakse talveaja järgi
SELECT CONVERT(datetime2(0), '2017-10-29T03:00:00', 126)   
AT TIME ZONE 'Central European Standard Time';  
-- Tulemus: 2015-10-25 03:00:00 +01:00  


USE AdventureWorks2014;  
GO  

SELECT SalesOrderID, OrderDate,   
    OrderDate AT TIME ZONE 'Pacific Standard Time' AS OrderDate_TimeZonePST,  
    OrderDate AT TIME ZONE 'Pacific Standard Time'   
    AT TIME ZONE 'Central European Standard Time' AS OrderDate_TimeZoneCET  
FROM Sales.SalesOrderHeader;
GO

USE AdventureWorks2016;  
GO  

-- Näide tabeli tasemel ajalugu säilitava tabeli puhul
DECLARE @ASOF datetimeoffset;  
SET @ASOF = DATEADD (month, -1, GETDATE()) AT TIME ZONE 'UTC';  

SELECT BusinessEntityID, PersonType, NameStyle, Title,   
    FirstName, MiddleName,  
    ValidFrom AT TIME ZONE 'Pacific Standard Time' 
FROM  Person.Person_Temporal  
FOR SYSTEM_TIME AS OF @ASOF;  
  

-- Ajavööndite teada saamine
select * from sys.time_zone_info
