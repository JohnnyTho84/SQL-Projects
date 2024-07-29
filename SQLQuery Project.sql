------------tabel1-----an/vanzari-----
select year(OrderDate),
		format(sum(SubTotal),'n')
from sales.SalesOrderHeader
group by year(OrderDate)
order by year(OrderDate)

-----------tabel 2----an/profit
select year(h.OrderDate) ,
		format(sum(d.LineTotal - p.StandardCost*OrderQty), 'n') as Profit
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Production.Product p
		on p.ProductID = d.ProductID
group by year(h.OrderDate)
order by year(h.OrderDate)

--------tabel 3------vanzari/luna
select format(sum(SubTotal), 'n') SalesTotal,
	  year(OrderDate) Year,
	  month(OrderDate) as Month
from Sales.SalesOrderHeader	 
group by year(OrderDate),MONTH(OrderDate)
order by year(OrderDate),Month(OrderDate)

---------tabel 4-------profit/luna
select year(h.OrderDate) ,
		month(h.OrderDate),
		format(sum(d.LineTotal - p.StandardCost*OrderQty), 'n') as Profit
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Production.Product p
		on p.ProductID = d.ProductID
group by year(h.OrderDate),month(h.OrderDate)
order by year(h.OrderDate),month(h.OrderDate)

---------tabel 5------vanzari/an/zona
select year(h.OrderDate) Year,
	  t.[Name],
	  format(sum(h.SubTotal), 'n') SalesTotal
from Sales.SalesOrderHeader h
	 join Sales.SalesTerritory t
	 on h.TerritoryID = t.TerritoryID
group by year(h.orderDate), t.[Name]
order by year(h.OrderDate) asc, t.[Name]

-------tabel 6------vanzari/luna/teritoriu
select year(h.OrderDate) Year,
		MONTH(h.OrderDate) Luna,
	  t.[Name],
	  format(sum(h.SubTotal), 'n') SalesTotal
from Sales.SalesOrderHeader h
	 join Sales.SalesTerritory t
	 on h.TerritoryID = t.TerritoryID
group by year(h.orderDate), t.[Name],MONTH(h.OrderDate)
order by year(h.OrderDate) asc, t.[Name],MONTH(h.OrderDate)

--------tabel 7 -------profit/an/teritoriu
select year(h.OrderDate) Year,
	  t.[Name],
	  format(sum(d.LineTotal - p.StandardCost*OrderQty), 'n') as Profit
from Sales.SalesOrderHeader h
	 join Sales.SalesTerritory t
	 on h.TerritoryID = t.TerritoryID
	 join Sales.SalesOrderDetail d
	 on h.SalesOrderID = d.SalesOrderID
	 join Production.Product p
	 on p.ProductID = d.ProductID
group by year(h.orderDate), t.[Name]
order by year(h.OrderDate) asc, t.[Name]


------tabel 8-----profit/luna/teritoriu
select year(h.OrderDate) Year,
		month(h.OrderDate) Luna,
	  t.[Name],
	  format(sum(d.LineTotal - p.StandardCost*OrderQty), 'n') as Profit
from Sales.SalesOrderHeader h
	 join Sales.SalesTerritory t
	 on h.TerritoryID = t.TerritoryID
	 join Sales.SalesOrderDetail d
	 on h.SalesOrderID = d.SalesOrderID
	 join Production.Product p
	 on p.ProductID = d.ProductID
group by year(h.orderDate), t.[Name],month(h.OrderDate)
order by year(h.OrderDate) asc, t.[Name],month(h.OrderDate)

-------- procedura calcul discount punctual------
create procedure spDiscountPunctual
        @pyear int,
		@pmonth int,
		@ominDisc decimal (8,2) out,
		@oavgDisc decimal(8,2) out,
		@omaxDisc decimal (8,2) out
