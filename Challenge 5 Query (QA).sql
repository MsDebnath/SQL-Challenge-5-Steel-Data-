/*1. How many pubs are located in each country??*/

SELECT country, COUNT(DISTINCT pub_name) AS pubs_count
FROM pubs
GROUP BY country;

/*2. What is the total sales amount for each pub, including the beverage price and quantity sold?*/

SELECT p.pub_name,
	SUM(b.price_per_unit * s.quantity) AS total_sales
FROM sales s 
	INNER JOIN pubs p USING(pub_id)
	INNER JOIN beverages b USING(beverage_id)
GROUP BY p.pub_name;

/*3. Which pub has the highest average rating?*/

SELECT p.pub_name,
	ROUND(AVG(r.rating),2) AS highest_average_rating
FROM ratings r
	INNER JOIN pubs p USING(pub_id)
GROUP BY p.pub_name
ORDER BY AVG(r.rating) DESC
LIMIT 1;

/*4. What are the top 5 beverages by sales quantity across all pubs?*/

SELECT b.beverage_name,
	SUM(s.quantity) AS total_quantity
FROM sales s
	INNER JOIN beverages b USING(beverage_id)
GROUP BY b.beverage_name
ORDER BY SUM(s.quantity) DESC
LIMIT 5;

/*5. How many sales transactions occurred on each date?*/

SELECT transaction_date, 
	COUNT(*) AS Number_of_sales
FROM sales
GROUP BY transaction_date;

/*6. Find the name of someone that had cocktails and which pub they had it in.*/

SELECT r.customer_name, p.pub_name
FROM sales s
	JOIN ratings r USING(pub_id)
    JOIN pubs p USING(pub_id)
	JOIN beverages b USING(beverage_id)
WHERE b.category = "Cocktail";

/*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?*/

SELECT category, 
	ROUND(AVG(price_per_unit),2) AS average_price
FROM beverages
WHERE NOT category = 'Spirit'
GROUP BY category
ORDER BY ROUND(AVG(price_per_unit),2) DESC;

/*8. Which pubs have a rating higher than the average rating of all pubs?*/

WITH CTE AS (
	SELECT pub_id, rating,
    ROUND(AVG(rating) OVER (PARTITION BY pub_id),1) AS avg_rating
    FROM ratings
    GROUP BY pub_id, rating)
SELECT c.pub_id AS Pub_id,
	p.pub_name AS Pub_name,
    c.rating AS Rating,
    c.avg_rating AS Avg_rating
FROM CTE c 
	INNER JOIN pubs p USING(pub_id)
WHERE c.rating > c.avg_rating;


/*9. What is the running total of sales amount for each pub, ordered by the transaction date?*/

SELECT s.transaction_date, p.pub_name,
	SUM(b.price_per_unit*s.quantity) OVER (PARTITION BY p.pub_id ORDER BY s.transaction_date) AS running_total
FROM sales s
	JOIN pubs p USING(pub_id)
    JOIN beverages b USING(beverage_id)
ORDER BY s.transaction_date;
    
/*10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?*/

WITH ap AS (
	SELECT p.country, b.category,
		ROUND(AVG(b.price_per_unit),2) AS average_price
    FROM sales s
		JOIN pubs p USING(pub_id)
        JOIN beverages b USING(beverage_id)
	GROUP BY p.country, b.category),
	oap AS (
    SELECT p.country,
		ROUND(AVG(b.price_per_unit),2) AS Overall_average_price
	FROM sales s
		JOIN pubs p USING(pub_id)
        JOIN beverages b USING(beverage_id)
	GROUP BY p.country)
SELECT  a.country AS country, a.category AS category,
	a.average_price AS Per_unit_avg_price, b.overall_average_price AS overall_average_price
FROM ap a 
	JOIN oap b USING(country);
    
/*11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?*/

WITH A AS (
	SELECT p.pub_id, p.pub_name, b.category,
		SUM(b.price_per_unit*s.quantity) AS TS
    FROM sales s
		JOIN pubs p USING(pub_id)
        JOIN beverages b USING(beverage_id)
	GROUP BY p.pub_id, p.pub_name, b.category),
	B AS (
    SELECT *,
		SUM(TS) OVER (PARTITION BY pub_name) AS TSO
    FROM A)
SELECT pub_id, pub_name, category, TS, 
	ROUND(((TS/TSO)*100),2) AS Cotribution_percentage
FROM B
ORDER BY pub_id;

    
