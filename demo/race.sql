-- [setup] Молока ровно на один капучино, два заказа без позиций
DELETE FROM order_items WHERE order_id IN
  (SELECT id FROM orders WHERE created_at IN ('2099-01-01 00:00:01+03', '2099-01-01 00:00:02+03'));
DELETE FROM orders WHERE created_at IN ('2099-01-01 00:00:01+03', '2099-01-01 00:00:02+03');
UPDATE inventory SET quantity = 150 WHERE coffee_shop_id = 2 AND product_name = 'Молоко';
INSERT INTO orders (coffee_shop_id, barista_id, status, created_at) VALUES
  (2, 2, 'new', '2099-01-01 00:00:01+03'),
  (2, 2, 'new', '2099-01-01 00:00:02+03');

-- [A] Окно A: добавляет капучино, молока хватает (150 >= 150)
BEGIN;
INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_order)
SELECT id, 3, 1, 250 FROM orders WHERE created_at = '2099-01-01 00:00:01+03';

-- [B] Окно B в тот же момент: триггер не видит позицию окна A, тоже пропускает
BEGIN;
INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_order)
SELECT id, 3, 1, 250 FROM orders WHERE created_at = '2099-01-01 00:00:02+03';

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Молока в оформленных заказах не больше, чем было на складе (150 мл)?
-- expect: false
SELECT COALESCE(SUM(m.milk_required_ml * oi.quantity), 0) <= 150
FROM order_items oi
JOIN menu_items m ON m.id = oi.menu_item_id
JOIN orders o ON o.id = oi.order_id
WHERE o.created_at IN ('2099-01-01 00:00:01+03', '2099-01-01 00:00:02+03');

-- [cleanup]
DELETE FROM order_items WHERE order_id IN
  (SELECT id FROM orders WHERE created_at IN ('2099-01-01 00:00:01+03', '2099-01-01 00:00:02+03'));
DELETE FROM orders WHERE created_at IN ('2099-01-01 00:00:01+03', '2099-01-01 00:00:02+03');
UPDATE inventory SET quantity = 10000 WHERE coffee_shop_id = 2 AND product_name = 'Молоко';