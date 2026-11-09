create database retail_analytics;
create schema duka_smart;
set search_path to duka_smart;

-- Q1: Retrieve all customer records
SELECT *
FROM customers
ORDER BY customer_id;

-- Q2: Display customer names, cities, and segments
SELECT customer_name, city, customer_segment
FROM customers;

-- Q3: Find customers living in Nairobi
SELECT customer_name, city
FROM customers
WHERE city = 'Nairobi'
ORDER BY customer_id;

-- Q4: Find customers registered after January 1, 2025
SELECT customer_name, registration_date
FROM customers
WHERE registration_date > DATE '2025-01-01'
ORDER BY registration_date, customer_id;

-- Q5: Display all unique customer cities
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- Q6: Retrieve the 10 most recent orders
SELECT product_name,order_date
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;

-- Q7: Find orders with unit prices above KSh 10,000
SELECT order_id, product_name, unit_price
FROM orders
WHERE unit_price > 10000
ORDER BY unit_price DESC, order_id;

-- Q8: Find customers whose names start with A
SELECT customer_name
FROM customers
WHERE customer_name LIKE 'A%'
ORDER BY customer_name;

-- Q9: Retrieve orders with quantities between 2 and 5 (BETWEEN includes both ends)
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5
ORDER BY quantity, order_id;

-- Q10: Find orders paid through M-Pesa
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa'
ORDER BY order_id;

-- Q11: Count all customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q12: Count all orders (every status counts)
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q13: Calculate completed-order revenue
SELECT ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_revenue
FROM orders
WHERE order_status = 'Completed';

-- Q14: Calculate the average completed-order value
SELECT ROUND(AVG(quantity * unit_price * (1 - discount / 100)), 2) AS avg_completed_order_value
FROM orders
WHERE order_status = 'Completed';

-- Q15: Find the highest and lowest product prices
(SELECT 'Highest' AS which, product_name, unit_price
FROM (SELECT DISTINCT product_name, unit_price FROM orders) AS p
ORDER BY unit_price DESC
LIMIT 1)
UNION all
(SELECT 'Lowest', product_name, unit_price
FROM (SELECT DISTINCT product_name, unit_price FROM orders) AS p
ORDER BY unit_price ASC
LIMIT 1);

-- Q16: Calculate revenue by product category (Completed orders only)
SELECT product_category,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

-- Q17: Count customers by city
SELECT city, COUNT(*) AS customers
FROM customers
GROUP BY city
ORDER BY customers DESC, city;

-- Q18: Calculate quantity sold by product

SELECT product_name, COALESCE(SUM(quantity) FILTER (WHERE order_status = 'Completed'), 0) AS units_sold,
SUM(quantity) AS units_ordered_all_statuses
FROM orders
GROUP BY product_name
ORDER BY units_sold DESC, product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue (Completed only)
SELECT product_category,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100)) > 100000
ORDER BY revenue DESC;

-- Q20: Calculate the percentage of cancelled orders
SELECT COUNT(*) FILTER (WHERE order_status = 'Cancelled') AS cancelled_orders,
COUNT(*) AS total_orders,
ROUND(COUNT(*) FILTER (WHERE order_status = 'Cancelled') * 100.0/ COUNT(*), 2) AS percentage_cancelled
FROM orders;

-- Q21: Display orders with customer names and cities. --
select o.order_id, c.customer_name, c.city
from orders o inner join customers c 
on o.customer_id = c.customer_id;

--Q22: Calculate total spending by customer.
select c.customer_name,
round(sum(quantity * unit_price * (1-discount/100)),2) as customer_spend
from orders o
right join customers c on o.customer_id = c.customer_id
where order_status in ('Completed')
group by c.customer_name;

--Q23: Identify customers who have never ordered.
select customer_name, c.customer_id
from customers c
left join orders o on c.customer_id = o.customer_id
where o.customer_id is null;

--Q24:Find the 10 highest-spending customers.
select c.customer_name,
round(sum(o.quantity * o.unit_price * (1 - o.discount/100)),2) as customer_spend
from customers c
join orders o on o.customer_id = c.customer_id
where order_status = 'Completed'
group by c.customer_name
order by customer_spend desc
limit 10;

