-- =============================================
-- Ranking Functions Implementation
-- RANK, DENSE_RANK, ROW_NUMBER, PERCENT_RANK
-- =============================================

-- 1. Top products per region using RANK()
SELECT 
    c.region,
    p.name AS product_name,
    SUM(t.amount) AS total_revenue,
    RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS revenue_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id
GROUP BY c.region, p.name
ORDER BY c.region, revenue_rank;

-- 2. Customer ranking using all ranking functions
SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.region,
    SUM(t.amount) AS total_spent,
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS row_num_rank,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS dense_rank_position,
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount)) AS percent_rank
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name, c.region
ORDER BY total_spent DESC;

-- 3. Top 3 products per category by revenue
SELECT 
    p.category,
    p.name AS product_name,
    SUM(t.amount) AS total_revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(t.amount) DESC) AS category_rank
FROM products p
JOIN transactions t ON p.product_id = t.product_id
GROUP BY p.category, p.name
HAVING RANK() OVER (PARTITION BY p.category ORDER BY SUM(t.amount) DESC) <= 3
ORDER BY p.category, category_rank;

-- 4. Monthly sales ranking per region
SELECT 
    c.region,
    DATE_TRUNC('month', t.sale_date) AS sales_month,
    SUM(t.amount) AS monthly_sales,
    RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS monthly_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.region, DATE_TRUNC('month', t.sale_date)
ORDER BY c.region, monthly_rank;