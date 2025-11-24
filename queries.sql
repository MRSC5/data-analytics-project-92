-- Запрос для подсчета уникальных покупателей в базе данных
SELECT 
    COUNT(DISTINCT customer_id) AS customers_count
FROM 
    customers;

-- Выбираем данные о топ-10 продавцах с наибольшей выручкой
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name,
    e.last_name
ORDER BY income DESC
LIMIT 10;

-- Получаем список продавцов с средней выручкой ниже средней по компании
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name,
    e.last_name
HAVING AVG(s.quantity * p.price) < (
    SELECT AVG(s2.quantity * p2.price) 
    FROM sales s2
    JOIN products p2 ON s2.product_id = p2.product_id
)
ORDER BY average_income ASC;

-- Получаем отчет о суммарной выручке продавцов по дням недели
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'FMDay') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY 
    e.first_name,
    e.last_name,
    TO_CHAR(s.sale_date, 'FMDay'),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY 
    EXTRACT(ISODOW FROM s.sale_date),
    seller;

-- Анализ покупателей по возрастным группам
SELECT 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(DISTINCT customer_id) AS age_count
FROM customers
GROUP BY 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END
ORDER BY 
    CASE 
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END;

-- Получаем данные по продажам с группировкой по месяцам
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM');

-- Получаем информацию о покупателях, совершивших первую покупку во время акции
WITH first_sales AS (
    SELECT 
        customer_id,
        MIN(sale_date) AS first_sale_date
    FROM sales
    GROUP BY customer_id
)
SELECT 
    DISTINCT ON (c.customer_id)
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
JOIN first_sales fs ON c.customer_id = fs.customer_id AND s.sale_date = fs.first_sale_date
WHERE p.price = 0
ORDER BY c.customer_id;