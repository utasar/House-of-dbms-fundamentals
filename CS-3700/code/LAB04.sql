-- =====================================================================
-- CS 3700 - Lab 04: SQL and Normalized Databases
-- Student Name: Utsav Acharya
-- Date: November 1, 2026
-- Database Engine: MariaDB 12.3
-- Run top to bottom on a fresh database (the first lines reset it).
-- =====================================================================


-- =====================================================================
-- PART 2: DDL - CREATING THE DATABASE, TABLES, AND CONSTRAINTS
-- Purpose: build the five normalized tables with primary keys, foreign
-- keys, and CHECK constraints (no negative prices, positive quantities).
-- =====================================================================

DROP DATABASE IF EXISTS OnlineRetailStore;
CREATE DATABASE OnlineRetailStore;
USE OnlineRetailStore;

CREATE TABLE CATEGORY (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(150) NOT NULL,
    Email VARCHAR(255) NOT NULL
);

CREATE TABLE PRODUCT (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    StockQuantity INT CHECK (StockQuantity >= 0),
    CategoryID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORY(CategoryID)
);

CREATE TABLE CUSTOMER_ORDER (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

CREATE TABLE ORDER_ITEM (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) CHECK (UnitPrice >= 0),
    FOREIGN KEY (OrderID) REFERENCES CUSTOMER_ORDER(OrderID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCT(ProductID)
);

-- ALTER TABLE: add the phone column (first created as Phone, then renamed
-- to PhoneNumber to match the assignment), and make Email unique.
ALTER TABLE CUSTOMER ADD COLUMN Phone VARCHAR(20);
ALTER TABLE CUSTOMER RENAME COLUMN Phone TO PhoneNumber;
ALTER TABLE CUSTOMER ADD CONSTRAINT UQ_Customer_Email UNIQUE (Email);
DESCRIBE CUSTOMER;

-- Testing Challenge: insert a product with CategoryID 99, which does not
-- exist in CATEGORY. Left commented out so the script runs to the end;
-- run it by hand to capture the error.
-- Expected: ERROR 1452 (23000) - foreign key constraint fails.
-- INSERT INTO PRODUCT (ProductName, Price, StockQuantity, CategoryID)
-- VALUES ('Test Item', 10.00, 5, 99);


-- =====================================================================
-- PART 3A: DML - SAMPLE DATA AND INDIVIDUALIZED DATASET
-- Purpose: insert the provided sample records, then my own records.
-- (PhoneNumber values are my own additions; the handout has no phones.)
-- =====================================================================

-- Provided sample data
INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES
(10, 'Electronics'),
(20, 'Clothing'),
(30, 'Home & Kitchen');

INSERT INTO CUSTOMER (CustomerID, CustomerName, Email, PhoneNumber) VALUES
(101, 'Alice Carter', 'alice@example.com', '555-0101'),
(102, 'Brian Lee', 'brian@example.com', '555-0102'),
(103, 'Sarah Wilson', 'sarah@example.com', '555-0103'),
(104, 'David Brown', 'david@example.com', '555-0104'),
(105, 'Emma Davis', 'emma@example.com', '555-0105');

INSERT INTO PRODUCT (ProductID, ProductName, Price, StockQuantity, CategoryID) VALUES
(201, 'Wireless Mouse', 25.99, 50, 10),
(202, 'Keyboard', 49.99, 30, 10),
(203, 'T-Shirt', 19.99, 100, 20),
(204, 'Coffee Maker', 89.99, 15, 30),
(205, 'Headphones', 59.99, 25, 10);

INSERT INTO CUSTOMER_ORDER (OrderID, CustomerID, OrderDate, Status) VALUES
(301, 101, '2026-09-01', 'Delivered'),
(302, 102, '2026-09-02', 'Shipped'),
(303, 101, '2026-09-05', 'Pending'),
(304, 103, '2026-09-06', 'Delivered'),
(305, 104, '2026-09-08', 'Pending');

INSERT INTO ORDER_ITEM (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(401, 301, 201, 2, 25.99),
(402, 301, 202, 1, 49.99),
(403, 302, 203, 3, 19.99),
(404, 303, 205, 1, 59.99),
(405, 304, 204, 1, 89.99),
(406, 305, 201, 1, 25.99);

-- My individualized dataset
-- Three customers; Marcus Vance contains the letter U from my first
-- initial; Kevin Smith (108) intentionally has no orders.
INSERT INTO CUSTOMER (CustomerID, CustomerName, Email, PhoneNumber) VALUES
(106, 'Marcus Vance', 'marcus.v@example.com', '555-0106'),
(107, 'Jessica Taylor', 'jessica.t@example.com', '555-0107'),
(108, 'Kevin Smith', 'kevin.s@example.com', '555-0108');

-- Four products across two categories (Electronics and Clothing)
INSERT INTO PRODUCT (ProductID, ProductName, Price, StockQuantity, CategoryID) VALUES
(206, 'Bluetooth Speaker', 45.50, 40, 10),
(207, 'Smartwatch', 199.99, 20, 10),
(208, 'Denim Jeans', 39.99, 60, 20),
(209, 'Winter Jacket', 79.99, 25, 20);

-- Three orders for the new customers
INSERT INTO CUSTOMER_ORDER (OrderID, CustomerID, OrderDate, Status) VALUES
(306, 106, '2026-09-10', 'Pending'),
(307, 107, '2026-09-11', 'Delivered'),
(308, 106, '2026-09-12', 'Shipped');

-- Five order items; UnitPrice equals the product's list price at purchase.
-- Order 306 contains two different products (multi-product order).
INSERT INTO ORDER_ITEM (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(407, 306, 206, 2, 45.50),
(408, 306, 209, 1, 79.99),
(409, 307, 207, 1, 199.99),
(410, 308, 208, 1, 39.99),
(411, 308, 209, 2, 79.99);


-- =====================================================================
-- PART 3B: SELECT - WHERE AND JOIN QUERIES
-- =====================================================================

-- 1. All products with their category names (expected: 9 rows)
SELECT p.ProductName, c.CategoryName
FROM PRODUCT p
JOIN CATEGORY c ON p.CategoryID = c.CategoryID;

-- 2. Customer names, order dates, and statuses for pending orders (3 rows)
SELECT cu.CustomerName, co.OrderDate, co.Status
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
WHERE co.Status = 'Pending';

-- 3. All products purchased by Alice Carter (3 rows)
SELECT DISTINCT p.ProductName
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID
WHERE cu.CustomerName = 'Alice Carter';

-- 4. Products over $50 with fewer than 30 units in stock (4 rows)
SELECT ProductName, Price, StockQuantity
FROM PRODUCT
WHERE Price > 50 AND StockQuantity < 30;

-- 5. Customer, order ID, product, quantity, purchase price per ordered
--    item (expected: 11 rows, one per ORDER_ITEM row)
SELECT cu.CustomerName, co.OrderID, p.ProductName, oi.Quantity, oi.UnitPrice
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID;

-- 6. All customers, including those who never placed an order
--    (expected: 10 rows = 8 order rows + 2 customers with NULL orders)
SELECT cu.CustomerName, co.OrderID, co.OrderDate, co.Status
FROM CUSTOMER cu
LEFT JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID;

-- 7. A specific product from my dataset (1 row)
SELECT *
FROM PRODUCT
WHERE ProductName = 'Smartwatch';


-- =====================================================================
-- PART 3C: UPDATE AND DELETE
-- =====================================================================

-- 1. Increase the price of Wireless Mouse by 10% (25.99 -> 28.59)
UPDATE PRODUCT
SET Price = Price * 1.10
WHERE ProductName = 'Wireless Mouse';

-- 2. Change OrderID 303's status from Pending to Shipped
UPDATE CUSTOMER_ORDER
SET Status = 'Shipped'
WHERE OrderID = 303;

-- 3. Update stock of a product I created (ProductID 206), with before/after
SELECT * FROM PRODUCT WHERE ProductID = 206;   -- BEFORE (stock 40)
UPDATE PRODUCT
SET StockQuantity = 45
WHERE ProductID = 206;
SELECT * FROM PRODUCT WHERE ProductID = 206;   -- AFTER (stock 45)

-- 4. Delete one ORDER_ITEM I created (OrderItemID 411), with before/after
SELECT * FROM ORDER_ITEM WHERE OrderItemID = 411;   -- BEFORE (1 row)
DELETE FROM ORDER_ITEM
WHERE OrderItemID = 411;
SELECT * FROM ORDER_ITEM WHERE OrderItemID = 411;   -- AFTER (empty set)


-- =====================================================================
-- PART 4: SQL DEBUGGING - ORIGINAL PROBLEMS AND CORRECTIONS
-- =====================================================================

-- Query A (flawed, left commented out): joins CUSTOMER.CustomerID to
-- PRODUCT.ProductID, which are unrelated IDs; returns an empty set.
-- SELECT CustomerName, ProductName
-- FROM CUSTOMER
-- JOIN PRODUCT
-- ON CUSTOMER.CustomerID = PRODUCT.ProductID;

-- Query A correction: customers reach products through orders and items
SELECT c.CustomerName, p.ProductName
FROM CUSTOMER c
JOIN CUSTOMER_ORDER co ON c.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID;

-- Query B (flawed, left commented out): no WHERE clause, so it would set
-- the price of every product to 10.00.
-- UPDATE PRODUCT
-- SET Price = 10.00;

-- Query B correction: only Wireless Mouse
UPDATE PRODUCT
SET Price = 10.00
WHERE ProductName = 'Wireless Mouse';

-- Query C (flawed, left commented out): joins ProductID to CategoryID
-- instead of the real foreign key; returns an empty set.
-- SELECT ProductName, CategoryName
-- FROM PRODUCT
-- JOIN CATEGORY
-- ON PRODUCT.ProductID = CATEGORY.CategoryID;

-- Query C correction: join on PRODUCT.CategoryID
SELECT p.ProductName, c.CategoryName
FROM PRODUCT p
JOIN CATEGORY c ON p.CategoryID = c.CategoryID;
