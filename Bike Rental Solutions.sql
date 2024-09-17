select * from customer;
select * from bike;
select * from rental;
select * from membership_type;
select * from membership;



--1
/*Emily would like to know how many bikes the shop owns by category. Can you get this for her? 
Display the category name and the number of bikes the shop owns in each category (call this column number_of_bikes ). 
Show only the categories where the number of bikes is greater than 2.
*/



select category, count(1) as number_of_bikes
from bike
group by category
having count(1) > 2
order by 2;



--2
/*
Emily needs a list of customer names with the total number of memberships purchased by each.
For each customer, display the customer's name and the count of memberships purchased (call this column membership_count ). 
Sort the results by membership_count , starting with the customer who has purchased the highest number of memberships.
Keep in mind that some customers may not have purchased any memberships yet. 
In such a situation, display 0 for the membership_count.
*/



select  c.name, count(m.*) as membership_count
from customer c
left join membership m on c.id = m.customer_id
group by c.id, c.name
order by 2 desc;



--3
/*
Emily is working on a special offer for the winter months. Can you help her prepare a list of new rental prices?
For each bike, display its ID, category, old price per hour (call this column old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), 
old price per day (call it old_price_per_day ), and discounted price per day (call it new_price_per_day ).
Electric bikes should have a 10% discount for hourly rentals and a 20% discount for daily rentals. 
Mountain bikes should have a 20% discount for hourly rentals and a 50% discount for daily rentals. 
All other bikes should have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits.
*/



select id, category
, price_per_hour as old_price_per_hour
, case when category = 'electric' then round((price_per_hour - price_per_hour*10/100),2)
       when category = 'mountain bike' then round((price_per_hour - price_per_hour*20/100),2)
	   else round((price_per_hour - price_per_hour*50/100),2) end as new_price_per_hour
, price_per_day as old_price_per_day
, case when category = 'electric' then round((price_per_day - price_per_day*20/100),2)
       when category = 'mountain bike' then round((price_per_day - price_per_day*50/100),2)
	   else round((price_per_day - price_per_day*50/100),2) end as new_price_per_day
from bike
order by 2;



--4
/*
Emily is looking for counts of the rented bikes and of the available bikes in each category.
Display the number of available bikes (call this column available_bikes_count ) 
and the number of rented bikes (call this column rented_bikes_count ) by bike category.
*/



select category
, count(case when status = 'available' then 1 end) as available_bikes_count
, count(case when status = 'rented' then 1 end) as rented_bikes_count
from bike
group by category;



--5
/*
Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across all the years. 
Display the total revenue from rentals for each month, the total for each year, and the total across all the years. Do not take memberships into account. 
There should be 3 columns: year, month and revenue .Sort the results chronologically. 
Display the year total after all the month totals for the corresponding year. Show the all-time total as the last row.
*/



select extract(year from start_timestamp) as year, extract(month from start_timestamp) as month_name, sum(total_paid) as revenue
from rental
group by rollup (extract(year from start_timestamp), extract(month from start_timestamp))
order by 1, 2;



--6
/* 
Emily has asked you to get the total revenue from memberships for each combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this column membership_type_name ), 
and the total revenue (call this column total_revenue ) for every combination of year, month, and membership type. 
Sort the results by year, month, and name of membership type.
*/



select extract(year from m.end_date) as year
, extract(month from m.end_date) as month
, mt.name as membership_type_name
, sum(m.total_paid) as total_revenue
from membership m
join membership_type mt on mt.id = m.membership_type_id
group by extract(year from m.end_date) 
, extract(month from m.end_date) 
, mt.name 
order by 1,2,3;



--7
/*
Next, Emily would like data about memberships purchased in 2023, with 
subtotals and grand totals for all the different combinations of membership 
types and months.
Display the total revenue from memberships purchased in 2023 for each combination of month and membership type. 
Generate subtotals and grand totals for all possible combinations.  
There should be 3 columns: membership_type_name , month , and total_revenue .
Sort the results by membership type name alphabetically and then chronologically by month.
*/



select mt.name as membership_type_name, extract(month from end_date) as month, sum(total_paid) as total_revenue 
from membership m
join membership_type mt on m.membership_type_id = mt.id
group by rollup  (mt.name , extract(month from end_date))
order by 1, 2;



--8
/*
Now it's time for the final task.
Emily wants to segment customers based on the number of rentals and see the count of customers in each segment. Use your SQL skills to get this!
Categorize customers based on their rental history as follows:

Customers who have had more than 10 rentals are categorized as -- 'more than 10'.
Customers who have had 5 to 10 rentals (inclusive) are categorized as -- 'between 5 and 10'.
Customers who have had fewer than 5 rentals should be categorized as -- 'fewer than 5'.

Calculate the number of customers in each category. Display two columns: 
rental_count_category (the rental count category) and 
number of customers in each category).
*/



with cte as 
		(select customer_id, count(1) as total
		from rental
		group by customer_id),
     cte2 as 
		(select *
		, case when total > 10 then 'more than 10'
		       when total between 5 and 10 then 'between 5 and 10'
			   else 'fewer than 5'
			   end as rental_count_category
		from cte)
select rental_count_category, count(1) as number_of_customers
from cte2
group by rental_count_category;


