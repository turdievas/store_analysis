create database my_final_project
use my_final_project

USE my_project;

-- Staging Customers
drop table staging_customers
create  TABLE Staging_Customers (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(50),
    address VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(100),
    zipcode VARCHAR(20),
    load_timestamp DATETIME DEFAULT GETDATE()
);

-- Staging Products
CREATE TABLE Staging_Products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT,
    load_timestamp DATETIME DEFAULT GETDATE()
);

-- Staging Orders
drop table staging_orders
CREATE TABLE Staging_Orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    total_amount varchar(20),

);

-- Staging Order Items
drop table staging_order_items
CREATE TABLE Staging_Order_Items (
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price varchar(20),

);

-- Staging Payments
drop table Staging_Payments
CREATE TABLE Staging_Payments (
    payment_id INT,
    order_id INT,
    payment_date DATE,
    amount varchar(20),
    payment_method VARCHAR(50),
    status VARCHAR(20),
);

-- Staging Shipments
drop table Staging_Shipments
CREATE TABLE Staging_Shipments (
    shipment_id INT,
    order_id INT,
    shipment_date DATE,
    delivery_date DATE,
    carrier VARCHAR(50),
    tracking_number VARCHAR(100),
    status VARCHAR(20),
);

-- Staging Reviews
drop table staging_reviews
CREATE TABLE Staging_Reviews (
    review_id INT,
    product_id INT,
    customer_id INT,
    rating INT,
    review_text VARCHAR(500),
    review_date DATE
);

--Bulk insert to staging tables:
-- Customers
BULK INSERT Staging_Customers
FROM 'C:\Users\hp\Desktop\data generation\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Products
BULK INSERT Staging_Products
FROM 'C:\Users\hp\Desktop\data generation\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Orders
BULK INSERT Staging_Orders
FROM 'C:\Users\hp\Desktop\data generation\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


-- Order Items
BULK INSERT Staging_Order_Items
FROM 'C:\Users\hp\Desktop\data generation\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Payments
BULK INSERT Staging_Payments
FROM 'C:\Users\hp\Desktop\data generation\payments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Shipments
BULK INSERT Staging_Shipments
FROM 'C:\Users\hp\Desktop\data generation\shipments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Reviews
BULK INSERT Staging_Reviews
FROM 'C:\Users\hp\Desktop\data generation\reviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--final tables
-- Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(50),
    address VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(100),
    zipcode VARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Products

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);



-- Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(12,2),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order Items
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(12,2),
    payment_method VARCHAR(50),
    status VARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Shipments
CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    shipment_date DATE,
    delivery_date DATE,
    carrier VARCHAR(50),
    tracking_number VARCHAR(100),
    status VARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Reviews
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT,
    review_text VARCHAR(500),
    review_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


-- Customers
INSERT INTO Customers (customer_id, first_name, last_name, email, phone, address, city, state, country, zipcode)
SELECT customer_id, first_name, last_name, email, phone, address, city, state, country, zipcode
FROM Staging_Customers;

-- Products


INSERT INTO Products (product_id, product_name, category, price, stock_quantity, created_at, updated_at)
SELECT DISTINCT
       s.product_id,
       s.product_name,
       s.category,
       CAST(s.price AS DECIMAL(10,2)),
       s.stock_quantity,
       GETDATE(),
       GETDATE()
FROM Staging_Products s
WHERE NOT EXISTS (
    SELECT 1
    FROM Products p
    WHERE p.product_id = s.product_id
);


-- Orders
INSERT INTO Orders (order_id, customer_id, order_date, total_amount)
SELECT order_id, customer_id, order_date, CAST(total_amount AS DECIMAL(12,2))
FROM Staging_Orders;



-- Order Items
INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT order_item_id, order_id, product_id, quantity, CAST(unit_price AS DECIMAL(10,2))
FROM Staging_Order_Items;

-- Payments
INSERT INTO Payments (payment_id, order_id, payment_date, amount, payment_method, status)
SELECT payment_id, order_id, payment_date, CAST(amount AS DECIMAL(12,2)), payment_method, status
FROM Staging_Payments;

-- Shipments
INSERT INTO Shipments (shipment_id, order_id, shipment_date, delivery_date, carrier, tracking_number, status)
SELECT shipment_id, order_id, shipment_date, delivery_date, carrier, tracking_number, status
FROM Staging_Shipments;

-- Reviews
INSERT INTO Reviews (review_id, product_id, customer_id, rating, review_text, review_date)
SELECT review_id, product_id, customer_id, rating, review_text, review_date
FROM Staging_Reviews;










--Views
--1.
create view vw_Sales_Summary_Total_Revenue as
select SUM(quantity*unit_price) as total_revenue
from Order_Items

--2.
create view  vw_Product_Popularity as
select p.product_name, SUM(oi.quantity) as units_sold_per_product from Products as p
join 
Order_Items as oi 
on oi.product_id=p.product_id
join Payments as pay
on oi.order_id=pay.order_id
where pay.status in ('Paid')
group by p.product_name
order by units_sold_per_product desc

