-- Выбираем данные о топ-10 продавцах с наибольшей выручкой
SELECT 
    -- Объединяем имя и фамилию продавца в один столбец
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    -- Считаем количество проведенных сделок
    COUNT(s.sales_id) AS operations,
    -- Суммируем общую выручку
    SUM(s.quantity) AS income
FROM sales s  -- Основная таблица с данными о продажах
-- Соединяем с таблицей сотрудников по идентификатору
JOIN employees e ON s.sales_person_id = e.employee_id
-- Группируем результаты по каждому продавцу
GROUP BY 
    e.first_name,
    e.last_name
-- Сортируем результат по убыванию выручки
ORDER BY income desc
-- Ограничиваем вывод первыми 10 записями
LIMIT 10;