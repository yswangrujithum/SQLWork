-- 1a. Display the first and last names of all actors from the table actor.
select first_name as 'First Name', last_name as 'Last Name'
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(upper(first_name), ' ', upper(last_name)) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id as ID, first_name as 'First Name', last_name as 'Last Name'
from actor
where first_name like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select first_name as 'First Name', last_name as 'Last Name'
from actor 
where last_name like '%G%E%N%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select first_name as 'First Name', last_name as 'Last Name'
from actor
where last_name like '%LI%'
order by last_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id as 'ID', country as 'Country'
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
alter table actor
add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name as 'Last Name', count(last_name) as 'Number of Occurance'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name as 'Last Name', count(last_name) as 'Number of Occurance'
from actor
group by last_name
having count(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
rollback;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select staff.first_name as 'First Name', staff.last_name as 'Last Name', address.address as 'Address'
from staff
inner join address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.first_name as 'First Name', staff.last_name as 'Last Name', sum(payment.amount) as 'Total Amount'
from staff
inner join payment on staff.staff_id = payment.staff_id
where payment.payment_date like '2005-08%'
group by staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title as "Film Title", count(actor_id) as "Number of Actors"
from film 
inner join film_actor 
on film.film_id = film_actor.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title as 'Film Title', count(inventory_id) as "Number of copies"
from film
inner join inventory
on film.film_id = inventory.film_id
where title = "Hunchback Impossible"
group by title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select first_name as "First Name", last_name as "Last Name", sum(amount) as "Total Paid"
from customer c	
inner join payment p	
on p.customer_id = c.customer_id
group by p.customer_id
order by last_name;

--     ![Total amount paid](Images/total_payment.png)

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title as 'Movie Title'
from film
inner join language on film.language_id = language.language_id
where title like 'K%'
or title like 'Q%'
and language.name = "English";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select actor.first_name as "First Namer", actor.last_name as 'Last Name'
from actor 
where actor_id in (
    select actor_id
    from film_actor
    where film_id in (
        select film_id
        from film
        where film.title = "Alone Trip"
    )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select customer.first_name as "First Name", customer.last_name as "Last Name", customer.email as "Email"
from customer
inner join address on address.address_id = customer.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
where country.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film.title as "Title"
from film
where film_id in (
    select film_id 
    from film_category
    where category_id in (
        select category_id 
        from category 
        where name = "Family"
    )
);

-- 7e. Display the most frequently rented movies in descending order.
select film.title as "Title", count(rental.rental_id) as "Rental Frequency"
from film 
inner join inventory on film.film_id = inventory.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
group by title
order by count(rental.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id as "Store Number", sum(payment.amount) as "Total Business ($)"
from store
inner join inventory on inventory.store_id = store.store_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id as "Store ID", city.city as "City", country.country as "Country"
from store 
inner join address on address.address_id = store.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name as "Category", sum(payment.amount) as "Total Revenue"
from category 
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) DESC
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as 
select category.name as "Category", sum(payment.amount) as "Total Revenue"
from category 
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) DESC
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;
