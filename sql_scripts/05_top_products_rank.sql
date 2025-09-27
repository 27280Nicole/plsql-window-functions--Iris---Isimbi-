SELECT 
    c.region,
    p.name AS product_name,
    SUM(t.amount) AS total_revenue,
    RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS revenue_rank,
    DENSE_RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS dense_revenue_rank,
    PERCENT_RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount)) AS percent_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id
GROUP BY c.region, p.name
ORDER BY c.region, revenue_rank;
