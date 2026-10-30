-- 1. Сколько заказов было сделано в Кофейня Южная?
SELECT Count(*) AS total_orders
FROM orders o
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id
WHERE cs.name = 'Кофейня Южная';

-- 2. Какой бариста не занят заказами в данный момент?
SELECT b.full_name
FROM baristas b
LEFT JOIN orders o ON o.barista_id = b.id AND o.status IN ('new', 'preparing')
WHERE o.id IS NULL;

-- 3. Список заказов с именем бариста и названием кофейни
SELECT o.id, b.full_name, cs.name
FROM orders o
JOIN baristas b ON O.barista_id = b.id
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id;

-- 4. Список заказов и их стоимость
SELECT o.id, SUM(oi.quantity * oi.price_at_order) AS total_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- 5. Список заказов, где стоимость больше 300
SELECT o.id, SUM(oi.quantity * oi.price_at_order) AS total_price300
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id
HAVING SUM(oi.quantity * oi.price_at_order) > 300;

-- 6. Сколько заказов было сделано в Кофейня Южная? (IN)
SELECT Count(*) AS total_orders
from orders o
WHERE o.coffee_shop_id IN (
    SELECT cs.id
    FROM coffee_shops cs
    WHERE cs.name = 'Кофейня Южная'
);

-- 7. Позиции заказов с ценой выше средней (скалярный подзапрос)
SELECT oi.order_id, oi.price_at_order
FROM order_items oi
WHERE oi.price_at_order > (SELECT AVG(price_at_order) FROM order_items);

-- 8. Сколько заказов у каждой кофейни
SELECT cs.name, COUNT(*) AS order_count
FROM orders o
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id
GROUP BY cs.name;

-- 9. Заказ в статусе new до изменения
SELECT id, status
FROM orders
WHERE status = 'new'
LIMIT 1;

-- 10. Меняем статус этого заказа
UPDATE orders
SET status = 'preparing'
WHERE id = 3;

-- 11. Проверяем после изменения
SELECT id, status
FROM orders
WHERE id = 3;

-- 12. Добавляем новый заказ
INSERT INTO orders (coffee_shop_id, barista_id, status, created_at)
VALUES (1, 1, 'new', NOW());

-- 13. Последний заказ до удаления (только что добавленный)
SELECT id, status
FROM orders
ORDER BY id DESC
LIMIT 1;

-- 14. Удаляем этот заказ
DELETE FROM orders
WHERE id = (SELECT MAX(id) FROM orders);


-- 15. Топ-3 самых дорогих заказа в каждой кофейне
WITH order_totals AS (
    SELECT o.id AS order_id, o.coffee_shop_id,
           SUM(oi.quantity * oi.price_at_order) AS total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    GROUP BY o.id, o.coffee_shop_id
),
ranked AS (
    SELECT order_id, coffee_shop_id, total,
           ROW_NUMBER() OVER (PARTITION BY coffee_shop_id ORDER BY total DESC) AS rn
    FROM order_totals
)
SELECT *
FROM ranked
WHERE rn <= 3;


-- 16. Накопительная выручка по заказам
WITH order_totals AS (
    SELECT o.id AS order_id, o.created_at,
           SUM(oi.quantity * oi.price_at_order) AS total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    GROUP BY o.id, o.created_at
)
SELECT order_id, created_at, total,
       SUM(total) OVER (ORDER BY created_at, order_id) AS running_total,
       LAG(total) OVER (ORDER BY created_at, order_id) AS prev_total
FROM order_totals;



