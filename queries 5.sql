-- Создаём CTE для группировки по возрастным категориям
WITH age_groups AS (
    SELECT 
        -- Определяем возрастную категорию
        CASE 
            WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
            WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
            WHEN c.age > 40 THEN '40+'
        END AS age_category,
        
        -- Считаем количество уникальных покупателей в каждой группе
        COUNT(DISTINCT c.customer_id) AS age_count
        
    FROM customers c
    JOIN sales s ON c.customer_id = s.customer_id
    
    -- Группируем по возрастным категориям
    GROUP BY 
        CASE 
            WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
            WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
            WHEN c.age > 40 THEN '40+'
        END
)

-- Выбираем данные из CTE и сортируем их
SELECT 
    age_category,
    age_count
FROM age_groups

-- Сортируем по возрастным группам
ORDER BY 
    CASE 
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        WHEN age_category = '40+' THEN 3
    END;
