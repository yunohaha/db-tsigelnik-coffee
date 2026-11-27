DROP MATERIALIZED VIEW IF EXISTS mv_shop_revenue;

CREATE MATERIALIZED VIEW mv_shop_revenue AS
SELECT cs.name AS coffee_shop,
       COUNT(DISTINCT o.id) AS orders_count,
       SUM(oi.quantity * oi.price_at_order) AS revenue
FROM orders o
JOIN coffee_shops cs ON cs.id = o.coffee_shop_id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY cs.name;


CREATE OR REPLACE FUNCTION find_orders(
    p_shop integer DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_min_total numeric DEFAULT NULL)
RETURNS TABLE (order_id integer, coffee_shop text, status text, total numeric)
LANGUAGE sql AS $$
    SELECT t.order_id, t.coffee_shop, t.status, t.total
    FROM (
        SELECT o.id::integer AS order_id,
               cs.name::text AS coffee_shop,
               o.status::text AS status,
               COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total
        FROM orders o
        JOIN coffee_shops cs ON cs.id = o.coffee_shop_id
        LEFT JOIN order_items oi ON oi.order_id = o.id
        WHERE (p_shop IS NULL OR o.coffee_shop_id = p_shop)
          AND (p_status IS NULL OR o.status::text = p_status)
        GROUP BY o.id, cs.name, o.status
    ) t
    WHERE p_min_total IS NULL OR t.total >= p_min_total;
$$;