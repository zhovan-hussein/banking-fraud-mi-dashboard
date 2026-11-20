-- ============================================================================
-- Retail Banking Fraud & Disputes MI Analysis (Synthetic Portfolio Project)
-- Author: Zhovan Hussein
-- Database: fraud_mi.db (SQLite / Standard ANSI SQL)
-- Note: 100% synthetic dataset created for portfolio demonstration only.
-- ============================================================================

-- 1. Executive Summary KPIs
SELECT
    COUNT(*) AS total_cases,
    ROUND(SUM(disputed_amount_gbp), 2) AS total_disputed_gbp,
    ROUND(SUM(recovered_amount_gbp), 2) AS total_recovered_gbp,
    ROUND(100.0 * SUM(recovered_amount_gbp) / NULLIF(SUM(disputed_amount_gbp), 0), 1) AS recovery_rate_pct,
    ROUND(100.0 * AVG(sla_met), 1) AS sla_compliance_pct,
    ROUND(AVG(resolution_days), 2) AS avg_resolution_days
FROM fraud_cases;

-- 2. Monthly Fraud & Dispute Volume and Value Trend
SELECT
    SUBSTR(opened_date, 1, 7) AS year_month,
    COUNT(*) AS case_count,
    ROUND(SUM(disputed_amount_gbp), 2) AS disputed_gbp,
    ROUND(SUM(recovered_amount_gbp), 2) AS recovered_gbp,
    ROUND(100.0 * AVG(sla_met), 1) AS sla_met_pct
FROM fraud_cases
GROUP BY SUBSTR(opened_date, 1, 7)
ORDER BY year_month;

-- 3. Top Merchant Categories by Disputed Value (JOIN + GROUP BY)
SELECT
    m.category,
    m.risk_tier,
    COUNT(f.case_id) AS case_count,
    ROUND(SUM(f.disputed_amount_gbp), 2) AS total_disputed_gbp,
    ROUND(AVG(f.disputed_amount_gbp), 2) AS avg_case_value_gbp,
    ROUND(100.0 * SUM(f.recovered_amount_gbp) / NULLIF(SUM(f.disputed_amount_gbp), 0), 1) AS recovery_rate_pct
FROM fraud_cases f
INNER JOIN merchants m ON f.merchant_id = m.merchant_id
GROUP BY m.category, m.risk_tier
ORDER BY total_disputed_gbp DESC;

-- 4. Vulnerable Customer Safeguarding — SLA Performance by Customer Segment
SELECT
    c.customer_segment,
    COUNT(f.case_id) AS total_cases,
    ROUND(AVG(f.sla_target_days), 1) AS avg_sla_target_days,
    ROUND(AVG(f.resolution_days), 2) AS avg_resolution_days,
    ROUND(100.0 * AVG(f.sla_met), 1) AS sla_compliance_pct,
    SUM(CASE WHEN f.sla_met = 0 THEN 1 ELSE 0 END) AS sla_breaches
FROM fraud_cases f
INNER JOIN customers c ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY sla_compliance_pct DESC;

-- 5. Debit vs Credit Card Performance by Payment Channel
SELECT
    card_type,
    channel,
    COUNT(*) AS case_count,
    ROUND(SUM(disputed_amount_gbp), 2) AS disputed_gbp,
    ROUND(AVG(disputed_amount_gbp), 2) AS avg_dispute_gbp
FROM fraud_cases
GROUP BY card_type, channel
ORDER BY disputed_gbp DESC;

-- 6. Claim Type Breakdown & Escalation Rate (CASE WHEN)
SELECT
    claim_type,
    COUNT(*) AS total_cases,
    ROUND(SUM(disputed_amount_gbp), 2) AS total_disputed_gbp,
    SUM(CASE WHEN outcome = 'Escalated to Specialist' THEN 1 ELSE 0 END) AS escalated_cases,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Escalated to Specialist' THEN 1 ELSE 0 END) / COUNT(*), 1) AS escalation_rate_pct
FROM fraud_cases
GROUP BY claim_type
ORDER BY total_disputed_gbp DESC;

-- 7. High-Value Cases Over £1,000 Requiring Enhanced Review (WHERE + ORDER BY)
SELECT
    f.case_id,
    f.opened_date,
    c.region,
    c.customer_segment,
    m.category AS merchant_category,
    f.claim_type,
    f.disputed_amount_gbp,
    f.outcome
FROM fraud_cases f
INNER JOIN customers c ON f.customer_id = c.customer_id
INNER JOIN merchants m ON f.merchant_id = m.merchant_id
WHERE f.disputed_amount_gbp >= 1000
ORDER BY f.disputed_amount_gbp DESC
LIMIT 20;

-- 8. Regional Disputed Value Ranking (CTE + Window Function)
WITH regional_totals AS (
    SELECT
        c.region,
        COUNT(f.case_id) AS case_count,
        ROUND(SUM(f.disputed_amount_gbp), 2) AS disputed_gbp,
        ROUND(100.0 * AVG(f.sla_met), 1) AS sla_met_pct
    FROM fraud_cases f
    INNER JOIN customers c ON f.customer_id = c.customer_id
    GROUP BY c.region
)
SELECT
    RANK() OVER (ORDER BY disputed_gbp DESC) AS value_rank,
    region,
    case_count,
    disputed_gbp,
    sla_met_pct
FROM regional_totals;

-- 9. High-Risk Merchants With Above-Average Dispute Value (HAVING)
SELECT
    m.merchant_id,
    m.merchant_name,
    m.category,
    COUNT(f.case_id) AS case_count,
    ROUND(SUM(f.disputed_amount_gbp), 2) AS total_disputed_gbp,
    ROUND(AVG(f.disputed_amount_gbp), 2) AS avg_disputed_gbp
FROM fraud_cases f
INNER JOIN merchants m ON f.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.category
HAVING COUNT(f.case_id) >= 200 AND AVG(f.disputed_amount_gbp) > 500
ORDER BY total_disputed_gbp DESC;

-- 10. SLA Resolution Speed Buckets (CASE WHEN Distribution)
SELECT
    CASE
        WHEN resolution_days <= 2 THEN '1-2 Days (Fast)'
        WHEN resolution_days <= 5 THEN '3-5 Days (Standard)'
        ELSE '6+ Days (Extended / Breach Risk)'
    END AS resolution_bucket,
    COUNT(*) AS case_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fraud_cases), 1) AS share_pct
FROM fraud_cases
GROUP BY resolution_bucket
ORDER BY case_count DESC;
