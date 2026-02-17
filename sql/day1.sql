--creating a schema
create sceham if not exists training;

--setting up the default schema to a new schema
set search_path to training;

--deaign a database for small online retail shop
--table customers
create table customers(
	customer_id bigserial primary key,
	full_name text not null,
	email text unique not null,
	phone text,
	city text not null default 'Pokhara',
	created_at timestamptz not null default now()
);

--table products
create table products(
	product_id bigserial primary key,
	sku text not null unique,
	product_name text not null,
	unit_price numeric(8,2) not null check(unit_price > 0),
	is_active boolean not null default true,
	created_at timestamptz not null default now()
);


--table orders
create table orders(
	order_id bigserial primary key,
	customer_id bigint not null references customers(customer_id),
	order_date date not null default current_date,
	status text null default 'new' check(status in('new','paid','shipped','cancelled')),
	notes text
);

--table order_items
create table order_items(
	order_item_id bigserial primary key,
	order_id bigint not null references orders(order_id) on delete cascade,
	product_id bigint not null references products(product_id),
	quantity int not null check (quantity > 0),
	unit_price numeric(10,2) not null check (unit_price>0),
	constraint uq_order_product unique (order_id,product_id)
);


--not null violation
insert into customers(full_name, email, city)
values(null, 'a@b.com','kathmandu');


--check violation
insert into products(sku, product_name,unit_price)
values('SKU-BAD','Bad price',-10);


--unique constraint violation
insert into customers(full_name, email, city)
values('Test user', 'a@b.com','kathmandu');

insert into customers(full_name, email, city)
values('Test user 2', 'a@b.com','kathmandu');


--foreign key violation
select * from customers;

insert into orders(customer_id, status)
values(2, 'new');


insert into orders(customer_id, status)
values(3, 'new');

drop table students_copy;


--add new columns
alter table customers
add column date_of_birth date;

--change the column type of an existing column
alter table customers
alter column phone type varchar(20);

--set or drop a constrain on an existing column
alter table customers
alter column phone set not null;

alter table customers
alter column phone drop not null;

--renaming column
alter table products
rename column product_name to name;


insert into customers(full_name, email, phone, city) values
('Asha Shrestha', 'asha@gmail.com', '9800000001', 'Kathmandu'),
('Ramesh Karki', 'ramesh@gmail.com', '9800000002', 'Lalitpur'),
('Sita Rai', 'sita@gmail.com', '9800000003', 'Biratnagar');

insert into products(sku, product_name, unit_price) values
('SKU-TSHIRT', 'T-Shirt', 1200),
('SKU-JEANS',  'Jeans',   3500),
('SKU-SHOES',  'Shoes',   5200);

insert into orders(customer_id, status,notes) values
(10, 'paid', 'Deliver after 6 PM'),
(10, 'new',  NULL),
(12, 'shipped', 'Fragile');

insert into order_items(order_id, product_id, quantity, unit_price) values
(12, 5, 2, 1200),
(13, 6, 1, 5200),
(12, 7, 1, 3500),
(14, 5, 1, 1200);


--update statment example
update orders
set status = 'paid'
where order_id=13


--delete statement example
delete from orders where order_id=13

select * from orders;
select * from order_items



--example of aliases
select full_name as customer_name, city
from customers;


--operators
-- IS operator used for null/not null checks

select * from orders where notes is null;

--like operator used for pattern search

select * from customers where email like '%gmail.com';


--in operator used for checking membership in a list of items

select * from orders where status in ('new','paid');

--between operator used for range checks

select * from orders
where order_date between current_date-30 and current_date;


--case operator used for conditional logic
select
	product_name, unit_price,
	case
		when unit_price < 2000 then 'budget'
		when unit_price between 2000 and 5000 then 'mid'
		else 'premium'
	end as price_band
from products;


--aggregations

select
	c.customer_id, c.full_name,
	sum(quantity*unit_price) as total_spent
from customers c  
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
group by c.customer_id, c.full_name
having sum(oi.quantity * oi.unit_price) > 50000
order by total_spent desc;
	








