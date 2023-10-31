USE TestDB;
GO

--  Control Flow

IF NULL = NULL
BEGIN
  PRINT 'TRUE'
END
ELSE
   PRINT 'FALSE'

DECLARE @Count Int

-- Ei tööta, kuna on algväärtustamata
SET @Count = @Count + 1

-- Kui me IsNull() funktsiooni ei kasutaks, siis rida ei trükita
--PRINT 'Count = ' + Cast(@Count as nvarchar(10))
PRINT 'Count = ' + Cast(IsNull(@Count, 0) as nvarchar(10))

GO
DECLARE @Count Int = 0

---- Algväärtustame
--SET @Count = 0

-- Nüüd töötab
SET @Count = @Count + 1

-- ja trükib korrektse väärtuse
PRINT 'Count = ' + Cast(@Count as nvarchar(10))

GO

--DECLARE @Count Int

---- 1. variant - traditsiooniline omistamine
--SET @Count = (select ...)

---- 2. variant - omistamine select lause sees
--SELECT @First = ID FROM ...

DECLARE @Count Int, @Name nvarchar(100)

SET @Count = IsNull((select Count(ID) from Contact), 0)

select @Count = Count(ID), @Name = FullName from Contact 

GO
-- Näide 2

DECLARE @Value Int, @FullName nvarchar(100)

-- Annab vea, kuna tagasi tuleb mitu rida
--SET @Value = (SELECT ID FROM dbo.Contact )

-- Annab vea, kuna kuigi tagades vaid 1 rea, on siin üle 1 väärtuse
--SET @Value = (SELECT TOP 1 ID, FullName FROM dbo.Contact ORDER BY ID DESC)

-- Töötab, kuna tagastame vaid 1 rea ja 1 väärtuse
SET @Value = (SELECT TOP 1 ID FROM dbo.Contact ORDER BY ID DESC)

-- Töötab, kuna tagastame vaid 1 rea ja 1 väärtuse
SELECT TOP 1 @Value = ID, @FullName = FullName FROM dbo.Contact ORDER BY ID DESC

SELECT @Value AS ID, @FullName AS Name

GO

DECLARE @Count Int = 0, @Mode Int = 1

-- Algväärtustame muutujad
SET @Count = 0
SET @Mode = 1

IF @Mode = 1 
BEGIN
    SET @Count = (select count(ContactID) from DesiredJob)
END
ELSE
BEGIN
    SET @Count = (select count(ID) from JobOffer)
END

SELECT @Count AS Cnt
GO

IF EXISTS (SELECT 1 FROM JobOffer)
BEGIN
  SELECT 1
END


-- CASE 1. variant
DECLARE @NameOrderMode Int 

-- Algväärtustame muutuja
SET @NameOrderMode = 4

-- Lihtne variant
SELECT CASE @NameOrderMode 
           WHEN 1 THEN FirstName  
           WHEN 2 THEN LastName 
           WHEN 3 THEN FirstName + ' ' + LastName 
           WHEN 4 THEN LastName + ', ' + FirstName 
           ELSE ''
       END AS Name,
	   ID
 FROM Contact 
GO

-- CASE 2. variant
DECLARE @NameOrderMode Int 

-- Algväärtustame muutuja
SET @NameOrderMode = 4

-- otsinguga variant
SELECT CASE 
           WHEN @NameOrderMode = 1 THEN FirstName 
           WHEN @NameOrderMode = 2 THEN LastName 
           WHEN @NameOrderMode = 3 THEN Trim(FirstName + ' ' + LastName)
           WHEN @NameOrderMode = 4 THEN Trim(LastName + ', ' + FirstName)
           ELSE ''
        END AS Name 
  FROM Contact
GO

-- WHILE Tsükkel
DECLARE @Count Int

-- Algväärtustame muutuja
SET @Count = 10

WHILE @Count > 0
BEGIN
   PRINT @Count

   IF @Count < 7
     CONTINUE

   SET @Count = @Count - 1
END
GO