as begin
select 
		@ominDisc = min(d.UnitPriceDiscount) *100 ,
		@oavgDisc = avg (d.UnitPriceDiscount) *100 ,
		@omaxDisc = max(d.UnitPriceDiscount) *100 
from Sales.SalesOrderDetail d
		join Sales.SalesOrderHeader h
		on d.SalesOrderID = h.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
where YEAR(h.OrderDate) = @pyear and month(h.OrderDate)=@pmonth
end

declare 
@vminDisc decimal(8,2),
@vavgDisc decimal(8,2),
@vmaxDisc decimal(8,2)

exec spDiscountPunctual '2012', '5', @vminDisc out, @vavgDisc out, @vmaxDisc out

select @vminDisc, @vavgDisc, @vmaxDisc


------------procedura calcul cantitati punctual-----
create procedure spQtyPunctual
        @pyear int,
		@pmonth int,
		@pQty int out
		
as begin
select 
		@pQty = sum(d.OrderQty) 		
from Sales.SalesOrderDetail d
		join Sales.SalesOrderHeader h
		on d.SalesOrderID = h.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
where YEAR(h.OrderDate) = @pyear and month(h.OrderDate)=@pmonth
end

declare 
@vQty int

exec spQtyPunctual '2012', '5', @vQty out

select @vQty

----------procedura calcul listprice punctual------

create procedure spListPricePunctual
        @pyear int,
		@pmonth int,
		@oavgListPrice decimal(8,2) out
		
as begin
select 
		@oavgListPrice = avg (p.ListPrice)
from Sales.SalesOrderDetail d
		join Sales.SalesOrderHeader h
		on d.SalesOrderID = h.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
where YEAR(h.OrderDate) = @pyear and month(h.OrderDate)=@pmonth
end

declare 
@vavgListPrice decimal(8,2)


exec spListPricePunctual'2012', '5',@vavgListPrice out

select @vavgListPrice


-------------procedura calcul medie cantitate/comenzi-----
create procedure spAvgQtyPunctual
        @pyear int,
		@pmonth int,
		@oavgOrderQty decimal (8,2) out
		
as begin
select 
		@oavgOrderQty = sum(d.OrderQty) / count(h.SalesOrderID)
from Sales.SalesOrderDetail d
		join Sales.SalesOrderHeader h
		on d.SalesOrderID = h.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
where YEAR(h.OrderDate) = @pyear and month(h.OrderDate)=@pmonth
end

declare 
@vavgOrderQty decimal(8,2)


exec spAvgQtyPunctual '2012', '1',@vavgOrderQty out

select @vavgOrderQty

--------------
select 
		year(h.OrderDate),
		month(h.OrderDate),
		avg (d.UnitPriceDiscount) *100,
		max(d.UnitPriceDiscount) *100,
		min(d.UnitPriceDiscount) *100
			
from Sales.SalesOrderDetail d
		join Sales.SalesOrderHeader h
		on d.SalesOrderID = h.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
group by year(h.OrderDate),month(h.OrderDate)
order by year(h.OrderDate),month(h.OrderDate)


--------tabel  clienti
select c.CustomerID,
	   t.[Name],
	   year(h.OrderDate) as Year,
	   format(sum(d.LineTotal), 'n') as Sales,
	   format(sum(d.LineTotal - p.StandardCost*OrderQty), 'n') as Profit
from Sales.Customer c
	 join Sales.SalesOrderHeader h
	 on c.CustomerID = h.CustomerID
	 join Sales.SalesOrderDetail d
	 on h.SalesOrderID = d.SalesOrderID
	 join Production.Product p
	 on d.ProductID = p.ProductID
	 join Sales.SalesTerritory t
	 on h.TerritoryID = t.TerritoryID
group by year(h.OrderDate), c.CustomerID, t.[name]
order by year(h.OrderDate), c.CustomerID, t.[Name]