--Q25: Calculate revenue by customer city.
select c.city,
round(sum(o.quantity * o.unit_price * (1 - o.discount/100)),2) as city_revenue
from customers c
left join orders o on o.customer_id = c.customer_id
where order_status = 'Completed'
group by c.city;

--Q26: Identify customers with more than five orders.
select c.customer_name, count(o.order_id) as total_orders 
from customers c 
join orders o on o.customer_id = c.customer_id
group by c.customer_name  
having count(o.order_id) > 5;

-- Q27: Average customer spending by segment.
WITH customer_spend AS (
SELECT c.customer_id, c.customer_segment,
SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_segment
)
SELECT customer_segment, ROUND(AVG(total_spend), 2) AS avg_customer_spend
FROM customer_spend
GROUP BY customer_segment
ORDER BY avg_customer_spend DESC;

--Q28: Identify the most popular category among VIP customers.
select o.product_category,
sum(quantity) as total_quantity
from orders o  
join customers c on c.customer_id = o.customer_id
where customer_segment = 'VIP'
group by product_category
order by total_quantity desc
limit 1;

-- Q29: Find customers spending above the average total spending per purchasing customer
WITH customer_spend AS (
SELECT customer_id,
SUM(quantity * unit_price * (1 - discount / 100)) AS total_spend
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
ROUND(s.total_spend, 2) AS total_spending,
(SELECT ROUND(AVG(total_spend), 2) FROM customer_spend) AS average_per_purchasing_customer
FROM customer_spend s
JOIN customers c ON c.customer_id = s.customer_id
WHERE s.total_spend > (SELECT AVG(total_spend) FROM customer_spend)
ORDER BY s.total_spend DESC, c.customer_id;

-- Q30: Find products priced above the overall average unit price
WITH product_prices AS (
SELECT DISTINCT product_name, product_category, unit_price
FROM orders
)
SELECT product_name, product_category, unit_price,
(SELECT ROUND(AVG(unit_price), 2) FROM product_prices) AS average_unit_price
FROM product_prices
WHERE unit_price > (SELECT AVG(unit_price) FROM product_prices)
ORDER BY unit_price DESC;

-- Q31: Use a CTE to identify the three highest-revenue months (Completed only)
WITH monthly AS (
SELECT DATE_TRUNC('month', order_date)::date AS month,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 3;
 
-- Q32: Find customers purchasing from at least three categories
SELECT c.customer_id, c.customer_name,
COUNT(DISTINCT o.product_category) AS categories_bought
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY categories_bought DESC, c.customer_id;
 
-- Q32 (alternative reading): count ANY order, whatever its status
SELECT c.customer_id, c.customer_name,
COUNT(DISTINCT o.product_category) AS categories_ordered
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY categories_ordered DESC, c.customer_id;
 
-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin
WITH category_totals AS (
SELECT product_category,
SUM(quantity * unit_price * (1 - discount / 100)) AS revenue,
SUM(quantity * cost_price) AS cost
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
)
SELECT product_category,
ROUND(revenue, 2) AS revenue,
ROUND(cost, 2)  AS cost,
ROUND(revenue - cost, 2) AS profit,
ROUND((revenue - cost) / NULLIF(revenue, 0) * 100, 2)  AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;
 
-- Q34: Find customers whose latest completed order is more than 90 days before the latest
WITH last_completed AS (
SELECT customer_id, MAX(order_date) AS last_order
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
),
today AS (
SELECT MAX(order_date) AS today FROM orders
)
SELECT c.customer_id, c.customer_name, c.customer_segment,
       l.last_order,
       t.today - l.last_order AS days_since_last_completed_order
FROM last_completed l
JOIN customers c ON c.customer_id = l.customer_id
CROSS JOIN today t
WHERE t.today - l.last_order > 90
ORDER BY days_since_last_completed_order DESC, c.customer_id;
 
-- Q35: Rank customers by spending using RANK()
WITH customer_spend AS (
SELECT c.customer_id, c.customer_name,
ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS total_spending
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
)
SELECT RANK() OVER (ORDER BY total_spending DESC) AS spending_rank,customer_id, customer_name, total_spending
FROM customer_spend
ORDER BY spending_rank, customer_id;
 
-- Q36: Number each customer's orders by recency using ROW_NUMBER()
SELECT customer_id, order_id, order_date, order_status,
ROW_NUMBER() OVER (PARTITION BY customer_id
ORDER BY order_date DESC, order_id DESC) AS order_recency
FROM orders
ORDER BY customer_id, order_recency;
 
-- Q37: Rank products within categories using DENSE_RANK()
WITH product_revenue AS (
SELECT product_category, product_name,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category, product_name
)
SELECT product_category, product_name, revenue,
DENSE_RANK() OVER (PARTITION BY product_category ORDER BY revenue DESC) AS rank_in_category
FROM product_revenue
ORDER BY product_category, rank_in_category, product_name;
 
-- Q38: Calculate cumulative monthly revenue (running total, Completed only)
WITH monthly AS (
SELECT DATE_TRUNC('month', order_date)::date AS month,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM monthly
ORDER BY month;
 
-- Q39: Compare monthly revenue using LAG()
WITH monthly AS (
SELECT DATE_TRUNC('month', order_date)::date AS month,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
revenue - LAG(revenue) OVER (ORDER BY month)  AS change_in_revenue
FROM monthly
ORDER BY month;
 
-- Q40: Calculate month-over-month revenue growth (%)
WITH monthly AS (
SELECT DATE_TRUNC('month', order_date)::date AS month,
SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month,
ROUND(revenue, 2) AS revenue,
ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_month_revenue,
ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;
 
-- Q41: Divide customers into four spending groups using NTILE(4)
WITH customer_spend AS (
SELECT c.customer_id, c.customer_name,
ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS total_spending
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
)
SELECT NTILE(4) OVER (ORDER BY total_spending DESC, customer_id) AS spending_group,
       customer_id, customer_name, total_spending
FROM customer_spend
ORDER BY spending_group, total_spending DESC, customer_id;
 
-- Q41 (summary): what each spending group looks like
WITH customer_spend AS (
SELECT customer_id,
SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
),
grouped AS (
SELECT NTILE(4) OVER (ORDER BY total_spending DESC, customer_id) AS spending_group,total_spending
FROM customer_spend
)
SELECT spending_group,
COUNT(*)  AS customers,
ROUND(MIN(total_spending), 2)    AS min_spend,
ROUND(MAX(total_spending), 2)    AS max_spend,
ROUND(SUM(total_spending), 2)    AS group_revenue,
ROUND(SUM(total_spending) * 100.0 / SUM(SUM(total_spending)) OVER (), 1) AS pct_of_revenue
FROM grouped
GROUP BY spending_group
ORDER BY spending_group;
 
-- Q42: Calculate each category's share of total revenue using window functions
SELECT product_category,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue,
ROUND(SUM(quantity * unit_price * (1 - discount / 100)) * 100.0
             / SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER (), 2) AS pct_of_total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;
 
-- Q43: Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then SELECT
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_TRUNC('month', order_date)::date AS month,
COUNT(*) AS orders,
ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
FILTER (WHERE order_status = 'Completed'), 0), 2) AS revenue,
ROUND(COALESCE(SUM(quantity * cost_price)
FILTER (WHERE order_status = 'Completed'), 0), 2) AS cost,
ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price)
FILTER (WHERE order_status = 'Completed'), 0), 2)   AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);
 
