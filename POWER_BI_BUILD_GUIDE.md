# Power BI Desktop — 15-Minute Build Guide

Follow these steps in **Power BI Desktop** (free download from Microsoft Store) to turn the 3 synthetic CSVs into a recruiter-ready 2-page interactive dashboard.

---

## Step 1: Load the 3 Tables
1. Open **Power BI Desktop** -> **Get Data** -> **Text/CSV**.
2. Import all three files from `data/`:
   - `fraud_cases_synthetic.csv`
   - `customers_synthetic.csv`
   - `merchants_synthetic.csv`
3. Click **Transform Data** to confirm data types:
   - `opened_date` -> **Date**
   - `disputed_amount_gbp` & `recovered_amount_gbp` -> **Fixed Decimal / Currency (£)**
   - `resolution_days`, `sla_target_days`, `sla_met` -> **Whole Number**
4. Click **Close & Apply**.

---

## Step 2: Check Star-Schema Relationships (Model View)
Ensure these two **One-to-Many (`1:*`)** relationships exist:
- `customers_synthetic[customer_id]` -> `fraud_cases_synthetic[customer_id]`
- `merchants_synthetic[merchant_id]` -> `fraud_cases_synthetic[merchant_id]`

---

## Step 3: Add 6 Core DAX Measures
Create a new measure table (or add to `fraud_cases_synthetic`) and paste these exact DAX measures:

```dax
Total Cases = COUNTROWS(fraud_cases_synthetic)

Total Disputed (£) = SUM(fraud_cases_synthetic[disputed_amount_gbp])

Total Recovered (£) = SUM(fraud_cases_synthetic[recovered_amount_gbp])

Recovery Rate % =
DIVIDE([Total Recovered (£)], [Total Disputed (£)], 0)

SLA Compliance % =
DIVIDE(
    CALCULATE(COUNTROWS(fraud_cases_synthetic), fraud_cases_synthetic[sla_met] = 1),
    [Total Cases],
    0
)

Avg Resolution Days =
AVERAGE(fraud_cases_synthetic[resolution_days])
```

Format `Recovery Rate %` and `SLA Compliance %` as **Percentage (1 decimal)** and currency measures as **£ English (United Kingdom)**.

---

## Step 4: Build 2 Clean Dashboard Pages

### Page 1 — Executive Fraud & Disputes Overview
* **Top Row (5 KPI Cards):** `Total Cases` (5,000) · `Total Disputed (£)` (£2.50M) · `Total Recovered (£)` (£1.57M) · `Recovery Rate %` (62.7%) · `SLA Compliance %` (93.5%)
* **Left Visual (Line Chart):** Monthly trend of `Total Disputed (£)` and `Total Cases` by `opened_date` (Month).
* **Right Visual (Clustered Bar Chart):** `Total Disputed (£)` by `merchants_synthetic[category]`, coloured by `risk_tier`.
* **Bottom Visual (Slicers):** `card_type` (Debit vs Credit), `channel`, `customer_segment`, and `region`.

### Page 2 — Safeguarding, SLA & Operations Performance
* **Top Left (Table / Matrix):** `customer_segment` vs `Total Cases`, `Avg Resolution Days`, and `SLA Compliance %` (highlighting **Vulnerable** customers' faster 3-day SLA target!).
* **Top Right (Donut Chart):** `Total Cases` by `outcome`.
* **Bottom (Clustered Column Chart):** `Total Cases` by `claim_type` split by `card_type`.

---

## Step 5: Publish Screenshots to LinkedIn & GitHub
1. Save as `Banking_Fraud_MI_Dashboard.pbix`.
2. Export clean screenshots of Page 1 and Page 2 (`File -> Export -> PDF` or macOS screenshot).
3. Add the project to **GitHub** and your **LinkedIn Featured** section — instant proof of real SQL, Power BI, and Excel ability!
