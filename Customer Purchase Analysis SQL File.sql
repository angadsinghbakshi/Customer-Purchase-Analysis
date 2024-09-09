create database Project1;
use Project1;

# Checking Duplicate CustomerIDS

select customerid, count(*) from customer_purchase_data
group by 1
having count(*) >1;

# As we can oberve there are multiple customers with the same customerID and Different Customer Names
# Hence we have to give unique cutomerID to each Customer
# Using Window Function to give Unique Customer IDs so it can be used as Primary Key in Customers Table later

select * from customer_purchase_data;
select *, row_number() over (order by customerid) + 99 as customer_id from customer_purchase_data;

# Creating a duplicte table of the original customer_purchase_data table

create table purchase_data as 
select *, row_number() over (order by customerid) + 99 as customer_id from customer_purchase_data;

select * from purchase_data;

# Dropping the CustomerID column with Duplicate CustomerIDs

alter table purchase_data
drop column customerid;

select * from purchase_data;

# Splitting the Customers Name into Firstname and Lastname

select customername,
substring_index(customername, ' ', 1) AS firstname,
substring_index(customername, ' ', -1) AS lastname
from
purchase_data;

# Adding the Firstname and Lastname columns to the purchase_data table

alter table purchase_data
add column firstname varchar(255),
add column lastname varchar(255);

select * from purchase_data;

# Adding data into the Firstname and Lastname column in the purchase_data table

update purchase_data
set 
firstname = substring_index(customername, ' ', 1),
lastname = substring_index(customername,' ', -1);

# Dropping the Customer Name column in purchase_data table

alter table purchase_data
drop column customername;

select * from purchase_data;



# ----------------------------------------------------- CREATING NEW TABLES ----------------------------------------------------

# -----------------------CUSTOMERS TABLE------------------------------------

# Creating Customers table with Customer ID (Primary Key), First Name, Last Name and Country

create table customers(
customerid int primary key,
firstname varchar(255),
lastname varchar(255),
country varchar(255)
);

select * from customers;

# Inserting values from purchase_data Table into Customers Table

insert into customers (customerid, firstname, lastname, country)
select customer_id, firstname, lastname, country
from purchase_data;

select * from customers;



# ------------------------CATEGORY TABLE--------------------------------

# Creating Category table with Category Name and Category ID (Primary Key)

select distinct productcategory from purchase_data;

# As we can observe there are only two Product Categories (Home Appliances and Electronics)

create table category(
categoryid int primary key,
categoryname varchar(255)
);

# Manually inserting values for the two avaliable categories (1001 as Home Appliances and 1002 as Electronics)

insert into category
values(1001, 'Home Appliances'),
(1002,'Electronics');

select * from category;

# Adding a Product Category Column in the purchase_data table which will be added later into the Products Table

alter table purchase_data
add column productcategoryid int;

select * from purchase_data;

# Inserting values into the productcategoryid column in purchase_data table

update purchase_data
set productcategoryid = 
case
when productcategory = "Home Appliances" then 1001
when productcategory = "Electronics" then 1002
end;

select * from purchase_data;

# ------------------------ PRODUCTS TABLE-----------------------------------

# Cheking for Duplicate values in the Product ID column

select ProductID, count(*) from customer_purchase_data
group by 1
having count(*) >1;

# We can observe that there are multiple products with the same Product ID
# Creating a duplicate table of purcase_data table for distinct Product ID so it can be used as Primary Key in the Products Table

create table purchase_data_2
select *, row_number() over (order by productid) +199 as product_id from purchase_data
order by PurchaseDate;

select * from purchase_data_2;

# Dropping the Product ID column with Duplicate IDs

alter table purchase_data_2
drop column productid;

select * from purchase_data_2;

# Creating Products Table with Product ID (Primary Key), Product Name,
# Category ID (Foreign Key reference to Category Table) and Sale Price columns

create table products(
productid int primary key,
productname varchar(255),
categoryid int,
saleprice double,
foreign key(categoryid) references category(categoryid)
);

# Inserting data into Products Table from purchase_data_2

insert into products(productid, productname, saleprice,categoryid)
select product_id, productname,PurchasePrice, productcategoryid 
from purchase_data_2;

select * from products;

# Checking the working of Foreign Key by Joining the Products and Category Table

select * from products p
join category c
on p.categoryid = c.categoryid
order by productid;

#------------------------ORDERS TABLE------------------------------

# Creating Orders Table with Order ID (Primary Key), Product ID (Foreign Key reference to Products Table),
# CustomerID (Foreign Key reference to Customers Table), Total Order Amount

create table orders(
orderid int primary key,
customerid int,
orderdate date,
totalorderamount double,
foreign key(customerid) references customers(customerid)
);

# Inserting data into Orders Table from purchase_data_2 Table

insert into orders(orderid, customerid, orderdate, totalorderamount)
select transactionid, customer_id, purchasedate, PurchasePrice
from purchase_data_2;

select * from orders;

# --------------------ORDERDETAILS TABLE-------------------------

# Creating Orderdetails table with Orderdetail ID (Primary Key), Order ID (Foreign Key reference to Orders Table)
# Product ID (Reference to Products Table) and Quantity

select * from purchase_data_2;

create table orderdetails(
orderdetailid int auto_increment primary key,
orderid int,
productid int,
quantity int,
foreign key(orderid) references orders(orderid),
foreign key(productid) references products(productid)
);

# Inserting data into Orders Table from purchase_data_2 table

insert into orderdetails(orderid, productid, quantity)
select transactionid, product_id, purchasequantity from purchase_data_2;


select * from customers;
select * from orders;
select * from products;
select * from category;
select * from orderdetails;
