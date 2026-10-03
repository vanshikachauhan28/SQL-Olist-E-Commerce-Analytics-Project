-- DDL

create table olist_customers_dataset (
	customer_id varchar (32) not null primary key,
	customer_unique_id varchar (32) not null, 
	customer_zip_code_prefix int not null,
	customer_city varchar (30) not null, 
	customer_state varchar (30) not null
)

create table olist_orders_dataset (
	order_id varchar (32) not null primary key, 
	customer_id varchar (32) not null, 
	order_status varchar (30) not null, 
	order_purchase_timestamp datetime not null,
	order_approved_at datetime,
	order_delivered_carrier_date datetime,
	order_delivered_customer_date datetime,
	order_estimated_delivery_date datetime not null,
	constraint FK_customer_id
		foreign key (customer_id) references olist_customers_dataset(customer_id)
)

create table olist_products_dataset (
	product_id varchar (32) not null primary key, 
	product_category_name varchar (200) not null, 
	product_name_length int,
	product_description_length int, 
	product_photos_qty int,
	product_weight_g int,
	product_length_cm int, 
	product_height_cm int,
	product_width_cm int
)

create table olist_order_items_dataset (
	primary key (order_id, order_item_id),
	order_id varchar (32) not null,
	order_item_id int not null,
	product_id varchar (32) not null,
	seller_id varchar (32) not null, 
	shipping_limit_date datetime not null,
	price decimal (7,2) not null,
	freight_value decimal (7,2) not null,
	constraint FK_product_id
		foreign key (product_id) references olist_products_dataset(product_id),
	constraint FK_order_id_items
		foreign key (order_id) references olist_orders_dataset(order_id)
)

create table olist_sellers_dataset (
	seller_id varchar (32) primary key not null,
	seller_zip_code_prefix int not null,
	seller_city varchar (100) not null,
	seller_state varchar (20) not null
)

create table olist_geolocation_dataset (
	primary key (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng),
	geolocation_zip_code_prefix int not null,
	geolocation_lat decimal (25,20) not null,
	geolocation_lng decimal (25,20) not null,
	geolocation_city varchar (100) not null,
	geolocation_state varchar (20) not null
)

create table olist_order_reviews_dataset (
	primary key (review_id, order_id),
	review_id varchar (32) not null,
	order_id varchar (32) not null,
	review_score int not null,
	review_comment_title text,
	review_comment_message text,
	review_creation_date datetime not null,
	review_answer_timestamp datetime not null,
	constraint FK_order_id_reviews
		foreign key (order_id) references olist_orders_dataset (order_id)
)

create table olist_order_payments_dataset (
	primary key (order_id, payment_sequential),
	order_id varchar (32) not null,
	payment_sequential int not null,
	payment_type varchar (50) not null,
	payment_installments int not null,
	payment_value decimal (7,2) not null,
	constraint FK_order_id_payments
		foreign key (order_id) references olist_orders_dataset (order_id)
)

create table product_category_name_translation (
	product_category_name varchar (200) not null primary key,
	product_category_name_english varchar (200) not null
)

create table staging_table (
	geolocation_zip_code_prefix int not null,
	geolocation_lat decimal (25,20) not null,
	geolocation_lng decimal (25,20) not null,
	geolocation_city varchar (100) not null,
	geolocation_state varchar (20) not null )