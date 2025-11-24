-- 1. Подсчёт общего количества покупателей
SELECT
    COUNT(customer_id) AS customers_count
FROM customers;


-- 2.1. Топ‑10 продавцов по доходу
SELECT
    employees.first_name || ' ' || employees.last_name AS seller,
    COUNT(sales.sales_person_id) AS operations,
    FLOOR(SUM(sales.quantity * products.price)) AS income
FROM sales
JOIN products ON sales.product_id = products.product_id
JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY
    employees.employee_id,
    employees.first_name,
    employees.last_name
ORDER BY income DESC
LIMIT 10;

-- 2.2. Продавцы с доходом ниже среднего
WITH avg_income AS (
    SELECT AVG(sales.quantity * products.price) AS global_avg
    FROM sales
    JOIN products ON sales.product_id = products.product_id
)
SELECT
    employees.first_name || ' ' || employees.last_name AS seller,
    FLOOR(AVG(sales.quantity * products.price)) AS average_income
FROM sales
JOIN products ON sales.product_id = products.product_id
JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY
    employees.employee_id,
    employees.first_name,
    employees.last_name
HAVING AVG(sales.quantity * products.price) < (SELECT global_avg FROM avg_income)
ORDER BY average_income;

-- 2.3. Выручка по дням недели
SELECT
    employees.first_name || ' ' || employees.last_name AS seller,
    TO_CHAR(sales.sale_date, 'ID') AS day_of_week,  -- 1-7 (понедельник-воскресенье)
    FLOOR(SUM(sales.quantity * products.price)) AS income
FROM sales
JOIN products ON sales.product_id = products.product_id
JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY
    EXTRACT('isodow' FROM sales.sale_date),
    seller
ORDER BY
    EXTRACT('isodow' FROM sales.sale_date),
    seller;

-- 3.1. Распределение покупателей по возрастным группам
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- 3.2. Количество уникальных покупателей и выручка по месяцам
SELECT
    TO_CHAR(sales.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT sales.customer_id) AS total_customers,
    FLOOR(SUM(sales.quantity * COALESCE(products.price, 0))) AS income
FROM sales
JOIN products ON sales.product_id = products.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

-- 3.3. Первые покупки по акциям (цена = 0)
-- Вариант 1: через ROW_NUMBER()
WITH tab AS (
    SELECT
        customers.customer_id,
        sales.sale_date,
        products.price,
        customers.first_name || ' ' || customers.last_name AS customer,
        employees.first_name || ' ' || employees.last_name AS seller,
        ROW_NUMBER() OVER (
            PARTITION BY customers.customer_id
            ORDER BY sales.sale_date
        ) AS sale_number
    FROM sales
    JOIN customers ON sales.customer_id = customers.customer_id
    JOIN products ON sales.product_id = products.product_id
    JOIN employees ON sales.sales_person_id = employees.employee_id
    WHERE products.price = 0
)
SELECT
    customer,
    sale_date,
    seller
FROM tab
WHERE sale_number = 1;

-- Вариант 2: через DISTINCT ON
SELECT DISTINCT ON (customers.customer_id)
    sales.sale_date,
    customers.first_name || ' ' || customers.last_name AS customer,
    employees.first_name || ' ' || employees.last_name AS seller
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN products ON sales.product_id = products.product_id
JOIN employees ON sales.sales_person_id = employees.employee_id
WHERE products.price = 0
ORDER BY
    customers.customer_id,
    sales.sale_date;
