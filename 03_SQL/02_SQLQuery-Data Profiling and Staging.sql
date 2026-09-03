-- =========================================
-- CREATE CLEAN TABLE
-- =========================================

USE CRM_Analytics;

CREATE TABLE dbo.Data_cust_Clean (
    customer_id INT,
    gender VARCHAR(50),
    age INT,
    country VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE,
    last_purchase_date DATE,
    acquisition_channel VARCHAR(50),
    device_type VARCHAR(30),
    subscription_type VARCHAR(30),

    is_premium_user BIT,

    total_visits INT,

    avg_session_time DECIMAL(18,2),
    pages_per_session DECIMAL(18,2),

    email_open_rate DECIMAL(10,4),
    email_click_rate DECIMAL(10,4),

    total_spent DECIMAL(18,2),
    avg_order_value DECIMAL(18,2),

    discount_used BIT,
    coupon_code VARCHAR(50),

    support_tickets INT,

    refund_requested BIT,

    delivery_delay_days INT,

    payment_method VARCHAR(30),

    satisfaction_score INT,
    nps_score INT,

    marketing_spend_per_user DECIMAL(18,2),
    lifetime_value DECIMAL(18,2),

    last_3_month_purchase_freq INT,

    churn BIT
);

-- =========================================
-- COPY RAW → CLEAN
-- Sekaligus konversi tipe data
-- =========================================

USE CRM_Analytics;

INSERT INTO dbo.Data_cust_Clean (
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
)

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

    TRY_CONVERT(DECIMAL(18,2), avg_session_time),
    TRY_CONVERT(DECIMAL(18,2), pages_per_session),

    TRY_CONVERT(DECIMAL(10,4), email_open_rate),
    TRY_CONVERT(DECIMAL(10,4), email_click_rate),

    TRY_CONVERT(DECIMAL(18,2), total_spent),
    TRY_CONVERT(DECIMAL(18,2), avg_order_value),

    discount_used,
    coupon_code,
    support_tickets,
    refund_requested,
    delivery_delay_days,
    payment_method,
    satisfaction_score,
    nps_score,

    TRY_CONVERT(DECIMAL(18,2), marketing_spend_per_user),
    TRY_CONVERT(DECIMAL(18,2), lifetime_value),

    last_3_month_purchase_freq,
    churn

FROM dbo.Data_cust;