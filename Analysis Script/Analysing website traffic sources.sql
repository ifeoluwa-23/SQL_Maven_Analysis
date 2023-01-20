/* shows the sources of website sessions 
with a breakdown by UTM source , campaign and referring domain */

select 
	utm_source,
    utm_campaign,
    http_referer,
    count(distinct website_session_id) as Sessions
from website_sessions
where created_at between '2012-03-19%' and '2012-04-12%'
group by utm_source, utm_campaign, http_referer
order by 4 desc;

/* shows deeper insight into gsearch nonbrand source/campaign */
select 
	count(distinct website_sessions.website_session_id) as Sessions,
    count(distinct orders.order_id) as Orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as cvr
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id 
where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at between '2012-03-19%' and '2012-04-12%'
	and website_sessions.utm_campaign = 'nonbrand';

/* shows the year and month website sessions */
select 
	year(created_at),
    month(created_at),
    count(distinct website_session_id) as Number_of_sessions
from website_sessions
where website_session_id between 10000 and 30000
group by 1, 2;

    
select
	min(date(created_at)) as Week_dates,
    count(website_session_id) as No_of_sessions
from website_sessions
where created_at <'2012-05-10'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by week(created_at);

/* shows the conversion rate (CVR) from session to order */

select 
	website_sessions.device_type,
    count(distinct website_sessions.website_session_id) as No_of_sessions,
    count(distinct orders.order_id) as No_of_orders,
    (count(distinct orders.order_id) / count(distinct website_sessions.website_session_id)) as CVR
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-05-11'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1;

/* shows website sessions based on device type*/

select 
	min(date(created_at)) as Week_start_date,
    count(distinct(case when device_type = 'mobile' then website_session_id else null end)) as Mobile,
    count(distinct(case when device_type = 'desktop' then website_session_id else null end)) as Desktop
from website_sessions
where created_at between '2012-04-15' and '2012-06-09'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by week(created_at);











