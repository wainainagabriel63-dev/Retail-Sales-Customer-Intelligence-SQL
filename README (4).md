# Retail Sales & Customer Intelligence Using PostgreSQL

A SQL analysis of **Duka Smart Electronics**, a fictional Kenyan retailer selling phones, laptops, accessories, TVs and home appliances in ten towns. The database holds 150 customers and 800 orders from January 2025 to September 2026.

This repository contains my database schema, my answers to 46 business questions, and a written summary of what the data tells management.


---

## What the project covers

- Creating a database and tables with primary keys, foreign keys and constraints
- Filtering, sorting and summarising data (`SELECT`, `WHERE`, `GROUP BY`, `HAVING`)
- Combining tables with `JOIN`s, including finding missing records with `LEFT JOIN`
- Breaking problems into steps with subqueries and CTEs
- Ranking, running totals and month-on-month growth with window functions
- Saving logic as a view and a function
- Turning query results into business recommendations

The questions the analysis answers include: who are the best customers, which products and categories make money, are sales growing, and which customers have stopped buying.

---

## Repository contents

```
retail-sales-sql/
├── README.md        # this file
├── schema.sql       # CREATE TABLE statements for customers and orders
├── queries.sql      # answers to all 46 questions (-- Q1 ... -- Q46)
├── insights.md      # business insights with numbers and recommendations
└── screenshots/     # data verification output and selected query results
```

| File | Description |
|---|---|
| `schema.sql` | Creates the `customers` and `orders` tables |
| `queries.sql` | All 46 queries, each labelled with its question number |
| `insights.md` | Findings, why they matter, and what I recommend |
| `screenshots/` | Output of the data check plus a few interesting results |

---

## Data model

```
customers (1) ──────────< orders (many)
customer_id               customer_id
```

**`customers`** (150 rows): `customer_id` (PK), `customer_name`, `gender`, `city`, `registration_date`, `customer_segment` (Retail / Corporate / VIP)

**`orders`** (800 rows): `order_id` (PK), `customer_id` (FK to customers), `order_date`, `product_name`, `product_category`, `quantity`, `unit_price`, `cost_price`, `discount` (a percentage), `payment_method`, `order_status` (Completed / Pending / Cancelled)

---

## Business rules used in every query

| Measure | Formula |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)` |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / revenue * 100`, using `NULLIF(revenue, 0)` to avoid dividing by zero |

1. Money questions (revenue, cost, profit, spending, averages) use **Completed** orders only, unless a question says otherwise.
2. Order counts include every order, whatever its status.
3. Customer counts use distinct customers.
4. "Today" is the latest `order_date` in the data (`SELECT MAX(order_date) FROM orders`), not the computer's date.
5. A month means year and month, using `DATE_TRUNC('month', order_date)`.
6. Money is rounded to 2 decimal places.

---

## How to set it up

### 1. Requirements

- **PostgreSQL 14 or newer** (<https://www.postgresql.org/download/>). The installer includes pgAdmin and psql.
- A SQL editor: pgAdmin, DBeaver, or VS Code with a PostgreSQL extension. Or just `psql` in a terminal.

Check the install:

```bash
psql --version
```

### 2. Get the data files

The sample data comes from the project page and is not stored in this repository. Download these files into one folder:

- `01_create_database.sql`
- `03_insert_customers.sql`
- `04_insert_orders.sql`
- `05_verify_data.sql`

(`schema.sql` in this repo replaces the project's `02_create_tables.sql`.)

### 3. Create the database, tables and load the data

Run these in order from a terminal, one at a time. Customers must be loaded before orders because of the foreign key.

```bash
git clone https://github.com/wainainagabriel63-dev/retail-sales-sql.git
cd retail-sales-sql

psql -U postgres -d postgres         -f 01_create_database.sql
psql -U postgres -d retail_analytics -f schema.sql
psql -U postgres -d retail_analytics -f 03_insert_customers.sql
psql -U postgres -d retail_analytics -f 04_insert_orders.sql
psql -U postgres -d retail_analytics -f 05_verify_data.sql
```

**Using pgAdmin instead:** right-click **Databases → Create → Database…**, name it `retail_analytics`, then open **Tools → Query Tool** on that database and run `schema.sql`, `03_insert_customers.sql`, `04_insert_orders.sql` and `05_verify_data.sql` in that order. pgAdmin does not support the `\gexec` line in file 01, so creating the database from the menu replaces that step.

### 4. Check the data loaded

`05_verify_data.sql` should show:

- 150 customers
- 800 orders
- 0 orders with no customer
- Orders from January 2025 to September 2026

A screenshot of this output is in `screenshots/`.

---

## How to run my queries

### Run everything

```bash
psql -U postgres -d retail_analytics -f queries.sql
```

This prints the result of all 46 queries in order. Q43 creates the view `monthly_sales_summary` and Q44 creates a function, both with `CREATE OR REPLACE`, so the file can be run more than once.

### Run one query at a time

Open `queries.sql` in pgAdmin's Query Tool (or DBeaver / VS Code), highlight a single query, and press **Execute** (F5 in pgAdmin). Each query starts with a comment such as:

```sql
-- Q13: Calculate completed-order revenue
```

so you can search for `-- Q13` to jump to it.

### Where to find each topic

| Section | Questions | Topic |
|---|---|---|
| A | Q1–Q10 | SQL fundamentals: `SELECT`, `WHERE`, `ORDER BY`, `LIKE`, `BETWEEN` |
| B | Q11–Q20 | Aggregation and grouping |
| C | Q21–Q28 | Joins and customer analytics |
| D | Q29–Q34 | Subqueries and CTEs |
| E | Q35–Q42 | Window functions |
| F | Q43–Q46 | View, function, customer segmentation, management report |

---

## Insights

My findings are written up in [`insights.md`](insights.md). Each one gives the finding with its number, why it matters to the business, and a recommendation.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `database "retail_analytics" does not exist` | Run `01_create_database.sql` first, or create the database in pgAdmin. |
| `relation "customers" does not exist` | You are connected to the wrong database. Connect to `retail_analytics`. |
| Foreign key violation when loading orders | Load customers (03) before orders (04). |
| `\gexec` syntax error in pgAdmin | Create the database from the pgAdmin menu instead. |
| `password authentication failed` | Use the password you set when installing PostgreSQL. |
| `psql` not found on Windows | Use the SQL Shell (psql) app, or add `C:\Program Files\PostgreSQL\<version>\bin` to your PATH. |
| A percentage comes out as 0 | Integer division. Multiply by `100.0` first. |

---

## Author

**Gabriel Nduati Wainaina**
