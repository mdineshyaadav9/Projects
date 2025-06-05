use orders;

-- 1
SELECT PRODUCT_CLASS_CODE AS 'Product Catagory',
 PRODUCT_ID AS 'Product ID',
PRODUCT_DESC AS 'Product Description',
PRODUCT_PRICE AS 'Actual Price',
CASE PRODUCT_CLASS_CODE
WHEN 2050 THEN PRODUCT_PRICE+2000 -- Increase Price for Category 2050
WHEN 2051 THEN PRODUCT_PRICE+500 -- Increase Price for Category 2051
WHEN 2052 THEN PRODUCT_PRICE+600 -- Increase Price for Category 2052
ELSE PRODUCT_PRICE
END AS 'Calculated Price'
FROM PRODUCT
-- Decending order by category(Product Class Code)
ORDER BY PRODUCT_CLASS_CODE DESC;


-- 2
SELECT PC.PRODUCT_CLASS_DESC AS 'Product Category',
P.PRODUCT_ID AS 'Product ID',
P.PRODUCT_DESC AS 'Product Description',
P.PRODUCT_QUANTITY_AVAIL AS 'Product Availability',
CASE
-- Electronics(2050) and Computer (2053)
WHEN PC.PRODUCT_CLASS_CODE IN (2050,2053) THEN
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' -- Out of stock criteria
WHEN P.PRODUCT_QUANTITY_AVAIL <=10 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL >=11 AND P.PRODUCT_QUANTITY_AVAIL <=30) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL >=31) THEN 'Enough stock'
END
-- Stationery(2052) and Clothes(2056)
WHEN PC.PRODUCT_CLASS_CODE IN (2052,2056) THEN
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' -- Out of stock criteria
WHEN P.PRODUCT_QUANTITY_AVAIL <=20 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL >=21 AND P.PRODUCT_QUANTITY_AVAIL <=80) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL >=81) THEN 'Enough stock'
END
-- Rest of the categories
ELSE
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' -- Out of stock criteria
WHEN P.PRODUCT_QUANTITY_AVAIL <=15 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL >=16 AND P.PRODUCT_QUANTITY_AVAIL <=50) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL >=51) THEN 'Enough stock'
END
END AS 'Inventory Status'
FROM PRODUCT P
-- Join the Product and Product Class TABLE based on the Product Class Code
INNER JOIN PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
-- Let’s do order by Product Class Code and available quantity by descending
ORDER BY P.PRODUCT_CLASS_CODE,P.PRODUCT_QUANTITY_AVAIL DESC;


-- 3 
SELECT COUNT(CITY) AS Count_of_Cites, -- Count Of The Cities
COUNTRY AS Country
 FROM ADDRESS
 GROUP BY COUNTRY
-- Count of cities more than 1 and exclude the USA and Malaysia
 HAVING COUNTRY NOT IN ('USA','Malaysia') AND COUNT(CITY) > 1
-- Descending order of count of cities
ORDER BY Count_of_Cites DESC;


-- 4
SELECT OC.CUSTOMER_ID AS 'Customer ID',
OC.CUSTOMER_FNAME || ' ' || OC.CUSTOMER_LNAME AS 'Customer Full Name' ,
A.CITY AS 'City',
A.PINCODE AS 'Pin Code',
OH.ORDER_ID AS 'Order Id',
 PC.PRODUCT_CLASS_DESC AS 'Product Class Description',
 P.PRODUCT_DESC AS 'Product Description',
P.PRODUCT_PRICE AS 'Product Price',
OI.PRODUCT_QUANTITY AS 'Product Order Quantity',
(P.PRODUCT_PRICE * OI.PRODUCT_QUANTITY) AS Sub_Total -- Calculated value Total Price
FROM
ONLINE_CUSTOMER OC
INNER JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID -- Join the Address table to fetch the City and Pincode details.
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
 INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID -- For Product Order Quantity
 INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID -- For Product Price
INNER JOIN PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE -- For Product Class Description
-- Filter the data which is shipped and Pin code does not have value 0.
WHERE OH.ORDER_STATUS='Shipped' AND A.PINCODE NOT LIKE '%0%'
-- Order by customer name and subtotal.
ORDER BY OC.CUSTOMER_FNAME, Sub_Total;


