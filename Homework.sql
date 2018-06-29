-- -------------------------------------------------- --
-- HOMEWORK
-- -------------------------------------------------- -- 

use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat (first_name , '  ' , last_name))
as Actor_Name
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select actor_id, first_name, last_name 
from actor
where first_name like 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from  actor
where last_name like '%Gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order: 
select last_name , first_name  from actor
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name.
alter table actor
add column middle_name varchar(40)
after first_name;

select * from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name blob(10) NULL;


-- 3c. Now delete the middle_name column.
alter table actor
drop middle_name;

select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name
select distinct last_name, count(last_name) as 'last_name_count'
from actor
group by last_name ;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'last_name_count'
from actor
group by last_name
having last_name_count >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher.
select * from actor
where last_name= 'WILLIAMS';

set sql_safe_updates=0;
update actor 
set first_name = 'HARPO'
where first_name = 'GROUCHO' AND last_name = 'WILLIAMS' ;

select * from actor
where last_name= 'WILLIAMS';

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
update actor
set first_name = 
case
when first_name = 'HARPO' 
 then 'GROUCHO'
else 'MUCHO GROUCHO'
end
where actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Describe address;
show create table sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name,address
from staff
inner join address 
on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select first_name, last_name ,sum(amount) as 'Total Amount'
from payment
inner join staff
on payment.staff_id = staff.staff_id
where payment.payment_date between '2005-08-01 00:00:00' and '2005-08-31 11:59:59' 
group by staff.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title,count(actor_id) as 'Total Actor' 
from film 
inner join film_actor
on film.film_id = film_actor.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id) as 'Copies'
from film
inner join inventory
on film.film_id = inventory.film_id
where title like 'Hunchback Impossible'
group by title;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
select last_name,first_name, sum(amount) as 'Total Payment'
from payment p
inner join customer c
on p.customer_id = c.customer_id
group by p.customer_id
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
--  As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where (title like 'K%' or title like 'Q%' ) And film.language_id =
(
select language.language_id from language
where name like 'English'
);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor
where actor_id in
(
		select  actor_id from film_actor
		where film_id in
			(
				select film_id from film
				where film_id in
					(
						select film_id from film
						where title = 'Alone Trip'
					)
			)
);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select customer.last_name, customer.first_name, customer.email
from customer
inner join
customer_list on customer.customer_id = customer_list.ID
where customer_list.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title, category
FROM film_list
WHERE category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select i.film_id, f.title, count(r.inventory_id)
from inventory i
inner join rental r
on i.inventory_id = r.inventory_id
inner join film_text f 
on i.film_id = f.film_id
group by r.inventory_id
order by count(r.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) as 'Total amount'
from store
inner join staff
on store.store_id = staff.store_id
inner join payment
on staff.staff_id = payment.staff_id
group by store.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country from store
inner join address
on store.address_id = address.address_id
inner join city
on city.city_id = address.city_id
inner join country
on country.country_id = city.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount)  as 'Gross Revenue'
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on inventory.film_id = film_category.film_id 
inner join rental
on rental.inventory_id = inventory.inventory_id
inner join payment
on payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
select category.name, sum(payment.amount)  as 'Gross Revenue'
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on inventory.film_id = film_category.film_id 
inner join rental
on rental.inventory_id = inventory.inventory_id
inner join payment
on payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;




