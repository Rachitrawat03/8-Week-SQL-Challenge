CREATE SCHEMA pizza_runner;

USE  pizza_runner;

 -- PIZZA METRICS
 
 -- 1. How many pizzas were ordered?
 
SELECT 
    COUNT(order_id) AS total_num_pizza
FROM
    customer_orders1;
 
 -- 2. How many unique customer orders were made?
 
 SELECT 
    COUNT(DISTINCT (order_id)) AS unique_orders
FROM
    customer_orders1;
 
 -- 3.How many successful orders were delivered by each runner?

SELECT 
    runner_id, COUNT(order_id) AS sucessful_orders
FROM
    runner_orders1
WHERE
    distance IS NOT NULL
GROUP BY runner_id;
 
 -- 4.How many of each type of pizza was delivered?

SELECT 
    pn.pizza_name, COUNT(co1.order_id) AS num_of_pizza
FROM
    customer_orders1 co1
        JOIN
    pizza_names pn ON co1.pizza_id = pn.pizza_id
        JOIN
    runner_orders1 ro1 ON co1.order_id = ro1.order_id
WHERE
    distance IS NOT NULL
GROUP BY pn.pizza_name;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
    co1.customer_id,
    pn.pizza_name,
    COUNT(co1.order_id) num_of_pizza
FROM
    customer_orders1 co1
        JOIN
    pizza_names pn ON co1.pizza_id = pn.pizza_id
        JOIN
    runner_orders1 ro1 ON co1.order_id = ro1.order_id
GROUP BY pn.pizza_name , co1.customer_id
ORDER BY co1.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT 
    co1.order_id, COUNT(co1.customer_id) AS max_delivery
FROM
    customer_orders1 co1
        JOIN
    runner_orders1 ro1 ON co1.order_id = ro1.order_id
WHERE
    distance IS NOT NULL
GROUP BY co1.order_id
ORDER BY max_delivery DESC
LIMIT 1;

-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

create temporary table changed_pizza (select co1.order_id,co1.customer_id,co1.exclusions,co1.extras from customer_orders1 co1
join runner_orders1 ro1
on co1.order_id = ro1.order_id
where cancellation is null);

SELECT 
    customer_id,
    exclusions,
    extras,
    SUM(CASE
        WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0
    END) AS atleast_one_change,
    SUM(CASE
        WHEN exclusions IS NULL AND extras IS NULL THEN 1
        ELSE 0
    END) AS no_change
FROM 
    changed_pizza
GROUP BY customer_id;

-- 8.How many pizzas were delivered that had both exclusions and extras?

