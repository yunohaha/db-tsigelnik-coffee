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
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id

-- 4. Список заказов и их стоимость
SELECT o.id, SUM(oi.quantity * oi.price_at_order) AS total_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id

-- 5. Список заказов, где стоимость больше 300
SELECT o.id, SUM(o.quantity * o.price_at_order) AS total_price300
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP by o.id
HAVING SUM(o.quantity * o.price_at_order) > 300

-- 6. Сколько заказов было сделано в Кофейня Южная? (IN)
SELECT Count(*) AS total_orders
from orders o
