\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

-- По умолчанию функции доступны всем (PUBLIC): забираем это право
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

-- Читатель видит только два представления
GRANT SELECT ON v_order_card, v_shop_stock TO app_reader;

-- Писатель может вызвать только бизнес-операцию
GRANT EXECUTE ON FUNCTION place_order(integer, integer, integer, integer) TO app_writer;

-- Функция работает с правами владельца, поэтому писателю не нужны права на таблицы
ALTER FUNCTION place_order(integer, integer, integer, integer)
    SECURITY DEFINER SET search_path = public, pg_temp;