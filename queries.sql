--запрос, который считает общее количество покупателей 
select count(*) as customers_count from customers c;

--отчет с продавцами у которых наибольшая выручка
select concat (e.first_name, ' ', e.last_name) as name, count(s.sales_person_id) as operations, sum(s.quantity*p.price) as income from employees e
left join sales s
on e.employee_id = s.sales_person_id
left join products p
on p.product_id = s.product_id
group by 1
order by income desc nulls last
limit 10
;

--отчет с продавцами, чья выручка ниже средней выручки всех продавцов
with average_employee_sales as (
select concat (e.first_name, ' ', e.last_name) as name, round(avg(s.quantity*p.price), 0) as average_income from employees e
left join sales s
on e.employee_id = s.sales_person_id
left join products p
on p.product_id = s.product_id
group by 1
)
select name, average_income from average_employee_sales
where average_income <
(select round(avg(s.quantity*p.price), 0) as average_sale from employees e
left join sales s
on e.employee_id = s.sales_person_id
left join products p
on p.product_id = s.product_id)
order by average_income
;

--отчет с данными по выручке по каждому продавцу и дню недели
select concat(e.first_name, ' ', e.last_name) as name,
to_char(s.sale_date, 'day') as weekday,
round(sum(s.quantity * p.price), 0) as income
from employees e
inner join sales s
on e.employee_id = s.sales_person_id
inner join products p
on p.product_id = s.product_id
group by to_char(s.sale_date, 'ID'), 2, 1
order by to_char(s.sale_date, 'ID'), name
;

-- отчет с возрастными группами покупателей
select
case
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
when age >= 40 then '40+'
else '0-15'
end as age_category,
sum(count_age) as count
from
(
select age, count(age) as count_age
from customers c
group by age
) as tab
group by age_category;

--отчет с количеством покупателей и выручкой по месяцам
select to_char(s.sale_date, 'YYYY-MM') as date,
count(distinct s.customer_id) as total_customers,
sum(s.quantity * p.price) as income from sales s
left join products p
on s.product_id = p.product_id
group by 1
;

-- отчет с покупателями первая покупка которых пришлась на время проведения специальных акций
select distinct on (c.customer_id) concat(c.first_name, ' ', c.last_name) as customer, s.sale_date,
concat(e.first_name, ' ', e.last_name) as seller
from sales s
left join customers c
on c.customer_id = s.customer_id
left join products p
on p.product_id = s.product_id
left join employees e
on s.sales_person_id = e.employee_id
where (p.price * s.quantity) = 0
order by c.customer_id, s.sale_date
