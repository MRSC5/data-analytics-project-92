-- Получаем список продавцов с средней выручкой ниже средней по компании
SELECT 
    -- Формируем полное имя продавца
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    -- Вычисляем среднюю выручку за сделку и округляем до целого
    ROUND(AVG(s.quantity)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
-- Группируем по продавцу
GROUP BY 
    e.first_name,
    e.last_name
-- Фильтруем только тех продавцов, чья средняя выручка ниже общей средней
HAVING AVG(s.quantity) < (
    SELECT AVG(quantity) 
    FROM sales
)
-- Сортируем по возрастанию средней выручки
ORDER BY average_income ASC;
