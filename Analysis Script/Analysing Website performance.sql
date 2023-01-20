-- most visited pages
select 
	pageview_url,
    count(distinct website_pageview_id) as pvs
from website_pageviews
where website_pageview_id<1000
group by 1
order by 2 desc;

create temporary table first_pageview
select 
	website_session_id,
    min(website_pageview_id) as pv_first_visit
from website_pageviews
where website_pageview_id < 1000
group by website_session_id;

select 
    website_pageviews.pageview_url,
    count(distinct first_pageview.website_session_id)
from first_pageview
left join website_pageviews
	on first_pageview.pv_first_visit = website_pageviews.website_pageview_id
group by 1;

-- TOP VISITED PAGES

select 
	pageview_url,
    count(distinct website_pageview_id)
from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;

select 
	pageview_url,
    count(distinct(website_session_id)) as Volume
    -- min(website_pageview_id),
from website_pageviews
where created_at < '2012-06-12'
group by pageview_url
order by 2 desc;

-- FINDING TOP ENTRY PAGE -- 

create temporary table psv
select
    website_session_id,
    min(website_pageview_id) as pv
from website_pageviews
where created_at between '2014-01-01' and '2014-02-01'
group by 1;

select 
	website_pageviews.pageview_url,
    count(distinct(psv.website_session_id))
from psv
left join website_pageviews
	on psv.pv = website_pageviews.website_pageview_id
group by 1;


-- finding first website pageview id for relevant sessions
create temporary table pwc
select
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as pvc
from website_pageviews
left join website_sessions
	on website_sessions.website_session_id = website_pageviews.website_session_id 
    and website_sessions.created_at between '2012-01-01' and '2012-06-14'
group by 1;

-- identifying the landing page of the sessions
create temporary table pwd
select 
	pwc.website_session_id,
    website_pageviews.pageview_url
from pwc
left join website_pageviews
	on pwc.pvc = website_pageviews.website_pageview_id
where pageview_url = '/home';


-- counting pageview of each session to identify bounces
create temporary table pwb  
select 
	pwd.website_session_id,
    pwd.pageview_url,
    count(website_pageviews.website_pageview_id) as visit
from pwd
left join website_pageviews
	on website_pageviews.website_session_id = pwd.website_session_id
group by
	1,
    2
having
	visit = '1';   
    
    
-- final output for calculating Bounce Rates
select
    count(distinct pwd.website_session_id) as sessions,
    count(distinct pwb.website_session_id) as bounce_no,
    count(distinct pwb.website_session_id) / count(distinct pwd.website_session_id) as bnc_rate
from pwd
	left join pwb
		on pwd.website_session_id = pwb.website_session_id;


-- QUESTION 3

-- finding the pageview id for all filter parameters
create temporary table pdp1
select
	website_sessions.website_session_id,
    min(website_pageviews.website_pageview_id)
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where 
	website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
    and website_sessions.created_at between '2012-06-19' and '2012-07-28'
group by 1;

-- filtering out landing page for lander and home
create temporary table pdp11
select 
	pdp1.website_session_id,
    website_pageviews.pageview_url
from pdp1
left join website_pageviews
	on pdp1.website_session_id = website_pageviews.website_session_id
having 
	website_pageviews.pageview_url in ('/lander-1', '/home');

-- sorting out the bounce sessions
create temporary table pdp111
select 
	pdp11.website_session_id,
    pdp11.pageview_url,
    count(website_pageviews.website_pageview_id) as visit
from pdp11
left join website_pageviews
	on website_pageviews.website_session_id = pdp11.website_session_id
group by
	1,
    2
having
	visit = '1';  

-- calculating the bounce rate
select
	pdp11.pageview_url,
	count(distinct pdp11.website_session_id) as number_of_sessions,
    count(distinct pdp111.website_session_id) as bounce_sessions,
    count(distinct pdp111.website_session_id) / count(distinct pdp11.website_session_id) as bounce_rate
from pdp11
left join pdp111
	on pdp11.website_session_id = pdp111.website_session_id
group by 
	1;
    
-- QUESTION 4

select 
	min(date (created_at))
from website_pageviews
group by week(created_at);

select * from website_sessions;

select
	min(date(website_sessions.created_at)),
	website_sessions.website_session_id,
    min(website_pageviews.website_pageview_id)
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where 
	website_sessions.utm_campaign = 'nonbrand'
    and website_sessions.created_at between '2012-06-01' and '2012-08-31'
group by 
	week(website_sessions.created_at);
    
# LAST ASSIGNMENT
select * from website_sessions;
select distinct pageview_url from website_pageviews;

-- filtering out sessions with required pages
select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    case when pageview_url = '/lander-1' then 1 else 0 end as lander_page,
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as fuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
    and website_pageviews.created_at > '2012-08-05'
    and website_pageviews.created_at < '2012-09-05'
order by
	website_sessions.website_session_id,
    website_pageviews.created_at;


-- creating temporary table for filtering out number of session for each page

