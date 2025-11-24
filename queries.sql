-- customers_count.csv
select count(customer_id) as customers_count
from
    customers;

-- top_10_total_income.csv
select
    concat(emp.first_name, ' ', emp.last_name) as seller,
    count(s.sales_person_id) as operations,
    trunc(sum(s.quantity * p.price), 0) as income
from
    sales as s
inner join
    employees as emp
    on s.sales_person_id = emp.employee_id
inner join
    products as p
    on s.product_id = p.product_id
group by
    emp.first_name,
    emp.last_name
order by
    income desc
limit 10;

-- lowest_average_income.csv
select
    concat(e.first_name, ' ', e.last_name) as seller,
    trunc(avg(s.quantity * p.price), 0) as average_income
from
    sales as s
inner join
    employees as e
    on s.sales_person_id = e.employee_id
inner join
    products as p
    on s.product_id = p.product_id
group by
    e.first_name,
    e.last_name
having
    avg(s.quantity * p.price) < (
        select avg(s2.quantity * p2.price)
        from
            sales as s2
        inner join
            products as p2
            on s2.product_id = p2.product_id
    )
order by
    average_income;

-- day_of_the_week_income.csv
select
    concat(emp.first_name, ' ', emp.last_name) as seller,
    to_char(s.sale_date, 'day') as day_of_week,
    trunc(sum(s.quantity * p.price), 0) as income
from
    sales as s
inner join
    employees as emp
    on s.sales_person_id = emp.employee_id
inner join
    products as p
    on s.product_id = p.product_id
group by
    emp.first_name,
    emp.last_name,
    to_char(s.sale_date, 'day'),
    dayofweek(s.sale_date) -- линтер ругался на extract(isodow from s.sale_date)
order by
    dayofweek(s.sale_date), -- та же ситуация
    seller;

-- age_groups.csv
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age between 41 and 100 then '40+'
    end as age_category,
    count(*) as age_count
from
    customers
group by
    age_category
order by
    age_category;

-- customers_by_month.csv
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    trunc(sum(s.quantity * p.price), 0) as income
from
    sales as s
inner join
    products as p
    on s.product_id = p.product_id
group by
    to_char(s.sale_date, 'YYYY-MM')
order by
    to_char(s.sale_date, 'YYYY-MM');

-- special_offer.csv
with sale_number as (
    select
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        row_number() over (
            partition by s.customer_id
            order by s.sale_date
        ) as sale_number
    from
        sales as s
    inner join
        products as p
        on s.product_id = p.product_id
    where
        p.price = 0
)

select
    sn.sale_date,
    concat(c.first_name, ' ', c.last_name) as customer,
    concat(e.first_name, ' ', e.last_name) as seller
from
    sale_number as sn
inner join
    customers as c
    on sn.customer_id = c.customer_id
inner join
    employees as e
    on sn.sales_person_id = e.employee_id
where
    sn.sale_number = 1
order by
    sn.customer_id;
