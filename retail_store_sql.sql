SELECT  [Order_ID]
      ,[Product]
      ,[Quantity_Ordered]
      ,[Price_Each]
      ,[Order_Date]
      ,[Purchase_Address]
  FROM [Sales2].[dbo].[all_months]

-- since I intend to determine sales by month and city, it will be necessary the creation of further columns
--------------------------------------add month column
update all_months
set Month=Month(Order_Date)

--------------------------------------add 'Sales' column

update all_months
set Sales=Quantity_Ordered * Price_Each
--------------------------------------Rounding 'Price_Each' and 'Sales'
update all_months
set Sales=Round(Sales,2),
	Price_Each=Round(Price_Each,2)

select*
from all_months

select Month, Sum(Sales) as sales
from all_months
group by Month
order by sales desc
------------------------December was the month with the bigest volume in sales
---Dropping Null values
DELETE FROM all_months
WHERE Order_ID IS NULL
------------------------ Adding 'City' Column
select
	reverse(parsename(replace(reverse(Purchase_Address),',','.'),2)) as City
	,reverse(parsename(replace(reverse(Purchase_Address),',','.'),3)) as State
from all_months

------------------------ Since there are different cities with the same name, the state will be added so they can be told apart

select
	Concat(reverse(parsename(replace(reverse(Purchase_Address),',','.'),2)),' (' ,substring(reverse(parsename(replace(reverse(Purchase_Address),',','.'),3)),1,3),')')
from all_months

update all_months
set City=Concat(reverse(parsename(replace(reverse(Purchase_Address),',','.'),2)),' (' ,substring(reverse(parsename(replace(reverse(Purchase_Address),',','.'),3)),1,3),')')

select City
	, sum(Sales) as sales
from all_months
group by City
order by sales desc
------------------------------San francisco was the city with the highest volume in sales
---------------------------------- Adding an 'Hour' Column


update all_months
set Hour= Datepart(hour, Order_Date)

select Hour, sum(Sales) as sales
from all_months
group by Hour
order by sales desc

------------------------------------- Most often sold together products 

select count(distinct t1.Order_ID )
	,t1.Product
	,t2.Product

from all_months as t1 join all_months as t2
		on t1.Order_ID=t2.Order_ID and
		t1.Product > t2.Product --the operator '<' guarentees  that each pair (combination) by order_id is count only one time, since there is only one way to arrange them satisfying the condition '<' and two ways for '!=' (permutations)
group by t1.Product, t2.Product
order by count(distinct t1.Order_ID ) desc

--------------------------------------Iphone and Lightning Charging Cable were the most products sold together


select product
	, sum(sales) as sales
from all_months
group by product
order by sales desc
----------------------------------------Macbook Pro Laptop was the product that most sold in usd

select product
	, sum(Quantity_Ordered) as #_of_items
from all_months
group by product
order by #_of_items desc
---------------------------------------- AAA Batteries (4-pack) was the product that most items sold 
exec sp_help all_months
