# Retail Banking Fraud & Disputes MI Dashboard (SQL + Power BI + Excel)

**Author:** Zhovan Hussein — BSc (Hons) Computing & IT Student (The Open University) | Senior Customer Advisor (Fraud & Disputes)  
**Tools:** SQL (SQLite / ANSI SQL), Microsoft Power BI, Microsoft Excel

> **Data Privacy Disclaimer:** All data in this repository (`data/*.csv` and `fraud_mi.db`) is **100% synthetically generated** for portfolio demonstration. No real customer, merchant, or employer data is included.

---

## Business Problem
Retail banking Fraud & Disputes teams handle thousands of debit and credit card claims every quarter under strict FCA regulatory and vulnerable-customer safeguarding SLAs. Operations managers need clear Management Information (MI) to answer:
1. Which merchant categories and payment channels drive the highest disputed value?
2. What percentage of disputed funds are recovered via fraud refunds and chargebacks?
3. Are **Vulnerable Customers** consistently meeting faster safeguarding SLA targets (3 days vs 5 days standard)?
4. Which claim types generate the highest escalation rates to specialist teams?

---

## Project Structure
```text
banking-fraud-mi-dashboard/
├── data/
│   ├── fraud_cases_synthetic.csv   # 5,000 synthetic fraud & dispute cases (12 months)
│   ├── customers_synthetic.csv     # 800 synthetic customer profiles (region, segment, tenure)
│   └── merchants_synthetic.csv     # 20 synthetic merchants across 10 categories & risk tiers
├── sql/
│   └── analysis_queries.sql        # 10 verified business SQL queries (JOINs, CTEs, CASE, Window Functions)
├── fraud_mi.db                     # Ready-to-query SQLite relational database
├── POWER_BI_BUILD_GUIDE.md         # Star-schema model, 6 DAX measures & 2-page dashboard layout
└── README.md
```

---

## Key Analytical Findings (Synthetic 12-Month Dataset)
* **Volume & Value:** 5,000 total cases totalling **£2,500,846** in disputed value, with **£1,568,131** recovered (**62.7%** overall recovery rate).
* **SLA Compliance:** **93.5%** overall SLA compliance across all segments, averaging **2.79 days** to resolve.
* **Risk Concentration:** High-risk online/card-not-present (CNP) channels and high-risk merchant tiers account for the majority of disputed value, highlighting where preventative controls and colleague coaching have the greatest impact.

---

## How to Run the SQL Queries Locally
```bash
sqlite3 fraud_mi.db < sql/analysis_queries.sql
```
