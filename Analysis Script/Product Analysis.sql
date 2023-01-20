select * from orders;

-- Calculating all orders, revenue, margin and AOV
select 
	count(order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    round(avg(price_usd),2) as average_order_value
from orders;

-- Monthly trends for date for number of sales, total revenue, and margin
-- Analyzing Product-Level Sales Analysis

select
	year(created_at) as year,
    month(created_at) as month,
    count(order_id) as orders,
    sum(price_usd) as total_revenue,
    sum(price_usd - cogs_usd) as total_margin
from orders
where
	created_at < '2013-01-04'
group by
	1,2;

-- Analyzing Product Launches
select 
    year(website_sessions.created_at) as year,
    month(website_sessions.created_at) as month,
    count(website_sessions.website_session_id) as sessions,
    count(orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as cvr,
    round(sum(orders.price_usd)/count(website_sessions.website_session_id),2) as revenue_per_session,
	count(case when primary_product_id = 1 then order_id else null end) as Product_1_orders,
    count(case when primary_product_id = 2 then order_id else null end) as Product_2_orders
from website_sessions
left join orders
	on orders.website_session_id = website_sessions.website_session_id
where
	website_sessions.created_at between '2012-04-01' and '2013-04-05'
group by
	1,2;

select * from orders;

select
	orders.primary_product_id as ordered_product,
    count(orders.order_id) as orders,
    count(case when order_items.product_id=1 then orders.order_id else null end) as Prod1,
    count(case when order_items.product_id=2 then orders.order_id else null end) as Prod2,
    count(case when order_items.product_id=3 then orders.order_id else null end) as Prod3
    -- order_items.product_id as cross_sell_product,
    
from orders
left join order_items
	on order_items.order_id = orders.order_id
    and order_items.is_primary_item=0
where 
	orders.order_id between 10000 and 11000
group by
	1
order by 1;


select * from order_item_refunds;
    
    
    