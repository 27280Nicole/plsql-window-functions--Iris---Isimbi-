-- =============================================
-- Distribution Functions Implementation
-- NTILE, CUME_DIST for segmentation
-- =============================================

-- 1. Customer segmentation using NTILE(4)
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.name,
        c.region,
        SUM(t.amount) AS total_spent,
        NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) AS spending_quartile,
        CUME_DIST() OVER (ORDER BY SUM(t.amount)) AS cumulative_distribution
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region
)
SELECT 
    customer_id,
    name,
    region,
    total_spent,
    spending_quartile,
    CASE 
        WHEN spending_quartile = 1 THEN 'Premium'
        WHEN spending_quartile = 2 THEN 'Gold'
        WHEN spending_quartile = 3 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment,
    ROUND(CAST(cumulative_distribution * 100 AS DECIMAL), 2) AS percentile
FROM customer_spending
ORDER BY total_spent DESC;

-- 2. Product performance distribution
WITH product_performance AS (
    SELECT 
        p.product_id,
        p.name AS product_name,
        p.category,
        SUM(t.quantity) AS total_quantity,
        SUM(t.amount) AS total_revenue,
        NTILE(5) OVER (ORDER BY SUM(t.amount) DESC) AS revenue_quintile,
        CUME_DIST() OVER (ORDER BY SUM(t.amount)) AS revenue_percentile
    FROM products p
    JOIN transactions t ON p.product_id = t.product_id
    GROUP BY p.product_id, p.name, p.category
)
SELECT 
    product_name,
    category,
    total_quantity,
    total_revenue,
    revenue_quintile,
    CASE 
        WHEN revenue_quintile = 1 THEN 'Top 20%'
        WHEN revenue_quintile = 2 THEN 'Upper Middle'
        WHEN revenue_quintile = 3 THEN 'Middle'
        WHEN revenue_quintile = 4 THEN 'Lower Middle'
        ELSE 'Bottom 20%'
    END AS performance_tier,
    ROUND(CAST(revenue_percentile * 100 AS DECIMAL), 2) AS revenue_percentile
FROM product_performance
ORDER BY total_revenue DESC;

-- 3. Regional sales distribution analysis
WITH regional_sales AS (
    SELECT 
        c.region,
        SUM(t.amount) AS total_sales,
        COUNT(DISTINCT c.customer_id) AS customer_count,
        CUME_DIST() OVER (ORDER BY SUM(t.amount)) AS sales_distribution,
        NTILE(3) OVER (ORDER BY SUM(t.amount) DESC) AS sales_tier
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.region
)
SELECT 
    region,
    total_sales,
    customer_count,
    ROUND(CAST(sales_distribution * 100 AS DECIMAL), 2) AS sales_percentile,
    CASE 
        WHEN sales_tier = 1 THEN 'High Performance'
        WHEN sales_tier = 2 THEN 'Medium Performance'
        ELSE 'Low Performance'
    END AS performance_category,
    ROUND(total_sales / customer_count, 2) AS avg_sales_per_customer
FROM regional_sales
ORDER BY total_sales DESC;

-- 4. Monthly sales distribution with CUME_DIST
WITH monthly_performance AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS sales_month,
        SUM(amount) AS monthly_sales,
        CUME_DIST() OVER (ORDER BY SUM(amount)) AS sales_percentile,
        NTILE(4) OVER (ORDER BY SUM(amount) DESC) AS monthly_quartile
    FROM transactions
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT 
    sales_month,
    monthly_sales,
    ROUND(CAST(sales_percentile * 100 AS DECIMAL), 2) AS percentile_rank,
    CASE 
        WHEN monthly_quartile = 1 THEN 'Top Quarter'
        WHEN monthly_quartile = 2 THEN 'Upper Middle'
        WHEN monthly_quartile = 3 THEN 'Lower Middle'
        ELSE 'Bottom Quarter'
    END AS monthly_performance,
    PERCENT_RANK() OVER (ORDER BY monthly_sales) AS percent_rank
FROM monthly_performance
ORDER BY sales_month;

-- 5. Customer value segmentation with multiple distribution functions
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.name,
        c.region,
        c.customer_type,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(t.amount) AS total_spent,
        AVG(t.amount) AS avg_transaction_value,
        NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) AS spending_quartile,
        NTILE(10) OVER (ORDER BY SUM(t.amount) DESC) AS spending_decile,
        CUME_DIST() OVER (ORDER BY SUM(t.amount)) AS spending_percentile
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region, c.customer_type
)
SELECT 
    customer_id,
    name,
    region,
    customer_type,
    transaction_count,
    total_spent,
    avg_transaction_value,
    spending_quartile,
    spending_decile,
    ROUND(CAST(spending_percentile * 100 AS DECIMAL), 2) AS spending_percentile,
    CASE 
        WHEN spending_decile = 1 THEN 'Top 10% - VIP'
        WHEN spending_decile <= 3 THEN 'Top 30% - Premium'
        WHEN spending_decile <= 6 THEN 'Middle 40% - Standard'
        ELSE 'Bottom 30% - Basic'
    END AS value_segment
FROM customer_metrics
ORDER BY total_spent DESC;