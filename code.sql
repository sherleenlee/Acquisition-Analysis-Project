--1. 
count(*) from accounts;

--2. 
select * from region;

--3. 
-- identify number of products
select * from orders;

-- calculate product sales distribution by sales volume
select 'Standard Paper' as label,
sum(standard_qty)*1.0/sum(total) *100 as Percentage from orders
union 
select 'Gloss Paper',
sum(gloss_qty)*1.0/sum(total) *100 from orders
union
select 'Poster Paper',
sum(poster_qty)*1.0/sum(total)*100 from orders
order by percentage desc;

-- -- calculate product sales distribution by sales revenue
select 'Standard Paper ($)' as label,
sum(standard_amt_usd)*1.0/sum(total_amt_usd) *100 as Percentage from orders
union 
select 'Gloss Paper ($)',
sum(gloss_amt_usd)*1.0/sum(total_amt_usd) *100 from orders
union
select 'Poster Paper ($)',
sum(poster_amt_usd)*1.0/sum(total_amt_usd)*100 from orders
order by percentage desc;

--5. 
select
  r.name as region_name,
  COUNT(sr.id) as num_reps
from region as r
left join sales_reps as sr 
on r.id = sr.region_id 
group by r.name
order by r.name;

--6. 
select r.name as region_name, count(o.id) as total_num_orders,
count(distinct sr.id) as num_reps,
count(distinct a.id) as num_accounts,
sum(o.total_amt_usd) as total_revenue,
round(avg(o.total_amt_usd), 2) as avg_revenue from region r
join sales_reps sr on r.id = sr.region_id
join accounts a on sr.id = a.sales_rep_id
join orders o on a.id = o.account_id
where extract(year from o.occurred_at) in (2016)
group by region_name;

--7. 
--avg group
with group_data as
(select ac.name,
case
	when ac.name like '%group' or ac.name like '%Group' then 'group'
	else 'not_group'
end as group_binary,
sum(o.total_amt_usd) total_revenue_by_customer
from accounts ac
left join orders o
on ac.id = o.account_id
group by ac.id, ac.name
having count(o.id) > 0
order by sum(o.total_amt_usd) desc)

select avg(gd.total_revenue_by_customer) avg_group from group_data gd
where gd.group_binary = 'group';

--avg not group
with group_data as
(select ac.name,
case
	when ac.name like '%group' or ac.name like '%Group' then 'group'
	else 'not_group'
end as group_binary,
sum(o.total_amt_usd) total_revenue_by_customer
from accounts ac
left join orders o
on ac.id = o.account_id
group by ac.id, ac.name
having count(o.id) > 0
order by sum(o.total_amt_usd) desc)

select avg(gd.total_revenue_by_customer) avg_not_group from group_data gd
where gd.group_binary != 'group';

--8. 
select 
	r.name,
	we.channel, 
	count(we.channel) channel_count, 
	rank() over(partition by r.name
		order by count(we.channel)) channel_rank, 
	round(100* count(we.channel)/sum(count(we.channel)) 
		over(partition by r.name), 3) channel_perc
from web_events we
join accounts a
on we.account_id = a.id 
join sales_reps sr 
on sr.id = a.sales_rep_id 
join region r 
on r.id = sr.region_id
where r.id between 1 and 4  
group by r.name, we.channel
order by channel_rank
limit 4;
