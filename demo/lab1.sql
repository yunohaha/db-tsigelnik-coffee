-- 1. название кофейни уже существует
-- expect: error unique
INSERT INTO coffee_shops (name, address)
VALUES ('Кофейня Центральная', 'ул. Новая, 15');


-- 2. цена напитка должна быть больше нуля
-- expect: error check 
INSERT INTO menu_items (name, price)
VALUES ('Тестовый напиток', -100);


-- 3. кофейни с таким id не существует
-- expect: error fk
INSERT INTO baristas (coffee_shop_id, full_name)
VALUES (999999, 'Тестовый бариста');