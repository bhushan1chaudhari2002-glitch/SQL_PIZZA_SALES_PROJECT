**Pizza Sales Performance SQL PROJECT**


 # Project Overview
 This project delivers a data-driven performance analysis of a high-volume pizza franchise utilizing structured relational data. By querying transactional logs across multiple operational layers, the analysis bridges the gap between raw data and executive decision-making. The project uncovers critical trends relating to operational bottlenecks, category sales distribution, and customer purchase patterns


  # Tools Used
  Database Management System (DBMS): MySQL Server
  Integrated Development Environment (IDE): MySQL Workbench (Query optimization & EER data modeling)
  Version Control & Hosting: GitHub

  # Database Logic Summary
  The database utilizes a normalized snowflake schema architecture comprising four tightly decoupled tables designed to eliminate redundancy and enforce transactional integrity:
  
  orders: Captures unique temporal footprints (order_date, order_time) for each customer checkout session.
  order_details: Resolves the many-to-many relationship between orders and products, capturing itemized quantity velocity per line item.
  pizzas: Functions as the product variant matrix mapping specific size configurations (S, M, L) to fixed itemized price values.
  pizza_types: The top-level product dimension containing static attributes including flavor profiling (name), operational classification (category), and recipe tracking (ingredients).

 # Major Insights 
**Bimodal Peak Hourly Traffic**: Order volume follows a predictable dual-peak distribution, spiking sharply during the mid-day lunch rush (12:00 PM – 1:00 PM) and late evening dinner windows (5:00 PM – 7:00 PM).
**High Category Concentration**: Sales are intensely concentrated within dominant menu tiers. A tiny selection of highly popular variants anchors the bulk of the brand's total financial stability
**High Category Concentration**: Sales are intensely concentrated within dominant menu tiers. A tiny selection of highly popular variants anchors the bulk of the brand's total financial stability

# KPI Metrics & Aggregations
Gross Revenue Generation:

SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id;

Pizza Flavors by Quantity:

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC LIMIT 5;

Cumulative Revenue Timeline

SELECT daily_sales.order_date,
       SUM(daily_sales.revenue) OVER (ORDER BY daily_sales.order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date, ROUND(SUM(od.quantity * p.price), 2) AS revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) AS daily_sales;


 Highest-Grossing Pizzas Per Isolated Categor
 WITH RankedPizzaRevenue AS (
    SELECT pt.category, pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue,
           DENSE_RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_num
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
)
SELECT category, name, revenue FROM RankedPizzaRevenue WHERE rank_num <= 3;

Month-over-Month (MoM) Revenue Growth Rate

WITH MonthlyRevenue AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           ROUND(SUM(od.quantity * p.price), 2) AS monthly_sales
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT order_month, monthly_sales,
       ROUND(((monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_month)) 
       / LAG(monthly_sales) OVER (ORDER BY order_month)) * 100, 2) AS mom_growth_percentage
       
FROM MonthlyRevenue;
[EER Diagram](pizza_EER_diagram.png)


