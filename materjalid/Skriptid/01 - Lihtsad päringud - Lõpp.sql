-----------------------
-- Ülesanded
-----------------------
USE WideWorldImporters;
GO

-- Kõik arved
select * from Sales.Invoices

-- Kõik arved (number, kuupäev, asjade koguarv)
select InvoiceID, InvoiceDate, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices

-- Kõik arved (number, kuupäev, asjade koguarv), kus on külmutatud tooteid
select InvoiceID, InvoiceDate, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices
 where TotalChillerItems > 0

-- Kõik 2016 aasta arved (number, kuupäev, asjade koguarv) koos kliendi nimega
select InvoiceID, CustomerName, InvoiceDate, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 where Sales.Invoices.InvoiceDate >= '2016-01-01' and Sales.Invoices.InvoiceDate <= '2016-12-31'

 
select InvoiceID, CustomerName, InvoiceDate, 
       TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers
          on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 where Sales.Invoices.InvoiceDate between '2016-01-01' and '2016-12-31'

 
select InvoiceID, CustomerName, InvoiceDate, 
       TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers
          on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 where DatePart(year, Sales.Invoices.InvoiceDate) = 2016


select InvoiceID, CustomerName, InvoiceDate, 
       TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers
          on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 where Year(Sales.Invoices.InvoiceDate) = 2016

-- See SQL Serveris ei tööta, kuigi MySQL saab sellega hakkama 
select InvoiceID, CustomerName, InvoiceDate, 
       TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers
          on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 where Sales.Invoices.InvoiceDate LIKE '2016-%'


-- Kõik arved (number, kuupäev, asjade koguarv) koos arve ridade summaga
select Sales.Invoices.InvoiceID, InvoiceDate, TotalDryItems + TotalChillerItems AS TotalItems, 
       Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by Sales.Invoices.InvoiceID, InvoiceDate, TotalDryItems + TotalChillerItems


-- Arved kuupäevade kaupa koos asjade koguarvu ja ridade kogusummaga järjestatuna kuupäevade kahanevas järjekorras
select InvoiceDate, Sum(TotalDryItems + TotalChillerItems) AS TotalItems, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by InvoiceDate
 order by InvoiceDate desc

 -- Kes on 2016 aasta 10 kõige edukamat müüjat
select TOP 10 Application.People.FullName, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID inner join
	   Application.People on Sales.Invoices.SalespersonPersonID = Application.People.PersonID
 where Sales.Invoices.InvoiceDate >= '2016-01-01' and Sales.Invoices.InvoiceDate <= '2016-12-31'
 group by Application.People.FullName
 order by Sum(Sales.InvoiceLines.ExtendedPrice) desc


 select TOP 10 Application.People.FullName, 
       Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines 
        on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID inner join
	 Application.People 
        on Sales.Invoices.SalespersonPersonID = Application.People.PersonID
 where Sales.Invoices.InvoiceDate >= '2016-01-01' and 
       Sales.Invoices.InvoiceDate <= '2016-12-31'
 group by Application.People.FullName
 order by TotalSum


