-- =============================================
-- Navigation Functions Implementation
-- LAG, LEAD for growth calculations
-- =============================================

-- 1. Month-over-month growth using LAG()
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS sales_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT 
    sales_month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY sales_month) AS previous_month_sales,
    monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY sales_month) AS sales_difference,
    ROUND(
        ((monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY sales_month)) / 
        LAG(monthly_sales, 1) OVER (ORDER BY sales_month)) * 100, 2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY sales_month;

-- 2. Lead analysis for forecasting
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS sales_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT 
    sales_month,
    monthly_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY sales_month) AS next_month_forecast,
    LEAD(monthly_sales, 2) OVER (ORDER BY sales_month) AS two_months_forecast,
    ROUND(
        ((LEAD(monthly_sales, 1) OVER (ORDER BY sales_month) - monthly_sales) / 
        monthly_sales) * 100, 2
    ) AS projected_growth
FROM monthly_sales
ORDER BY sales_month;

-- 3. Daily sales comparison with LAG and LEAD
SELECT 
    sale_date,
    amount AS daily_sales,
    LAG(amount, 1) OVER (ORDER BY sale_date) AS previous_day_sales,
    LEAD(amount, 1) OVER (ORDER BY sale_date) AS next_day_sales,
    amount - LAG(amount, 1) OVER (ORDER BY sale_date) AS day_over_day_change
FROM transactions
ORDER BY sale_date;

-- 4. Regional growth analysis
WITH regional_monthly AS (
    SELECT 
        c.region,
        DATE_TRUNC('month', t.sale_date) AS sales_month,
        SUM(t.amount) AS regional_sales
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    GROUP BY c.region, DATE_TRUNC('month', t.sale_date)
)
SELECT 
    region,
    sales_month,
    regional_sales,
    LAG(regional_sales, 1) OVER (PARTITION BY region ORDER BY sales_month) AS prev_month,
    ROUND(
        ((regional_sales - LAG(regional_sales, 1) OVER (PARTITION BY region ORDER BY sales_month)) / 
        LAG(regional_sales, 1) OVER (PARTITION BY region ORDER BY sales_month)) * 100, 2
    ) AS regional_growth_pct
FROM regional_monthly
ORDER BY region, sales_month;

-- 5. Product performance trends
WITH product_monthly AS (
    SELECT 
        p.name AS product_name,
        DATE_TRUNC('month', t.sale_date) AS sales_month,
        SUM(t.quantity) AS monthly_quantity,
        SUM(t.amount) AS monthly_revenue
    FROM transactions t
    JOIN products p ON t.product_id = p.product_id
    GROUP BY p.name, DATE_TRUNC('month', t.sale_date)
)
SELECT 
    product_name,
    sales_month,
    monthly_quantity,
    monthly_revenue,
    LAG(monthly_quantity, 1) OVER (PARTITION BY product_name ORDER BY sales_month) AS prev_month_qty,
    LAG(monthly_revenue, 1) OVER (PARTITION BY product_name ORDER BY sales_month) AS prev_month_rev,
    ROUND(
        ((monthly_revenue - LAG(monthly_revenue, 1) OVER (PARTITION BY product_name ORDER BY sales_month)) / 
        LAG(monthly_revenue, 1) OVER (PARTITION BY product_name ORDER BY sales_month)) * 100, 2
    ) AS revenue_growth_pct
FROM product_monthly
ORDER BY product_name, sales_month;