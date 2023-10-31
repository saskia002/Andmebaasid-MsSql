USE TestDB;
GO

CREATE FUNCTION dbo.udfGetContactMinimumDesiredMaxSalary (@ContactID int)
RETURNS Money
AS
BEGIN
  DECLARE @MinMaxPalk Money

  SET @MinMaxPalk = 
    IsNull((select Min(MaxSalary) 
              from DesiredJob
             where ContactID = @ContactID), 0)

  RETURN @MinMaxPalk
END
GO

select ID, FullName, 
       dbo.udfGetContactMinimumDesiredMaxSalary(ID) AS MinPalk
  from Contact
 where dbo.udfGetContactMinimumDesiredMaxSalary(ID) < 3000
 order by 3 desc

DECLARE @Num Money
SET @Num = dbo.udfGetContactMinimumDesiredMaxSalary(8)

GO

CREATE FUNCTION dbo.udfGetContactWithJob (@ContactID int = 0)
RETURNS TABLE
AS
RETURN
  SELECT C.ID, C.FullName, C.FirstName, C.LastName, 
         J.Company, J.Position
    FROM Contact C INNER JOIN
         Job J ON C.ID = J.ContactID
   -- WHERE @ContactID in (C.ID, 0)
   WHERE @ContactID = 0 or @ContactID = C.ID
GO

select * 
  from dbo.udfGetContactWithJob(0) AS Contacts


select * 
  from dbo.udfGetContactWithJob(default)

select * 
  from dbo.udfGetContactWithJob(4)

GO


