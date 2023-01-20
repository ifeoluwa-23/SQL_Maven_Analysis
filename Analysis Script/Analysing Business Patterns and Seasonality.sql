select * from website_sessions;
select * from orders;

-- Analyzing Seasonality by year and month

select
	year(website_sessions.created_at) as Year,
    month(website_sessions.created_at) as Month,
    -- week(website_sessions.created_at) as Week,
    count(website_sessions.website_session_id) as Sessions,
    count(orders.order_id) as Orders
from website_sessions
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by
	1,2;
    
-- Analyzing Seasonalty by week
select
	year(website_sessions.created_at) as Year,
    week(website_sessions.created_at) as Week,
    min(date(website_sessions.created_at)) as Week_start_date,
    count(website_sessions.website_session_id) as Sessions,
    count(orders.order_id) as Orders
from website_sessions
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by
	1, 2;
    
    
-- Analyzing Business Patterns

select 
	hr,
    -- round(avg(sessions),1) as avg_sessions,
    round(avg(case when wkday=0 then sessions else null end),1) as mon,
    round(avg(case when wkday=1 then sessions else null end),1) as tue,
    round(avg(case when wkday=2 then sessions else null end),1) as wed,
    round(avg(case when wkday=3 then sessions else null end),1) as thur,
    round(avg(case when wkday=4 then sessions else null end),1) as fri,
    round(avg(case when wkday=5 then sessions else null end),1) as sat,
    round(avg(case when wkday=6 then sessions else null end),1) as sun
from (
select 
	date(created_at) as date,
    weekday(created_at) as wkday,
    hour(created_at) as hr,
    count(website_session_id) as sessions
from website_sessions
where 
	created_at > '2012-09-15'
    and created_at < '2012-11-15'
group by
	1,2,3
) as daily_hourly_sessions
group by
	1
order by 1;







