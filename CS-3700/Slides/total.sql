SELECT p.product_name, COUNT(p.product_name) AS total 
FROM orders o 
JOIN customer c ON o.customer_id_fk = c.customer_id 
JOIN product p ON o.product_id_fk = p.product_id 
WHERE c.customer_name = 'Wright State University' 
GROUP BY p.product_name;
