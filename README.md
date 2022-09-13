# SQLChallenge
Repository of SQL practice codes

--What is the total amount each customer spent at the restaurant?

SELECT 
  customer_id
, SUM (price)
FROM sales
JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY customer_id

--How many days has each customer visited the restaurant?
SELECT 
customer_id
, COUNT(DISTINCT order_date) as days
FROM sales
GROUP BY customer_id
