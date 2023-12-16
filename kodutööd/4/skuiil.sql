IF OBJECT_ID('dbo.GetNumbers', 'P') IS NOT NULL
	DROP PROCEDURE dbo.GetNumbers;
GO

CREATE PROCEDURE dbo.GetNumbers (@inpCounter INT = 0) AS BEGIN
	CREATE TABLE #tt_num (
		num INT
	);

	DECLARE @Counter INT = 1;

	WHILE @counter <= @inpCounter BEGIN
		INSERT INTO #tt_num (num) VALUES (@counter);
		SET @counter = @counter + 1;
	END;

	SELECT * FROM #tt_num;
	DROP TABLE #tt_num;

END;
GO

EXEC dbo.GetNumbers 11;
GO

---

DECLARE @LastNr AS INT = 34;

WITH Fibonacci (num, next_num)
AS (
	SELECT  0  AS num,
			1  AS next_num
	UNION ALL

	SELECT  a.next_num         AS num,
			a.num + a.next_num AS next_num
	FROM Fibonacci a
	WHERE a.num <> @LastNr
)

SELECT fn.num FROM Fibonacci fn;
GO

---

WITH RankedPosts AS (
    SELECT
        P.ID,
        U.Username,
        COUNT(L.PostID) AS LikeCount,
        ROW_NUMBER() OVER (ORDER BY COUNT(L.PostID) DESC) AS Ranking
    FROM
        dbo.Post P
    INNER JOIN
        dbo.Liking L
			ON P.ID = L.PostID
    INNER JOIN
        dbo.[User] U
			ON P.UserID = U.ID
    GROUP BY
        P.ID, U.Username
)

SELECT TOP 10
    ID,
    Username,
    LikeCount
FROM
    RankedPosts
ORDER BY
    LikeCount DESC;
GO