-----client valoare disc/an----
select top 10 h.CustomerID,
		sum(p.ListPrice - d.LineTotal / d.orderQty) as SumDiff,
		year(h.OrderDate)
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Production.Product p
		on d.ProductID = p.ProductID
		join Sales.Customer c
		on h.CustomerID = c.CustomerID
group by h.CustomerID , year(h.OrderDate)
order by SumDiff desc


--query total discount
select  d.ProductID,
		/*d.LineTotal / d.orderQty as PriceAfterDisc*/
		/*p.ListPrice*/
		sum(p.ListPrice - d.LineTotal / d.orderQty) as SumDiff,
		t.[name],
		year(h.OrderDate) as Year
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
group by d.productID,t.[name],year(h.OrderDate)
order by d.ProductID ,t.[name],year(h.OrderDate)

------------top articole vandute-------
select  top 100 p.ProductID,
		p.[Name],
		t.[Name],
		format(sum(d.LineTotal ),'n')  as Sales,
		format(sum(d.LineTotal - p.StandardCost*d.OrderQty), 'n') as Profit,
		sum(d.OrderQty) as QTY,
		format(sum(p.ListPrice - d.LineTotal / d.orderQty),'n')  as DiscountValue	
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
group by p.ProductID , p.[Name], t.[Name],p.ListPrice
order by QTY desc

------------top articole vandute Germany-------
select  top 100 p.ProductID,
		p.[Name],
		t.[Name],
		format(sum(d.LineTotal ),'n')  as Sales,
		format(sum(d.LineTotal - p.StandardCost*d.OrderQty), 'n') as Profit,
		sum(d.OrderQty) as QTY,
		format(sum(p.ListPrice - d.LineTotal / d.orderQty),'n')  as DiscountValue	
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
where t.[name] = 'Germany'
group by p.ProductID , p.[Name], t.[Name],p.ListPrice
order by QTY desc

------------top articole vandute NorthEast-------
select  top 100 p.ProductID,
		p.[Name],
		t.[Name],
		format(sum(d.LineTotal ),'n')  as Sales,
		format(sum(d.LineTotal - p.StandardCost*d.OrderQty), 'n') as Profit,
		sum(d.OrderQty) as QTY,
		format(sum(p.ListPrice - d.LineTotal / d.orderQty),'n')  as DiscountValue	
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
where t.[name]= ' NorthEast'
group by p.ProductID , p.[Name], t.[Name],p.ListPrice
order by QTY desc


-------nr clienti anual----
select year(h.OrderDate),
		t.[name],		
		count(h.CustomerID) NoOfCustomers
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
group by year(h.OrderDate), t.[Name]
order by year(h.OrderDate)

-------top 100 articole pe teritoriile cu extreme----
select  top 100 p.ProductID,
		p.[Name],
		t.[Name],
		year(h.orderdate),
		format(sum(d.LineTotal ),'n')  as Sales,
		format(sum(d.LineTotal - p.StandardCost*d.OrderQty), 'n') as Profit,
		sum(d.OrderQty) as QTY,
		format(sum(p.ListPrice - d.LineTotal / d.orderQty),'n')  as DiscountValue	
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
where t.[name] = 'Germany' 
group by p.ProductID , p.[Name], t.[Name],p.ListPrice,year(h.OrderDate)
order by QTY desc


select  top 100 p.ProductID,
		p.[Name],
		t.[Name],
		format(sum(d.LineTotal ),'n')  as Sales,	
		format(sum(d.LineTotal - p.StandardCost*d.OrderQty), 'n') as Profit,
		sum(d.OrderQty) as QTY,
		format(sum(p.ListPrice - d.LineTotal / d.orderQty),'n')  as DiscountValue	
from Sales.SalesOrderHeader h
		join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
		join Sales.SalesTerritory t
		on h.TerritoryID = t.TerritoryID
		join Production.Product p
		on d.ProductID = p.ProductID
where t.[name] = 'NorthEast' 
group by p.ProductID , p.[Name], t.[Name],p.ListPrice
order by QTY desc



