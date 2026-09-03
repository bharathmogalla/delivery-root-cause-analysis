# Olist Delivery Root-Cause Analysis

SQL + Power BI project analyzing 96,000+ Brazilian e-commerce orders to identify the real root causes of delivery failures.

## 📊 Dashboard Preview

![Olist Delivery Dashboard](BI%20Dashboard.png)

## Key Findings
- Only 6.8% of orders arrived late, but average delay was -11 days — estimates are heavily padded
- Extreme delays (30+ days) concentrate in high-volume hubs (RJ, SP) — not remote regions as initially hypothesized
- Sharp seasonal spike Nov 2017–Feb 2018, independently confirmed by Power BI Anomaly Detection (flagged Feb 28, 2018)
- Power BI Key Influencers found CE state customers face 5.36x higher risk of extreme delay

## Tools
SQL Server, Power BI (DAX, Key Influencers, Decomposition Tree, Anomaly Detection)

## Files
- `SQLQuery14.sql` — full root-cause SQL analysis
- `delivery_dashboard.pbix` — Power BI dashboard
- `case_study.md` — full write-up with methodology and recommendations
