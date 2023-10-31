-- K�ik arved
select * from Sales.Invoices

-- K�ik arved (number, kuup�ev, asjade koguarv)
select InvoiceID, InvoiceDate,  
       TotalDryItems + TotalChillerItems AS Kogus
from Sales.Invoices

-- K�ik arved (number, kuup�ev, asjade koguarv), 
-- kus on k�lmutatud tooteid
select InvoiceID, InvoiceDate,  
       TotalDryItems + TotalChillerItems AS Kogus
from Sales.Invoices
where TotalChillerItems > 0

-- K�ik 2016 aasta arved (number, kuup�ev, asjade koguarv) 
-- koos kliendi nimega
select InvoiceID, InvoiceDate,  
       TotalDryItems + TotalChillerItems AS Kogus
from Sales.Invoices
where Year(InvoiceDate) = 2016
--where DatePart(year, InvoiceDate) = 2016
--where InvoiceDate >= '2016-01-01' and InvoiceDate <= '2016-12-31'
--where InvoiceDate between '2016-01-01' and '2016-12-31'

-- K�ik arved (number, kuup�ev, asjade koguarv) 
-- koos arve ridade summaga
select Invoices.InvoiceID, InvoiceDate,  
       TotalDryItems + TotalChillerItems AS Kogus,
	   Sum(ExtendedPrice) as Summa
from Sales.Invoices inner join 
     Sales.InvoiceLines on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by Invoices.InvoiceID, InvoiceDate,  
       TotalDryItems + TotalChillerItems

-- Arved kuup�evade kaupa koos asjade koguarvu ja ridade kogusummaga j�rjestatuna kuup�evade kahanevas j�rjekorras
select InvoiceDate,  
       Sum(TotalDryItems + TotalChillerItems) AS Kogus,
	   Sum(ExtendedPrice) as Summa
from Sales.Invoices inner join 
     Sales.InvoiceLines on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by InvoiceDate 
order by InvoiceDate desc

-- Kes on 2016 aasta 10 k�ige edukamat m��jat
select top 6 People.FullName AS M��ja,  
	   Sum(ExtendedPrice) as Summa
from Sales.Invoices inner join 
     Sales.InvoiceLines on Invoices.InvoiceID = InvoiceLines.InvoiceID inner join
	 Application.People on Invoices.SalespersonPersonID = People.PersonID
group by People.FullName
-- order by Sum(ExtendedPrice) 
order by Summa desc


select top 6 People.FullName AS M��ja,  
	   Sum(ExtendedPrice) as Summa
from Sales.Invoices inner join 
     Sales.InvoiceLines on Invoices.InvoiceID = InvoiceLines.InvoiceID inner join
	 Application.People on Invoices.SalespersonPersonID = People.PersonID
where Year(InvoiceDate) = 2016 -- Sum(ExtendedPrice) > 20000000
group by People.FullName
having Sum(ExtendedPrice) > 20000000
-- order by Sum(ExtendedPrice) 
order by Summa desc
