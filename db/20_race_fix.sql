-- Защищённое списание: блокируем склад кофейни, потом проверяем и списываем
CREATE OR REPLACE FUNCTION take_stock(p_shop integer, p_menu_item integer, p_qty integer)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    m menu_items%ROWTYPE;
BEGIN
    SELECT * INTO m FROM menu_items WHERE id = p_menu_item;

    -- Блокируем строки склада кофейни в одном порядке (по id).
    -- Вторая сессия ждёт здесь, пока первая не сделает COMMIT.
    PERFORM 1 FROM inventory WHERE coffee_shop_id = p_shop ORDER BY id FOR UPDATE;

    IF m.milk_required_ml > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory WHERE coffee_shop_id = p_shop AND product_name = 'Молоко'
          AND quantity >= m.milk_required_ml * p_qty) THEN
        RAISE EXCEPTION 'Не хватает молока';
    END IF;
    IF m.coffee_required_g > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory WHERE coffee_shop_id = p_shop AND product_name = 'Кофейные зёрна'
          AND quantity >= m.coffee_required_g * p_qty) THEN
        RAISE EXCEPTION 'Не хватает кофе';
    END IF;
    IF m.sugar_required_g > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory WHERE coffee_shop_id = p_shop AND product_name = 'Сахар'
          AND quantity >= m.sugar_required_g * p_qty) THEN
        RAISE EXCEPTION 'Не хватает сахара';
    END IF;

    UPDATE inventory SET quantity = quantity - m.milk_required_ml * p_qty
     WHERE coffee_shop_id = p_shop AND product_name = 'Молоко' AND m.milk_required_ml > 0;
    UPDATE inventory SET quantity = quantity - m.coffee_required_g * p_qty
     WHERE coffee_shop_id = p_shop AND product_name = 'Кофейные зёрна' AND m.coffee_required_g > 0;
    UPDATE inventory SET quantity = quantity - m.sugar_required_g * p_qty
     WHERE coffee_shop_id = p_shop AND product_name = 'Сахар' AND m.sugar_required_g > 0;
END $$;

-- place_order после добавления позиции вызывает take_stock
CREATE OR REPLACE FUNCTION place_order(
    p_shop integer, p_barista integer, p_menu_item integer, p_qty integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_order integer;
BEGIN
    INSERT INTO orders (coffee_shop_id, barista_id, status, created_at)
    VALUES (p_shop, p_barista, 'new', now())
    RETURNING id INTO v_order;

    INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_order)
    SELECT v_order, id, p_qty, price FROM menu_items WHERE id = p_menu_item;

    PERFORM take_stock(p_shop, p_menu_item, p_qty);
    RETURN v_order;
END $$;