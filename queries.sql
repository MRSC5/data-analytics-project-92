SELECT COUNT(*) AS customers_count
FROM customers;


SELECT
   CONCAT(e.first_name, ' ', e.last_name) AS seller,
   COUNT(s.sales_id) AS operations,
   FLOOR(SUM(p.price * s.quantity)) AS income
   FROM
   employees e
JOIN
   sales s ON e.employee_id = s.sales_person_id
JOIN
   products p ON s.product_id = p.product_id
GROUP BY
   e.employee_id
ORDER BY
   income DESC
LIMIT 10;


SELECT
   CONCAT(e.first_name, ' ', e.last_name) AS seller,
   TO_CHAR(s.sale_date, 'day') AS day_of_week,
   FLOOR(SUM(p.price * s.quantity)) AS income
FROM
   employees e
JOIN
   sales s ON e.employee_id = s.sales_person_id
JOIN
   products p ON s.product_id = p.product_id
GROUP BY
    EXTRACT(ISODOW FROM s.sale_date), CONCAT(e.first_name, ' ', e.last_name), TO_CHAR(s.sale_date, 'day')
   ORDER BY
   EXTRACT(ISODOW FROM s.sale_date), seller;


with average_income as (
select sales_person_id,
floor(sum(quantity * price)/ count(sales_id)) as avg_income
from sales s
join products p on
s.product_id = p.product_id
group by sales_person_id
),
overall_average as (
select floor(avg(avg_income)) as overall_avg
from average_income
)
select concat(e.first_name,' ', e.last_name) as seller,
ai.avg_income as average_income
from average_income ai
join employees e on
ai.sales_person_id = e.employee_id
where
ai.avg_income < (select overall_avg from overall_average)
order by average_income asc;


WITH tab AS (
   SELECT
       c.customer_id,
       s.sale_date,
       p.price,
       s.quantity
   FROM customers c
   JOIN sales s ON c.customer_id = s.customer_id
   JOIN products p ON s.product_id = p.product_id
)
SELECT
   TO_CHAR(sale_date, 'YYYY-MM') AS selling_month,
   COUNT(DISTINCT customer_id) AS total_customers,
   FLOOR(SUM(price * quantity)) AS income
FROM tab
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(sale_date, 'YYYY-MM');


with tab as (
select
c.customer_id,
concat(c.first_name, ' ', c.last_name) as customer,
MIN(s.sale_date) as sale_date,
concat(e.first_name, ' ', e.last_name) as seller
from customers c
join sales s on
c.customer_id = s.customer_id
join employees e on
s.sales_person_id = e.employee_id
join products p on
s.product_id = p.product_id
where p.price = 0
group by c.first_name, c.customer_id, c.last_name, e.first_name, e.last_name
order by sale_date
)
select
customer,
sale_date,
seller
from tab
where sale_date in (
select min(sale_date)
from sales s group by customer_id
)
order by customer;
