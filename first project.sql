--project
/*Task1: Create a list of all the different (distinct) replacement costs of the films.
Question: Whats the lowest replacement cost?*/

SELECT DISTINCT replacement_cost
FROM film
ORDER BY replacement_cost ASC;

/*Task2: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
Question: How many films have a replacement cost in the "low" group?*/

SELECT COUNT(replacement_cost), 
CASE
WHEN replacement_cost <=19.99 THEN 'low'
WHEN replacement_cost <=24.99 THEN 'medium'
ELSE 'high'
END AS replacement_price
FROM film
GROUP BY replacement_price;


/*Task3: Create a list of the film titles including their title, length and category name ordered descendingly by the length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
Question: In which category is the longest film and how long is it?*/

SELECT title, name,length FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id=fc.film_id
INNER JOIN category c
ON fc.category_id= c.category_id
WHERE name LIKE '%Drama%' OR name LIKE '%Sports%'
ORDER BY length DESC;

/*Task4: Create an overview of how many movies (titles) there are in each category (name).
Question: Which category (name) is the most common among the films?*/

SELECT name,COUNT(title) FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id=fc.film_id
INNER JOIN category c
ON fc.category_id= c.category_id
GROUP BY name
ORDER BY COUNT(title) DESC;

--5
/*Task5: Create an overview of the actors first and last names and in  how many movies they appear.
Question: Which actor is part of most movies??*/

SELECT first_name,last_name, COUNT(title) FROM actor AS a
INNER JOIN film_actor AS fa
ON a.actor_id=fa.actor_id
INNER JOIN film f
ON fa.film_id= f.film_id
GROUP BY  first_name,last_name
ORDER BY COUNT(title) DESC;

/*Task6: Create an overview of the addresses that are not associated to any customer.
Question: How many addresses are that?*/

SELECT COUNT(address) FROM address a
LEFT JOIN  customer c
ON a.address_id = c.address_id
WHERE customer_id IS null;

/*Task7: Create an overview of the cities and how much sales (sum of amount) have occured there.
Question: Which city has the most sales?*/

SELECT city,SUM(amount) AS sales FROM  customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
INNER JOIN address a
ON a.address_id = c.address_id
INNER JOIN city ci
ON ci.city_id = a.city_id
GROUP BY city
ORDER BY sales DESC;

/*Task8: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
Question: Which country, city has the least sales?*/

SELECT country,city,SUM(amount) AS sales FROM  customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
INNER JOIN address a
ON a.address_id = c.address_id
INNER JOIN city ci
ON ci.city_id = a.city_id
INNER JOIN country co
ON co.country_id = ci.country_id
GROUP BY country, city
ORDER BY sales ASC;

/*Task9: Create a list with the average of the sales amount each staff_id has per customer.
Question: Which staff_id makes in average more revenue per customer?*/

SELECT staff_id, ROUND(AVG(revenue),2) AS avg_revenue
FROM 
(SELECT staff_id, customer_id, sum(amount) AS revenue FROM payment
 GROUP BY  staff_id, customer_id) a
GROUP BY staff_id;

/*Task10: Create a query that shows average daily revenue of all Sundays.
Question: What is the daily average revenue of all Sundays?*/

SELECT ROUND(AVG(revenue),2) AS daily_avg_revenue
FROM 
(SELECT SUM(amount) AS revenue,
 DATE(payment_date), EXTRACT(DOW from payment_date) as weekday
FROM payment
WHERE EXTRACT(DOW from payment_date) = 0
GROUP BY DATE(payment_date),weekday) b;

/*Task11: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group.
Question: Which two movies are the shortest in that list and how long are they?*/

SELECT title, length, replacement_cost 
FROM film f1
WHERE length > (SELECT ROUND(AVG(length),2)FROM film f2
			   WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY length ASC;


/*Task12: Create a list that shows how much the average customer spent in total (customer life-time value) grouped by the different districts.
Question: Which district has the highest average customer life-time value?*/

SELECT district, ROUND(AVG(revenue),2) AS customer_life_time_value
FROM (SELECT district,c.customer_id, SUM(amount) AS revenue FROM  customer c
	  INNER JOIN payment p
	  ON p.customer_id = c.customer_id
	  INNER JOIN address a
	  on c.address_id = a.address_id
	 GROUP BY  district,c.customer_id) c
GROUP BY district
ORDER BY customer_life_time_value DESC;

/*Task: Create a list that shows all payments including the payment_id, amount and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.
Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?*/

    SELECT payment_id,name,amount,
    (SELECT SUM(amount) AS revenue FROM payment p
	INNER JOIN rental r
	ON p.rental_id=r.rental_id
	INNER JOIN inventory i
	ON r.inventory_id=i.inventory_id
	INNER JOIN film f
	ON i.film_id = f.film_id
	INNER JOIN film_category fc
	ON f.film_id = fc.film_id
	INNER JOIN category c
	ON fc.category_id=c.category_id
	WHERE c1.name=c.name) 
	FROM payment p
	INNER JOIN rental r
	ON p.rental_id=r.rental_id
	INNER JOIN inventory i
	ON r.inventory_id=i.inventory_id
	INNER JOIN film f
	ON i.film_id = f.film_id
	INNER JOIN film_category fc
	ON f.film_id = fc.film_id
	INNER JOIN category c1
	ON fc.category_id=c1.category_id
    ORDER BY payment_id ASC;

/*Task14: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).
Question: Which is the top performing film in the animation category?*/		

SELECT
title,
name,
SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) =(SELECT MAX(total)
			  FROM 
                     (SELECT
			          title,
                      name,
			          SUM(amount) as total
			          FROM payment p
			          LEFT JOIN rental r
			          ON r.rental_id=p.rental_id
			          LEFT JOIN inventory i
			          ON i.inventory_id=r.inventory_id
				  LEFT JOIN film f
				  ON f.film_id=i.film_id
				  LEFT JOIN film_category fc
				  ON fc.film_id=f.film_id
				  LEFT JOIN category c1
				  ON c1.category_id=fc.category_id
				  GROUP BY name,title) sub
			   WHERE c.name=sub.name)

