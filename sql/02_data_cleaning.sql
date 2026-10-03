-- DATA CLEANING


-- Checking NULLs
select count (*)
from olist_orders_dataset
where order_approved_at is null;

select count (*)
from olist_orders_dataset
where order_delivered_carrier_date is null;

select count (*)
from olist_orders_dataset
where order_delivered_customer_date is null


-- Checking if NULLs match with Order Status
select count(*) as count_of_status
from olist_orders_dataset
where order_status!='delivered'


-- Finding the inconsistent rows
select *
from olist_orders_dataset
where order_status='delivered' and order_delivered_customer_date is null
-- (8 orders marked as delivered lack a customer delivery timestamp)


-- Checking date logic violations
select 
*,
case when order_purchase_timestamp>order_delivered_customer_date then 'delivered before purchase'
	 when order_purchase_timestamp>order_delivered_carrier_date then 'carrier before purchase'
	 when order_purchase_timestamp>order_approved_at then 'approved before purchase'
end as date_logic_violation
from olist_orders_dataset
where order_purchase_timestamp>order_delivered_customer_date or
	  order_purchase_timestamp>order_delivered_carrier_date or
	  order_purchase_timestamp>order_approved_at


-- Checking text based inconsistencies in product name
select distinct product_category_name
from olist_products_dataset
group by product_category_name;

select *
from olist_products_dataset
where product_category_name='' and product_weight_g is null; --(Identifying NULLs)

select distinct p.product_category_name
from olist_products_dataset p
left join product_category_name_translation t
on t.product_category_name=p.product_category_name
where t.product_category_name is null; --(Checking how many product names match the translation table)

select *
from olist_products_dataset
where product_category_name in('portateis_cozinha_e_preparadores_de_alimentos', 'pc_gamer');

update olist_products_dataset
set product_category_name='missing_category'
where product_category_name=''; --(Updating empty string name)

insert into product_category_name_translation (product_category_name, product_category_name_english)
values ('portateis_cozinha_e_preparadores_de_alimentos', 'small kitchen appliances and food preparation appliances'),
	   ('pc_gamer', 'pc_gamer') -- (Updating missing rows)


-- Checking State/City name discrepancies
select distinct customer_state, lower(customer_state) as lower_state
from olist_customers_dataset
where customer_state != lower(customer_state);

select distinct customer_state, trim(customer_state) as trim_state
from olist_customers_dataset
where customer_state != trim(customer_state);

select distinct customer_city, lower(customer_city) as lower_city
from olist_customers_dataset
where customer_city != lower(customer_city);

select distinct customer_city, trim(customer_city) as trim_city
from olist_customers_dataset
where customer_city != trim(customer_city);

select distinct seller_state, lower(seller_state) as lower_state
from olist_sellers_dataset
where seller_state != lower(seller_state);

select distinct seller_state, trim(seller_state) as trim_state
from olist_sellers_dataset
where seller_state != trim(seller_state);

select distinct seller_city, lower(seller_city) as lower_city
from olist_sellers_dataset
where seller_city != lower(seller_city);

select distinct seller_city, trim(seller_city) as trim_city
from olist_sellers_dataset
where seller_city != trim(seller_city);

select distinct geolocation_state, lower(geolocation_state) as lower_state
from olist_geolocation_dataset
where geolocation_state != lower(geolocation_state);

select distinct geolocation_state, trim(geolocation_state) as trim_state
from olist_geolocation_dataset
where geolocation_state != trim(geolocation_state);

select distinct geolocation_city, lower(geolocation_city) as lower_city
from olist_geolocation_dataset
where geolocation_city != lower(geolocation_city);

select distinct geolocation_city, trim(geolocation_city) as trim_city
from olist_geolocation_dataset
where geolocation_city != trim(geolocation_city); --(text based discrepancy found) 

create table staging_table (
	geolocation_zip_code_prefix int not null,
	geolocation_lat decimal (25,20) not null,
	geolocation_lng decimal (25,20) not null,
	geolocation_city varchar (100) not null,
	geolocation_state varchar (20) not null ); --(creating a placeholder table to fix the discrepancy)

select distinct geolocation_city, count(*) as row_count
from staging_table
where geolocation_city LIKE '%paulo%'
group by geolocation_city; --(testing data)

update staging_table
set geolocation_city = 
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(
        geolocation_city,
    'á','a'), 'à','a'), 'â','a'), 'ã','a'),
    'é','e'), 'ê','e'),
    'í','i'),
    'ó','o'), 'ô','o'), 'õ','o'),
    'ú','u'),
    'ç','c'); --(replacing language anomalies)

update staging_table 
set geolocation_city = 'sao paulo' 
where geolocation_city in ('sa£o paulo', 'saopaulo')

with deduped as (
    select *,
           row_number() over ( partition by geolocation_zip_code_prefix, geolocation_lat, geolocation_lng order by geolocation_zip_code_prefix
           ) as rn
    from staging_table
)
insert into olist_geolocation_dataset (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
select geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
from deduped
where rn = 1; --(transfering clean data into the main table)

drop table staging_table; --(dropping placeholder table)


-- Orphan foreign key checks

select distinct c.customer_zip_code_prefix
from olist_customers_dataset as c
left join olist_geolocation_dataset as g
on c.customer_zip_code_prefix=g.geolocation_zip_code_prefix
where g.geolocation_zip_code_prefix is null

select distinct s.seller_zip_code_prefix
from olist_sellers_dataset s
left join olist_geolocation_dataset g
on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
where g.geolocation_zip_code_prefix IS NULL


-- Numeric outliers check
select 
    min(price) min_price, max(price) max_price, avg(price) avg_price,
    min(freight_value) min_fv, max(freight_value) max_fv, avg(freight_value) avg_fv
from olist_order_items_dataset

select p.product_category_name, o.price
from olist_order_items_dataset as o
left join olist_products_dataset as p
on o.product_id=p.product_id
where o.price=6735

select min(o.price) min_price, max(o.price) max_price, avg(o.price) avg_price
from olist_order_items_dataset as o
left join olist_products_dataset as p
on o.product_id=p.product_id
where p.product_category_name='utilidades_domesticas'
group by p.product_category_name

with category_flag as (
    select o.product_id, p.product_category_name, o.price,
           avg(o.price) over(partition by p.product_category_name) as category_avg_price
    from olist_order_items_dataset as o
    left join olist_products_dataset as p
    on o.product_id=p.product_id
    ) 
select product_id, product_category_name, price, category_avg_price
from category_flag
where price>category_avg_price*20 --(checking how many products have their avg and max price varied greatly)

select 
    min(product_weight_g) min_weight, max(product_weight_g) max_weight, avg(product_weight_g) avg_weight,
    min(product_length_cm) min_length, max(product_length_cm) max_length, avg(product_length_cm) avg_length,
    min(product_height_cm) min_height, max(product_height_cm) max_height, avg(product_height_cm) avg_height, 
    min(product_width_cm) min_width, max(product_width_cm) max_width, avg(product_width_cm) avg_width
from olist_products_dataset

select *
from olist_products_dataset
where product_weight_g=0 --(4 products have complete dimensional data (length/height/width) but a recorded weight of 0g)