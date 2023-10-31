select CustomerID AS ID, CustomerName AS Name, 1 AS IsCustomer
  from Sales.Customers
union all
select PersonID, FullName, 0 AS IsCustomer
  from Application.People
order by Name