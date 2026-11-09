# Retail Sales & Customer Intelligence Using PostgreSQL

**Duka Smart Electronics** is a fictional Kenyan retailer selling phones, laptops, accessories, TVs and home appliances in ten towns. This project sets up its sales database in PostgreSQL, answers **46 business questions in SQL**, and turns the results into **recommendations for management**.

- **Data:** 150 customers and 800 orders, January 2025 – September 2026 (all people and companies are fictional)
- **Tools:** PostgreSQL 14+ (tested on 16), DBeaver / pgAdmin / psql, Power BI
- **Author:** Gabriel Nduati Wainaina · Cohort 9, Data Science · Week 10 project

---

## Headline results

All money figures use **Completed orders only**.

| Measure | Value |
|---|---|
| Revenue | **KSh 24,155,371.70** |
| Cost | KSh 21,264,450.00 |
| Profit | **KSh 2,890,921.70** (11.97% margin) |
| Orders (all statuses) | 800 |
| Cancelled orders | 90 (11.25%) |
| Customers who have never ordered | 12 |

## Key findings

The full write-up, with the number, why it matters and a recommendation for each, is in [`insights.md`](insights.md).

1. **Accessories** are only 4.5% of revenue but 15.8% of profit, with a 42% margin. Bundle them with every big sale.
2. **Discounts** gave away KSh 1.52M, about 53% of all profit, and orders at 20–25% off lose money. Cap discounts at 10%.
3. **34 customers produce 70% of revenue**, and 9 of the top 10 spenders are labelled "Retail", not VIP. Segment by spend instead.
4. **47 of 132 buyers** have not ordered in 90+ days, worth KSh 4.6M of past revenue. Start a win-back list.
5. **Revenue is up 86%** on the same months last year, but December spikes and January 2026 drops 84%. Plan stock and a January campaign.
6. **Nairobi** brings in 40% of revenue, and Machakos and Mombasa buyers spend the most per head outside it.
7. **KSh 3.2M** is stuck in Pending orders, and M-Pesa orders cancel more often (12.5%) than bank transfers (4.8%).

---

## Repository contents

```
retail-sales-sql/
├── README.md        this file
├── schema.sql       CREATE TABLE statements (primary/foreign keys, CHECK constraints, indexes)
├── queries.sql      all 46 answers, numbered -- Q1 ... -- Q46 (plus a few extra summary queries)
├── insights.md      7 business insights with evidence and recommendations
└── screenshots/     verification output, query results and the dashboard
```

## The database

Two tables, connected by `customer_id`:

```
customers (1) ──────────< orders (many)
```

| Table | Rows | Main columns |
|---|---|---|
| `customers` | 150 | `customer_id` (PK), `customer_name`, `gender`, `city`, `registration_date`, `customer_segment` |
| `orders` | 800 | `order_id` (PK), `customer_id` (FK), `order_date`, `product_name`, `product_category`, `quantity`, `unit_price`, `cost_price`, `discount`, `payment_method`, `order_status` |

`schema.sql` includes a primary key on each table, a foreign key from `orders` to `customers`, and `CHECK` constraints that only allow valid values (for example `quantity > 0`, `discount` between 0 and 100, and status limited to Completed / Pending / Cancelled).

---

## How to set it up

You need PostgreSQL 14 or newer and a SQL tool (psql, pgAdmin or DBeaver). The data scripts come from the course project page and are not stored in this repo.

### Option A: psql

```bash
psql -U postgres -d postgres         -f 01_create_database.sql
psql -U postgres -d retail_analytics -f schema.sql
psql -U postgres -d retail_analytics -f 03_insert_customers.sql
psql -U postgres -d retail_analytics -f 04_insert_orders.sql
psql -U postgres -d retail_analytics -f 05_verify_data.sql
```

### Option B: DBeaver or pgAdmin

