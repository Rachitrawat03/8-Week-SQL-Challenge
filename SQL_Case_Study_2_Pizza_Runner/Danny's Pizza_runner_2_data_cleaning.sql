#Creating new table to avoid any data loss

CREATE TABLE customer_orders1 SELECT * FROM
    customer_orders;

UPDATE customer_orders1 
SET 
    exclusions = CASE exclusions
        WHEN 'null' THEN NULL
        ELSE exclusions
    END,
    extras = CASE extras
        WHEN 'null' THEN NULL
        ELSE extras
    END;

UPDATE customer_orders1 
SET 
    exclusions = NULLIF(exclusions, '');

UPDATE customer_orders1 
SET 
    extras = NULLIF(extras, '');


select * from runner_orders;

#creating new table to avoid any data loss

CREATE TABLE runner_orders1 SELECT * FROM
    runner_orders;

select * from runner_orders1;


UPDATE runner_orders1 
SET 
    distance = REPLACE(distance, 'km', '');

UPDATE runner_orders1 
SET 
    distance = NULLIF(distance, 'null');

UPDATE runner_orders1 
SET 
    duration = REPLACE(duration, 'minutes', '');


UPDATE runner_orders1 
SET 
    duration = REPLACE(duration, 'mins', '');


UPDATE runner_orders1 
SET 
    duration = REPLACE(duration, 'minute', '');


UPDATE runner_orders1 
SET 
    duration = NULLIF(duration, 'null');

UPDATE runner_orders1 
SET 
    pickup_time = NULLIF(pickup_time, 'null');

UPDATE runner_orders1 
SET 
    cancellation = NULLIF(cancellation, 'null');

UPDATE runner_orders1 
SET 
    cancellation = NULLIF(cancellation, '');

 
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH, 
    CHARACTER_OCTET_LENGTH AS OCTET_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = "runner_orders1";

#Updating datatypes for runner table

 alter table runner_orders1
 modify column pickup_time datetime null,
 modify column distance decimal(5,1) null,
 modify column duration int null;
 
SELECT * FROM customer_orders;
SELECT * FROM customer_orders1;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_orders;
SELECT * FROM runner_orders1;
SELECT * FROM runners;