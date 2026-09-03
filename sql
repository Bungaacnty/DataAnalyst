# Total Population

SELECT COUNT(customer_id) AS total_population FROM my_project.main.customers

SELECT 
YEAR(TRY_CAST(signup_date AS DATE)) AS signup_year,
COUNT(customer_id) AS total_population 
FROM my_project.main.customers 
GROUP BY 1
ORDER BY 1

# Total Session

SELECT 
device, 
COUNT(DISTINCT customer_id) AS total_customer, 
COUNT(session_id) AS total_session
FROM my_project.main.sessions
GROUP BY 1
ORDER BY 2 DESC

# Conversion Rate

SELECT 
    s.device,
    COUNT(DISTINCT CASE 
        WHEN e.event_type = 'page_view' THEN e.session_id
    END) AS page_view_session,
    COUNT(DISTINCT CASE 
        WHEN e.event_type = 'add_to_cart' THEN e.session_id
    END) AS add_to_cart_session,
    COUNT(DISTINCT CASE 
        WHEN e.event_type = 'checkout' THEN e.session_id
    END) AS checkout_session,
    COUNT(DISTINCT CASE 
        WHEN e.event_type = 'purchase' THEN e.session_id
    END) AS purchase_session,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN e.event_type = 'purchase' 
            THEN e.session_id
        END) * 100.0
        /
        NULLIF(
            COUNT(DISTINCT CASE 
                WHEN e.event_type = 'page_view' 
                THEN e.session_id
            END),
            0
        ),
        2
    ) AS cvr_percent
FROM my_project.main.sessions s
LEFT JOIN my_project.main.events e
    ON e.session_id = s.session_id
GROUP BY 1
ORDER BY 2 DESC

# Funnel by device

SELECT 
    s.device,
	-- Page View → Add to Cart
    ROUND(
        COUNT(DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN e.session_id END)
        * 100.0 /
        NULLIF(
            COUNT(DISTINCT CASE WHEN e.event_type = 'page_view' THEN e.session_id END),
            0
        ),
        2
    ) AS pv_to_atc_rate,
    -- Add to Cart → Checkout
    ROUND(
        COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN e.session_id END)
        * 100.0 /
        NULLIF(
            COUNT(DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN e.session_id END),
            0
        ),
        2
    ) AS atc_to_checkout_rate,
    -- Checkout → Purchase
    ROUND(
        COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)
        * 100.0 /
        NULLIF(
            COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN e.session_id END),
            0
        ),
        2
    ) AS checkout_to_purchase_rate,
    -- Overall CVR
    ROUND(
        COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)
        * 100.0 /
        NULLIF(
            COUNT(DISTINCT CASE WHEN e.event_type = 'page_view' THEN e.session_id END),
            0
        ),
        2
    ) AS overall_cvr
FROM my_project.main.sessions s
LEFT JOIN my_project.main.events e
    ON e.session_id = s.session_id
GROUP BY 1
ORDER BY 2 DESC

# Group of Experiment

WITH order_summary AS (
    SELECT
        customer_id,
        ROUND(SUM(total_usd), 2) AS total_transaction
    FROM my_project.main.orders
    WHERE device = 'mobile'
    GROUP BY customer_id
),
session_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT session_id) AS total_session
    FROM my_project.main.sessions
    WHERE device = 'mobile'
    GROUP BY customer_id
),
base AS (
    SELECT
    	CASE
            WHEN MOD(c.customer_id, 2) = 0 THEN 'A'
            WHEN MOD(c.customer_id, 2) = 1 THEN 'B'
        END AS experiment_group,
        c.customer_id,
        c.name AS customer_name,
        c.signup_date,
        'mobile' AS device,
        o.total_transaction,
        s.total_session
    FROM my_project.main.customers c
    INNER JOIN order_summary o
        ON o.customer_id = c.customer_id
    INNER JOIN session_summary s
        ON s.customer_id = c.customer_id
    WHERE c.marketing_opt_in = 'Yes'
)
SELECT
	*
FROM base
WHERE total_transaction > 10
  AND total_session >= 2
ORDER BY customer_id;

# Experiment Balance

SELECT  
experiment_group,
COUNT(customer_id) AS total_customer,
ROUND(SUM(total_transaction),2) AS total_transaction
FROM my_project.main.experiment_population
GROUP BY 1

# Build Conversion Funnel
SELECT 
    e.event_type,
    COUNT(DISTINCT CASE 
        WHEN ep.experiment_group = 'A' 
        THEN e.session_id
    END) AS group_control,
    COUNT(DISTINCT CASE 
        WHEN ep.experiment_group = 'B' 
        THEN e.session_id
    END) AS group_treatment
FROM my_project.main.events e
LEFT JOIN my_project.main.sessions s
    ON s.session_id = e.session_id
LEFT JOIN my_project.main.experiment_population ep
    ON ep.customer_id = s.customer_id
GROUP BY 1
ORDER BY 2 DESC;

# AOV Analysis

WITH pop AS (
    SELECT 
        experiment_group,
        customer_id 
    FROM my_project.main.experiment_population
),
customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_order,
        SUM(total_usd) AS total_transaction,
        SUM(total_usd) / COUNT(DISTINCT order_id) AS aov
    FROM my_project.main.orders
    WHERE device = 'mobile'
    GROUP BY customer_id
),
customer_aov AS (
    SELECT
        p.experiment_group,
        p.customer_id,
        o.*
    FROM pop p
    LEFT JOIN customer_orders o
        ON p.customer_id = o.customer_id
)
SELECT
    experiment_group,
    SUM(total_order) AS total_order,
	ROUND(SUM(total_transaction), 2) AS total_transaction,
	ROUND(SUM(aov), 2) AS total_aov,
	ROUND(AVG(aov), 2) AS avg_aov,
	ROUND(STDDEV_SAMP(aov), 2) AS stdev_ao
FROM customer_aov
WHERE aov IS NOT NULL
GROUP BY experiment_group
ORDER BY experiment_group;