SELECT *
FROM monthly_sales_summary
ORDER BY month;
 
-- Q44: Create a PL/pgSQL function returning completed-order revenue for a customer ID
CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_result NUMERIC;
BEGIN
    SELECT COALESCE(ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2), 0)
    INTO v_result
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';
 
    RETURN v_result;
END;
$$;
 
-- A customer who exists and buys a lot (customer 33 - should equal their total in Q24):
SELECT 33 AS customer_id, customer_completed_revenue(33) AS completed_revenue;
 
-- An ID that does not exist (must return 0, not NULL):
SELECT 9999 AS customer_id, customer_completed_revenue(9999) AS completed_revenue;
 
-- A real customer who has never ordered (also 0):
SELECT c.customer_id, customer_completed_revenue(c.customer_id) AS completed_revenue
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
ORDER BY c.customer_id
LIMIT 1;
 
-- Q45: Segment customers into High, Medium and Low Value
SELECT ROUND(percentile_cont(0.33) WITHIN GROUP (ORDER BY spend)::numeric, 0) AS p33,
ROUND(percentile_cont(0.50) WITHIN GROUP (ORDER BY spend)::numeric, 0) AS median,
ROUND(percentile_cont(0.75) WITHIN GROUP (ORDER BY spend)::numeric, 0) AS p75,
ROUND(MAX(spend)::numeric, 0)                                          AS max_spend
FROM (SELECT SUM(quantity * unit_price * (1 - discount / 100)) AS spend
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id) AS buyers;
 
