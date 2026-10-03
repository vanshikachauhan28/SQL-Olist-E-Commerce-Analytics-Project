-- PERFORMANCE AND INDEXING

set statistics io on

select 
	sum(case when order_estimated_delivery_date < order_delivered_customer_date and order_delivered_customer_date is not null then 1
		else 0 end) as late_orders,
	count(order_delivered_customer_date) as delivered_orders,
	round((sum(case when order_estimated_delivery_date < order_delivered_customer_date and order_delivered_customer_date is not null then 1
		   else 0 end)*100.0/count(order_delivered_customer_date)),2) as percentage_of_late_orders
from olist_orders_dataset

select * from 
olist_orders_dataset
where customer_id='3ce436f183e68e07877b285a838db11a'

create index idx_orders_customer_id on olist_orders_dataset(customer_id)

/*  Querying 'olist_orders_dataset' by 'customer_id' without an index required 2391 logical reads.
	After creating a non-clustered index on 'customer_id', the same query dropped to 6 logical reads.
	This demonstrates that indexes benefit selective, filtering queries but provide on benefit to full table
	aggregate queries. */

set statistics io off