--3.
create view vw_Customer_Lifetime_Value as
select c.customer_id, c.first_name , cast(SUM(oi.quantity*oi.unit_price) as decimal(10,2)) as CLV from customers as c
join orders as o 
on c.customer_id=o.customer_id
join Order_Items as oi 
on oi.order_id=o.order_id
join payments as pay 
on pay.order_id=o.order_id
where pay.status in ('Paid')
group by c.customer_id, c.first_name

--Stored proc
--1.
drop procedure sp_place_order
CREATE PROCEDURE sp_Place_Order
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @PaymentMethod VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitPrice DECIMAL(10,2),
            @TotalAmount DECIMAL(12,2),
            @OrderID INT,
            @OrderItemID INT,
            @PaymentID INT;

    SELECT @UnitPrice = price
    FROM Products
    WHERE product_id = @ProductID;

    SET @TotalAmount = @UnitPrice * @Quantity;

    SELECT @OrderID = ISNULL(MAX(order_id), 0) + 1 FROM Orders;

    INSERT INTO Orders (order_id, customer_id, order_date, total_amount, created_at, updated_at)
    VALUES (@OrderID, @CustomerID, GETDATE(), @TotalAmount, GETDATE(), GETDATE());

    SELECT @OrderItemID = ISNULL(MAX(order_item_id), 0) + 1 FROM Order_Items;

    INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at)
    VALUES (@OrderItemID, @OrderID, @ProductID, @Quantity, @UnitPrice, GETDATE(), GETDATE());

    SELECT @PaymentID = ISNULL(MAX(payment_id), 0) + 1 FROM Payments;

    INSERT INTO Payments (payment_id, order_id, payment_date, amount, payment_method, status, created_at, updated_at)
    VALUES (@PaymentID, @OrderID, GETDATE(), @TotalAmount, @PaymentMethod, 'pending', GETDATE(), GETDATE());

    UPDATE Products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductID;

    -- Natijani qaytarish
    SELECT 'Order Placed Successfully' AS Message,
           @OrderID AS OrderID,
           @OrderItemID AS OrderItemID,
           @PaymentID AS PaymentID,
           @TotalAmount AS TotalAmount,
           @UnitPrice AS UnitPrice,
           @Quantity AS Quantity,
           (SELECT stock_quantity FROM Products WHERE product_id = @ProductID) AS RemainingStock;
END;

EXEC sp_Place_Order
    @CustomerID = 1,
    @ProductID = 5,
    @Quantity = 2,
    @PaymentMethod = 'Credit Card';



--2.
CREATE PROCEDURE sp_update_inventory
    @orderid INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.stock_quantity = p.stock_quantity - oi.quantity
    FROM Products p
    INNER JOIN Order_Items oi
        ON p.product_id = oi.product_id
    WHERE oi.order_id = @orderid;

    -- Natijani ko'rsatish
    SELECT p.product_id, p.product_name, p.stock_quantity
    FROM Products p
    INNER JOIN Order_Items oi
        ON p.product_id = oi.product_id
    WHERE oi.order_id = @orderid;
END;



exec sp_update_inventory @orderid = 101;

--Trigger
create trigger trg_update_stock
on order_items
after insert
as
begin
set nocount on;

update p
set p.stock_quantity = p.stock_quantity - i.quantity
from products p
inner join inserted i
on p.product_id = i.product_id;
end;



--Joins and aggregations
--1. MoM --> month over month sales
select year(o.order_date) as order_year,
month(o.order_date) as order_month,
sum(oi.quantity * oi.unit_price) as monthly_revenue,
lag(sum(oi.quantity * oi.unit_price)) over (order by year(o.order_date), month(o.order_date)) as prev_month_revenue,
case 
when lag(sum(oi.quantity * oi.unit_price)) over (order by year(o.order_date), month(o.order_date)) is null then null
else (sum(oi.quantity * oi.unit_price) - lag(sum(oi.quantity * oi.unit_price)) over (order by year(o.order_date), month(o.order_date))) * 100.0 / lag(sum(oi.quantity * oi.unit_price)) over (order by year(o.order_date), month(o.order_date))
end as mom_growth_percent
from orders o
join order_items oi on o.order_id = oi.order_id
join payments p on o.order_id = p.order_id
where p.status = 'Paid'
group by year(o.order_date), month(o.order_date)
order by order_year, order_month;


--2.average order behaviour
select c.customer_id,
c.first_name + ' ' + c.last_name as customer_name,
count(distinct o.order_id) as total_orders,
sum(oi.quantity * oi.unit_price) as total_spent,
cast(sum(oi.quantity * oi.unit_price) * 1.0 / count(distinct o.order_id) as decimal(10,2)) as average_order_value
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join payments p on o.order_id = p.order_id
where p.status = 'Paid'
group by c.customer_id, c.first_name, c.last_name
order by average_order_value desc;

--3. stock below min threshold

select product_id,
product_name,
stock_quantity,
case 
when stock_quantity < 15 then 'Reorder Needed'
else 'No need'
end as reorder_status
from products
order by stock_quantity asc;



