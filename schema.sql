CREATE TABLE IF NOT EXISTS customers (
    customer_id        INTEGER      PRIMARY KEY,
    customer_name      VARCHAR(100) NOT NULL,
    gender             VARCHAR(10)  CHECK (gender IN ('Male', 'Female')),
    city               VARCHAR(50)  NOT NULL,
    registration_date  DATE         NOT NULL,
    customer_segment   VARCHAR(20)  NOT NULL
                       CHECK (customer_segment IN ('Retail', 'Corporate', 'VIP'))
);
 
CREATE TABLE IF NOT EXISTS orders (
    order_id          INTEGER       PRIMARY KEY,
    customer_id       INTEGER       NOT NULL REFERENCES customers (customer_id),
    order_date        DATE          NOT NULL CHECK (order_date >= DATE '2025-01-01'),
    product_name      VARCHAR(100)  NOT NULL,
    product_category  VARCHAR(50)   NOT NULL,
    quantity          INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price        NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    cost_price        NUMERIC(12,2) NOT NULL CHECK (cost_price >= 0),
    discount          NUMERIC(5,2)  NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    payment_method    VARCHAR(30)   NOT NULL
                      CHECK (payment_method IN ('M-Pesa', 'Cash', 'Card', 'Bank Transfer')),
    order_status      VARCHAR(20)   NOT NULL
                      CHECK (order_status IN ('Completed', 'Pending', 'Cancelled'))
);
 
-- Joins, date filters and the Completed-only filter are used by almost every query.
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date     ON orders (order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status   ON orders (order_status);
