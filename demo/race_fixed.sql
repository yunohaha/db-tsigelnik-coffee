-- [setup] Молока ровно на один капучино
UPDATE inventory SET quantity = 150 WHERE coffee_shop_id = 2 AND product_name = 'Молоко';

-- [A] Окно A: оформляет капучино целиком
BEGIN;
SELECT place_order(2, 2, 3, 1);

-- [B] Окно B: то же самое, и ждёт, пока A закончит (take_stock заблокировал склад)
-- expect: blocked
BEGIN;
SELECT place_order(2, 2, 3, 1);

-- [A]
COMMIT;

-- [B] B дождался, увидел 0 молока и получил отказ
ROLLBACK;

-- [check] Остаток молока не отрицательный?
-- expect: true
SELECT quantity >= 0 FROM inventory WHERE coffee_shop_id = 2 AND product_name = 'Молоко';

-- [cleanup]
DELETE FROM order_items WHERE order_id IN
  (SELECT id FROM orders WHERE coffee_shop_id = 2 AND barista_id = 2 AND created_at > now() - interval '5 minutes');
DELETE FROM orders WHERE coffee_shop_id = 2 AND barista_id = 2 AND created_at > now() - interval '5 minutes';
UPDATE inventory SET quantity = 10000 WHERE coffee_shop_id = 2 AND product_name = 'Молоко';