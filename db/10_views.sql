CREATE OR REPLACE VIEW v_order_card AS
SELECT o.id AS order_id, o.status, cs.name AS coffee_shop, b.full_name AS barista
FROM orders o
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id
JOIN baristas b ON b.id = o.barista_id;

CREATE OR REPLACE VIEW v_shop_stock AS
SELECT cs.name AS coffee_shop, i.product_name, i.quantity
FROM inventory i
JOIN coffee_shops cs ON cs.id = i.coffee_shop_id;