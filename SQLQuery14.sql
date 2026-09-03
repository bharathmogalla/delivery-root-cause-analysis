SELECT TOP 10 * FROM OlistDeliveryAnalytics.dbo.olist_orders_dataset;

SELECT TABLE_NAME 
FROM OlistDeliveryAnalytics.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT 
    order_id,
    order_status,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) AS delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
ORDER BY delay_days DESC;

SELECT 
    COUNT(*) AS total_delivered_orders,
    SUM(CASE WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 1 ELSE 0 END) AS late_orders,
    SUM(CASE WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) <= 0 THEN 1 ELSE 0 END) AS on_time_or_early_orders,
    AVG(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)) AS avg_delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered';


SELECT 
    COUNT(*) AS late_order_count,
    AVG(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)) AS avg_delay_when_late,
    MIN(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)) AS min_delay,
    MAX(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)) AS max_delay
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) > 0;

  --  see the actual distribution, not just the average
  -- This is the query that proves (or disproves) the skew theory — bucketing late orders into ranges:

  SELECT 
    CASE 
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 1 AND 3 THEN '1-3 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 4 AND 7 THEN '4-7 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 8 AND 14 THEN '8-14 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 15 AND 30 THEN '15-30 days late'
        ELSE '30+ days late'
    END AS delay_bucket,
    COUNT(*) AS order_count
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) > 0
GROUP BY 
    CASE 
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 1 AND 3 THEN '1-3 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 4 AND 7 THEN '4-7 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 8 AND 14 THEN '8-14 days late'
        WHEN DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 15 AND 30 THEN '15-30 days late'
        ELSE '30+ days late'
    END
ORDER BY MIN(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date));

-- find out WHERE the problem concentrates — by region

-- Now we move from "how bad" to "why" — starting with geography, since that's usually the biggest driver of delivery problems:

SELECT 
    c.customer_state,
    COUNT(*) AS late_order_count,
    AVG(DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS avg_delay_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 0
GROUP BY c.customer_state
ORDER BY late_order_count DESC;

SELECT * FROM olist_customers_dataset;

-- Next: check if this connects to your earlier "30+ day" outlier group
-- Let's confirm the extreme delays (30+ days) are concentrated in these remote states specifically:

SELECT 
    c.customer_state,
    COUNT(*) AS extreme_delay_count
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 30
GROUP BY c.customer_state
ORDER BY extreme_delay_count DESC;

-- Next: let's find out why RJ and SP specifically break down
-- Let's check if it's concentrated among specific sellers shipping to these states — that would point to a fixable operational cause rather than a geography problem:

SELECT TOP 20
    s.seller_state,
    s.seller_id,
    COUNT(*) AS extreme_delay_count
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 30
  AND c.customer_state IN ('RJ', 'SP')
GROUP BY s.seller_state, s.seller_id
ORDER BY extreme_delay_count DESC;

-- Next: check if this is time-concentrated (a seasonal/volume spike)
/* This is the natural next test of the "capacity strain" theory — if it's volume-driven, 
   we'd expect these extreme delays to cluster around specific months (holidays, sales events): */

   SELECT 
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(*) AS extreme_delay_count
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 30
  AND c.customer_state IN ('RJ', 'SP')
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;