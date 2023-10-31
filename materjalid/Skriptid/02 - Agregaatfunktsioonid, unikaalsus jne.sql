-----------------------
-- Agregaatfunktsioonid
-----------------------

-- Lihtne kasutus
select COUNT(*) AS ArveteArv from Sales.Invoices

-- Keerukam juht, kus tuleb agregeerida mingi väärtuse kaupa 
select InvoiceDate, 
       Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines 
          on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by InvoiceDate

-- Vaatame, kas on ka mingi vahe, kui meid huvitaks vaid unikaalsed väärtused
select InvoiceDate, 
       Count(Sales.InvoiceLines.ExtendedPrice) as TotalCount,
       Count(distinct Sales.InvoiceLines.ExtendedPrice) as DistinctTotalCount
  from Sales.Invoices inner join
       Sales.InvoiceLines 
          on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by InvoiceDate


-----------------------
-- Unikaalsus
-----------------------

-- Kõik read
select CustomerName, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers on Sales.Invoices.CustomerID = Sales.Customers.CustomerID

-- Unikaalsed read DISTINCT abil
select DISTINCT CustomerName, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers on Sales.Invoices.CustomerID = Sales.Customers.CustomerID

-- Unikaalsed read GROUP BY abil
select CustomerName, TotalDryItems + TotalChillerItems AS TotalItems
  from Sales.Invoices inner join
       Sales.Customers on Sales.Invoices.CustomerID = Sales.Customers.CustomerID
 group by CustomerName, TotalDryItems + TotalChillerItems 


-----------------------
-- WHERE grupeeringutes
-----------------------

-- Grupeeritud päring, mis tagastab iga kuupäeva arvete summad
select InvoiceDate, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by InvoiceDate

-- Kui me soovime arvestada vaid neid kuupäevi, kus teeniti päevas üle 200000, siis kuidas me seda teeks?
select InvoiceDate, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 where Sum(Sales.InvoiceLines.ExtendedPrice) >= 200000
 group by InvoiceDate

-- Kasutame HAVING lauset
select InvoiceDate, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 group by InvoiceDate
having Sum(Sales.InvoiceLines.ExtendedPrice) >= 200000

-- Kasutame WHERE tingimust koos HAVING tingimusega
select InvoiceDate, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 where Sales.Invoices.InvoiceDate >= '2016-01-01' and Sales.Invoices.InvoiceDate <= '2016-12-31'
 group by InvoiceDate
having Sum(Sales.InvoiceLines.ExtendedPrice) >= 200000

select InvoiceDate, Sum(Sales.InvoiceLines.ExtendedPrice) as TotalSum
  from Sales.Invoices inner join
       Sales.InvoiceLines on Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
 where Sales.Invoices.InvoiceDate >= '2016-01-01' and Sales.Invoices.InvoiceDate <= '2016-12-31'
 group by InvoiceDate
having Sum(Sales.InvoiceLines.ExtendedPrice) >= 200000
 order by TotalSum desc

-----------------------
-- Hulgateooria
-----------------------
 

-- Kaks eraldi päringut
select CustomerID, CustomerName from Sales.Customers
select PersonID, FullName from Application.People

-- Ühend
select CustomerID, CustomerName from Sales.Customers
union
select PersonID, FullName from Application.People

-- Vigane ühend
select CustomerID, CustomerName from Sales.Customers
union
select PersonID, IsEmployee, IsSalesPerson, FullName  from Application.People

-- Ühend koos veergude ümber nimetamisega
select CustomerID AS ID, CustomerName AS Name from Sales.Customers
union
select PersonID AS ID, FullName AS Name from Application.People

-- Veergude ümber nimetamine
select CustomerID AS ID, CustomerName AS Name from Sales.Customers
union
select PersonID, FullName from Application.People

-- Tulemuste sorteerimine
select CustomerID AS ID, CustomerName as Name from Sales.Customers
union 
select PersonID AS ID, FullName as Name from Application.People
order by ID

-- union all
select CustomerID AS ID, CustomerName as Name from Sales.Customers
union all
select PersonID AS ID, FullName as Name from Application.People
order by ID


