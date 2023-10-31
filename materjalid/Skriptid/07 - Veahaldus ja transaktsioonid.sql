USE TestDB;
GO

-- Vigade haldus
CREATE TABLE dbo.TestRethrow
(    ID INT PRIMARY KEY
);
GO

BEGIN TRY
    INSERT dbo.TestRethrow(ID) VALUES(1);
--  Force error 2627, Violation of PRIMARY KEY constraint to be raised.
    INSERT dbo.TestRethrow(ID) VALUES(1);
END TRY
BEGIN CATCH
    PRINT 'In catch block. ' + ERROR_MESSAGE();
    THROW;
END CATCH;

-- Transaktsioonide testimine

-- Testime lihtsat ebaedukat tehingut
BEGIN TRANSACTION;
SELECT * FROM Boys;
UPDATE Boys SET Boy = 'Triin' WHERE ID = 2;
SELECT * FROM Boys;
ROLLBACK;
SELECT * FROM Boys;

-- Testime ka edukat tehingut
BEGIN TRANSACTION;
SELECT * FROM Boys;
INSERT INTO Boys (Boy, ToyID) VALUES ('Sven', 5);
SELECT * FROM Boys;
COMMIT;
SELECT * FROM Boys;


--select * from Kontakt
--select * from SoovitudAmet

-- Esmalt  oleme kindlad, et kontaktide ja soovitud ametite vahel on v�line seos
ALTER TABLE dbo.DesiredJob ADD CONSTRAINT
	FK_DesiredJob_Contact FOREIGN KEY ( ContactID ) 
         REFERENCES dbo.Contact ( ID )
GO

-- SET XACT_ABORT ON sunnib transaktsiooni l�bi kukkuma, kui m�ni viga juhtub 
-- - n�iteks viidete piirangute viga 
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;
        -- See rida p�hjustab vea kuna eksisteerib seotud ridu
        DELETE FROM Contact WHERE ID = 2;

    -- Kui DELETE �nnestub, l�peta transaktsioon edukalt.
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Kui oli viga, p��ame teada saada nii palju infot kui v�imalik.
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState,
        ERROR_LINE () AS ErrorLine, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_MESSAGE() AS ErrorMessage;

    -- Testime XACT_STATE v��rtust:
        -- Kui 1, on transaktsioon l�petatav
        -- Kui -1, pole transaktsioon l�petatav ja tuleks tagasi v�tta
        -- XACT_STATE = 0 t�hendab, et transaktsiooni pole ja commit v�i 
        -- rollback operatsioonid p�hjustaksid ise vea.

    -- Testime kas transaktsioon pole edukalt l�petatav.
    IF (XACT_STATE()) = -1
    BEGIN
        PRINT N'Transaktsioon pole l�petatav. T�histame transaktsiooni.'
         ROLLBACK TRANSACTION;
    END;

    -- Testime, kas transaktsioon on l�petatav.
    IF (XACT_STATE()) = 1
    BEGIN
        PRINT N'Transaktsioon on l�petatav'
        COMMIT TRANSACTION;   
    END;
END CATCH;


-- Isolatsiooni tasemed ja p�ringu vihjed
select Contact.FullName, DesiredJob.Position
  from Contact WITH (READUNCOMMITTED) left outer join
       DesiredJob WITH (READUNCOMMITTED) 
         on Contact.ID = DesiredJob.ContactID
 order by Contact.FullName


 CREATE TABLE TestX
 ( ID Int PRIMARY KEY,
   RV ROWVERSION,
 )

 ALTER TABLE TestX
 ADD Value Int DEFAULT 0

 INSERT TestX (ID) VALUES (1), (2)

 select * from TestX

 update TestX set Value = 2 
  where ID = 1 and RV = 0x00000000000007D3
 select @@ROWCOUNT