-- Each customer with their value tier (all 150 customers; no spend = 0 = Low)
WITH customer_spend AS (
SELECT c.customer_id, c.customer_name, c.customer_segment,
COALESCE(ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
ON o.customer_id = c.customer_id
AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
)
SELECT customer_id, customer_name, customer_segment, total_spending,
CASE WHEN total_spending >= 250000 THEN 'High Value'
WHEN total_spending >= 60000  THEN 'Medium Value'
ELSE 'Low Value'
END AS value_tier
FROM customer_spend
ORDER BY total_spending DESC, customer_id;
 
-- Q45 (summary): how many customers and how much revenue sit in each tier
WITH customer_spend AS (
SELECT c.customer_id,
COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
ON o.customer_id = c.customer_id
AND o.order_status = 'Completed'
GROUP BY c.customer_id
),
tiered AS (
SELECT total_spending,
CASE WHEN total_spending >= 250000 THEN 'High Value'
WHEN total_spending >= 60000  THEN 'Medium Value'
ELSE 'Low Value'
END AS value_tier
FROM customer_spend
)
SELECT value_tier,
COUNT(*) AS customers,
ROUND(SUM(total_spending), 2) AS revenue,
ROUND(SUM(total_spending) * 100.0 / SUM(SUM(total_spending)) OVER (), 1) AS pct_of_revenue,
ROUND(AVG(total_spending), 2) AS avg_spend
FROM tiered
GROUP BY value_tier
ORDER BY MIN(total_spending) DESC;
 
-- Q46: Management report - top five customers, top five products, most profitable category,
WITH completed AS (
SELECT *,
           quantity * unit_price * (1 - discount / 100) AS revenue,
           quantity * unit_price * (1 - discount / 100) - quantity * cost_price AS profit
FROM orders
WHERE order_status = 'Completed'
),
top_customers AS (
SELECT c.customer_name AS name, SUM(o.revenue) AS revenue, SUM(o.profit) AS profit
FROM completed o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC, c.customer_id
LIMIT 5
),
top_products AS (
SELECT product_name AS name, SUM(revenue) AS revenue, SUM(profit) AS profit
FROM completed
GROUP BY product_name
ORDER BY revenue DESC, product_name
LIMIT 5
),
best_category AS (
SELECT product_category AS name, SUM(revenue) AS revenue, SUM(profit) AS profit
FROM completed
GROUP BY product_category
ORDER BY profit DESC
LIMIT 1
),
worst_month AS (
SELECT TO_CHAR(DATE_TRUNC('month', order_date), 'YYYY-MM') AS name,
SUM(revenue) AS revenue, SUM(profit) AS profit
FROM completed
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY revenue ASC
LIMIT 1
)
SELECT '1. Top 5 customers' AS section, ROW_NUMBER() OVER (ORDER BY revenue DESC) AS position,
       name, ROUND(revenue, 2) AS revenue, ROUND(profit, 2) AS profit
FROM top_customers
UNION ALL
SELECT '2. Top 5 products', ROW_NUMBER() OVER (ORDER BY revenue DESC),
       name, ROUND(revenue, 2), ROUND(profit, 2)
FROM top_products
UNION ALL
SELECT '3. Most profitable category', 1, name, ROUND(revenue, 2), ROUND(profit, 2)
FROM best_category
UNION ALL
SELECT '4. Lowest-revenue month', 1, name, ROUND(revenue, 2), ROUND(profit, 2)
FROM worst_month
ORDER BY section, position;
 
