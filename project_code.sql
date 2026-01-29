-- creating database and creating tables and importaing data
create database projects;
use projects;
Drop table if exists category;
create table category (
			category_id varchar(10),
            category_name varchar(25));
select * from category;

alter table category modify column category_id varchar(10) primary key;
drop table if exists products;

create table products(
			product_id varchar(20) primary key,
            product_name varchar(40),
            category_id varchar(20),
            launch_date date,
            price float,
            foreign key(category_id) references category (category_id)
            );


create table stores(
			store_id varchar(10) primary key,
            store_name varchar (30),
            city varchar(20),
            country varchar(20));
create table sales (
			sale_id varchar(15) primary key,
            sale_date date,
            store_id varchar(10), -- foreign key
            product_id varchar(10),-- foreign key
            quantity Int,
            foreign key (store_id)references stores(store_id)
           );
select * from sales order by sale_date;
 create table warranty (
				claim_id varchar(20) primary key,
                claim_date date,
                sale_id varchar (20), -- foreign key
                repair_status varchar(20),
                foreign key(sale_id) references sales(sale_id));

select * from warranty;

select * from products;

create index product_index on sales(product_id);

-- problem solving

-- Q1.    Find the number of stores in each country.
select 
	country,
 	count(*) as total_stores
    from stores 
    group by 1;
    
 -- Q2 Calculate the total number of units sold by each store.
 select 	 
	s.store_name,
    count(q.quantity) as Total_units
    from stores s join sales q on s.store_id = q.store_id
    group by 1;

-- Q3. Identify how many sales occurred in December 2023.
select 
	count(*)
    from sales 
     where  date_format(sale_date,'%M-%y')= 'December-23';  -- changed date format 
     
-- Q3 . Determine how many stores have never had a warranty claim filed.
select 
	 count(*)
    from stores 
    where store_id not IN (
                        select 
	                        distinct store_id
					    from sales s Right join warranty w on s.sale_id = w.sale_id);
   
   
-- Q5. Calculate the percentage of warranty claims marked as "declineœ"
 select distinct repair_status from warranty;
 select 
	 count(*)/(select count(*) from warranty)*100 as percentage  -- (no of event/total no of event) * 100 = percentage
     from warranty 
 where repair_status = 'Rejected';
 
 -- Q6 Identify which store had the highest total units sold in the last year
 
select distinct year( sale_date) from sales;

SELECT
    s. store_id,
    t.store_name,
    t.city,
    SUM(s.quantity) AS total_quantity
FROM sales s
Join stores t on 
s.store_id = t.store_id
WHERE sale_date >= CURRENT_DATE - INTERVAL 2 YEAR -- removing date from current data to get last year data
GROUP BY store_id
ORDER BY total_quantity DESC
limit 1;



-- Q7 Count the number of unique products sold in the last year
select 
	count(distinct product_id) 
    from sales
    where sale_date >= (current_date - interval 2 year);
    
    
-- Q8  Find the average price of products in each category.
select 
	c.category_id,
    c.category_name,
    round(avg(p.price),2)
from products p
join category c on
p.category_id = c.category_id
group by 1;
    
    
-- Q9 How many warranty claims were filed in 2024?
select 
	count(*) as count_of_warranty
from warranty
where extract(year from claim_date) = 2024;

-- Q10 For each store, identify the best-selling day based on highest quantity sold.

select * from 
(
select
    store_id,
    dayname(sale_date)as days,
    sum(quantity)as total_units,
    rank() over(partition by store_id order by sum(quantity) desc ) as high
    
    from sales
    group by store_id,days
    ) as ts
where high = 1;

-- Medium to Hard 
-- Q11. Identify the least selling product in each country for each year based on total units sold.

with sale as (select 
	p.product_name,
    t.country,
    sum(s.quantity) as total ,
    rank() over (partition by t.country order by sum(s.quantity) desc) as ranks  -- ranking the sum of quantity by country in decs order
from sales s
join stores t on s.store_id = t.store_id
join products p on s.product_id = p.product_id
group by 2,1)
select * from sale where ranks = 1;


-- Q.12 Calculate how many warranty claims were filed within 180 days of a product sale.


select 
	count(*)
from warranty w
left join sales s on w.sale_id = s.sale_id
where w.claim_date - s.sale_date <= 180;

-- Q13. Determine how many warranty claims were filed for products launched in the last two years.

select
	product_name,
    count(claim_id) as number_of_claims,
    count(s.sale_id) as number_of_sales
from warranty w 
right join  sales s on s.sale_id = w.sale_id
join products p on p.product_id = s.product_id
where launch_date >= date_sub(current_date(),interval 2 year)
group by product_name;


-- Q14.List the months in the last three years where sales exceeded 5,000 units in the USA..

select 
	sum(quantity) as sale_units,
	date_format(sale_date,'%m-%Y')as dates
from sales s 
join stores st on s.store_id = st.store_id
where sale_date >= date_sub(current_date(), interval 3 year)
and country = 'united states'
group by 2
having sum(quantity) > 5000
order by year(dates);


-- Q15.Identify the product category with the most warranty claims filed in the last two years.

select
	c.category_name,
    count(w.claim_id) as no_of_claims
from warranty w
left join sales s on s.sale_id = w.sale_id
join products p on p.product_id = s.product_id 
join category c on c.category_id = p.category_id
where w.claim_date >= date_sub(current_date(),interval 2 year)
group by 1
order by 2 desc;

-- complex problems

-- Q16.Determine the percentage chance of receiving warranty claims after each purchase for each country.




