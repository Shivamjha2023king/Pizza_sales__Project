-- ✅ Query 1: Total number of orders placed
SELECT COUNT(order_id) AS total_orders FROM orders;

-- ✅ Query 2: Total revenue from pizza sales
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_sales
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- ✅ Query 3: Highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- ✅ Query 4: Most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM pizzas
JOIN orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- ✅ Query 5: Top 5 most ordered pizza types
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- ✅ Query 6: Total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- ✅ Query 7: Distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- ✅ Query 8: Category-wise distribution of pizzas
SELECT category, COUNT(name) FROM pizza_types
GROUP BY category;

-- ✅ Query 9: Average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_order_per_day
FROM (
    SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;

-- ✅ Query 10: Top 3 most ordered pizza types by revenue
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- ✅ Query 11: % revenue contribution of each pizza category
SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (
        SELECT ROUND(SUM(orders_details.quantity * pizzas.price), 2)
        FROM orders_details
        JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
    )) * 100, 2) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- ✅ Query 12: Cumulative revenue over time
SELECT order_date, 
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date,
           SUM(pizzas.price * orders_details.quantity) AS revenue
    FROM orders_details
    JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- ✅ Query 13: Top 3 pizzas by revenue per category
SELECT name, revenue FROM (
    SELECT category, name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pizza_types.category, pizza_types.name,
               SUM(orders_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn < 3;
