USE MiniInsta;
GO

--select * from dbo.[User]

--select * from dbo.[User] where ID = 191

--select * from dbo.[User] where Username = 'cbaccup3b'

----------------------------------------------------------
-- Esilehe päring
----------------------------------------------------------

SELECT 
	P.ID as PostID, 
	U.ID as UserID,
	U.Username, 
	P.CreationTime, 
	P.LocationName, 
	(SELECT COUNT(*) FROM dbo.Liking WHERE dbo.Liking.PostID = P.ID) AS LikeCount
	--COUNT(ISNULL(L.PostID, 0)) as LikeCount <- See annab isegi kui peaks olema "0" siis annab "1"
	-- COUNT(L.PostID, 0) as LikeCount <- See annab warningu
FROM 
	dbo.Post P
INNER JOIN
	dbo.[User] U
		ON 
			P.UserID = U.ID
INNER JOIN 
	dbo.Following F
		ON 
			F.FolloweeID = U.ID 
/*
  Saaks teha ka subquery
  WEHRE P.UserID IN (
	SELECT FolloweeID
	FROM dbo.Following
	WHERE FollowerID = <ID>
  );
*/
/* Ei saanud tööle kui 0 väärtus. Töötab aga saa warning-u.
LEFT JOIN
	dbo.Liking L
		ON
			L.PostID = P.ID
			*/
WHERE
	F.FollowerID = 191
GROUP BY
	P.ID, U.ID, U.Username, P.CreationTime, P.LocationName;

----------------------------------------------------------
-- Profiili Lehe päring
----------------------------------------------------------
BEGIN
	SET NOCOUNT ON;

	DECLARE @Username nvarchar(50) = 'cbaccup3b'

	SELECT 
		U.Username, 
		U.ImageUrl,
		(SELECT COUNT(*) FROM dbo.Post WHERE dbo.Post.UserID = U.ID) as PostCount,
		(SELECT COUNT(*) FROM dbo.Following WHERE dbo.Following.FollowerID = U.ID) as FollowingCount,
		(SELECT COUNT(*) FROM dbo.Following WHERE dbo.Following.FolloweeID = U.ID) as FollowerCount,
		U.Description
	FROM 
		dbo.[User] U
	WHERE
		U.Username = @Username;

	SELECT 
		P.*,
		U.Username,
		(SELECT COUNT(*) FROM dbo.Liking WHERE dbo.Liking.PostID = P.ID) AS LikeCount
	FROM
		dbo.Post P
	INNER JOIN 
		dbo.[User] U
			ON
				P.UserID = U.ID
	WHERE
		U.Username = @Username;
END;

----------------------------------------------------------
-- Post detailide päring
----------------------------------------------------------

BEGIN
	SET NOCOUNT ON;

	DECLARE @PostID Int = 74

	SELECT 
		P.ID AS PostID,
		U.ID AS UserID,
		U.Username,
		U.ImageUrl,
		(SELECT COUNT(*) FROM dbo.Liking WHERE dbo.Liking.PostID = P.ID) AS LikeCount
	FROM
		dbo.Post P
	INNER JOIN
		dbo.[User] U
			ON P.UserID = U.ID
	WHERE
		P.ID = @PostID;

	SELECT 
		PM.PostID,
		PM.ID AS PostMediaID,
		PM.MediaFileUrl,
		MT.Name as MediaTypeName
	FROM
		dbo.PostMedia PM
	INNER JOIN 
		dbo.MediaType MT
			ON 
				PM.MediaTypeID = MT.ID
	WHERE
		PM.PostID = @PostID;

	SELECT
		C.PostID,
		C.ID AS CommentID,
		C.UserID,
		U.Username,
		C.Comment,
		C.CreationTime
	FROM
		dbo.Comment C
	INNER JOIN 
		dbo.[User] U
			ON 
				C.UserID = U.ID
	WHERE
		C.PostID = @PostID;

END;

----------------------------------------------------------
-- Analüütilised arvud ühe andmehulgana (Userite koguarv, Postituste koguarv, Keskmine Postituste arv User kohta, 
-- avg ja max kommentaaride arv Poste kohta, avg ja max meeldimiste arv Poste kohta
----------------------------------------------------------

SELECT 
    (SELECT COUNT(*) FROM dbo.[User]) AS TotalUsers,
    (SELECT COUNT(*) FROM dbo.Post) AS TotalPosts,
    (
		SELECT AVG(PostsPerUser) FROM 
			(SELECT COUNT(*) AS PostsPerUser FROM dbo.Post GROUP BY UserID) AS PostCounts
	) AS AvgPostsPerUser,
    (
		SELECT AVG(CommentCounts) FROM 
			(SELECT COUNT(*) AS CommentCounts FROM dbo.Comment GROUP BY PostID) AS CommentCounts
	) AS AvgCommentsPerPost,
    (
		SELECT MAX(CommentCounts) FROM 
			(SELECT COUNT(*) AS CommentCounts FROM dbo.Comment GROUP BY PostID) AS CommentCounts
	) AS MaxCommentsPerPost,
    (
		SELECT AVG(LikeCounts) FROM 
			(SELECT COUNT(*) AS LikeCounts FROM dbo.Liking GROUP BY PostID) AS LikeCounts
	) AS AvgLikesPerPost,
    (
		SELECT MAX(LikeCounts) FROM 
			(SELECT COUNT(*) AS LikeCounts FROM dbo.Liking GROUP BY PostID) AS LikeCounts
	) AS MaxLikesPerPost;


----------------------------------------------------------
-- TOP 10 Userit, kellel on kõige rohkem postitusi
----------------------------------------------------------

SELECT TOP 10
	U.ID,
	U.Username,
	COUNT(P.ID) AS PostCount
FROM 
	dbo.[User] U
INNER JOIN 
	dbo.Post P
		ON
			P.UserID = U.ID
GROUP BY U.ID, U.Username
ORDER BY COUNT(P.ID) DESC;


----------------------------------------------------------
-- TOP 10 Userit, kellel on kõige rohkem jälgijaid
----------------------------------------------------------

SELECT TOP 10
	U.ID,
	U.Username,
	COUNT(F.FolloweeID) AS FollowerCount
FROM 
	dbo.[User] U
INNER JOIN 
	dbo.Following F
		ON
			F.FolloweeID = U.ID
GROUP BY U.ID, U.Username
ORDER BY COUNT(F.FolloweeID) DESC;


----------------------------------------------------------
-- Useriks registreerimiste arv päevade kaupa
----------------------------------------------------------

SELECT 
    CAST(U.CreationTime AS DATE) AS RegistrationDate, 
    COUNT(U.ID) AS Registrations
FROM 
	dbo.[User] U
GROUP BY 
	CAST(U.CreationTime AS DATE)
ORDER BY 
	CAST(U.CreationTime AS DATE) DESC;

----------------------------------------------------------
-- Userite jagunemine sooliselt
----------------------------------------------------------

SELECT 
	G.Name AS Gender, 
	COUNT(U.ID) AS UserCount
FROM 
	dbo.[User] U
INNER JOIN 
	dbo.Gender G 
		ON
			U.GenderID = G.ID
GROUP BY 
	G.Name;

