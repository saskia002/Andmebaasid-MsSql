USE MiniInsta;
GO

-- Peale andmete lisamist katsume nüüd sequence väärtused ka viia tasakaalu nendega, mis meil tabelitesse jõudis
DECLARE @MaxID Int, @ResetSQL nvarchar(255)
SET @resetSQL = 'ALTER SEQUENCE dbo.UserSequence RESTART WITH ' + IsNull((SELECT CAST(MAX(ID) + 1 as nvarchar(10)) FROM dbo.[User]), 1)
exec sp_executesql @resetSQL;
SET @resetSQL = 'ALTER SEQUENCE dbo.PostSequence RESTART WITH ' + IsNull((SELECT CAST(MAX(ID) + 1 as nvarchar(10)) FROM dbo.Post), 1)
exec sp_executesql @resetSQL;
SET @resetSQL = 'ALTER SEQUENCE dbo.CommentSequence RESTART WITH ' + IsNull((SELECT CAST(MAX(ID) + 1 as nvarchar(10)) FROM dbo.Comment), 1)
exec sp_executesql @resetSQL;
SET @resetSQL = 'ALTER SEQUENCE dbo.MediaSequence RESTART WITH ' + IsNull((SELECT CAST(MAX(ID) + 1 as nvarchar(10)) FROM dbo.PostMedia), 1)
exec sp_executesql @resetSQL;