--Stored Procedures and Automation
--1. Load data from staging to final
create procedure sp_load_staging_to_final
as
begin
set nocount on;

insert into customers (customer_id, first_name, last_name, email, phone, address, city, state, country, zipcode, created_at, updated_at)
select distinct s.customer_id, s.first_name, s.last_name, s.email, s.phone, s.address, s.city, s.state, s.country, s.zipcode, getdate(), getdate()
from staging_customers s
where not exists (select 1 from customers c where c.customer_id = s.customer_id)

insert into products (product_id, product_name, category, price, stock_quantity, created_at, updated_at)
select distinct s.product_id, s.product_name, s.category, cast(s.price as decimal(10,2)), s.stock_quantity, getdate(), getdate()
from staging_products s
where not exists (select 1 from products p where p.product_id = s.product_id)

insert into orders (order_id, customer_id, order_date, total_amount, created_at, updated_at)
select s.order_id, s.customer_id, s.order_date, cast(s.total_amount as decimal(12,2)), getdate(), getdate()
from staging_orders s
where not exists (select 1 from orders o where o.order_id = s.order_id)

insert into order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at)
select s.order_item_id, s.order_id, s.product_id, s.quantity, cast(s.unit_price as decimal(10,2)), getdate(), getdate()
from staging_order_items s
where not exists (select 1 from order_items oi where oi.order_item_id = s.order_item_id)

insert into payments (payment_id, order_id, payment_date, amount, payment_method, status, created_at, updated_at)
select s.payment_id, s.order_id, s.payment_date, cast(s.amount as decimal(12,2)), s.payment_method, s.status, getdate(), getdate()
from staging_payments s
where not exists (select 1 from payments p where p.payment_id = s.payment_id)

insert into shipments (shipment_id, order_id, shipment_date, delivery_date, carrier, tracking_number, status, created_at, updated_at)
select s.shipment_id, s.order_id, s.shipment_date, s.delivery_date, s.carrier, s.tracking_number, s.status, getdate(), getdate()
from staging_shipments s
where not exists (select 1 from shipments sh where sh.shipment_id = s.shipment_id)

insert into reviews (review_id, product_id, customer_id, rating, review_text, review_date, created_at, updated_at)
select s.review_id, s.product_id, s.customer_id, s.rating, s.review_text, s.review_date, getdate(), getdate()
from staging_reviews s
where not exists (select 1 from reviews r where r.review_id = s.review_id)

end

--2.update inventory after each order

create procedure sp_update_inventory_for_automation
@orderid int
as
begin
set nocount on
update p
set p.stock_quantity = p.stock_quantity - oi.quantity
from products p
inner join order_items oi on p.product_id = oi.product_id
where oi.order_id = @orderid
end



--3. log failed

create table  log_table
(
log_id int identity(1,1) primary key,
table_name varchar(50),
row_data varchar(max),
error_type varchar(50),
log_timestamp datetime default getdate()
)

create procedure sp_log_failed_inserts
as
begin
set nocount on

insert into log_table (table_name, row_data, error_type)
select 'customers', concat(customer_id,',',first_name,',',last_name,',',email), 'duplicate' from staging_customers s
where exists (select 1 from customers c where c.customer_id = s.customer_id)

insert into log_table (table_name, row_data, error_type)
select 'products', concat(product_id,',',product_name,',',category), 'duplicate' from staging_products s
where exists (select 1 from products p where p.product_id = s.product_id)

insert into log_table (table_name, row_data, error_type)
select 'orders', concat(order_id,',',customer_id,',',order_date), 'duplicate' from staging_orders s
where exists (select 1 from orders o where o.order_id = s.order_id)

insert into log_table (table_name, row_data, error_type)
select 'order_items', concat(order_item_id,',',order_id,',',product_id), 'duplicate' from staging_order_items s
where exists (select 1 from order_items oi where oi.order_item_id = s.order_item_id)

insert into log_table (table_name, row_data, error_type)
select 'payments', concat(payment_id,',',order_id,',',amount), 'duplicate' from staging_payments s
where exists (select 1 from payments p where p.payment_id = s.payment_id)

insert into log_table (table_name, row_data, error_type)
select 'shipments', concat(shipment_id,',',order_id,',',tracking_number), 'duplicate' from staging_shipments s
where exists (select 1 from shipments sh where sh.shipment_id = s.shipment_id)

insert into log_table (table_name, row_data, error_type)
select 'reviews', concat(review_id,',',product_id,',',customer_id), 'duplicate' from staging_reviews s
where exists (select 1 from reviews r where r.review_id = s.review_id)

end
--1.
exec sp_load_staging_to_final;
--2.
exec sp_update_inventory_for_automation @orderid = 101;
--3.
exec sp_log_failed_inserts;


SELECT @@VERSION;
SELECT SERVERPROPERTY('Edition') AS Edition, 
       SERVERPROPERTY('ProductLevel') AS ProductLevel,
       SERVERPROPERTY('EngineEdition') AS EngineEdition;
