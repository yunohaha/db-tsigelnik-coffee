-- 1. Представление: карточки заказов
SELECT * FROM v_order_card ORDER BY order_id LIMIT 5;

-- 2. Представление: остатки на складе
SELECT * FROM v_shop_stock ORDER BY coffee_shop;

-- 3. Функция: сколько стоит заказ 4
SELECT order_total(4) AS total;

-- 4. Бизнес-операция: два эспрессо в кофейне 1 (кофе хватает)
SELECT place_order(1, 1, 1, 2) AS new_order_id;

-- 5. Проверяем, что заказ появился и сколько он стоит
SELECT order_id, status, coffee_shop FROM v_order_card ORDER BY order_id DESC LIMIT 1;

-- 6. Капучино в кофейне 2: все ингредиенты есть, заказ оформляется
SELECT place_order(2, 2, 3, 1) AS new_order_id;

-- 7. Правило нарушается: капучино в кофейне 1, а молока на складе нет
-- expect: error "Не хватает молока"
SELECT place_order(1, 1, 3, 1);

-- 8. Служебный триггер: при смене статуса обновляется updated_at
UPDATE orders SET status = 'preparing' WHERE id = 3;
SELECT id, status, updated_at FROM orders WHERE id = 3;

-- 9. Отчёт: обновляем и смотрим выручку по кофейням
REFRESH MATERIALIZED VIEW mv_shop_revenue;
SELECT * FROM mv_shop_revenue ORDER BY coffee_shop;

-- 10. Новый заказ в кофейне 2
SELECT place_order(2, 2, 1, 1) AS new_order_id;

-- 11. Отчёт ещё не изменился: он хранит старый результат
SELECT * FROM mv_shop_revenue ORDER BY coffee_shop;

-- 12. Обновляем отчёт: выручка кофейни 2 выросла
REFRESH MATERIALIZED VIEW mv_shop_revenue;
SELECT * FROM mv_shop_revenue ORDER BY coffee_shop;

-- 13. Функция без фильтров: все заказы
SELECT * FROM find_orders();

-- 14. Только кофейня 2
SELECT * FROM find_orders(p_shop => 2);

-- 15. Завершённые заказы от 300
SELECT * FROM find_orders(p_status => 'completed', p_min_total => 300);

-- 16. Журнал по заказу 3: что менялось и кем
SELECT operation, old_data->>'status' AS old_status,
       new_data->>'status' AS new_status, changed_by
FROM orders_log WHERE order_id = 3 ORDER BY id;

-- 17. Состояние заказа 3 сейчас
SELECT order_state_at(3, clock_timestamp()) ->> 'status' AS status_now;

-- 18. Состояние заказа 3 за мгновение до изменения статуса
SELECT order_state_at(3,
    (SELECT changed_at FROM orders_log
     WHERE order_id = 3 AND operation = 'UPDATE'
     ORDER BY id LIMIT 1) - interval '1 millisecond') ->> 'status' AS status_before;