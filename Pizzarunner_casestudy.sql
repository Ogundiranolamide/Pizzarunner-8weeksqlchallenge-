/****** Script for SelectTopNRows command from SSMS  ******/
-- A. Pizza Metrics
-- Q1 How many pizzas were ordered?
-- Q2 How many unique customer orders were made?
-- Q3 How many successful orders were delivered by each runner?
-- Q4 How many of each type of pizza was delivered?
-- Q5 How many Vegetarian and Meatlovers were ordered by each customer?
-- Q6 What was the maximum number of pizzas delivered in a single order?
-- Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- Q8 How many pizzas were delivered that had both exclusions and extras?
-- Q9 What was the total volume of pizzas ordered for each hour of the day?
-- Q10 What was the volume of orders for each day of the week?

-- All 6 Tables in view
SELECT
	*
from customer_orders

SELECT
	*
from pizza_names

SELECT
	*
from pizza_recipes

SELECT
	*
from pizza_toppings

SELECT
	*
from runner_orders

SELECT
	*
from runners

-- Cleaning the data

-- New Customer Order Data
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
SELECT * FROM new_customer_orders
-- New Runner Order Data
WITH new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
SELECT * FROM new_runner_orders

-- Joined Table Customer and runner order table
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
, new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders)
Select * from new_customer_orders nc
join new_runner_orders nr
on nc.order_id = nr.order_id

-- DEEP DIVE INTO THE QUESTIONS
-- Q1 How many pizzas were ordered?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
SELECT
	Count(order_id) AS pizza_ordered
FROM new_customer_orders

-- Q2 How many unique customer orders were made?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders)
select
	Count(distinct order_id) as unique_ordered_pizza
from new_customer_orders

-- Q3 How many successful orders were delivered by each runner?
WITH new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select 
	runner_id,
	count(order_id) AS "Successful Orders"
from new_runner_orders
where cancellation = ''
group by runner_id

-- Q4 How many of each type of pizza was delivered?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
, new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select 
	--*
	max(cast (pz.pizza_name as nvarchar)) as pizza_name,
	nc.pizza_id,
	count(nc.pizza_id) AS "Successfully Delivered"
from new_runner_orders as nr
join new_customer_orders as nc
on nc.order_id = nr.order_id
join pizza_names pz
on pz.pizza_id = nc.pizza_id
where cancellation = ''
group by nc.pizza_id

-- Q5 How many Vegetarian and Meatlovers were ordered by each customer?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
, new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select 
	--*
	nc.customer_id,
	max(cast (pz.pizza_name as nvarchar)) as pizza_name,
	count(nc.pizza_id) AS "Orders"
from new_runner_orders as nr
join new_customer_orders as nc
on nc.order_id = nr.order_id
join pizza_names pz
on pz.pizza_id = nc.pizza_id
group by nc.customer_id,nc.pizza_id

-- Q6 What was the maximum number of pizzas delivered in a single order?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) , new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select top 1
	order_time,
	count(nc.order_id) as "count of orders"
from new_runner_orders as nr
join new_customer_orders as nc
on nc.order_id = nr.order_id
where cancellation = ''
group by order_time 
order by 2 desc

-- Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) , new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select
	nc.customer_id,
	count(case when extras = '' and exclusions = '' then 1
          end) as no_change,
	count(case when extras <> '' or exclusions <> '' then 1
           end) as change
from new_runner_orders as nr
join new_customer_orders as nc
on nc.order_id = nr.order_id
where cancellation = ''
group by nc.customer_id

-- Q8 How many pizzas were delivered that had both exclusions and extras?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) , new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders) 
select
	--nc.customer_id,
	count(case when extras <> '' and exclusions <> '' then 1
           end) as change
from new_runner_orders as nr
join new_customer_orders as nc
on nc.order_id = nr.order_id
where cancellation = ''
--group by nc.customer_id

-- Q9 What was the total volume of pizzas ordered for each hour of the day?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
, new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders)
Select
	DATEPART(hour,order_time) as Hour_of_order,
	count(nc.order_id) as "Volume of Order Per Hour"
from new_customer_orders nc
join new_runner_orders nr
on nc.order_id = nr.order_id
group by DATEPART(hour,order_time)

-- Q10 What was the volume of orders for each day of the week?
WITH new_customer_orders AS(
SELECT order_id, customer_id, pizza_id,
	(CASE 
		WHEN 
			exclusions is null or exclusions like '%null%' THEN ''
		ELSE exclusions 
	END) AS exclusions,
	(CASE 
		WHEN 
			extras is null or extras like '%null%' THEN '' 
		ELSE extras 
	END) AS extras, 
	order_time
FROM customer_orders) 
, new_runner_orders AS (
SELECT order_id, runner_id,
	(CASE --  CLEANING FOR PICKUP TIME
		WHEN 
			pickup_time is null or pickup_time like '%null%' THEN '' 
        ELSE pickup_time 
    END) AS pickup_time,
  	(CASE -- CLEANING FOR DISTANCE
		WHEN distance is null or distance like '%null%' THEN ''
  		WHEN distance like '%km' THEN TRIM ('km' FROM distance)
  		ELSE distance
	END) AS distance, 
    (CASE -- CLEANING FOR DURATION
		WHEN duration is null or duration like '%null%' THEN '' 
        WHEN duration like '%mins' THEN TRIM ('mins' FROM duration) 
        WHEN duration like '%minute' THEN TRIM ('minute' FROM duration)
        WHEN duration like '%minutes' THEN TRIM ('minutes' FROM duration)
        ELSE duration 
    END) AS duration,
    (CASE -- CLEANING FOR CANCELLATION
		WHEN cancellation is null or cancellation like '%null%' THEN '' 
		--WHEN cancellation like '%Cancellation%' then trim ('Cancellation' from "cancellation")
        ELSE cancellation 
    END) AS cancellation
FROM runner_orders)
Select
	DATEPART(WEEKDAY,order_time) AS Day_of_the_week_order,
	DATENAME(WEEKDAY,order_time) AS Name_of_the_week_order,
	count(nc.order_id) as "Volume of Order"
from new_customer_orders nc
join new_runner_orders nr
on nc.order_id = nr.order_id
group by DATEPART(WEEKDAY,order_time),DATENAME(WEEKDAY,order_time)
order by DATEPART(WEEKDAY,order_time)