SELECT 
    customer_id,
    SUM(CASE
        WHEN
            exclusions IS NOT NULL
                AND extras IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS exclusions_extras
FROM
    changed_pizza
GROUP BY customer_id;

-- 9.What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    HOUR(order_time) AS hour_of_the_day,
    COUNT(order_id) AS pizza_volume
FROM
    customer_orders1
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;

-- 10.What was the volume of orders for each day of the week?

SELECT 
    DAYNAME(order_time) AS day_name, COUNT(order_id)
FROM
    customer_orders1
GROUP BY day_name
ORDER BY day_name;

-- SECTION B 

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    EXTRACT(WEEK FROM registration_date) AS week_num,
    COUNT(runner_id) AS runner_signed_up
FROM
    runners
GROUP BY week_num;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
    runner_id,
    AVG(EXTRACT(MINUTE FROM TIMEDIFF(pickup_time, order_time))) AS avg_time
FROM
    runner_orders1 ro1
        JOIN
    customer_orders1 co1 ON ro1.order_id = co1.order_id
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
    num_of_pizza, avg_time
FROM
    (SELECT 
        COUNT(co1.order_id) AS num_of_pizza,
            AVG(EXTRACT(MINUTE FROM TIMEDIFF(pickup_time, order_time))) AS avg_time
    FROM
        customer_orders1 co1
    JOIN runner_orders1 ro1 ON co1.order_id = ro1.order_id
    GROUP BY co1.order_id) temp
GROUP BY num_of_pizza;

-- 4. What was the average distance travelled for each customer?

SELECT 
    customer_id, AVG(distance)
FROM
    runner_orders1 ro1
        JOIN
    customer_orders1 co1 ON ro1.order_id = co1.order_id
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(time_taken) - MIN(time_taken) AS diff_time
FROM
    (SELECT 
        EXTRACT(MINUTE FROM TIMEDIFF(order_time, pickup_time)) AS time_taken
    FROM
        runner_orders1 ro1
    JOIN customer_orders1 co1 ON ro1.order_id = co1.order_id) temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    order_id,
    runner_id,
    CONCAT(ROUND((distance / duration * 60)),
            ' km/hr') AS speed
FROM
    runner_orders1
WHERE
    distance IS NOT NULL
ORDER BY runner_id;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
    runner_id,
    CONCAT(ROUND(100 * SUM(IF(cancellation IS NULL, 1, 0)) / COUNT(*)),
            ' %') AS success_order
FROM
    runner_orders1
GROUP BY runner_id;

-- SECTION C -  Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?


with cte as ( select pn.pizza_name, prn.pizza_id, pt.topping_name
from pizza_recipes_new prn
join pizza_toppings pt
on prn.toppings = pt.topping_id
join pizza_names pn
on pn.pizza_id = prn.pizza_id
order by pizza_name, prn.pizza_id)
select pizza_name, group_concat(topping_name) as Standard_Toppings
from cte
group by pizza_name;

-- 2. What was the most commonly added extra?

SELECT
  extras,
  COUNT(*) as num_extras
FROM customer_orders1
GROUP BY extras
limit 4 offset 1;

-- 3. What was the most common exclusion?

SELECT 
    exclusions, COUNT(*) AS num_excluded
FROM
    customer_orders1
GROUP BY exclusions
LIMIT 3 OFFSET 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT 
    subquery_alias.order_id,
    subquery_alias.pizza_id,
    pizza_names.pizza_name,
    subquery_alias.exclusions,
    subquery_alias.extras,
    (CASE
        WHEN
            subquery_alias.pizza_id = 1
        THEN
            (CASE
                WHEN
                    subquery_alias.exclusions = 4
                        AND (subquery_alias.extras IS NULL
                        OR subquery_alias.extras = 0)
                THEN
                    'Meat Lovers - Exclude Cheese'
                WHEN
                    (subquery_alias.exclusions LIKE '%3%'
                        OR subquery_alias.exclusions = 3)
                        AND (subquery_alias.extras IS NULL
                        OR subquery_alias.extras = 0)
                THEN
                    'Meat Lovers - Exclude Beef'
                WHEN
                    subquery_alias.extras = 1
                        AND (subquery_alias.exclusions IS NULL
                        OR subquery_alias.exclusions = 0)
                THEN
                    'Meat Lovers - Extra Bacon'
                WHEN
                    subquery_alias.exclusions = '1, 4'
                        AND subquery_alias.extras = '6, 9'
                THEN
                    'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
                WHEN
                    subquery_alias.exclusions = '2, 6'
                        AND subquery_alias.extras = '1, 4'
                THEN
                    'Meat Lovers - Exclude BBQ Sauce, Mushroom - Extra Bacon, Cheese'
                WHEN
                    subquery_alias.exclusions = 4
                        AND subquery_alias.extras = '1, 5'
                THEN
                    'Meat Lovers - Exclude Cheese - Extra Bacon, Chicken'
                ELSE 'Meat Lovers'
            END)
        WHEN
            subquery_alias.pizza_id = 2
        THEN
            CASE
                WHEN
                    subquery_alias.exclusions = 4
                        AND (subquery_alias.extras IS NULL
                        OR subquery_alias.extras = 0)
                THEN
                    'Veg Lovers - Exclude Cheese'
                ELSE 'Veg Lovers'
            END 
    END) OrderItem 
FROM
    (SELECT 
        customer_orders1.order_id,
        customer_orders1.pizza_id,
        customer_orders1.exclusions,
        customer_orders1.extras
    FROM
        customer_orders1
    ) AS subquery_alias
INNER JOIN 
    pizza_names ON pizza_names.pizza_id = subquery_alias.pizza_id;


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
SELECT 
    cust.order_id,
    cust.customer_id,
    cust.pizza_id,
    GROUP_CONCAT(CASE
            WHEN recipe_alias.toppings IN (1, 2, 3) THEN CONCAT('2x ', topping.topping_name)
            ELSE topping.topping_name
        END
        ORDER BY topping.topping_name
        SEPARATOR ', ') AS Ingredients
FROM
    customer_orders1 cust
        INNER JOIN
    pizza_recipes_new recipe_alias ON cust.pizza_id = recipe_alias.pizza_id
        INNER JOIN
    pizza_toppings topping ON topping.topping_id = recipe_alias.toppings
GROUP BY cust.order_id, cust.customer_id, cust.pizza_id;

                                                                        ##     D. Pricing and Ratings
                                                                        
                                                                        
-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
    pizza_id,
    COUNT(pizza_id) AS num_pizza,
    CASE
        WHEN pizza_id = 1 THEN COUNT(pizza_id) * 12
        ELSE COUNT(pizza_id) * 10
    END AS total_amount
FROM
    customer_orders1 co1
        JOIN
    runner_orders1 ro1 ON co1.order_id = ro1.order_id
WHERE
    distance IS NOT NULL
GROUP BY pizza_id;


-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

set @basecost = 138;
SELECT 
    (LENGTH(GROUP_CONCAT(extras)) - LENGTH(REPLACE(GROUP_CONCAT(extras), ',', '')) + 1) + @basecost AS Total
FROM
    customer_orders1
        INNER JOIN
    runner_orders1 ON customer_orders1.order_id = runner_orders1.order_id
WHERE
    extras IS NOT NULL
        AND distance IS NOT NULL;

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE ratings (
    order_id INTEGER,
    rating INTEGER
);
insert into ratings
(order_id, rating)
values
(1,4),
(2,5),
(3,4),
(4,2),
(5,5),
(7,3),
(8,1),
(10,2);

SELECT 
    *
FROM
    ratings;

-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

SELECT 
    cO1.customer_id,
    co1.order_id,
    ro1.runner_id,
    ratings.rating,
    co1.order_time,
    ro1.pickup_time,
    TIMESTAMPDIFF(MINUTE,
        order_time,
        pickup_time) AS Order_pickup_time,
    ro1.duration,
    ROUND(AVG(ro1.distance * 60 / ro1.duration), 1) AS avg_speed,
    COUNT(co1.pizza_id) AS pizza_count
FROM
    customer_orders1 co1
        JOIN
    runner_orders1 ro1 ON co1.order_id = ro1.order_id
        JOIN
    ratings ON ratings.order_id = co1.order_id
GROUP BY co1.customer_id , co1.order_id , ro1.runner_id , ratings.rating , co1.order_time , ro1.pickup_time , Order_pickup_time , ro1.duration
ORDER BY customer_id;


-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
set @pizzaamountearned = 138;
select @pizzaamountearned - (sum(distance))*0.3 as amount_left
from runner_orders1;


-- E. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

INSERT INTO pizza_names VALUES(3, 'Supreme');


SELECT 
    *
FROM
    pizza_names;


INSERT INTO pizza_recipes
VALUES(3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));

SELECT 
    *
FROM
    pizza_recipes;


