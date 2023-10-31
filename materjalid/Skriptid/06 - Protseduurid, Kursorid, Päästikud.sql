-- STORED PROCEDURE
CREATE PROCEDURE dbo.GetContactJobCount
  @FirstName nvarchar(50) = ''
AS
BEGIN
  SET @FirstName = NULLIF(@FirstName, '')

  select C.FullName, Count(J.ID) AS NumberOfJobs
    from Contact C LEFT OUTER JOIN 
         Job J ON C.ID = J.ContactID
   where (@FirstName IS NULL) OR (C.FirstName = @FirstName)
   group by C.FullName

   -- RETURN 1 � see ei tagasta mitte andmeid, vaid spetsiaalse tagastuskoodi
END

GO
-- Protseduuri v�lja kutsumine
-- K�ik kontaktid
EXECUTE dbo.GetContactJobCount

-- K�ik kontaktid
EXEC dbo.GetContactJobCount ''

-- K�ik kontaktid
EXEC dbo.GetContactJobCount NULL

-- K�ik kontaktid
EXEC dbo.GetContactJobCount default

-- �ks kontakt
EXEC dbo.GetContactJobCount 'Elon'
GO

-- Mitu select lauset �hes protseduuris
CREATE PROCEDURE dbo.GetContactData @ContactID Int
AS
BEGIN
  SELECT FullName, FirstName, LastName FROM Contact 
   WHERE ID = @ContactID

  SELECT Position, MinSalary, MaxSalary, WorkingExperienceInYears 
    FROM DesiredJob
   WHERE ContactID = @ContactID

  SELECT Company, Position FROM Job WHERE ContactID = @ContactID
END
GO

-- K�ivitame p�ringu
EXEC GetContactData 8







-- Kursorid
DECLARE @ID as Int;
DECLARE @FullName as nVarChar(250);
 
-- Deklareerime kursori
DECLARE ContactCursor CURSOR FOR
   SELECT ID, FullName FROM dbo.Contact;
 
-- Avame kursori 
OPEN ContactCursor;
-- P�rime esimese rea v��rtused muutujatesse
FETCH NEXT FROM ContactCursor INTO @ID, @FullName;
 
-- Seni kuni on veel ridu tulemas
WHILE @@FETCH_STATUS = 0
BEGIN
   -- Teeme midagi andmetega
   PRINT Cast(@ID as VARCHAR (50)) + ' ' + @FullName;

   -- Kutsume v�lja j�rgmise rea
   FETCH NEXT FROM ContactCursor INTO @ID, @FullName;
END
 
-- Sulgeme ja deallokeerime kursori
CLOSE ContactCursor;
DEALLOCATE ContactCursor;

GO



-- Kursor muutuja kujul
-- Kursorid
DECLARE @ID as Int;
DECLARE @FullName as nVarChar(250);
 
-- Deklareerime kursori
DECLARE @ContactCursor AS CURSOR 

SET @ContactCursor = CURSOR FOR
   SELECT ID, FullName FROM dbo.Contact;
 
-- Avame kursori 
OPEN @ContactCursor;
-- P�rime esimese rea v��rtused muutujatesse
FETCH NEXT FROM @ContactCursor INTO @ID, @FullName;
 
-- Seni kuni on veel ridu tulemas
WHILE @@FETCH_STATUS = 0
BEGIN
   -- Teeme midagi andmetega
   PRINT Cast(@ID as VARCHAR (50)) + ' ' + @FullName;

   -- Kutsume v�lja j�rgmise rea
   FETCH NEXT FROM @ContactCursor INTO @ID, @FullName;
END
 
-- Sulgeme ja deallokeerime kursori
CLOSE @ContactCursor;
DEALLOCATE @ContactCursor;
GO

-- Parem kursori j�udlus
DECLARE ContactCursor CURSOR FORWARD_ONLY STATIC FOR
     SELECT ID, FullName FROM dbo.Contact;
GO




-- P��STIKUD

-- See p��stik keelab rea lisamise Kontakt tabelisse kui
-- seal on juba samasuguse t�isnimega kontakt.
CREATE TRIGGER Contact_ValidateContactName ON Contact
AFTER INSERT, UPDATE
AS
  IF EXISTS (SELECT C.ID 
               FROM Contact AS C JOIN 
                    inserted AS i ON C.FullName = i.FullName AND C.ID <> i.ID
            )
  BEGIN
    RAISERROR ('Selline TaisNimi on juba kasutusel.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN 
  END;

GO

-- Vaatame, kas on juba sellise ID-ga kasutaja
select * from Contact where ID = 9

-- Lisame paar uut kasutajat
INSERT INTO Contact (FullName, FirstName, LastName) VALUES ('Saapa Sass', 'Sass', 'Saabas')
INSERT INTO Contact (FullName, FirstName, LastName) VALUES ('Saapa Sass', 'Sass 2', 'Saabas 2')

update Contact set FullName = 'Pann' where ID = 9

-- Eemaldame testimiseks m�eldud kasutaja
DELETE FROM Contact where ID = 9

