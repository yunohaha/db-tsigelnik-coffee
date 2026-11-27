CREATE TABLE IF NOT EXISTS orders_log (
    id bigserial PRIMARY KEY,
    operation text NOT NULL,
    order_id integer,
    old_data jsonb,
    new_data jsonb,
    changed_by text NOT NULL,
    changed_at timestamptz NOT NULL
);


INSERT INTO orders_log (operation, order_id, new_data, changed_by, changed_at)
SELECT 'INSERT', o.id, to_jsonb(o), session_user, o.created_at
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM orders_log);


CREATE OR REPLACE FUNCTION log_orders() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO orders_log (operation, order_id, new_data, changed_by, changed_at)
        VALUES ('INSERT', NEW.id, to_jsonb(NEW), session_user, clock_timestamp());
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO orders_log (operation, order_id, old_data, new_data, changed_by, changed_at)
        VALUES ('UPDATE', NEW.id, to_jsonb(OLD), to_jsonb(NEW), session_user, clock_timestamp());
    ELSE
        INSERT INTO orders_log (operation, order_id, old_data, changed_by, changed_at)
        VALUES ('DELETE', OLD.id, to_jsonb(OLD), session_user, clock_timestamp());
    END IF;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS trg_orders_log ON orders;
CREATE TRIGGER trg_orders_log AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION log_orders();


CREATE OR REPLACE FUNCTION order_state_at(p_order_id integer, p_at timestamptz)
RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT new_data
    FROM orders_log
    WHERE order_id = p_order_id AND changed_at <= p_at
    ORDER BY changed_at DESC, id DESC
    LIMIT 1;
$$;