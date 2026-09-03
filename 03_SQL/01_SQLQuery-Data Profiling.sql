-- Cek jumlah data
-- =================================
SELECT COUNT(*) AS Total_Rows
FROM dbo.Data_cust;

-- Cek 10 data pertama
SELECT TOP 10 *
FROM dbo.Data_cust;

-- Cek struktur tabel Data_cust
-- =================================
SELECT 
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	NUMERIC_PRECISION,
	NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Data_cust'
ORDER BY ORDINAL_POSITION;

-- Cek Missing Value
-- =================================
SELECT
	COUNT(*) TOTAL_ROWS,

	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
	SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_null,
	SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_null,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_null,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_null,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS signup_date_null,
    SUM(CASE WHEN last_purchase_date IS NULL THEN 1 ELSE 0 END) AS last_purchase_date_null,
    SUM(CASE WHEN acquisition_channel IS NULL THEN 1 ELSE 0 END) AS acquisition_channel_null,
    SUM(CASE WHEN device_type IS NULL THEN 1 ELSE 0 END) AS device_type_null,
    SUM(CASE WHEN subscription_type IS NULL THEN 1 ELSE 0 END) AS subscription_type_null,
    SUM(CASE WHEN is_premium_user IS NULL THEN 1 ELSE 0 END) AS is_premium_user_null,
    SUM(CASE WHEN total_visits IS NULL THEN 1 ELSE 0 END) AS total_visits_null,
    SUM(CASE WHEN avg_session_time IS NULL THEN 1 ELSE 0 END) AS avg_session_time_null,
    SUM(CASE WHEN pages_per_session IS NULL THEN 1 ELSE 0 END) AS pages_per_session_null,
    SUM(CASE WHEN email_open_rate IS NULL THEN 1 ELSE 0 END) AS email_open_rate_null,
    SUM(CASE WHEN email_click_rate IS NULL THEN 1 ELSE 0 END) AS email_click_rate_null,
    SUM(CASE WHEN total_spent IS NULL THEN 1 ELSE 0 END) AS total_spent_null,
    SUM(CASE WHEN avg_order_value IS NULL THEN 1 ELSE 0 END) AS avg_order_value_null,
    SUM(CASE WHEN discount_used IS NULL THEN 1 ELSE 0 END) AS discount_used_null,
    SUM(CASE WHEN coupon_code IS NULL THEN 1 ELSE 0 END) AS coupon_code_null,
    SUM(CASE WHEN support_tickets IS NULL THEN 1 ELSE 0 END) AS support_tickets_null,
    SUM(CASE WHEN refund_requested IS NULL THEN 1 ELSE 0 END) AS refund_requested_null,
    SUM(CASE WHEN delivery_delay_days IS NULL THEN 1 ELSE 0 END) AS delivery_delay_days_null,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_null,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) AS satisfaction_score_null,
    SUM(CASE WHEN nps_score IS NULL THEN 1 ELSE 0 END) AS nps_score_null,
    SUM(CASE WHEN marketing_spend_per_user IS NULL THEN 1 ELSE 0 END) AS marketing_spend_null,
    SUM(CASE WHEN lifetime_value IS NULL THEN 1 ELSE 0 END) AS lifetime_value_null,
    SUM(CASE WHEN last_3_month_purchase_freq IS NULL THEN 1 ELSE 0 END) AS purchase_freq_null,
    SUM(CASE WHEN churn IS NULL THEN 1 ELSE 0 END) AS churn_null
FROM dbo.Data_cust;

-- Cek duplikasi customer_id
-- =================================
SELECT
    customer_id,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;

-- Cek duplikasi seluruh column
-- =================================
SELECT
    customer_id,
    gender,
    age,
    country,
    city,
    signup_date,
    last_purchase_date,
    acquisition_channel,
    device_type,
    subscription_type,
    is_premium_user,
    total_visits,
    avg_session_time,
    pages_per_session,
    email_open_rate,
    email_click_rate,
    total_spent,
    avg_order_value,
    discount_used,
    coupon_code,
    support_tickets,
    refund_requested,
    delivery_delay_days,
    payment_method,
    satisfaction_score,
    nps_score,
    marketing_spend_per_user,
    lifetime_value,
    last_3_month_purchase_freq,
    churn,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY
    customer_id,
    gender,
    age,
    country,
    city,
    signup_date,
    last_purchase_date,
    acquisition_channel,
    device_type,
    subscription_type,
    is_premium_user,
    total_visits,
    avg_session_time,
    pages_per_session,
    email_open_rate,
    email_click_rate,
    total_spent,
    avg_order_value,
    discount_used,
    coupon_code,
    support_tickets,
    refund_requested,
    delivery_delay_days,
    payment_method,
    satisfaction_score,
    nps_score,
    marketing_spend_per_user,
    lifetime_value,
    last_3_month_purchase_freq,
    churn
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;

