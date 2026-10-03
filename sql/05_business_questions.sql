-- BUSINESS QUESTIONS

-- Percentage of orders were delivered late
select 
	sum(case when order_estimated_delivery_date < order_delivered_customer_date and order_delivered_customer_date is not null then 1
		else 0 end) as late_orders,
	count(order_delivered_customer_date) as delivered_orders,
	round((sum(case when order_estimated_delivery_date < order_delivered_customer_date and order_delivered_customer_date is not null then 1
		   else 0 end)*100.0/count(order_delivered_customer_date)),2) as percentage_of_late_orders
from olist_orders_dataset

-- Checking if late delivery affects customer's score
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


-- Distribution of payment types used
select 
	payment_type,
	count(*) as count_of_payment_types,
	round(count(payment_type)*100.0/(select count(*) from olist_order_payments_dataset),2) as percentage_of_payment_types
from olist_order_payments_dataset
group by payment_type

-- Typical number of installments customers choose
select 
	min(payment_installments) as min_installment,
	max(payment_installments) as max_installment,
	avg(payment_installments) as avg_installment,
	(select count(*) from olist_order_payments_dataset where payment_installments=1) as single_installment,
	(select count(*) from olist_order_payments_dataset where payment_installments!=1) as multiple_installments
from olist_order_payments_dataset

-- RFM segmentation (recency, frequency, monetary)
select 
	c.customer_unique_id,
	count(distinct o.order_id) as number_of_orders,
	sum(i.price) as money_spent,
	datediff(day, max(o.order_purchase_timestamp),(select max(order_purchase_timestamp) from olist_orders_dataset)) as recent_order_date
from olist_customers_dataset c
join olist_orders_dataset o
on c.customer_id=o.customer_id
join olist_order_items_dataset i
on o.order_id=i.order_id
group by c.customer_unique_id