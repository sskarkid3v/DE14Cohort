set search_path to training;

create or replace view vw_order_totals as
select
	o.order_id, o.customer_id, o.order_date, o.status,
	sum(oi.quantity * oi.unit_price) as order_total,
	count(*) as line_count,
	sum(oi.quantity) as total_qty
from orders o
join order_items oi on oi.order_id = o.order_id
group by o.order_id, o.customer_id, o.order_date, o.status;

select * from vw_order_totals


create or replace materialized view mv_order_totals as
select
	o.order_id, o.customer_id, o.order_date, o.status,
	sum(oi.quantity * oi.unit_price) as order_total,
	count(*) as line_count,
	sum(oi.quantity) as total_qty
from orders o
join order_items oi on oi.order_id = o.order_id
group by o.order_id, o.customer_id, o.order_date, o.status;

refresh materialized view mv_order_totals;

refresh materialized view concurrently mv_order_totals;

select * from mv_order_totals


--scalar subquery
select product_id, product_name, unit_price,
(select AVG(unit_price) from products) as avg_price
from products;

--IN subquery
select * from customers where customer_id in (select customer_id from orders)

--exists subquery
select * from customers c where exists (select 1 from orders o where o.customer_id=c.customer_id)

--correlated subquery
select
	c.customer_id, c.full_name,
	(select max(o.order_date) from orders o where o.customer_id=c.customer_id) as last_order_date
from customers c;


select
	v.order_id,
	v.customer_id,
	c.full_name,
	v.order_date,
	v.status,
	v.order_total
from vw_order_totals v
join customers c on c.customer_id = v.customer_id

create view vw_customer_spend as
select c.customer_id, c.full_name,c.city, coalesce(sum(v.order_total),0) as lifetime_spend,
count(v.order_id) as total_orders
from customers c
left join vw_order_totals v on v.customer_id = c.customer_id
group by c.customer_id, c.full_name,c.city


select customer_Id, full_name, lifetime_spend,
rank() over (order by lifetime_spend desc) as spend_rank,
dense_rank() over (order by lifetime_spend desc) as desnse_spend_rank,
row_number() over (order by lifetime_spend desc) as row_num_rank
from vw_customer_spend

1	1
2	2
3	3
3	3
5	4

select order_id, status, order_total,
	rank() over(partition by status order by order_total desc) as rank_in_status
from vw_order_totals

--running_totals
select order_date, sum(order_total) as daily_revenue,
sum(sum(order_total)) over(order by order_date) as running_revenue
from vw_order_totals
group by order_date


--procedures
create or replace procedure place_order(
	p_customer_id bigint,
	p_product_id bigint,
	p_qty int
)
language plpgsql
as $$
declare
	v_order_id bigint;
	v_price numeric(10,2);
begin
	--validate qty
	if p_qty <= 0 then
		raise exception 'quantity must be > 0';
	end if;

	--validate if prodcut exists and is active
	select unit_price into v_price
	from products
	where product_id = p_product_id and is_active= TRUE;

	if v_price is NULL then
		raise exception 'product not found or inactive';
	end if;

	--create order
	insert into orders(customer_id, status)
	values (p_customer_id, 'new')
	returning order_id into v_order_id;

	--create order item
	insert into order_items(order_id, product_id, quantity, unit_price)
	values (v_order_id, p_product_id, p_qty, v_price);

	raise notice 'order created with order_id=%', v_order_id;
end;
$$;

call place_order(11,5,0);

select * from customers;
select * from products

select * from products

	

