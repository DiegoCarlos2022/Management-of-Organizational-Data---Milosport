ALTER TABLE miloorders CHANGE ï»¿OrderID OrderID varchar(255);
ALTER TABLE milofulfillment CHANGE ï»¿OrderID OrderID varchar(255);

# Drop products from previous years
select skuid, title, inventoryQty
from miloproduct 
where title like "%2018%" or title like "%2019%" or title like "%2020%" and inventoryQty > 0
order by inventoryQty desc;

# Most Profitable items by Supplier
SELECT SupplierName, round(avg(price - costPurchase),2) as AvgSupplierProfit , round(Average.AverageProfit,2) 
FROM miloproduct,
(SELECT AVG(price - costPurchase) AS AverageProfit FROM miloproduct where costPurchase > 0) AS Average,
milosupplier
WHERE (price - costPurchase > Average.AverageProfit) and costPurchase > 0 and miloproduct.supplierId = milosupplier.SupplierID
Group by SupplierName
order by AvgSupplierProfit desc;


# City with most orders
select milocustomer.State, milocustomer.City, count(miloorders.OrderID) as OrderperCity 
from miloorders
inner join milocustomer
on miloorders.CustID = milocustomer.CustID
group by milocustomer.City
order by OrderperCity desc
limit 3;

# Highest Fullfillment per Courier 
select milofulfillment.CourierID, count(miloorders.OrderID) as 'totalorders'
from milofulfillment
inner join miloorders
on milofulfillment.OrderID = miloorders.OrderID
group by milofulfillment.CourierID
order by Count(miloorders.OrderID) desc;

#top 10 product sold
select miloproduct_order.skuid, miloproduct.title, sum(miloproduct_order.item_qty) as qty
from miloproduct_order
inner join miloproduct
on miloproduct_order.skuId = miloproduct.skuid
group by miloproduct_order.skuid
order by qty desc
limit 10;

# Average profit by Category
CREATE TABLE temp2
SELECT miloproduct_category.skuid, miloproduct_category.product_type, milocategory.Category_Name
FROM miloproduct_category
LEFT JOIN milocategory
ON miloproduct_category.product_type = milocategory.Category_ID;

select  b.Category_Name,round(avg(price-costPurchase),2) as avg_profit
from miloproduct a inner join temp2 b
on a.skuId=b.skuId
group by b.Category_Name
having avg(price-costPurchase) > (SELECT AVG(price - costPurchase) AS AverageProfit 
FROM miloproduct 
where costPurchase > 0)
order by avg(price-costPurchase) desc;

DROP TABLE temp2;

#volume per channel
select  miloorders.ChannelID, milochannel.Name, sum(miloproduct_order.item_qty) as QTY
from miloproduct_order 
inner join miloorders
on miloproduct_order.orderId = miloorders.OrderID
inner join milochannel
on miloorders.ChannelID = milochannel.ChannelID
group by miloorders.ChannelID
order by QTY desc ;

#bottom 5 category
Select miloproduct_category.product_type, milocategory.Category_Name, 
round(avg(miloproduct.price-miloproduct.costPurchase),2) as AverageProfitbyCategory 
from miloproduct_category
Inner join miloproduct
On miloproduct_category.SKUID = miloproduct.skuId
inner join milocategory
on miloproduct_category.product_type=milocategory.Category_ID
Group by miloproduct_category.product_type
Order by AverageProfitbyCategory asc
Limit 5;

#top 5 category
Select miloproduct_category.product_type, milocategory.Category_Name, 
round(avg(miloproduct.price-miloproduct.costPurchase),2) as AverageProfitbyCategory 
from miloproduct_category
Inner join miloproduct
On miloproduct_category.SKUID = miloproduct.skuId
inner join milocategory
on miloproduct_category.product_type=milocategory.Category_ID
Group by miloproduct_category.product_type
Order by AverageProfitbyCategory desc
Limit 5;



-- Get number of items out of stock by category
CREATE TABLE temp1
SELECT miloproduct_category.skuid, miloproduct_category.product_type, milocategory.Category_Name
FROM miloproduct_category
LEFT JOIN milocategory
ON miloproduct_category.product_type = milocategory.Category_ID;

CREATE TABLE temp2
SELECT miloproduct.inventoryQty, miloproduct.skuId 
FROM miloproduct 
INNER JOIN miloproduct_order ON miloproduct.skuId = miloproduct_order.skuid;

select temp1.Category_Name, count(temp2.skuId) as OutOfStockItems
from temp2
inner join temp1
on temp2.skuId  = temp1.skuid
where temp2.inventoryQty = 0
group by temp1.Category_Name
order by OutOfStockItems desc;

DROP TABLE temp1;
DROP TABLE temp2;

-- Show distribution of basket value over orders
SELECT 
sum(CASE WHEN BasketValue < 250 THEN 1 END) as 'Basket Value < 250',
sum(CASE WHEN BasketValue >= 250 AND BasketValue < 500 THEN 1 END) as 'Basket Value 250-500',
sum(CASE WHEN BasketValue >= 500 AND BasketValue < 750 THEN 1 END) as 'Basket Value 500-750',
sum(CASE WHEN BasketValue >= 750 AND BasketValue < 1000 THEN 1 END) as 'Basket Value 750-1000',
sum(CASE WHEN BasketValue >= 1000 THEN 1 END) as 'Basket Value >1000'
FROM miloorders;

#promotion
Select c.Category_Name, a.title, (a.InventoryQty) as inventory
From miloproduct a inner join
miloproduct_category b on a.skuId=b.skuid
inner join milocategory c
on b.product_type = c.Category_ID
where PromotionID != '' and a.InventoryQty > 0
order by inventory asc;

