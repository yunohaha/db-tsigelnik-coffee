-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.
--
-- Пример, замените своими таблицами:
--
-- CREATE TABLE halls (
--     id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--     name  text NOT NULL UNIQUE,
--     seats integer NOT NULL CHECK (seats > 0)
-- );

CREATE TABLE coffee_shops (
    id       INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     TEXT        NOT NULL UNIQUE,
    address  TEXT        NOT NULL
);

CREATE TABLE baristas (
    id         INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    coffee_shop_id     INTEGER     NOT NULL REFERENCES coffee_shops(id),
    full_name          TEXT        NOT NULL
);

CREATE TABLE menu_items ( 
    id                 INTEGER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name               TEXT             NOT NULL,
    price              NUMERIC(10, 2)   NOT NULL CHECK (price > 0),
    milk_required_ml   NUMERIC(10, 2)   NOT NULL DEFAULT 0
                                        CHECK (milk_required_ml >= 0),
    coffee_required_g  NUMERIC(10, 2)   NOT NULL DEFAULT 0
                                        CHECK (coffee_required_g >= 0),
    sugar_required_g   NUMERIC(10, 2)   NOT NULL DEFAULT 0
                                        CHECK (sugar_required_g >= 0)
);

CREATE TABLE orders (
    id                INTEGER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    coffee_shop_id    INTEGER          NOT NULL REFERENCES coffee_shops(id),
    barista_id        INTEGER          NOT NULL REFERENCES baristas(id),
    created_at        TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            TEXT             NOT NULL
                                       CHECK (status IN ('new', 'preparing', 'completed', 'cancelled'))
);

CREATE TABLE order_items (
    id               INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id         INTEGER         NOT NULL REFERENCES orders(id),
    menu_item_id     INTEGER         NOT NULL REFERENCES menu_items(id),
    quantity         INTEGER         NOT NULL CHECK (quantity > 0),
    price_at_order   NUMERIC(10, 2)  NOT NULL
                                     CHECK (price_at_order >= 0),
                                     UNIQUE (order_id, menu_item_id)
);

CREATE TABLE inventory (
    id                 INTEGER           GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    coffee_shop_id     INTEGER NOT NULL  REFERENCES coffee_shops(id),
    product_name       TEXT              NOT NULL,
    quantity           NUMERIC(10, 2)    NOT NULL DEFAULT 0
                                         CHECK (quantity >= 0),
    unit               TEXT              NOT NULL,
                                         UNIQUE (coffee_shop_id, product_name)
);
