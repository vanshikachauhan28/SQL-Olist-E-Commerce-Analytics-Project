-- VIEWS

-- Delivery-review comparison
go
create view vw_delivery_review_comparison as (
select 
	case when o.order_estimated_delivery_date < o.order_delivered_customer_date and o.order_delivered_customer_date is not null then 'Late'
	     else 'On Time'
	end as order_delivery_status,
	round((avg(review_score)),2) as avg_review_score
from olist_orders_dataset o
join olist_order_reviews_dataset r
on o.order_id=r.order_id
group by case when o.order_estimated_delivery_date < o.order_delivered_customer_date and o.order_delivered_customer_date is not null then 'Late'
	     else 'On Time'
	     end
)
go

-- Avg order value by state
go
create view vw_avg_order_value_by_state as
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
go


-- PROCEDURE

-- State orders summary
go
create procedure state_order_summary
@state varchar (20)
as
begin
	with total_value as (
	select order_id, sum(price) as order_total_value
	from olist_order_items_dataset
	group by order_id
)
select 
	c.customer_state, 
	avg(t.order_total_value) as avg_order_value, 
	count(o.order_id) as number_of_orders
from total_value as t
join olist_orders_dataset as o
on o.order_id=t.order_id
join olist_customers_dataset as c
on o.customer_id=c.customer_id
where customer_state=@state
group by c.customer_state
end
go

exec state_order_summary @state='SP'