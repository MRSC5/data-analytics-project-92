-- Получаем данные по продажам с группировкой по месяцам
SELECT 
 -- Форматируем дату в формат ГОД-МЕСЯЦ
 TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
 
 -- Считаем количество уникальных покупателей
 COUNT(DISTINCT s.customer_id) AS total_customers,
 
 -- Суммируем общую выручку
 SUM(s.quantity) AS income
 
FROM sales s

-- Группируем результаты по месяцу
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')

-- Сортируем по дате в хронологическом порядке
ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM');
