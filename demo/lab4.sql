-- 1. Сколько заказов сейчас
SELECT count(*) FROM orders;

-- 2. Транзакция падает на середине: заказ создался, а позиция отклонена триггером
-- expect: error "Не хватает молока"
BEGIN;
INSERT INTO orders (coffee_shop_id, barista_id, status, created_at) VALUES (1, 1, 'new', now());
INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_order)
SELECT max(id), 3, 1, 250 FROM orders;
COMMIT;

-- 3. Заказов столько же: заказ из шага 2 откатился вместе с ошибкой
-- expect: same 1
SELECT count(*) FROM orders;

-- 4. Читатель читает представление
SET ROLE app_reader;
SELECT * FROM v_order_card LIMIT 1;
RESET ROLE;

-- 5. Читатель пытается менять данные: отказ
-- expect: error "permission denied"
SET ROLE app_reader;
DELETE FROM orders WHERE id = 1;
RESET ROLE;

-- 6. Писатель пытается менять таблицу напрямую: отказ
-- expect: error "permission denied"
SET ROLE app_writer;
UPDATE inventory SET quantity = 0;
RESET ROLE;