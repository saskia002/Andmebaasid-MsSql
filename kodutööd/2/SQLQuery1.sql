USE WideWorldImporters;
GO



-- 1.
-- "DROP VIEW IF EXISTS Sales.TopProfitableSellers2016" Sobiks ka aga ei tea kumb on parem.
-- Kahjuks pole "IF NOT EXISTS" ?
CREATE OR ALTER VIEW Sales.TopProfitableSellers2016 AS
	SELECT 
		TOP 10 
			p.FullName, SUM(il.LineProfit) AS 'TotalProfit'
	FROM 
		Sales.Invoices i 
	INNER JOIN 
		Application.People as p  
	ON 
		p.PersonID = i.SalespersonPersonID
	INNER JOIN 
		Sales.InvoiceLines as il
	ON
		il.InvoiceID = i.InvoiceID
		-- Saaks ka "AND YEAR(i.InvoiceDate) = 2016" kasutada siin aga see halb ja aeglasem
	WHERE
		YEAR(i.InvoiceDate) = 2016
	GROUP BY
		p.FullName
	ORDER BY 
		SUM(il.LineProfit) DESC;
GO

SELECT * FROM Sales.TopProfitableSellers2016;
GO



-- 2.
IF OBJECT_ID('Sales.getTotalProfit', 'FN') IS NOT NULL
    DROP FUNCTION Sales.getTotalProfit;
GO

CREATE FUNCTION Sales.getTotalProfit 
(
	@beginDate DATE, 
	@endDate DATE,
	@employeeID INT = 0
) 
RETURNS DECIMAL(18,2) AS BEGIN
	DECLARE @totalProfit DECIMAL(18,2);

	SET @totalProfit = isNull(
	(
		SELECT 
			SUM(IL.LineProfit)
		FROM 
			Sales.InvoiceLines IL
		INNER JOIN 
			Sales.Invoices I 
				ON 
					IL.InvoiceID = I.InvoiceID
		INNER JOIN 
			Application.People AS P
				ON
					P.PersonID = I.SalespersonPersonID
		WHERE 
			I.InvoiceDate BETWEEN @beginDate AND @endDate
			AND @employeeID IN (P.PersonID, 0)
	), 0);
	
	RETURN @totalProfit;
END;
GO

--DECLARE @result DECIMAL(18,2);
--SET @result = Sales.getTotalProfit('2016-01-01', '2016-12-31', 3); 
--SELECT @result AS TotalProfit;

SELECT Sales.getTotalProfit('2016-01-01', '2016-01-02', 2) as 'TotalProfit';
GO



-- 3. 
IF OBJECT_ID('Sales.GetQuarterlyEarnings') IS NOT NULL
    DROP FUNCTION Sales.GetQuarterlyEarnings;
GO

CREATE FUNCTION Sales.GetQuarterlyEarnings
(
    @startDate DATE, 
    @endDate DATE, 
    @customerID INT = 0
)
RETURNS TABLE AS RETURN
(
    SELECT 
        C.CustomerID,
        C.CustomerName,
        DATEPART(QUARTER, I.InvoiceDate) AS Quarter,
        SUM(IL.LineProfit) AS 'Total earnings'
    FROM 
        Sales.Customers C
			INNER JOIN 
				Sales.Invoices I 
					ON 
						C.CustomerID = I.CustomerID
			INNER JOIN 
				Sales.InvoiceLines IL 
					ON 
						I.InvoiceID = IL.InvoiceID
    WHERE 
        I.InvoiceDate BETWEEN @startDate AND @endDate
		AND @customerID IN (C.CustomerID, 0)
    GROUP BY 
        C.CustomerID,
        C.CustomerName,
        DATEPART(QUARTER, I.InvoiceDate)
);
GO

SELECT * FROM Sales.GetQuarterlyEarnings('2016-01-01', '2016-12-31', 0) ORDER BY CustomerName, Quarter;
GO

SELECT * FROM Sales.GetQuarterlyEarnings('2016-01-01', '2016-12-31', 2) ORDER BY CustomerName, Quarter;
GO



-- 4.
IF OBJECT_ID('Sales.GetInvoicesAndLines', 'P') IS NOT NULL
    DROP PROCEDURE Sales.GetInvoicesAndLines;
GO

CREATE PROCEDURE Sales.GetInvoicesAndLines
(
    @startDate DATE, 
    @endDate DATE
)
AS BEGIN 
	SET NOCOUNT ON; -- Ei anna seda "rows affected" sõnumit

    SELECT 
        I.InvoiceID,
        I.InvoiceDate,
        I.CustomerID,
        IL.InvoiceLineID,
        IL.InvoiceID,
        IL.Quantity,
        IL.UnitPrice,
        IL.ExtendedPrice,
        IL.LineProfit
    FROM 
        Sales.Invoices I
        INNER JOIN 
			Sales.InvoiceLines IL 
				ON I.InvoiceID = IL.InvoiceID
    WHERE 
        I.InvoiceDate BETWEEN @startDate AND @endDate;
END;
GO

EXEC Sales.GetInvoicesAndLines '2016-01-01', '2016-12-31';
GO



-- 5.
DECLARE @invoiceID INT;
DECLARE @extendedPrice DECIMAL(18, 2);
DECLARE @totalExtendedPrice DECIMAL(18, 2);

SET @totalExtendedPrice = 0;
DECLARE invoice_cursor CURSOR FOR 
	SELECT I.InvoiceID, SUM(IL.ExtendedPrice) as ExtendedPrice
	FROM 
		Sales.Invoices I
	INNER JOIN 
		Sales.InvoiceLines IL 
			ON 
				I.InvoiceID = IL.InvoiceID
	WHERE 
		YEAR(I.InvoiceDate) = 2016
	GROUP BY 
		I.InvoiceID;

OPEN invoice_cursor;

FETCH NEXT FROM invoice_cursor INTO @invoiceID, @extendedPrice;

WHILE @@FETCH_STATUS = 0 BEGIN
    SET @totalExtendedPrice = @totalExtendedPrice + @extendedPrice;
    FETCH NEXT FROM invoice_cursor INTO @invoiceID, @extendedPrice;
END;

CLOSE invoice_cursor;
DEALLOCATE invoice_cursor;

SELECT @totalExtendedPrice as TotalExtendedPrice;
GO



-- 6.
IF OBJECT_ID('Sales.CheckDiscountPercent', 'TR') IS NOT NULL
    DROP TRIGGER Sales.CheckDiscountPercent;
GO

CREATE TRIGGER Sales.CheckDiscountPercent 
	ON Sales.SpecialDeals 
	AFTER INSERT, UPDATE AS BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DiscountPercentage >= 90) BEGIN
        RAISERROR ('Discount percentage must be less than 90!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

INSERT INTO Sales.SpecialDeals 
	(DealDescription, DiscountPercentage, StartDate, EndDate, LastEditedBy) 
VALUES 
	('Special Deal 1', 80, GETDATE(), GETDATE(), 2),
	('Special Deal 2', 95, GETDATE(), GETDATE(), 2);
GO

INSERT INTO Sales.SpecialDeals 
	(DealDescription, DiscountPercentage, StartDate, EndDate, LastEditedBy) 
VALUES 
	('Special Deal 3', 90, GETDATE(), GETDATE(), 2);
GO
