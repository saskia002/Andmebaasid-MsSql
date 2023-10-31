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

-- Ei t��ta, kuna on algv��rtustamata
SET @Count = @Count + 1

-- Kui me IsNull() funktsiooni ei kasutaks, siis rida ei tr�kita
--PRINT 'Count = ' + Cast(@Count as nvarchar(10))
PRINT 'Count = ' + Cast(IsNull(@Count, 0) as nvarchar(10))

GO
DECLARE @Count Int = 0

---- Algv��rtustame
--SET @Count = 0

-- N��d t��tab
SET @Count = @Count + 1

-- ja tr�kib korrektse v��rtuse
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
-- N�ide 2

DECLARE @Value Int, @FullName nvarchar(100)

-- Annab vea, kuna tagasi tuleb mitu rida
--SET @Value = (SELECT ID FROM dbo.Contact )

-- Annab vea, kuna kuigi tagades vaid 1 rea, on siin �le 1 v��rtuse
--SET @Value = (SELECT TOP 1 ID, FullName FROM dbo.Contact ORDER BY ID DESC)

-- T��tab, kuna tagastame vaid 1 rea ja 1 v��rtuse
SET @Value = (SELECT TOP 1 ID FROM dbo.Contact ORDER BY ID DESC)

-- T��tab, kuna tagastame vaid 1 rea ja 1 v��rtuse
SELECT TOP 1 @Value = ID, @FullName = FullName FROM dbo.Contact ORDER BY ID DESC

SELECT @Value AS ID, @FullName AS Name

GO

DECLARE @Count Int = 0, @Mode Int = 1

-- Algv��rtustame muutujad
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

-- Algv��rtustame muutuja
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

-- Algv��rtustame muutuja
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

-- WHILE Ts�kkel
DECLARE @Count Int

-- Algv��rtustame muutuja
SET @Count = 10

WHILE @Count > 0
BEGIN
   PRINT @Count

   IF @Count < 7
     CONTINUE

   SET @Count = @Count - 1
END
GO

