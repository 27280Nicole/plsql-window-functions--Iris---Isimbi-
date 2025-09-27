-- =============================================
-- Rwanda Coffee Collective Database Setup
-- Creates tables and inserts sample data
-- =============================================

-- Clean start: Drop existing tables if they exist
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- Create customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    registration_date DATE,
    customer_type VARCHAR(20) CHECK (customer_type IN ('Individual', 'Cafe', 'Restaurant', 'Hotel'))
);

-- Create products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

-- Create transactions table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER REFERENCES products(product_id),
    sale_date DATE NOT NULL,
    quantity INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20)
);

-- Insert sample customer data
INSERT INTO customers (name, region, registration_date, customer_type) VALUES
('Kigali Coffee House', 'Kigali', '2023-01-15', 'Cafe'),
('Hotel Rwanda', 'Kigali', '2023-02-20', 'Hotel'),
('Huye Mountain Resort', 'Southern', '2023-03-10', 'Hotel'),
('Musanze Local Market', 'Northern', '2023-01-25', 'Individual'),
('Gisenyi Beach Cafe', 'Western', '2023-04-05', 'Cafe'),
('Nyamata Cooperative', 'Eastern', '2023-05-12', 'Individual'),
('Rubavu Restaurant', 'Western', '2023-06-18', 'Restaurant'),
('Butare University Cafe', 'Southern', '2023-07-22', 'Cafe');

-- Insert sample product data
INSERT INTO products (name, category, price, cost) VALUES
('Arabica Premium', 'Coffee Beans', 15000, 8000),
('Robusta Blend', 'Coffee Beans', 12000, 6000),
('Bourbon Special', 'Coffee Beans', 18000, 10000),
('Instant Coffee', 'Processed', 8000, 4000),
('Coffee Filters', 'Accessories', 5000, 2000),
('Traditional Coffee Set', 'Accessories', 25000, 12000),
('Coffee Grinder', 'Equipment', 35000, 20000),
('Thermal Carafe', 'Equipment', 12000, 6000);

-- Insert sample transaction data
INSERT INTO transactions (customer_id, product_id, sale_date, quantity, amount, payment_method) VALUES
(1, 1, '2024-01-15', 10, 150000, 'Bank Transfer'),
(2, 2, '2024-01-20', 5, 60000, 'Cash'),
(3, 1, '2024-02-05', 8, 120000, 'Mobile Money'),
(1, 3, '2024-02-10', 20, 160000, 'Bank Transfer'),
(4, 2, '2024-03-15', 3, 36000, 'Cash'),
(5, 1, '2024-03-20', 12, 180000, 'Mobile Money'),
(2, 4, '2024-04-05', 15, 120000, 'Bank Transfer'),
(6, 3, '2024-04-10', 6, 108000, 'Cash'),
(7, 1, '2024-05-15', 8, 120000, 'Mobile Money'),
(8, 2, '2024-05-20', 10, 120000, 'Bank Transfer'),
(1, 5, '2024-06-05', 25, 125000, 'Bank Transfer'),
(3, 1, '2024-06-10', 15, 225000, 'Mobile Money'),
(5, 4, '2024-07-15', 20, 160000, 'Cash'),
(2, 1, '2024-07-20', 12, 180000, 'Bank Transfer');

-- Verification query
SELECT 'Database setup completed successfully!' as status;
SELECT COUNT(*) as customer_count FROM customers;
SELECT COUNT(*) as product_count FROM products;
SELECT COUNT(*) as transaction_count FROM transactions;