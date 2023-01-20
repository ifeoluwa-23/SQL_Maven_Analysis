select * from website_sessions;


-- Analysing channels
select 
	distinct website_sessions.utm_content,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as cvr
from website_sessions
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 
	1
order by sessions desc;

-- count of bsearch against gsearch sessions
select 
	min(date(created_at)),
    count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_session_id else null end) as bsearch_session,
    count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_session_id else null end) as gsearch_session
from website_sessions
where 
	created_at > '2012-08-22'
    and created_at < '2012-11-29'
group by yearweek(created_at)
;

-- Comparing Channel Characteristics

select 
	count(distinct website_session_id),
    count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_session,
	(count(case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) / 
    count(case when utm_source = 'bsearch' then website_session_id else null end)) * 100 as bmp,
    count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_session,
	(count(case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) / 
    count(case when utm_source = 'gsearch' then website_session_id else null end)) * 100 as gmp
from website_sessions
where utm_campaign = 'nonbrand'
	and created_at > '2012-08-22'
    and created_at < '2012-11-30' 
;

-- Cross Channel Bid Optimization
select 
	website_sessions.utm_source,
    count(case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile,
    count(case when website_sessions.device_type = 'mobile' then orders.order_id else null end) as mobile_order,
    count(case when website_sessions.device_type = 'mobile' then orders.order_id else null end) / 
    count(case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile_cvr,
    count(case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop,
    count(case when website_sessions.device_type = 'desktop' then orders.order_id else null end) as desktop_order,
    count(case when website_sessions.device_type = 'desktop' then orders.order_id else null end) / 
    count(case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_cvr
from website_sessions
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_campaign = 'nonbrand'
	and website_sessions.created_at > '2012-08-22'
    and website_sessions.created_at < '2012-09-18'
group by
	website_sessions.utm_source
;

-- Analyzing Channel Portfolio Weekly Trends
select
	min(date(created_at)),
    count(case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_mobile,
    count(case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_mobile,
    (count(case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) 
    / count(case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end)) * 100 as m_comparison,
    count(case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_desktop,
    count(case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_desktop,
    (count(case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) 
    / count(case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end)) * 100 as d_comparison

from website_sessions
where
	utm_campaign = 'nonbrand'
    and created_at > '2012-11-04'
    and created_at < '2012-12-22'
group by
	yearweek(created_at)
;
select * from website_sessions;

-- Analyzing direct brand-driven traffic
select
	case
		when http_referer is null then 'direct_type_in'
        when http_referer = 'https://www.gsearch.com' then 'gsearch'
        when http_referer = 'https://www.bsearch.com' then 'bsearch'
        else 'others'
	end,
    count(website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
	and utm_source is null
group by 1
order by 2 desc;

select
	month(created_at) as Month,
	case
		when http_referer is null then 'direct_type_in'
        when http_referer = 'https://www.gsearch.com' then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' then 'bsearch_organic'
        else 'others'
	end as Referer,
    count(website_session_id) as sessions
from 
	website_sessions
where 
	created_at < '2012-12-23'
    and utm_campaign = 'brand'
group by
	1, 2;













