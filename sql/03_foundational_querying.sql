-- FOUNDATIONAL QUERYING

-- Bucketing query

-- Bucketing orders by value
with price_distribution as (
	select price,
	case when price >= 0.85 and price <= 80 then 'low_price'
		 when price >= 81 and price <= 200 then 'medium_price'
		 else 'high_price'
	end price_range
	from olist_order_items_dataset
)
select price_range, count(*) as number_of_orders
from price_distribution
group by price_range;


-- Filtering queries

-- Orders with canceled or unavaiable as their status
select order_id, order_status
from olist_orders_dataset
where order_status in ('canceled', 'unavailable');

-- Orders with price between 200 and 300
select count (*) as count_of_orders
from olist_order_items_dataset
where price between 200 and 300;

-- Cities starting with 'santo' in their name
select customer_city
from olist_customers_dataset
where customer_city like 'santo%'


-- Ordering and top/offset-fetch queries

-- Top 10 highest priced orders
select top 10 order_id, price
from olist_order_items_dataset
order by price desc --(top technique)

-- 11-20 highest priced orders
select order_id, price
from olist_order_items_dataset
order by price desc
offset 10 rows
fetch next 10 rows only --(offset-fetch technique)


-- Distinct queries

-- Distinct customerids
select count(distinct customer_id) as dist_customer_id
from olist_orders_dataset