create temporary table lander_sorting2
select 
	website_session_id,
    max(lander_page) as lander_made_it,
    max(product_page) as product_made_it,
    max(fuzzy_page) as fuzzy_made_it,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thank_page) as final_thank_you
from 
	(select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    case when pageview_url = '/lander-1' then 1 else 0 end as lander_page,
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as fuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
    and website_pageviews.created_at > '2012-08-05'
    and website_pageviews.created_at < '2012-09-05'
order by
	website_sessions.website_session_id,
    website_pageviews.created_at) as page_session
group by 
	website_session_id;

-- counting number of sessions for each

select
	count( distinct website_session_id) as session_id,
    -- count( distinct case when lander_made_it = 1 then website_session_id else null end) as lander,
    count( distinct case when product_made_it = 1 then website_session_id else null end) as product,
    count( distinct case when fuzzy_made_it = 1 then website_session_id else null end) as fuzzy,
    count( distinct case when cart_made_it = 1 then website_session_id else null end) as cart,
    count( distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping,
    count( distinct case when billing_made_it = 1 then website_session_id else null end) as billing,
    count( distinct case when final_thank_you = 1 then website_session_id else null end) as thank
from lander_sorting2;

-- calculating the percentage

select
    -- count( distinct case when lander_made_it = 1 then website_session_id else null end) as lander_session,
    count( distinct website_session_id) as session_id,
    count( distinct case when product_made_it = 1 then website_session_id else null end)
    / count( distinct website_session_id) as rate_lander,
    count( distinct case when fuzzy_made_it = 1 then website_session_id else null end)
    / count( distinct case when product_made_it = 1 then website_session_id else null end) as rate_product,
    count( distinct case when cart_made_it = 1 then website_session_id else null end) 
    / count( distinct case when fuzzy_made_it = 1 then website_session_id else null end) as rate_fuzzy,
    count( distinct case when shipping_made_it = 1 then website_session_id else null end)
    / count( distinct case when cart_made_it = 1 then website_session_id else null end) as rate_cart,
    count( distinct case when billing_made_it = 1 then website_session_id else null end)
    / count( distinct case when shipping_made_it = 1 then website_session_id else null end) as rate_shipping,
    count( distinct case when final_thank_you = 1 then website_session_id else null end)
    / count( distinct case when billing_made_it = 1 then website_session_id else null end) as rate_billing
from lander_sorting2;


-- FINAL ASSIGNMENT 2

-- filtering out sessions with required pages
select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/billing-2' then 1 else 0 end as billing_page2,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_pageviews.created_at > '2012-09-05'
    and website_pageviews.created_at < '2012-11-10'
    and website_pageviews.pageview_url in ('/billing', '/billing-2', '/thank-you-for-your-order')
order by
	website_sessions.website_session_id,
    website_pageviews.created_at;


create temporary table bill_page
select 
	website_session_id,
    max(billing_page) as billing_made_it,
    max(billing_page2) as billing_made_it2,
    max(thank_page) as final_thank_you
from 
	(select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/billing-2' then 1 else 0 end as billing_page2,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_pageviews.created_at > '2012-09-05'
    and website_pageviews.created_at < '2012-11-10'
    and website_pageviews.pageview_url in ('/billing', '/billing-2', '/thank-you-for-your-order')
order by
	website_sessions.website_session_id,
    website_pageviews.created_at) as page_view
group by 
	website_session_id;

select * from bill_page;

select 
	count( distinct website_session_id) as session,
	count( distinct case when billing_made_it =1 and final_thank_you = 1 then website_session_id else null end) as bill,
    count( distinct case when billing_made_it =1 and final_thank_you = 0 then website_session_id else null end) as bill_fail,
	count( distinct case when billing_made_it2 =1 and final_thank_you = 1 then website_session_id else null end) as bill2,
    count( distinct case when billing_made_it2 =1 and final_thank_you = 0 then website_session_id else null end) as bill2_fail
from bill_page;

select 
	count( distinct website_session_id) as session,
    count( distinct case when billing_made_it = 1 then website_session_id else null end)
    / count( distinct website_session_id) as bill_view,
	count( distinct case when billing_made_it = 1 and final_thank_you = 1 then website_session_id else null end)
    / count( distinct case when billing_made_it = 1 then website_session_id else null end) as bill_done,
    count( distinct case when billing_made_it = 1 and final_thank_you = 0 then website_session_id else null end)
    / count( distinct case when billing_made_it = 1 then website_session_id else null end) as bill_not_done,
	count( distinct case when billing_made_it2 = 1 then website_session_id else null end)
    / count( distinct website_session_id) as bill2_view,
	count( distinct case when billing_made_it2 = 1 and final_thank_you = 1 then website_session_id else null end)
    / count( distinct case when billing_made_it2 = 1 then website_session_id else null end) as bill2_done,
    count( distinct case when billing_made_it2 = 1 and final_thank_you = 0 then website_session_id else null end)
    / count( distinct case when billing_made_it2 = 1 then website_session_id else null end) as bill2_not_done
from bill_page;




