-- 1. What percentage of total orders were shipped on the same date?

select round((count(*)) * 100 /(select count(*) from superstore), 1) percentage
from superstore
where ship_mode = 'same day';
 
-- 2. Name the top 3 customers with highest total value of orders

select customer_id, customer_name, sum(sales) Total_value_orders
from superstore
group by customer_id, customer_name
order by Total_value_orders desc
limit 3;

-- 3. find the top 5 items with highest average sales per day

select Product_ID, avg(sales) as Average_Sales
from superstore
group by Product_ID
order by Average_Sales desc
limit 5;

-- 4. Write a query to find the average order value for each customer, and rank the customers by their average order value.

with cte as
(select Customer_ID, Customer_Name, avg(sales) as Avg_Order_Value
 from superstore
group by customer_id, Customer_Name)
 
 select cte.Customer_ID, cte.Customer_Name, cte.Avg_Order_Value,
 rank() over (order by cte.Avg_Order_Value desc) Ranking
 from cte;

-- 5.Give the name of customers who ordered highest and lowest orders from each city.

with cte as
(
select distinct customer_Name, City, 
sum(sales) over (partition by city, customer_name) Orders
from superstore
)

select distinct cte.City,
	last_value(cte.orders) over (partition by cte.city order by cte.orders
		rows between unbounded preceding and unbounded following) highest_order_sales,
	first_value(cte.orders) over (partition by cte.city order by cte.orders,cte.customer_name) lowest_order_sales,
	last_value(cte.customer_name) over (partition by cte.city order by cte.orders
		rows between unbounded preceding and unbounded following) highest_order_customer,
	first_value(cte.customer_name) over (partition by cte.city order by cte.orders, cte.customer_name) lowest_order_customer
from cte
order by cte.city;

-- 6. What is the most demanded sub-category in the west region?

select Sub_Category, sum(sales) total_quantity
from superstore
where region = 'west'
group by Sub_Category
order by total_quantity desc
limit 1;

-- 7. Which order has the highest number of items?

select Order_ID, count(*) order_count
from superstore
group by order_id
order by order_count desc
limit 1;

-- 8. Which order has the highest cumulative value?

Select Order_ID, 
sum(sales) 
over(partition by order_id rows between unbounded preceding and current row) total_sales
from superstore
order by total_sales desc
limit 1;

-- 9. Which segment’s order is more likely to be shipped via first class?

select distinct Segment, Ship_Mode 
from superstore
where ship_mode = 'first class'; 

-- 10. Which city is least contributing to total revenue?

select City, sum(sales) TotalSales
from superstore
group by city
order by TotalSales
limit 1;

-- 11. What is the average time for orders to get shipped after order is placed?

select avg(datediff(ship_date, order_date)) date_diff
from superstore;

-- 12. Which segment places the highest number of orders from each state?

with cte as
(
select distinct state, segment, 
count(*) over (partition by state, segment) orders 
from superstore
)

select distinct cte.State,first_value(cte.segment) over (partition by cte.state order by cte.orders) Segment
from cte
order by cte.state;
