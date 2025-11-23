-- Получаем отчет о суммарной выручке продавцов по дням недели
SELECT 
 -- Формируем полное имя продавца
 CONCAT(e.first_name, ' ', e.last_name) AS seller,
 -- Получаем название дня недели из даты продажи
 TO_CHAR(s.sale_date, 'Day') AS day_of_week,
 -- Вычисляем суммарную выручку за день и округляем до целого
 ROUND(SUM(s.quantity)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
-- Группируем по продавцу и дню недели
GROUP BY 
 e.first_name,
 e.last_name,
 TO_CHAR(s.sale_date, 'Day'), -- группируем по названию дня
 EXTRACT(DOW FROM s.sale_date) -- группируем по номеру дня
-- Сортируем сначала по номеру дня недели, затем по имени продавца
ORDER BY 
 EXTRACT(DOW FROM s.sale_date),
 seller;
