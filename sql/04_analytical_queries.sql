-- ANALYTICAL QUERIES


-- Aggregations

-- Total revenue and number of items sold by product
select product_id, count(order_id) as items_sold, sum(price) as revenue
from olist_order_items_dataset
group by product_id
having count(order_id)>50

-- Average order value by state
with total_value as (
	select order_id, sum(price) as order_total_value
	from olist_order_items_dataset
	group by order_id
)
select c.customer_state, avg(t.order_total_value) as avg_order_value
from total_value as t
join olist_orders_dataset as o
on o.order_id=t.order_id
join olist_customers_dataset as c
on o.customer_id=c.customer_id
group by c.customer_state
order by avg_order_value desc

-- Monthly order trends
select
format(order_purchase_timestamp, 'MM-yyyy') as purchase_month,
count(order_id) as no_of_orders
from olist_orders_dataset
group by year(order_purchase_timestamp), month(order_purchase_timestamp), format(order_purchase_timestamp, 'MM-yyyy')
order by year(order_purchase_timestamp), month(order_purchase_timestamp)


-- JOINS

-- Template showing every possible combination of customer state and status
with customer_orders_cross as (
select distinct s.customer_state, o.order_status
from (select distinct customer_state from olist_customers_dataset) as s
cross join (select distinct order_status from olist_orders_dataset) as o
),
customer_orders as (
select o.order_id, o.order_status, c.customer_state
from olist_orders_dataset o
join olist_customers_dataset c
on c.customer_id=o.customer_id 
)
select count(order_id) count_of_orders, coc.customer_state, coc.order_status
from customer_orders_cross coc
left join customer_orders co
on co.order_status=coc.order_status and co.customer_state=coc.customer_state
group by coc.order_status, coc.customer_state

-- Mismatch between names
select p.product_category_name, t.product_category_name_english
from olist_products_dataset p
full outer join product_category_name_translation t
on p.product_category_name=t.product_category_name
where p.product_category_name is null or t.product_category_name is null

-- Finding customers who placed more than one order
select distinct o1.customer_id
from olist_orders_dataset o1
join olist_orders_dataset o2
on o1.customer_id = o2.customer_id
where o1.order_id <> o2.order_id

with customers_orders_cte as (
select o.order_id, c.customer_unique_id
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id=c.customer_id
)
select distinct coc1.customer_unique_id
from customers_orders_cte coc1
join customers_orders_cte coc2
on coc1.customer_unique_id=coc2.customer_unique_id
where coc1.order_id<>coc2.order_id


-- Subqueries and CTEs

-- Order items priced above the overall average price
select order_item_id, price
from olist_order_items_dataset
where price > (
	select avg(price) avg_price
	from olist_order_items_dataset )

-- Order item that is priced above the average price for its own specific product
select o1.product_id, o1.price
from olist_order_items_dataset o1
where o1.price > (
	select avg(price)
	from olist_order_items_dataset o2
	where o1.product_id=o2.product_id )


-- Window Functions

-- Rank sellers by total revenue
with seller_revenue as (
	select seller_id, sum(price) revenue
	from olist_order_items_dataset
	group by seller_id
)
select seller_id, revenue,
	   rank() over(order by revenue desc) revenue_rank,
	   dense_rank() over(order by revenue desc) revenue_rank_dense
from seller_revenue

-- Previous month comparision
with monthly_trends as (
	select
		format(order_purchase_timestamp, 'MM-yyyy') as purchase_month, 
		count(order_id) as no_of_orders,
		year(order_purchase_timestamp) as purchase_year,
		month(order_purchase_timestamp) as purchase_month_2
	from olist_orders_dataset
	group by year(order_purchase_timestamp), month(order_purchase_timestamp), format(order_purchase_timestamp, 'MM-yyyy')
),
with_previous as (
select purchase_month, no_of_orders, purchase_year, purchase_month_2,
	   lag(no_of_orders) over(order by purchase_year, purchase_month_2) as previous_month_order --(ranking)
from monthly_trends )
select purchase_month, no_of_orders, previous_month_order,
	   round(((no_of_orders - previous_month_order)*100.0/previous_month_order),2) as month_on_month_trend, --(percentage)
	   sum(no_of_orders) over (order by purchase_year, purchase_month_2) as running_total_orders -- (cumulative sum)
from with_previous