CREATE OR REPLACE FUNCTION check_stock() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_shop integer;
    m menu_items%ROWTYPE;
BEGIN
    SELECT coffee_shop_id INTO v_shop FROM orders WHERE id = NEW.order_id;
    SELECT * INTO m FROM menu_items WHERE id = NEW.menu_item_id;

    IF m.milk_required_ml > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory
        WHERE coffee_shop_id = v_shop AND product_name = 'Молоко'
          AND quantity >= m.milk_required_ml * NEW.quantity) THEN
        RAISE EXCEPTION 'Не хватает молока';
    END IF;

    IF m.coffee_required_g > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory
        WHERE coffee_shop_id = v_shop AND product_name = 'Кофейные зёрна'
          AND quantity >= m.coffee_required_g * NEW.quantity) THEN
        RAISE EXCEPTION 'Не хватает кофе';
    END IF;

    IF m.sugar_required_g > 0 AND NOT EXISTS (
        SELECT 1 FROM inventory
        WHERE coffee_shop_id = v_shop AND product_name = 'Сахар'
          AND quantity >= m.sugar_required_g * NEW.quantity) THEN
        RAISE EXCEPTION 'Не хватает сахара';
    END IF;

    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_check_stock ON order_items;
CREATE TRIGGER trg_check_stock BEFORE INSERT ON order_items
FOR EACH ROW EXECUTE FUNCTION check_stock();

ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();