1. Create a database called `retail_analytics` from the menu (the `\gexec` line in `01_create_database.sql` only works in psql).
2. Open each `.sql` file **as a SQL script** (File → Open File), not through the import wizard, and run it with **Execute Script (Alt+X in DBeaver)**, in this order: `schema.sql`, `03_insert_customers.sql`, `04_insert_orders.sql`, `05_verify_data.sql`.
3. If you use a custom schema, set it for every session so plain table names resolve:
   ```sql
   ALTER DATABASE retail_analytics SET search_path TO duka_smart, public;
   ```
   then reconnect. If you use the default `public` schema, no change is needed.

### Check it worked

`05_verify_data.sql` should show **150 customers**, **800 orders**, **0 orders with no customer**, and orders from **2025-01-01 to 2026-09-30**. See `screenshots/05_verify_data.png`.

## How to run the queries

```bash
psql -U postgres -d retail_analytics -f queries.sql
```

In DBeaver, open `queries.sql` and press **Alt+X**. Each query starts with a `-- Qn:` comment, so you can also run one at a time. The file creates the view `monthly_sales_summary` (Q43) and the function `customer_completed_revenue()` (Q44) with `CREATE OR REPLACE`, so it is safe to run more than once.

---

## Business rules used in every answer

| Measure | Formula |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)`, where discount is a percentage |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / NULLIF(revenue, 0) * 100` |

- Money questions (revenue, cost, profit, spending, averages) count **Completed** orders only.
- Order counts include **every** order, whatever its status. Customer counts use distinct customers.
- "Today" is the latest `order_date` in the data (**2026-09-30**), not the computer's date.
- Months mean year **and** month (`DATE_TRUNC('month', order_date)`). Money is rounded to 2 decimals.

## What the 46 queries cover

| Section | Questions | Topics |
|---|---|---|
| A. SQL fundamentals | Q1–Q10 | `SELECT`, `WHERE`, `DISTINCT`, `ORDER BY`, `LIMIT`, `LIKE`, `BETWEEN` |
| B. Aggregation | Q11–Q20 | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`, `FILTER` |
| C. Joins and customer analytics | Q21–Q28 | `INNER JOIN`, `LEFT JOIN` (customers who never ordered) |
| D. Subqueries and CTEs | Q29–Q34 | `WITH`, nested aggregation, 90-day lapsed customers |
| E. Window functions | Q35–Q42 | `RANK`, `ROW_NUMBER`, `DENSE_RANK`, `LAG`, `NTILE`, running totals |
| F. Business intelligence | Q43–Q46 | a view, a PL/pgSQL function, value tiers, management report |

## Where a question could be read two ways

A few questions are open to interpretation. I chose one reading and wrote it in a comment above the query.

| Question | What I chose | Why |
|---|---|---|
| Q18 quantity sold | Completed units, with all-status units shown beside it | "Sold" means paid |
| Q27 average spending by segment | Average of each buying customer's total (at least one completed order) | Follows the brief's tip: total per customer first, then average |
| Q28 most popular VIP category | Number of orders placed, with units and revenue shown too | Home Appliances wins on orders and units; Mobile Phones wins on revenue |
| Q30 average unit price | Each product counted once | Averaging over order rows gives the same 8 products |
| Q32 three or more categories | Completed orders (55 customers); an all-orders version (66) is included | A cancelled order is not a purchase |
| Q43 view | `orders` counts all statuses; revenue, cost and profit are Completed only | Applies both business rules together |
| Q45 value tiers | High ≥ KSh 250,000, Medium KSh 60,000–249,999, Low below | Round numbers close to the 75th and 33rd percentiles of buyers |

---

## Dashboard

A one-page Power BI dashboard built on this database, showing revenue, profit, margin, orders, cancellation rate, monthly revenue, profit by category and revenue by city.

![Dashboard](screenshots/dashboard.png)

## Checks I ran

- Every query was run on PostgreSQL 16 against the loaded data, and `queries.sql` runs end to end with no errors.
- Revenue ties out three ways: Q13, the sum of the five categories in Q16, and the final cumulative total in Q38 are all **KSh 24,155,371.70**, matching `05_verify_data.sql`.
- Key results (totals, top customers, category margins, lapsed customers, value tiers) were recalculated independently in Python from the raw insert scripts and matched.
- The function in Q44 returns `0`, not `NULL`, for a customer ID that does not exist.
