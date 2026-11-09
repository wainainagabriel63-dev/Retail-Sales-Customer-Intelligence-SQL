# J Cars Logistics: Executive Sales & Operations Dashboard

An interactive Power BI dashboard that analyses vehicle sales, profitability, customers, payments and delivery performance for **J Cars Logistics**, a Kenyan vehicle sales and logistics business. It turns the sales data into a management view that shows where the business makes money, where it loses it, and what deserves investigation.

> **Author:** Gabriel Nduati Wainaina
> **Tool:** Microsoft Power BI Desktop
> **Status:** [Semi-final / Final, update this]

---

## Table of Contents
1. [Business Problem](#business-problem)
2. [Headline Numbers](#headline-numbers)
3. [Data Model](#data-model)
4. [Dashboard Pages](#dashboard-pages)
5. [Key Insights](#key-insights)
6. [Recommendations](#recommendations)
7. [Data Considerations](#data-considerations)
8. [Design](#design)
9. [How to Open This Project](#how-to-open-this-project)
10. [Repository Structure](#repository-structure)
11. [Author](#author)

---

## Business Problem

J Cars Logistics generated about **Ksh 1.46bn** in revenue but only a **1.80%** gross profit margin. Management needs to know:

- Which vehicle types, car makes, regions and sales channels drive profit, and which drive losses?
- Who are the most important customers, and how concentrated is the revenue?
- How are payments, returns, cancellations and deliveries affecting the numbers?

This dashboard answers those questions and shows the evidence behind each answer.

---

## Headline Numbers

| Metric | Value |
|---|---|
| Total Revenue | Ksh 1.46bn |
| Units Sold | 458 |
| Gross Profit | Ksh 26.43M |
| Gross Profit Margin | 1.80% |
| Total Cost | Ksh 1.44bn |
| Logistics Cost | Ksh 27.78M |
| Delivery Fees Collected | Ksh 24.91M |

---

## Data Model

The report uses a star schema with one fact table and five dimension tables.

| Table | Type | Purpose |
|---|---|---|
| `Fact_Sales` | Fact | Transactions: revenue, units, costs, discounts, payment and delivery details |
| `Dim_Car` | Dimension | Car make, model, vehicle type, fuel type, vehicle year |
| `Dim_Customer Type` | Dimension | Customer categories (dealer, government, NGO, corporate, individual, etc.) |
| `Dim_Date` | Dimension | Calendar attributes for time analysis |
| `Dim_Location` | Dimension | Branch, county and region |
| `Dim_Sales Rep` | Dimension | Sales representatives |

**Data source:** [Add where the data came from, e.g. provided dataset, Excel workbook, course project]

---

## Dashboard Pages

| Page | What it shows |
|---|---|
| **Executive Dashboard** | Headline KPIs, revenue by branch, car make and car model, and revenue and profit by month |
| **Products** | Vehicle type profitability, margin by car make, sales by vehicle year, fuel type by region, returns and cancellations by car model |
| **Geography & Sales Team** | Revenue by county and region, sales rep ranking, revenue and profit by lead source, regional margin table |
| **Customers & Payments** | Revenue by customer type, customer ratings, payment status and method, discount rate against margin by branch |
| **Logistics & Delivery** | Total cost, logistics cost, delivery fees, delivery status, delivery fees by region and vehicle type |
| **[Page 6]** | [Add name and a one-line description] |

Each page has slicers for Vehicle Year and other filters so the numbers can be broken down by time, region, car make or customer type.

---

## Key Insights

1. **SUVs carry the business.** They generate Ksh 844.86M, which is 57.7% of revenue from 38% of units, at a 9.14% margin.
2. **Four vehicle types sell at a loss:** Sedan (-16.24%), Truck (-65.57%), Van (-27.67%) and Crossover (-9.84%). Together they make up about 23.6% of revenue. The data shows where the losses are but not why.
3. **Three regions with negative margins account for about 35% of revenue:** Central (-4.13%), Nyanza (-8.90%) and Nairobi (-16.77%). Rift Valley is the largest region (25.8% of revenue) with a 4.58% margin.
4. **Lead sources differ sharply in profitability.** Instagram (17.20%), WhatsApp (12.51%) and Facebook (10.09%) are the most profitable, while Referral (-22.21%) and Corporate Tender (-18.02%) lose money. This may reflect the vehicles each channel sells rather than the channel itself.
5. **Revenue is concentrated in a few buyer groups.** Car Dealers, Government, NGOs and Corporates make up about 83% of revenue, and Government and NGOs alone about 43%.
6. **Returns, cancellations and delivery may weaken the headline figures.** The data shows 149 returned units against 458 sold, 37 cancelled transactions, and logistics costs (Ksh 27.78M) above delivery fees collected (Ksh 24.91M).

---

## Recommendations

1. **Investigate pricing and cost on Sedans, Trucks, Vans and Crossovers.** Compare purchase cost, selling price, discount and delivery cost on the loss-making sales with the profitable SUV sales.
2. **Review margins in Nairobi, Nyanza and Central.** Compare their vehicle mix and discounting with Rift Valley and Coast before changing branch strategy.
3. **Review pricing approval for Referral and Corporate Tender sales.** First test whether the gap comes from the channel or from the vehicles sold through it.
4. **Fix how returns, cancellations and delivery are measured.** Make sure cancelled and refunded orders are excluded from revenue, and review delivery fees against logistics costs.
5. **Monitor dependence on Government and NGO buyers.** Track their revenue share and payment status each quarter.

These are starting points for investigation. The dashboard shows relationships between variables, and a relationship does not by itself prove cause.

---

## Data Considerations

Points to be aware of when reading the numbers:

- Some categories are duplicated or blank (for example Person/Individual, Company/Corporate, and blank lead sources or months).
- The discount rate column mixes fractions and whole percentages, so discount conclusions should be treated with caution.
- Some records have no matching date, which shows up as (Blank) or 1899 on time axes.
- Segment-level margins should be checked against the headline 1.80% to confirm the margin measure is total gross profit divided by total revenue.

*[Remove any item above once you have fixed it in Power Query or the data model.]*

---

## Design

- Navy and light-blue palette applied through a custom Power BI theme (`JCars_Navy_Theme.json`)
- Consistent left navigation panel, title area and slicer row across pages
- White rounded cards on a light background, in the style of an executive logistics dashboard

---

## How to Open This Project

1. Install **Power BI Desktop** (free) from Microsoft.
2. Download this repository.
3. Open the `.pbix` file in Power BI Desktop.
4. To apply the theme: **View → Themes → Browse for themes**, then choose `JCars_Navy_Theme.json`.
5. If prompted, refresh the data and point the source to your local data file.

---

## Repository Structure

```
├── JCARS_Dashboard.pbix        # Power BI report
├── JCars_Navy_Theme.json       # Custom theme
├── data/                       # Source data files
├── screenshots/                # Dashboard page images
└── README.md
```

*[Adjust file names to match your repository.]*

---

## Screenshots

*[Add one screenshot per page, for example:]*

```
![Executive Dashboard](screenshots/executive_dashboard.png)
![Products](screenshots/products.png)
![Geography & Sales Team](screenshots/geography_sales_team.png)
![Customers & Payments](screenshots/customers_payments.png)
![Logistics & Delivery](screenshots/logistics_delivery.png)
```

---

## Author

**Gabriel Nduati Wainaina**
BSc Statistics, Jomo Kenyatta University of Agriculture and Technology (JKUAT)
[LinkedIn / GitHub / Email: add your links]
