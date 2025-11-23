-- Запрос для подсчета уникальных покупателей в базе данных
SELECT 
    -- Подсчитываем уникальные значения ID покупателей
    -- DISTINCT гарантирует, что каждый customer_id будет учтен только один раз
    COUNT(DISTINCT customer_id) AS customers_count  -- результат будет сохранен в колонке customers_count
FROM 
    customers;  -- выбираем данные из таблицы customers


