--inner join -> show only matched rows

select 
c.customer_Id, c.full_name, o.order_id, o.status
from training.customers c
inner join training.orders o
	on o.customer_id = c.customer_id
	
--left join --> keep everything from the left table
	select 
c.customer_Id, c.full_name, o.order_id, o.status
from training.customers c
left join training.orders o
	on o.customer_id = c.customer_id
	
	
--right join --> keep everything from the right table
	select 
c.customer_Id, c.full_name, o.order_id, o.status
from training.customers c
right join training.orders o
	on o.customer_id = c.customer_id
	
--full outer join --> keep everything from both sides
	select 
c.customer_Id, c.full_name, o.order_id, o.status
from training.customers c
full outer join training.orders o
	on o.customer_id = c.customer_id	
	
--TCL
--rollback

select sku, unit_price from training.products order by product_id;

begin;

update training.products
set unit_price = unit_price * 2
where sku='SKU-TSHIRT';

select sku, unit_price from training.products where sku='SKU-TSHIRT';

rollback;


select sku, unit_price from training.products where sku='SKU-TSHIRT';

--commit
begin;

update training.products
set unit_price = unit_price + 50
where sku='SKU-TSHIRT';

commit;

select sku, unit_price from training.products where sku='SKU-TSHIRT';


--savepoint
begin;

update training.products
set unit_price = unit_price + 50
where sku='SKU-JEANS';

savepoint sp_after_reasonable_change;

update training.products
set unit_price = unit_price + 9999
where sku='SKU-JEANS';

select sku, unit_price from training.products where sku='SKU-JEANS';

rollback to sp_after_reasonable_change;

select sku, unit_price from training.products where sku='SKU-JEANS';

commit;


--DCL 
--roles
create role analyst noninherit;
create role app_user noninherit;

--users
create user u_analyst with password 'password123';
create user u_app with password 'password123';

--assign roles to users
grant analyst to u_analyst;
grant app_user to u_app;

--grant access to schema
grant usage on schema training to analyst, app_user;

--grant read access to tables
grant select on all tables in schema training to analyst;

--grant read access to all new and old tables
alter default privileges in schema training grant select on tables to analyst;

--grant write acess
grant select on training.customers, training.products to app_user;
grant select, insert, update on training.orders, training.order_items to app_user;


-- revoke permissions
revoke update on training.orders from app_user;

--postgresql metadata example
select * from information_schema.role_table_grants rtg 


create table training.app_orders (
	order_id bigserial primary key,
	tenant_id int not null,
	amount numeric(10,2) not null,
	created_by text not null
);

--enable RLS
alter table training.app_orders enable row level security;

create role app_user login password 'password123';
grant usage on schema training to app_user;
grant select, insert, update, delete on training.app_orders to app_user;

--use a session variable to store who/which tenant is calling and set it per connection after login
set training.tenant_id = '10';

--create policies
create policy orders_select_tenant
on training.app_orders
for select
to app_user
using(tenant_id=current_setting('training.tenant_id')::int);


--set operations
--union/union all
--union removes duplicates
select city from training.customers c
union
select city from training.customers c ;

--union all keeps all duplicates
select city from training.customers c
union all
select city from training.customers c ;

--intersect (common members between groups)
select customer_id from training.customers 
intersect
select customer_id from training.orders 

--except (difference between 2 groups)
select customer_id from training.customers 
except
select customer_id from training.orders 


--views (reusable queries)
create or replace view training.vw_orders_totals as
select
	c.customer_id, c.full_name,
	sum(quantity*unit_price) as total_spent
from training.customers c  
join training.orders o on o.customer_id = c.customer_id
join training.order_items oi on oi.order_id = o.order_id
group by c.customer_id, c.full_name
having sum(oi.quantity * oi.unit_price) > 1000
order by total_spent desc;


select * from training.vw_orders_totals

