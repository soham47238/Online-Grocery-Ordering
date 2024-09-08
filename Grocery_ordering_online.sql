create database online_grocery_ordering_system;

use online_grocery_ordering_system;

-- User Story 1: Login Table
CREATE TABLE Login (
    customer_id INT NOT NULL,
    last_login DATETIME NOT NULL,
    last_logout DATETIME NOT NULL,
    updated_password VARCHAR(255) NOT NULL,
    old_password VARCHAR(255) NOT NULL,
    is_now_logged_in CHAR(1) NOT NULL CHECK (is_now_logged_in IN ('Y', 'N')),
    PRIMARY KEY (customer_id)
);

INSERT INTO Login (customer_id, last_login, last_logout, updated_password, old_password, is_now_logged_in) VALUES
(1, '2024-09-01 08:00:00', '2024-09-01 12:00:00', 'newPass123', 'oldPass123', 'Y'),
(2, '2024-09-01 09:00:00', '2024-09-01 11:00:00', 'newPass456', 'oldPass456', 'N'),
(3, '2024-09-01 10:00:00', '2024-09-01 11:30:00', 'newPass789', 'oldPass789', 'Y'),
(4, '2024-09-01 07:00:00', '2024-09-01 09:00:00', 'newPass101', 'oldPass101', 'Y');


-- User Story 2: Registration Table
CREATE TABLE Registration (
    customer_id INT PRIMARY KEY NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact_number BIGINT NOT NULL
);

INSERT INTO Registration (customer_id, customer_name, email, password, address, contact_number) VALUES
(1, 'Bharat', 'bharat@example.com', 'bharatPass', 'US, New York', 1234567890),
(2, 'Harish', 'harish@example.com', 'harishPass', 'India, Kolkata', 2345678901),
(3, 'Aryabhatt', 'aryabhatt@example.com', 'aryabhattPass', 'Canada, Toronto', 3456789012),
(4, 'Kanisk', 'kanisk@example.com', 'kaniskPass', 'US, California', 4567890123);


-- User Story 3: Product Table
CREATE TABLE Product (
    product_id INT PRIMARY KEY NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price INT NOT NULL,
    quantity INT NOT NULL,
    reserved VARCHAR(255) NOT NULL CHECK (reserved IN ('Reserved', 'Not Reserved')),
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Registration(customer_id)
);

INSERT INTO Product (product_id, product_name, price, quantity, reserved, customer_id) VALUES
(101, 'Laptop', 1000, 10, 'Reserved', 1),
(102, 'Smartphone', 500, 5, 'Not Reserved', 2),
(103, 'Tablet', 300, 7, 'Reserved', 3),
(104, 'Monitor', 200, 3, 'Not Reserved', 4);


-- User Story 4: Transaction Table
CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    total_amount INT NOT NULL,
    number_of_items INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Registration(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Transaction (transaction_id, customer_id, product_id, total_amount, number_of_items) VALUES
(1001, 1, 101, 1000, 1),
(1002, 2, 102, 500, 1),
(1003, 3, 103, 600, 2),
(1004, 4, 104, 400, 2);


-- User Story 5: Admin Table
CREATE TABLE Admin (
    admin_id INT PRIMARY KEY NOT NULL,
    admin_password VARCHAR(255) NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    transaction_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Registration(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (transaction_id) REFERENCES Transaction(transaction_id)
);


INSERT INTO Admin (admin_id, admin_password, customer_id, product_id, transaction_id) VALUES
(501, 'adminPass1', 1, 101, 1001),
(502, 'adminPass2', 2, 102, 1002),
(503, 'adminPass3', 3, 103, 1003),
(504, 'adminPass4', 4, 104, 1004);



-- User story 1 implementation : Generate a report with the first 50% logged-in customer IDs.

SET @total_logged_in =  (SELECT count(*) from Login WHERE is_now_logged_in = 'Y');
SET @half_logged_in = Ceil(@total_logged_in/2);
SET @query = CONCAT('SELECT customer_id, last_login, last_logout, is_now_logged_in FROM Login WHERE is_now_logged_in = "Y" LIMIT ', @half_logged_in);
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- User story 2 implementation : Update customer names based on their residency.
-- If INDIA is address the name -> IN_Name
-- If US is address the name -> US_Name (Basically Concatination)
UPDATE Registration
SET customer_name = CASE 
                      WHEN address LIKE '%US%' THEN CONCAT('US_', customer_name)
                      WHEN address LIKE '%India%' THEN CONCAT('IN_', customer_name)
                      ELSE customer_name
                    END;

SELECT customer_id, customer_name, address 
FROM Registration;


-- User story 3 implementation : 
-- Report 1: Generate reports for distinct products 
-- Report 2: customer-product mapping.

SELECT DISTINCT product_name 
FROM Product;

SELECT customer_id, product_name
FROM Product
ORDER BY customer_id;


-- User story 4 implementation : 
-- Report 1: Generate a report of all sorted transactions 
-- Report 2: Show the second highest transaction by total amount.

SELECT * 
FROM Transaction
ORDER BY total_amount DESC;

SELECT * 
FROM Transaction
ORDER BY total_amount DESC
LIMIT 1 OFFSET 1;



-- User story 5 implementation : Generate a report of all customers whose orders have been successfully placed.
SELECT Registration.customer_name, Admin.transaction_id, Product.product_name
FROM Admin
JOIN Registration ON Admin.customer_id = Registration.customer_id
JOIN Product ON Admin.product_id = Product.product_id
JOIN Transaction ON Admin.transaction_id = Transaction.transaction_id;




