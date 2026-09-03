USE CRM_Analytics;
-- STEP 1 Customer Overview
-- =========================================================
-- CRM ANALYTICS - BUSINESS ANALYTICS
-- =========================================================
-- Dataset:
-- dbo.Data_cust_Clean
--
-- Tujuan:
-- Menganalisis customer untuk memahami:
-- 1. Customer Overview
-- 2. Customer Churn
-- 3. Customer Value
-- 4. Customer Acquisition
-- 5. Customer Satisfaction & NPS
-- 6. Customer Behavior
-- =========================================================

-- =========================================================
-- BUSINESS QUESTION 1 - CUSTOMER OVERVIEW
-- =========================================================
-- Pertanyaan bisnis:
-- Bagaimana gambaran umum customer dalam dataset?
--
-- Metrics:
-- - Total Customer
-- - Customer Churn
-- - Churn Rate
-- - Premium Customer
-- - Premium Customer %
-- - Rata-rata Age
-- - Rata-rata Satisfaction
-- - Rata-rata NPS
-- =========================================================

SELECT
    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate,

    SUM(
        CASE
            WHEN is_premium_user = 1 THEN 1
            ELSE 0
        END
    ) AS premium_customer,

    CAST(
        SUM(
            CASE
                WHEN is_premium_user = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS premium_customer_percentage,

    CAST(AVG(age) AS DECIMAL(10,2)) AS average_age,

    CAST(
        AVG(satisfaction_score)
        AS DECIMAL(10,2)
    ) AS average_satisfaction,

    CAST(
        AVG(nps_score)
        AS DECIMAL(10,2)
    ) AS average_nps

FROM dbo.Data_cust_Clean;

-- =========================================================
-- VALIDASI CUSTOMER STATUS
-- =========================================================
SELECT
    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn IN (0,1) THEN 1
            ELSE 0
        END
    ) AS total_valid_churn

FROM dbo.Data_cust_Clean;

-- STEP 2 Churn Analysis
-- =========================================================
-- BUSINESS QUESTION 2 - CHURN BY SUBSCRIPTION
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah tingkat churn berbeda berdasarkan
-- jenis subscription customer?
--
-- Metrics:
-- - Total Customer
-- - Churn Customer
-- - Active Customer
-- - Churn Rate
-- =========================================================

SELECT
    subscription_type,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

GROUP BY subscription_type

ORDER BY churn_rate DESC;

-- =========================================================
-- BUSINESS QUESTION 2B - CHURN BY PREMIUM STATUS
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah customer premium memiliki tingkat churn
-- yang berbeda dibandingkan customer non-premium?
-- =========================================================
SELECT
    is_premium_user,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

GROUP BY is_premium_user

ORDER BY churn_rate DESC;

-- =========================================================
-- BUSINESS QUESTION 2C - CHURN BY ACQUISITION CHANNEL
-- =========================================================
-- Pertanyaan bisnis:
-- Channel acquisition mana yang memiliki tingkat
-- churn paling tinggi?
-- =========================================================
SELECT
    acquisition_channel,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

GROUP BY acquisition_channel

ORDER BY churn_rate DESC;

-- STEP 3 Customer Value Analysis
-- =========================================================
-- BUSINESS QUESTION 3 - CUSTOMER VALUE OVERVIEW
-- =========================================================
-- Pertanyaan bisnis:
-- Berapa nilai ekonomi customer secara keseluruhan?
--
-- Metrics:
-- - Total Customer
-- - Total Revenue / Total Spent
-- - Average Order Value
-- - Average Lifetime Value
-- - Minimum & Maximum Lifetime Value
-- =========================================================

SELECT
    COUNT(*) AS total_customer,

    SUM(total_spent) AS total_customer_spent,

    CAST(
        AVG(avg_order_value)
        AS DECIMAL(20,2)
    ) AS average_order_value,

    CAST(
        AVG(lifetime_value)
        AS DECIMAL(20,2)
    ) AS average_lifetime_value,

    MIN(lifetime_value) AS minimum_lifetime_value,

    MAX(lifetime_value) AS maximum_lifetime_value

FROM dbo.Data_cust_Clean
WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND lifetime_value IS NOT NULL;

-- =========================================================
-- BUSINESS QUESTION 3B - CUSTOMER VALUE BY CHURN
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah customer churn memiliki nilai ekonomi
-- yang berbeda dibandingkan customer aktif?
-- =========================================================

SELECT
    churn,

    COUNT(*) AS total_customer,

    CAST(
        AVG(total_spent)
        AS DECIMAL(20,2)
    ) AS average_total_spent,

    CAST(
        AVG(avg_order_value)
        AS DECIMAL(20,2)
    ) AS average_order_value,

    CAST(
        AVG(lifetime_value)
        AS DECIMAL(20,2)
    ) AS average_lifetime_value

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND lifetime_value IS NOT NULL

GROUP BY churn

ORDER BY churn;

-- =========================================================
-- BUSINESS QUESTION 3C - CUSTOMER VALUE BY ACQUISITION
-- =========================================================
-- Pertanyaan bisnis:
-- Channel acquisition mana yang menghasilkan
-- customer dengan nilai ekonomi tertinggi?
-- =========================================================

SELECT
    acquisition_channel,

    COUNT(*) AS total_customer,

    CAST(
        AVG(total_spent)
        AS DECIMAL(20,2)
    ) AS average_total_spent,

    CAST(
        AVG(avg_order_value)
        AS DECIMAL(20,2)
    ) AS average_order_value,

    CAST(
        AVG(lifetime_value)
        AS DECIMAL(20,2)
    ) AS average_lifetime_value

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND lifetime_value IS NOT NULL

GROUP BY acquisition_channel

ORDER BY average_lifetime_value DESC;

-- STEP 4 Satisfaction & NPS Analysis
-- =========================================================
-- BUSINESS QUESTION 4A
-- SATISFACTION & NPS BERDASARKAN CHURN
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah tingkat kepuasan dan NPS berbeda antara
-- customer aktif dan customer yang churn?
-- =========================================================

SELECT
    churn,

    COUNT(*) AS total_customer,

    CAST(
        AVG(satisfaction_score)
        AS DECIMAL(10,2)
    ) AS average_satisfaction,

    CAST(
        AVG(nps_score)
        AS DECIMAL(10,2)
    ) AS average_nps

FROM dbo.Data_cust_Clean

WHERE satisfaction_score IS NOT NULL
  AND nps_score IS NOT NULL

GROUP BY churn

ORDER BY churn;

-- =========================================================
-- BUSINESS QUESTION 4B
-- CHURN BERDASARKAN SATISFACTION SCORE
-- =========================================================

SELECT
    satisfaction_score,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

WHERE satisfaction_score IS NOT NULL

GROUP BY satisfaction_score

ORDER BY satisfaction_score;

-- =========================================================
-- BUSINESS QUESTION 4C
-- CHURN BERDASARKAN NPS SCORE
-- =========================================================

SELECT
    nps_score,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

WHERE nps_score IS NOT NULL

GROUP BY nps_score

ORDER BY nps_score;

-- =========================================================
-- BUSINESS QUESTION 4D
-- CUSTOMER EXPERIENCE BERDASARKAN ACQUISITION CHANNEL
-- =========================================================

SELECT
    acquisition_channel,

    COUNT(*) AS total_customer,

    CAST(
        AVG(satisfaction_score)
        AS DECIMAL(10,2)
    ) AS average_satisfaction,

    CAST(
        AVG(nps_score)
        AS DECIMAL(10,2)
    ) AS average_nps

FROM dbo.Data_cust_Clean

WHERE satisfaction_score IS NOT NULL
  AND nps_score IS NOT NULL

GROUP BY acquisition_channel

ORDER BY average_satisfaction DESC;

-- =========================================================
-- STEP 5 - Customer Behavior Analysis
-- =========================================================
-- BUSINESS QUESTION 5A
-- CUSTOMER BEHAVIOR BERDASARKAN CHURN
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah terdapat perbedaan perilaku antara customer
-- aktif dan customer yang churn?
--
-- Metrics:
-- - Total Visits
-- - Email Open Rate
-- - Email Click Rate
-- - Purchase Frequency
-- - Support Tickets
-- - Refund Requested
-- - Delivery Delay
-- =========================================================

SELECT
    churn,

    COUNT(*) AS total_customer,

    CAST(
        AVG(total_visits)
        AS DECIMAL(10,2)
    ) AS average_total_visits,

    CAST(
        AVG(email_open_rate)
        AS DECIMAL(10,2)
    ) AS average_email_open_rate,

    CAST(
        AVG(email_click_rate)
        AS DECIMAL(10,2)
    ) AS average_email_click_rate,

    CAST(
        AVG(last_3_month_purchase_freq)
        AS DECIMAL(10,2)
    ) AS average_purchase_frequency,

    CAST(
        AVG(support_tickets)
        AS DECIMAL(10,2)
    ) AS average_support_tickets,

    CAST(
        AVG(CAST(refund_requested AS INT))
        AS DECIMAL(10,2)
    ) AS average_refund_requested,

    CAST(
        AVG(delivery_delay_days)
        AS DECIMAL(10,2)
    ) AS average_delivery_delay

FROM dbo.Data_cust_Clean

GROUP BY churn

ORDER BY churn;

-- =========================================================
-- BUSINESS QUESTION 5B
-- CHURN BERDASARKAN PURCHASE FREQUENCY
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah customer dengan frekuensi pembelian tertentu
-- memiliki tingkat churn yang berbeda?
-- =========================================================

SELECT
    last_3_month_purchase_freq,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

WHERE last_3_month_purchase_freq IS NOT NULL

GROUP BY last_3_month_purchase_freq

ORDER BY last_3_month_purchase_freq;

-- =========================================================
-- BUSINESS QUESTION 5C
-- CHURN BERDASARKAN REFUND
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah customer yang pernah melakukan refund
-- memiliki tingkat churn yang berbeda?
-- =========================================================

SELECT
    refund_requested,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

GROUP BY refund_requested

ORDER BY refund_requested;

-- =========================================================
-- BUSINESS QUESTION 5D
-- CHURN BERDASARKAN DELIVERY DELAY
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah tingkat churn berbeda berdasarkan
-- tingkat keterlambatan delivery?
--
-- Kelompok:
-- 0 hari    = Tidak terlambat
-- 1-2 hari  = Keterlambatan rendah
-- 3-5 hari  = Keterlambatan sedang
-- >5 hari   = Keterlambatan tinggi
-- =========================================================

SELECT
    CASE
        WHEN delivery_delay_days = 0
            THEN '0 Hari - Tidak Terlambat'

        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN '1-2 Hari - Rendah'

        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN '3-5 Hari - Sedang'

        WHEN delivery_delay_days > 5
            THEN '>5 Hari - Tinggi'
    END AS delivery_delay_group,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

WHERE delivery_delay_days IS NOT NULL

GROUP BY
    CASE
        WHEN delivery_delay_days = 0
            THEN '0 Hari - Tidak Terlambat'

        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN '1-2 Hari - Rendah'

        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN '3-5 Hari - Sedang'

        WHEN delivery_delay_days > 5
            THEN '>5 Hari - Tinggi'
    END

ORDER BY
    churn_rate DESC;

-- =========================================================
-- BUSINESS QUESTION 5E
-- CHURN BERDASARKAN SUPPORT TICKETS
-- =========================================================
-- Pertanyaan bisnis:
-- Apakah tingkat churn berbeda berdasarkan
-- jumlah tiket customer support?
-- =========================================================

SELECT
    support_tickets,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Data_cust_Clean

WHERE support_tickets IS NOT NULL

GROUP BY support_tickets

ORDER BY support_tickets;

-- =========================================================
-- STEP 6 - FINAL KPI DATASET
-- =========================================================

-- =========================================================
-- 6.1 EXECUTIVE CRM KPI
-- =========================================================
-- Tujuan:
-- Menyiapkan KPI utama yang akan digunakan
-- sebagai Scorecard di Power BI.
--
-- KPI:
-- - Total Customer
-- - Active Customer
-- - Churn Customer
-- - Churn Rate
-- - Premium Customer
-- - Premium Customer Rate
-- - Average Age
-- - Average Satisfaction
-- - Average NPS
-- - Total Customer Spent
-- - Average Order Value
-- - Average Lifetime Value
-- =========================================================

SELECT

    -- CUSTOMER
    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    CAST(
        SUM(
            CASE
                WHEN churn = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS churn_rate,


    -- PREMIUM
    SUM(
        CASE
            WHEN is_premium_user = 1 THEN 1
            ELSE 0
        END
    ) AS premium_customer,

    CAST(
        SUM(
            CASE
                WHEN is_premium_user = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS premium_customer_rate,


    -- CUSTOMER PROFILE
    CAST(
        AVG(age)
        AS DECIMAL(10,2)
    ) AS average_age,

    CAST(
        AVG(satisfaction_score)
        AS DECIMAL(10,2)
    ) AS average_satisfaction,

    CAST(
        AVG(nps_score)
        AS DECIMAL(10,2)
    ) AS average_nps,


    -- CUSTOMER VALUE
    SUM(total_spent) AS total_customer_spent,

    CAST(
        AVG(avg_order_value)
        AS DECIMAL(20,2)
    ) AS average_order_value,

    CAST(
        AVG(lifetime_value)
        AS DECIMAL(20,2)
    ) AS average_lifetime_value

FROM dbo.Data_cust_Clean;

-- =========================================================
-- 6.2 VALIDASI FINAL KPI
-- =========================================================

SELECT

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN churn = 0 THEN 1
            ELSE 0
        END
    ) AS active_customer,

    SUM(
        CASE
            WHEN churn = 1 THEN 1
            ELSE 0
        END
    ) AS churn_customer,

    SUM(
        CASE
            WHEN churn IN (0,1) THEN 1
            ELSE 0
        END
    ) AS valid_churn,

    SUM(
        CASE
            WHEN is_premium_user IN (0,1) THEN 1
            ELSE 0
        END
    ) AS valid_premium

FROM dbo.Data_cust_Clean;

-- =========================================================
-- STEP 7 - LOOKER STUDIO DASHBOARD DATASET
-- =========================================================
-- Tujuan:
-- Menyiapkan dataset final untuk Google Sheets
-- dan Looker Studio.
--
-- Sumber:
-- dbo.Data_cust_Clean
--
-- 1 row = 1 customer
-- Total expected rows = 15,000
-- =========================================================

SELECT

    -- =========================================
    -- CUSTOMER IDENTIFICATION
    -- =========================================
    customer_id,
    gender,
    age,
    country,
    city,


    -- =========================================
    -- CUSTOMER DATE
    -- =========================================
    signup_date,
    last_purchase_date,


    -- =========================================
    -- CUSTOMER ACQUISITION
    -- =========================================
    acquisition_channel,
    subscription_type,
    is_premium_user,

    CASE
        WHEN is_premium_user = 1
            THEN 'Premium'
        ELSE 'Non-Premium'
    END AS premium_status,


    -- =========================================
    -- CUSTOMER ACTIVITY
    -- =========================================
    total_visits,

    CAST(email_open_rate AS DECIMAL(5,2))
        AS email_open_rate,

    CAST(email_click_rate AS DECIMAL(5,2))
        AS email_click_rate,


    -- =========================================
    -- CUSTOMER VALUE
    -- =========================================
    total_spent,
    avg_order_value,
    lifetime_value,


    -- =========================================
    -- MARKETING / PROMOTION
    -- =========================================
    discount_used,
    coupon_code,
    marketing_spend_per_user,


    -- =========================================
    -- CUSTOMER SERVICE
    -- =========================================
    support_tickets,
    refund_requested,
    delivery_delay_days,


    -- =========================================
    -- PAYMENT
    -- =========================================
    payment_method,


    -- =========================================
    -- CUSTOMER EXPERIENCE
    -- =========================================
    satisfaction_score,
    nps_score,


    -- =========================================
    -- PURCHASE BEHAVIOR
    -- =========================================
    last_3_month_purchase_freq,


    -- =========================================
    -- CHURN
    -- =========================================
    churn,

    CASE
        WHEN churn = 1
            THEN 'Churn'
        ELSE 'Active'
    END AS churn_status,


    -- =========================================
    -- SATISFACTION GROUP
    -- =========================================
    CASE
        WHEN satisfaction_score <= 2
            THEN 'Low'
        WHEN satisfaction_score = 3
            THEN 'Medium'
        WHEN satisfaction_score >= 4
            THEN 'High'
    END AS satisfaction_group,


    -- =========================================
    -- NPS GROUP
    -- =========================================
    CASE
        WHEN nps_score <= 6
            THEN 'Detractor'
        WHEN nps_score <= 8
            THEN 'Passive'
        WHEN nps_score >= 9
            THEN 'Promoter'
    END AS nps_group,


    -- =========================================
    -- SUPPORT TICKET GROUP
    -- =========================================
    CASE
        WHEN support_tickets = 0
            THEN '0 Tickets'
        WHEN support_tickets BETWEEN 1 AND 4
            THEN '1-4 Tickets'
        WHEN support_tickets >= 5
            THEN '5+ Tickets'
    END AS support_ticket_group,


    -- =========================================
    -- PURCHASE FREQUENCY GROUP
    -- =========================================
    CASE
        WHEN last_3_month_purchase_freq = 0
            THEN 'No Purchase'
        WHEN last_3_month_purchase_freq BETWEEN 1 AND 4
            THEN '1-4 Purchases'
        WHEN last_3_month_purchase_freq BETWEEN 5 AND 9
            THEN '5-9 Purchases'
        WHEN last_3_month_purchase_freq >= 10
            THEN '10+ Purchases'
    END AS purchase_frequency_group,


    -- =========================================
    -- DELIVERY DELAY GROUP
    -- =========================================
    CASE
        WHEN delivery_delay_days = 0
            THEN 'No Delay'
        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN '1-2 Days'
        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN '3-5 Days'
        WHEN delivery_delay_days > 5
            THEN '6+ Days'
    END AS delivery_delay_group,


    -- =========================================
    -- REFUND STATUS
    -- =========================================
    CASE
        WHEN refund_requested = 1
            THEN 'Refund Requested'
        ELSE 'No Refund'
    END AS refund_status,


    -- =========================================
    -- DISCOUNT STATUS
    -- =========================================
    CASE
        WHEN discount_used = 1
            THEN 'Used Discount'
        ELSE 'No Discount'
    END AS discount_status


FROM dbo.Data_cust_Clean;

----------- CHECK TYPE DATA ALL -------------

SELECT
    column_ordinal,
    name AS column_name,
    system_type_name AS data_type,
    is_nullable,
    error_number,
    error_message
FROM sys.dm_exec_describe_first_result_set
(
N'
SELECT

    customer_id,
    gender,
    age,
    country,
    city,

    signup_date,
    last_purchase_date,

    acquisition_channel,
    subscription_type,
    is_premium_user,

    CASE
        WHEN is_premium_user = 1
            THEN ''Premium''
        ELSE ''Non-Premium''
    END AS premium_status,

    total_visits,

    CAST(email_open_rate AS DECIMAL(5,2))
        AS email_open_rate,

    CAST(email_click_rate AS DECIMAL(5,2))
        AS email_click_rate,

    total_spent,
    avg_order_value,
    lifetime_value,

    discount_used,
    coupon_code,
    marketing_spend_per_user,

    support_tickets,
    refund_requested,
    delivery_delay_days,

    payment_method,

    satisfaction_score,
    nps_score,

    last_3_month_purchase_freq,

    churn,

    CASE
        WHEN churn = 1
            THEN ''Churn''
        ELSE ''Active''
    END AS churn_status,

    CASE
        WHEN satisfaction_score <= 2
            THEN ''Low''
        WHEN satisfaction_score = 3
            THEN ''Medium''
        WHEN satisfaction_score >= 4
            THEN ''High''
    END AS satisfaction_group,

    CASE
        WHEN nps_score <= 6
            THEN ''Detractor''
        WHEN nps_score <= 8
            THEN ''Passive''
        WHEN nps_score >= 9
            THEN ''Promoter''
    END AS nps_group,

    CASE
        WHEN support_tickets = 0
            THEN ''0 Tickets''
        WHEN support_tickets BETWEEN 1 AND 4
            THEN ''1-4 Tickets''
        WHEN support_tickets >= 5
            THEN ''5+ Tickets''
    END AS support_ticket_group,

    CASE
        WHEN last_3_month_purchase_freq = 0
            THEN ''No Purchase''
        WHEN last_3_month_purchase_freq BETWEEN 1 AND 4
            THEN ''1-4 Purchases''
        WHEN last_3_month_purchase_freq BETWEEN 5 AND 9
            THEN ''5-9 Purchases''
        WHEN last_3_month_purchase_freq >= 10
            THEN ''10+ Purchases''
    END AS purchase_frequency_group,

    CASE
        WHEN delivery_delay_days = 0
            THEN ''No Delay''
        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN ''1-2 Days''
        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN ''3-5 Days''
        WHEN delivery_delay_days > 5
            THEN ''6+ Days''
    END AS delivery_delay_group,

    CASE
        WHEN refund_requested = 1
            THEN ''Refund Requested''
        ELSE ''No Refund''
    END AS refund_status,

    CASE
        WHEN discount_used = 1
            THEN ''Used Discount''
        ELSE ''No Discount''
    END AS discount_status

FROM dbo.Data_cust_Clean
',
NULL,
0
)
ORDER BY column_ordinal;