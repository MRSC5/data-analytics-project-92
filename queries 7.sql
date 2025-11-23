-- Получаем информацию о покупателях, совершивших первую покупку во время акции
SELECT 
 -- Формируем полное имя покупателя
 CONCAT(c.first_name, ' ', c.last_name) AS customer,
 
 -- Дата первой покупки
 MIN(s.sale_date) AS sale_date,
 
 -- Формируем полное имя продавца
 CONCAT(e.first_name, ' ', e.last_name) AS seller
 
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id

-- Фильтруем только акционные покупки (цена = 0)
WHERE p.price = 0

-- Группируем по покупателю, чтобы найти первую покупку
GROUP BY 
 c.customer_id,
 c.first_name,
 c.last_name,
 e.first_name,
 e.last_name

-- Сортируем по id покупателя
ORDER BY c.customer_id;
