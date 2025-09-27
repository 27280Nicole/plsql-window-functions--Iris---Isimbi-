-- =============================================
-- Aggregate Functions with Window Frames
-- SUM, AVG, MIN, MAX with ROWS vs RANGE
-- =============================================

-- 1. Running total of sales using SUM() OVER()
SELECT 
    transaction_id,
    sale_date,
    amount,
    SUM(amount) OVER (ORDER BY sale_date, transaction_id) AS running_total,
    SUM(amount) OVER (ORDER BY sale_date, transaction_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_explicit
FROM transactions
ORDER BY sale_date, transaction_id;

-- 2. 3-month moving average using AVG() OVER()
SELECT 
    DATE_TRUNC('month', sale_date) AS sales_month,
    SUM(amount) AS monthly_sales,
    AVG(SUM(amount)) OVER (
        ORDER BY DATE_TRUNC('month', sale_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_moving_avg,
    AVG(SUM(amount)) OVER (
        ORDER BY DATE_TRUNC('month', sale_date) 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS centered_moving_avg
FROM transactions
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sales_month;

-- 3. Regional cumulative sales with PARTITION BY
SELECT 
    c.region,
    t.sale_date,
    t.amount,
    SUM(t.amount) OVER (
        PARTITION BY c.region 
        ORDER BY t.sale_date, t.transaction_id
    ) AS regional_running_total,
    AVG(t.amount) OVER (
        PARTITION BY c.region 
        ORDER BY t.sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS regional_moving_avg
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
ORDER BY c.region, t.sale_date;

-- 4. MIN and MAX with window frames
SELECT 
    sale_date,
    amount,
    MIN(amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS min_3_transactions,
    MAX(amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS max_3_transactions,
    AVG(amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_3_transactions
FROM transactions
ORDER BY sale_date;

-- 5. ROWS vs RANGE comparison
SELECT 
    sale_date,
    amount,
    SUM(amount) OVER (ORDER BY sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rows_running_total,
    SUM(amount) OVER (ORDER BY sale_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS range_running_total
FROM transactions
ORDER BY sale_date;