-- Cek Category Consistency
-- =================================
SELECT
    'gender' AS nama_kolom,
    CAST(gender AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY gender

UNION ALL

SELECT
    'country' AS nama_kolom,
    CAST(country AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY country

UNION ALL

SELECT
    'city' AS nama_kolom,
    CAST(city AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY city

UNION ALL

SELECT
    'acquisition_channel' AS nama_kolom,
    CAST(acquisition_channel AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY acquisition_channel

UNION ALL

SELECT
    'device_type' AS nama_kolom,
    CAST(device_type AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY device_type

UNION ALL

SELECT
    'subscription_type' AS nama_kolom,
    CAST(subscription_type AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY subscription_type

UNION ALL

SELECT
    'coupon_code' AS nama_kolom,
    CAST(coupon_code AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY coupon_code

UNION ALL

SELECT
    'payment_method' AS nama_kolom,
    CAST(payment_method AS VARCHAR(100)) AS nilai,
    COUNT(*) AS jumlah
FROM dbo.Data_cust
GROUP BY payment_method

ORDER BY nama_kolom, jumlah DESC;

-- Cek INVALID VALUE PROFILING - INT
-- =================================
SELECT
    'age' AS column_name,
    MIN(age) AS min_value,
    MAX(age) AS max_value,
    AVG(CAST(age AS DECIMAL(18,2))) AS avg_value
FROM dbo.Data_cust

UNION ALL

SELECT
    'total_visits',
    MIN(total_visits),
    MAX(total_visits),
    AVG(CAST(total_visits AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'email_open_rate',
    MIN(email_open_rate),
    MAX(email_open_rate),
    AVG(CAST(email_open_rate AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'email_click_rate',
    MIN(email_click_rate),
    MAX(email_click_rate),
    AVG(CAST(email_click_rate AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'support_tickets',
    MIN(support_tickets),
    MAX(support_tickets),
    AVG(CAST(support_tickets AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'delivery_delay_days',
    MIN(delivery_delay_days),
    MAX(delivery_delay_days),
    AVG(CAST(delivery_delay_days AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'satisfaction_score',
    MIN(satisfaction_score),
    MAX(satisfaction_score),
    AVG(CAST(satisfaction_score AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'nps_score',
    MIN(nps_score),
    MAX(nps_score),
    AVG(CAST(nps_score AS DECIMAL(18,2)))
FROM dbo.Data_cust

UNION ALL

SELECT
    'last_3_month_purchase_freq',
    MIN(last_3_month_purchase_freq),
    MAX(last_3_month_purchase_freq),
    AVG(CAST(last_3_month_purchase_freq AS DECIMAL(18,2)))
FROM dbo.Data_cust

ORDER BY column_name;

-- Cek INVALID VALUE PROFILING - DATE
-- =================================
SELECT
    MIN(signup_date) AS min_signup_date,
    MAX(signup_date) AS max_signup_date,
    MIN(last_purchase_date) AS min_last_purchase_date,
    MAX(last_purchase_date) AS max_last_purchase_date
FROM dbo.Data_cust;

-- Purchase terjadi sebelum signup
SELECT
    customer_id,
    signup_date,
    last_purchase_date,
    DATEDIFF(DAY, signup_date, last_purchase_date) AS selisih_hari
FROM dbo.Data_cust
WHERE last_purchase_date < signup_date
ORDER BY selisih_hari;

-- Jumlah record dengan tanggal yang tidak konsisten
SELECT
    COUNT(*) AS jumlah_invalid_date
FROM dbo.Data_cust
WHERE last_purchase_date < signup_date;

-- Cek INVALID VALUE PROFILING - BOOLEAN
-- =================================
SELECT
    'is_premium_user' AS column_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_premium_user = 1 THEN 1 ELSE 0 END) AS true_count,
    SUM(CASE WHEN is_premium_user = 0 THEN 1 ELSE 0 END) AS false_count,
    SUM(CASE WHEN is_premium_user IS NULL THEN 1 ELSE 0 END) AS null_count
FROM dbo.Data_cust

UNION ALL

SELECT
    'discount_used',
    COUNT(*),
    SUM(CASE WHEN discount_used = 1 THEN 1 ELSE 0 END),
    SUM(CASE WHEN discount_used = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN discount_used IS NULL THEN 1 ELSE 0 END)
FROM dbo.Data_cust

UNION ALL

SELECT
    'refund_requested',
    COUNT(*),
    SUM(CASE WHEN refund_requested = 1 THEN 1 ELSE 0 END),
    SUM(CASE WHEN refund_requested = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN refund_requested IS NULL THEN 1 ELSE 0 END)
FROM dbo.Data_cust

UNION ALL

SELECT
    'churn',
    COUNT(*),
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END),
    SUM(CASE WHEN churn = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN churn IS NULL THEN 1 ELSE 0 END)
FROM dbo.Data_cust;