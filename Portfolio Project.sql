
--გამოვიტანოთ მეორე ყველაზე ძვირიანი პროდუქტი თითოეული კატეგორიისთვის

 select category_name, list_price, product_name
 from (
	select 
		 c.category_name, 
		 list_price, 
		 product_name,
	row_number () over (partition by c.category_name order by list_price desc) rn
	from production#products p
	join production#categories c on p.category_id=c.category_id
	 ) as subquery
 where rn=2


-- გამოვიტანოთ ისეთი კლიენტები რომლებსაც აქვთ gmail

select concat(first_name,' ',last_name) full_name, email
from sales#customers
where email like '%gmail.com'


--გამოვიტანოთ ისეთი კლიენტების სახელები, რომლებიც არიან NY-დან და გაკეთებული აქვთ 2ზე მეტი შეკვეთა.

select first_name, last_name
from sales#customers c
join sales#orders o on c.customer_id=o.customer_id
where state='NY'
group by first_name, last_name
having count(o.order_id)>2


--დავითვალოთ თითოეული კლიენტისთვის რა იყო მთლიანი მოგება, დისკონტირების გათვალისწინებით. დათვლილი მოგების საფუძველზე
--შევქმნათ ახალი სვეტი სადაც დააჯგუფებთ მთლიან მოგებას შემდეგნაირად: თუ იქნება 400-ზე ნაკლები -დაბალი
																	-- თუ იქნება 400-დან 1000-მდე - საშუალო
																	-- 1000-ზე მეტი -მაღალი

select first_name, last_name,
       sum(od.list_price * od.quantity * (1-od.discount)) as total_profit,
	   case
	   when sum(list_price * od.quantity * (1-od.discount))<400 then 'low'
	   when sum(list_price * od.quantity * (1-od.discount))>=400 and
	        sum(list_price * od.quantity * (1-od.discount))<1000 then 'avarage'
	   else 'high'
	   end as profit_group
from sales#customers c
join sales#orders o on c.customer_id=o.customer_id
join sales#order_items od on o.order_id=od.order_id
group by first_name, last_name


-- ზემოთ შექმნილი სკრიპტის საფუძველზე შევქმნათ პროცედურა, სადაც ასარჩევად მექნება შეკვეთის გაკეთების თარიღი

CREATE PROCEDURE ProfitByTimeRange
	  @Startdate date,
	  @Enddate date
as
  BEGIN
	select first_name, last_name,
		   sum(od.list_price * od.quantity * (1-od.discount)) as total_profit,
		   case
		   when sum(list_price * od.quantity * (1-od.discount))<400 then 'low'
		   when sum(list_price * od.quantity * (1-od.discount))>=400 and
				sum(list_price * od.quantity * (1-od.discount))<1000 then 'avarage'
		   else 'high'
		   end as profit_group
	from sales#customers c
	join sales#orders o on c.customer_id=o.customer_id
	join sales#order_items od on o.order_id=od.order_id
	where o.order_date between @Startdate and @Enddate
	group by first_name, last_name

end

exec [dbo].[ProfitByTimeRange] '2016-01-01', '2018-01-01'





