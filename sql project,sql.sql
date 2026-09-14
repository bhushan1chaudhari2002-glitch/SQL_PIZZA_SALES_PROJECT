create database pizzahut;
use pizzahut;
select * from pizzahut.pizzas;
create table orders( order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id ));

select * from orders;
 create table order_details(order_details_id int not null,
 order_id int not null,
 pizza_id text not null,
 quantity int not null,
 primary key(order_details_id));
 select * from order_details;
 CREATE DATABASE IF NOT EXISTS pizzahut;

 
 -- Let'S SEE QUESTION
 -- Q1) Retrieve the total number of orders placed.
 select count(order_id) as total_orders from orders;
 
 -- Q2)Calculate the total revenue generates from pizza sales;
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    -- Q3)Identify the highest priced pizza.
    select 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4) Identify the most common pizza size ordered
SELECT 
    pizzas.size, COUNT(order_details.order_details_id)as order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC ;

    
    -- Q5) LIST  THE TOP 5 MOST ORDERED PIZZA TYPR ALONG WITH THEIR QUANTITIES
  
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- INTERMEDIATE QUESTIONS

-- Q6) JOIN THE NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- Q7)DETERMINE THE DISTRIBUTIONOF ORDERS BY HOUR OF THE DAY
SELECT 
    HOUR(orders.order_time) AS order_hour,
    COUNT(orders.order_id) AS order_count
FROM
    orders
GROUP BY HOUR(orders.order_time)
ORDER BY order_hour;

-- Q8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pizza_types.category,
    COUNT(pizza_types.pizza_type_id) AS total_pizzas
FROM
    pizza_types
GROUP BY pizza_types.category;

-- Q9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(daily_sales.daily_total_quantity), 0) AS avg_pizzas_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS daily_total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS daily_sales;
    
  --  Q10)Determine the top 3 most ordered pizza types based on revenue
 SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

  -- Advanced:
  -- Q11)Calculate the percentage contribution of each pizza type to total revenue.
  SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- Q12)Analyze the cumulative revenue generated over time.
SELECT 
    daily_sales.order_date,
    daily_sales.revenue,
    SUM(daily_sales.revenue) OVER (ORDER BY daily_sales.order_date) AS cumulative_revenue
FROM (
    SELECT 
        orders.order_date, 
        ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
    FROM orders
    JOIN order_details 
        ON orders.order_id = order_details.order_id
    JOIN pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY orders.order_date
) AS daily_sales;

-- Q13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH RankedPizzaRevenue AS (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY pizza_types.category 
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS rank_num
    FROM pizza_types
    JOIN pizzas 
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details 
        ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
)
SELECT 
    RankedPizzaRevenue.category, 
    RankedPizzaRevenue.name, 
    RankedPizzaRevenue.revenue
FROM RankedPizzaRevenue
WHERE RankedPizzaRevenue.rank_num <= 3;

-- Q14)Month-over-Month (MoM) Revenue Growth Rate Calculate 
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(orders.order_date, '%Y-%m') AS order_month,
        ROUND(SUM(order_details.quantity * pizzas.price), 2) AS monthly_sales
    FROM orders
    JOIN order_details 
        ON orders.order_id = order_details.order_id
    JOIN pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
)
SELECT 
    MonthlyRevenue.order_month,
    MonthlyRevenue.monthly_sales,
    LAG(MonthlyRevenue.monthly_sales) OVER (ORDER BY MonthlyRevenue.order_month) AS previous_month_sales,
    ROUND(
        ((MonthlyRevenue.monthly_sales - LAG(MonthlyRevenue.monthly_sales) OVER (ORDER BY MonthlyRevenue.order_month)) 
        / LAG(MonthlyRevenue.monthly_sales) OVER (ORDER BY MonthlyRevenue.order_month)) * 100, 
        2
    ) AS mom_growth_percentage
FROM MonthlyRevenue;

-- Q15)Average Order Value (AOV) Calculate 
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price) / COUNT(DISTINCT orders.order_id),
            2) AS average_order_value
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


 
 