-- =====================================================================
-- CS 3700 - Lab 04: SQL and Normalized Databases
-- Student Name: Utsav Acharya
-- Date: November 1, 2026
-- Database Engine: MariaDB / MySQL
-- =====================================================================

-- =====================================================================
-- PART 2: DDL - CREATING THE DATABASE & CONSTRAINTS
-- =====================================================================

CREATE DATABASE IF NOT EXISTS OnlineRetailStore;
USE OnlineRetailStore;

-- Create Tables with Primary Keys, Foreign Keys, and CHECK Constraints
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

-- Alter Tables for Phone Number and UNIQUE Email
ALTER TABLE CUSTOMER ADD COLUMN Phone VARCHAR(20);
ALTER TABLE CUSTOMER ADD CONSTRAINT UQ_Customer_Email UNIQUE (Email);

-- Part 2 Testing Challenge: Attempting invalid FK reference (CategoryID 99)
-- Expected Result: Fails with ERROR 1452 (23000) Foreign Key Constraint Violation
-- INSERT INTO PRODUCT (ProductName, Price, StockQuantity, CategoryID) VALUES ('Test Item', 10.00, 5, 99);


-- =====================================================================
-- PART 3A: DML - DATA CREATION (SAMPLE & INDIVIDUALIZED DATA)
-- =====================================================================

-- Insert Sample Categories
INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES
(10, 'Electronics'),
(20, 'Clothing'),
(30, 'Home & Kitchen');

-- Insert Sample Customers
INSERT INTO CUSTOMER (CustomerID, CustomerName, Email, Phone) VALUES
(101, 'Alice Carter', 'alice@example.com', '555-0101'),
(102, 'Brian Lee', 'brian@example.com', '555-0102'),
(103, 'Sarah Wilson', 'sarah@example.com', '555-0103'),
(104, 'David Brown', 'david@example.com', '555-0104'),
(105, 'Emma Davis', 'emma@example.com', '555-0105');

-- Insert Sample Products
INSERT INTO PRODUCT (ProductID, ProductName, Price, StockQuantity, CategoryID) VALUES
(201, 'Wireless Mouse', 25.99, 50, 10),
(202, 'Keyboard', 49.99, 30, 10),
(203, 'T-Shirt', 19.99, 100, 20),
(204, 'Coffee Maker', 89.99, 15, 30),
(205, 'Headphones', 59.99, 25, 10);

-- Insert Sample Orders
INSERT INTO CUSTOMER_ORDER (OrderID, CustomerID, OrderDate, Status) VALUES
(301, 101, '2026-09-01', 'Delivered'),
(302, 102, '2026-09-02', 'Shipped'),
(303, 101, '2026-09-05', 'Pending'),
(304, 103, '2026-09-06', 'Delivered'),
(305, 104, '2026-09-08', 'Pending');

-- Insert Sample Order Items
INSERT INTO ORDER_ITEM (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(401, 301, 201, 2, 25.99),
(402, 301, 202, 1, 49.99),
(403, 302, 203, 3, 19.99),
(404, 303, 205, 1, 59.99),
(405, 304, 204, 1, 89.99),
(406, 305, 201, 1, 25.99);

-- Insert Custom Individualized Dataset
INSERT INTO CUSTOMER (CustomerID, CustomerName, Email, Phone) VALUES
(106, 'Marcus Vance', 'marcus.v@example.com', '555-0106'),
(107, 'Jessica Taylor', 'jessica.t@example.com', '555-0107'),
(108, 'Kevin Smith', 'kevin.s@example.com', '555-0108');

INSERT INTO PRODUCT (ProductID, ProductName, Price, StockQuantity, CategoryID) VALUES
(206, 'Bluetooth Speaker', 45.50, 40, 10),
(207, 'Smartwatch', 199.99, 20, 10),
(208, 'Denim Jeans', 39.99, 60, 20),
(209, 'Winter Jacket', 79.99, 25, 20);

INSERT INTO CUSTOMER_ORDER (OrderID, CustomerID, OrderDate, Status) VALUES
(306, 106, '2026-09-10', 'Pending'),
(307, 107, '2026-09-11', 'Delivered'),
(308, 106, '2026-09-12', 'Shipped');

INSERT INTO ORDER_ITEM (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(407, 306, 206, 2, 24.99),
(408, 306, 209, 1, 14.99),
(409, 307, 207, 1, 39.99),
(410, 308, 208, 1, 79.99),
(411, 308, 209, 2, 14.99);


-- =====================================================================
-- PART 3B: SELECT - WHERE AND JOIN QUERIES
-- =====================================================================

-- 1. Display all products with their category names
SELECT p.ProductName, c.CategoryName
FROM PRODUCT p
JOIN CATEGORY c ON p.CategoryID = c.CategoryID;

-- 2. Display customer names, order dates, and order statuses for all pending orders
SELECT cu.CustomerName, co.OrderDate, co.Status
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
WHERE co.Status = 'Pending';

-- 3. Find all products purchased by Alice Carter
SELECT DISTINCT p.ProductName
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID
WHERE cu.CustomerName = 'Alice Carter';

-- 4. Display products costing more than $50 with fewer than 30 units in stock
SELECT ProductName, Price, StockQuantity
FROM PRODUCT
WHERE Price > 50 AND StockQuantity < 30;

-- 5. Display customer name, order ID, product name, quantity, and purchase price for each ordered item
SELECT cu.CustomerName, co.OrderID, p.ProductName, oi.Quantity, oi.UnitPrice
FROM CUSTOMER cu
JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID;

-- 6. Display all customers, including those who have never placed an order
SELECT cu.CustomerName, co.OrderID, co.OrderDate, co.Status
FROM CUSTOMER cu
LEFT JOIN CUSTOMER_ORDER co ON cu.CustomerID = co.CustomerID;

-- 7. Retrieve a specific product from individualized dataset using WHERE
SELECT *
FROM PRODUCT
WHERE ProductName = 'Smartwatch';


-- =====================================================================
-- PART 3C: UPDATE AND DELETE OPERATIONS
-- =====================================================================

-- 1. Increase the price of Wireless Mouse by 10%
UPDATE PRODUCT
SET Price = Price * 1.10
WHERE ProductName = 'Wireless Mouse';

-- 2. Change OrderID 303's status from Pending to Shipped
UPDATE CUSTOMER_ORDER
SET Status = 'Shipped'
WHERE OrderID = 303;

-- 3. Update stock quantity of custom product (ProductID 206)
UPDATE PRODUCT
SET StockQuantity = 45
WHERE ProductID = 206;

-- 4. Delete one ORDER_ITEM record created (OrderItemID 411)
DELETE FROM ORDER_ITEM
WHERE OrderItemID = 411;


-- =====================================================================
-- PART 4: SQL DEBUGGING AND CORRECTIONS
-- =====================================================================

-- Query A Correction:
SELECT c.CustomerName, p.ProductName
FROM CUSTOMER c
JOIN CUSTOMER_ORDER co ON c.CustomerID = co.CustomerID
JOIN ORDER_ITEM oi ON co.OrderID = oi.OrderID
JOIN PRODUCT p ON oi.ProductID = p.ProductID;

-- Query B Correction:
UPDATE PRODUCT
SET Price = 10.00
WHERE ProductName = 'Wireless Mouse';

-- Query C Correction:
SELECT p.ProductName, c.CategoryName
FROM PRODUCT p
JOIN CATEGORY c ON p.CategoryID = c.CategoryID;