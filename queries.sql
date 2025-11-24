-- CUSTOMERS_COUNT
-- Этот запрос подсчитывает общее количество покупателей в таблице customers
-- и возвращает результат в колонке с именем customers_count.
-- Он использует функцию COUNT(*), которая считает все строки в таблице,
-- не учитывая, есть ли в них значения NULL.

SELECT
    COUNT(*) AS customers_count
FROM
    customers;


-- top_10_total_income
-- Этот запрос извлекает информацию о десяти лучших продавцах на основе их общей выручки.

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY
    income DESC
LIMIT 10;


-- day_of_the_week_income
-- Этот SQL-запрос выполняет следующие действия:
-- 1. Выбор данных: объединяет имя и фамилию продавца, извлекает день недели, вычисляет выручку
-- 2. Объединение таблиц: employees, sales, products
-- 3. Группировка данных по дню недели и продавцу
-- 4. Сортировка результатов по дню недели и имени продавца

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'day') AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    EXTRACT(ISODOW FROM s.sale_date),
    e.first_name,
    e.last_name,
    TO_CHAR(s.sale_date, 'day')
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;


-- lowest_average_income
-- Этот запрос находит продавцов с доходом ниже среднего

WITH average_income AS (
    SELECT
        s.sales_person_id,
        FLOOR(SUM(p.price * s.quantity) / COUNT(s.sales_id)) AS avg_income
    FROM
        sales AS s
    INNER JOIN
        products AS p
        ON s.product_id = p.product_id
    GROUP BY
        s.sales_person_id
),

overall_average AS (
    SELECT
        FLOOR(AVG(avg_income)) AS overall_avg
    FROM
        average_income
)

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    ai.avg_income AS average_income
FROM
    average_income AS ai
INNER JOIN
    employees AS e
    ON ai.sales_person_id = e.employee_id
WHERE
    ai.avg_income < (
        SELECT
            overall_average.overall_avg
        FROM
            overall_average
    )
ORDER BY
    average_income ASC;


-- customers_by_month
-- Этот запрос анализирует покупателей и доход по месяцам

WITH tab AS (
    SELECT
        c.customer_id,
        s.sale_date,
        p.price,
        s.quantity
    FROM
        customers AS c
    INNER JOIN
        sales AS s
        ON c.customer_id = s.customer_id
    INNER JOIN
        products AS p
        ON s.product_id = p.product_id
)

SELECT
    TO_CHAR(tab.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT tab.customer_id) AS total_customers,
    FLOOR(SUM(tab.price * tab.quantity)) AS income
FROM
    tab
GROUP BY
    TO_CHAR(tab.sale_date, 'YYYY-MM')
ORDER BY
    TO_CHAR(tab.sale_date, 'YYYY-MM');


-- special_offer
-- Этот запрос находит покупателей, которые совершили первую покупку по специальному предложению (цена = 0)

WITH tab AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        MIN(s.sale_date) AS sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller
    FROM
        customers AS c
    INNER JOIN
        sales AS s
        ON c.customer_id = s.customer_id
    INNER JOIN
        employees AS e
        ON s.sales_person_id = e.employee_id
    INNER JOIN
        products AS p
        ON s.product_id = p.product_id
    WHERE
        p.price = 0
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        e.first_name,
        e.last_name
)

SELECT
    tab.customer,
    tab.sale_date,
    tab.seller
FROM
    tab
WHERE
    tab.sale_date IN (
        SELECT
            MIN(sales.sale_date)
        FROM
            sales
        GROUP BY
            sales.customer_id
    )
ORDER BY
    tab.customer;