-- 5
SELECT OI.PRODUCT_ID AS Product_ID, -- 2. Look for other product_id that are brought along with product_id 201
P.PRODUCT_DESC AS Product_Description, -- 4. Get the Product Description from Product Table
SUM(OI.PRODUCT_QUANTITY) AS Total_Quantity-- 3. Total quantity(sum(product quantity) for each product_id that was brought along with product_id 201
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID -- Join the Product Table to fetch the description
WHERE OI.ORDER_ID IN
( -- 1. Pull out all the orders that have the product_id 201
SELECT DISTINCT
ORDER_ID
FROM
ORDER_ITEMS A
WHERE
PRODUCT_ID = 201
)
AND OI.PRODUCT_ID <> 201
GROUP BY OI.PRODUCT_ID
ORDER BY Total_Quantity DESC -- 5. Sort by Total_Quantity on descending
LIMIT 1; -- 6. Show the first row


-- 6
SELECT
OC.CUSTOMER_ID AS Customer_ID,
(OC.CUSTOMER_FNAME ||' '|| OC.CUSTOMER_LNAME) AS Customer_Full_Name,
OC.CUSTOMER_EMAIL AS Customer_Email,
O.ORDER_ID AS Order_ID,
P.PRODUCT_DESC AS Product_Description,
 OI.PRODUCT_QUANTITY AS Purchase_Quantity,
P.PRODUCT_PRICE AS Product_Price,
(OI.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS Subtotal -- Calulated value Total Price
FROM
ONLINE_CUSTOMER OC
LEFT JOIN ORDER_HEADER O ON OC.CUSTOMER_ID = O.CUSTOMER_ID -- Join the Order header to fetch the order id and connect product and customer
LEFT JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID -- For Prodcut Quantity
LEFT JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID -- For Product Price
ORDER BY Customer_ID,Purchase_Quantity DESC; -- Lets Order by Customer_ID and Purchase_Quantity


-- 7
SELECT C.CARTON_ID AS Carton_ID,
 (C.LEN*C.WIDTH*C.HEIGHT) as Carton_Volume
FROM ORDERS.CARTON C
WHERE (C.LEN*C.WIDTH*C.HEIGHT) >= (
-- Subquery to take volume details from both Order_items and Product tables.
SELECT SUM(P.LEN*P.WIDTH*P.HEIGHT*OI.PRODUCT_QUANTITY) AS VOL -- Optimum carton value
 FROM
ORDERS.ORDER_ITEMS OI
INNER JOIN ORDERS.PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID -- Join to get the LEN, WIDTH and HEIGHT
WHERE OI.ORDER_ID =10006 )
ORDER BY (C.LEN*C.WIDTH*C.HEIGHT) ASC
LIMIT 1;
# Order by descending will arrange the outcome in decreasing order of Product of Len*Wodth*Height, and Limit 1 will display only 1 record


-- 8
SELECT OC.CUSTOMER_ID AS Customer_ID,
CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS Customer_FullName,
OH.ORDER_ID AS Order_ID,
 SUM(OI.PRODUCT_QUANTITY) AS Total_Order_Quantity
FROM ONLINE_CUSTOMER OC
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID -- To connect the Order and Customer details.
INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID -- To fetch the Product Quantity.
WHERE OH.ORDER_STATUS = 'Shipped' -- To check for order_status whether it is shipped.
GROUP BY OH.ORDER_ID
HAVING Total_Order_Quantity > 10 -- To check the Total Order Quality is greater than 10.
ORDER BY CUSTOMER_ID;


-- 9
SELECT
OC.CUSTOMER_ID AS Customer_ID,
CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS Customer_FullName,
 OH.ORDER_ID AS Order_ID,
SUM(OI.PRODUCT_QUANTITY) AS Total_Order_Quantity
FROM ONLINE_CUSTOMER OC
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID -- To connect the Order and Customer details.
INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID -- To fetch the Product Quantity.
WHERE OH.ORDER_STATUS = 'Shipped' AND OH.ORDER_ID > 10060 -- To check for order_status whether it is shipped.
GROUP BY OH.ORDER_ID
ORDER BY Customer_FullName;


-- 10
SELECT PC.PRODUCT_CLASS_CODE AS Product_Class_Code,
PC.PRODUCT_CLASS_DESC AS Product_Class_Description,
SUM(OI.PRODUCT_QUANTITY) AS Total_Quantity,
SUM(OI.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS Total_Value
FROM ORDER_ITEMS OI
INNER JOIN ORDER_HEADER OH ON OH.ORDER_ID = OI.ORDER_ID -- Join to connect Online Customer
INNER JOIN ONLINE_CUSTOMER OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID
INNER JOIN PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
INNER JOIN ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID -- To retrive the country details.
WHERE OH.ORDER_STATUS ='Shipped' AND A.COUNTRY NOT IN('India','USA') # Order status as Shipped & country without India and USA.
GROUP BY PC.PRODUCT_CLASS_CODE,PC.PRODUCT_CLASS_DESC
ORDER BY Total_Quantity DESC -- Order by Total_Quatity
LIMIT 1;
