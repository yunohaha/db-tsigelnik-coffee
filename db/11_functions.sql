CREATE OR REPLACE FUNCTION order_total(p_order_id integer)
RETURNS numeric LANGUAGE sql AS $$
    SELECT SUM(quantity * price_at_order)
    FROM order_items
    WHERE order_id = p_order_id;
$$;

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

    RETURN v_order;
END $$;