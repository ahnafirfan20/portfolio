-- =========================================
-- AKTIFKAN DATABASE CRM_ANALYTICS
-- =========================================
USE CRM_Analytics;

-- Cek database yang sedang aktif
SELECT DB_NAME() AS database_aktif;

-- =========================================
-- CHECK MISSING VALUE
-- =========================================
SELECT
    COUNT(*) - COUNT(gender) AS gender_null,
    COUNT(*) - COUNT(age) AS age_null,
    COUNT(*) - COUNT(country) AS country_null,
    COUNT(*) - COUNT(city) AS city_null,
    COUNT(*) - COUNT(signup_date) AS signup_date_null,
    COUNT(*) - COUNT(last_purchase_date) AS last_purchase_date_null,
    COUNT(*) - COUNT(acquisition_channel) AS acquisition_channel_null,
    COUNT(*) - COUNT(device_type) AS device_type_null,
    COUNT(*) - COUNT(subscription_type) AS subscription_type_null,
    COUNT(*) - COUNT(avg_session_time) AS avg_session_time_null,
    COUNT(*) - COUNT(pages_per_session) AS pages_per_session_null,
    COUNT(*) - COUNT(email_open_rate) AS email_open_rate_null,
    COUNT(*) - COUNT(email_click_rate) AS email_click_rate_null,
    COUNT(*) - COUNT(total_spent) AS total_spent_null,
    COUNT(*) - COUNT(avg_order_value) AS avg_order_value_null,
    COUNT(*) - COUNT(coupon_code) AS coupon_code_null,
    COUNT(*) - COUNT(payment_method) AS payment_method_null,
    COUNT(*) - COUNT(marketing_spend_per_user) AS marketing_spend_null,
    COUNT(*) - COUNT(lifetime_value) AS lifetime_value_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- CHECK NUMERIC NULL
-- =========================================
SELECT
    'age' AS column_name,
    COUNT(*) AS null_count,
    AVG(CAST(age AS DECIMAL(18,2))) AS mean_value
FROM dbo.Data_cust_Clean
WHERE age IS NULL

UNION ALL

SELECT
    'total_visits',
    COUNT(*),
    AVG(CAST(total_visits AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE total_visits IS NULL

UNION ALL

SELECT
    'support_tickets',
    COUNT(*),
    AVG(CAST(support_tickets AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE support_tickets IS NULL

UNION ALL

SELECT
    'delivery_delay_days',
    COUNT(*),
    AVG(CAST(delivery_delay_days AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE delivery_delay_days IS NULL

UNION ALL

SELECT
    'satisfaction_score',
    COUNT(*),
    AVG(CAST(satisfaction_score AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE satisfaction_score IS NULL

UNION ALL

SELECT
    'nps_score',
    COUNT(*),
    AVG(CAST(nps_score AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE nps_score IS NULL

UNION ALL

SELECT
    'last_3_month_purchase_freq',
    COUNT(*),
    AVG(CAST(last_3_month_purchase_freq AS DECIMAL(18,2)))
FROM dbo.Data_cust_Clean
WHERE last_3_month_purchase_freq IS NULL;

-- =========================================
-- MENCARI MEDIAN
-- =========================================
SELECT DISTINCT
    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY age)
    OVER () AS median_age
FROM dbo.Data_cust_Clean
WHERE age IS NOT NULL;

SELECT DISTINCT
    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY satisfaction_score)
    OVER () AS median_satisfaction
FROM dbo.Data_cust_Clean
WHERE satisfaction_score IS NOT NULL;

-- =========================================
-- IMPUTASI MISSING VALUE
-- Numeric NULL → Median
-- =========================================

USE CRM_Analytics;

-- Isi NULL pada age dengan median = 35
UPDATE dbo.Data_cust_Clean
SET age = 35
WHERE age IS NULL;

-- Isi NULL pada satisfaction_score dengan median = 4
UPDATE dbo.Data_cust_Clean
SET satisfaction_score = 4
WHERE satisfaction_score IS NULL;

-- =========================================
-- VALIDASI IMPUTASI
-- =========================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(age) AS age_null,
    COUNT(*) - COUNT(satisfaction_score) AS satisfaction_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- CHECK CATEGORICAL NULL
-- =========================================
SELECT
    COUNT(*) - COUNT(gender) AS gender_null,
    COUNT(*) - COUNT(country) AS country_null,
    COUNT(*) - COUNT(city) AS city_null,
    COUNT(*) - COUNT(acquisition_channel) AS acquisition_channel_null,
    COUNT(*) - COUNT(device_type) AS device_type_null,
    COUNT(*) - COUNT(subscription_type) AS subscription_type_null,
    COUNT(*) - COUNT(coupon_code) AS coupon_code_null,
    COUNT(*) - COUNT(payment_method) AS payment_method_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- COUPON BUSINESS LOGIC
-- =========================================
SELECT
    discount_used,

    CASE
        WHEN coupon_code IS NULL THEN 'NULL'
        ELSE 'HAS_COUPON'
    END AS coupon_status,

    COUNT(*) AS jumlah

FROM dbo.Data_cust_Clean

GROUP BY
    discount_used,
    CASE
        WHEN coupon_code IS NULL THEN 'NULL'
        ELSE 'HAS_COUPON'
    END

ORDER BY
    discount_used,
    coupon_status;

-- =========================================
-- GENDER IMPUTATION
-- =========================================
UPDATE dbo.Data_cust_Clean
SET gender = 'Unknown'
WHERE gender IS NULL;

-- VALIDASI GENDER
SELECT
    COUNT(*) - COUNT(gender) AS gender_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- Cek apakah semua data avg_session_time abnormal
-- =========================================
SELECT
    COUNT(*) AS total_valid,
    
    SUM(
        CASE
            WHEN avg_session_time < 60
            THEN 1
            ELSE 0
        END
    ) AS below_60,

    SUM(
        CASE
            WHEN avg_session_time >= 60
             AND avg_session_time <= 1440
            THEN 1
            ELSE 0
        END
    ) AS between_60_1440,

    SUM(
        CASE
            WHEN avg_session_time > 1440
            THEN 1
            ELSE 0
        END
    ) AS above_1440

FROM dbo.Data_cust_Clean
WHERE avg_session_time IS NOT NULL;

-- =========================================
-- INVALID VALUE - AVG_SESSION_TIME
-- =========================================
-- Business Rule:
-- avg_session_time seharusnya merepresentasikan
-- rata-rata durasi session dalam satuan menit.
--
-- Hasil profiling:
-- Total non-NULL : 14,876
-- <= 1,440 menit : 0
-- > 1,440 menit  : 14,876
--
-- Kesimpulan:
-- 100% nilai non-NULL berada di atas 1 hari
-- sehingga dianggap invalid secara business logic.
--
-- Treatment:
-- Nilai invalid akan diubah menjadi NULL.

-- =========================================
-- Ubah nilai invalid menjadi NULL
-- =========================================
UPDATE dbo.Data_cust_Clean
SET avg_session_time = NULL
WHERE avg_session_time > 1440;

-- Validasi
SELECT
    COUNT(*) AS total_rows,
    COUNT(avg_session_time) AS remaining_valid,
    COUNT(*) - COUNT(avg_session_time) AS null_count
FROM dbo.Data_cust_Clean;

-- =========================================
-- PROFILING - PAGES PER SESSION
-- =========================================
SELECT
    MIN(pages_per_session) AS min_value,
    MAX(pages_per_session) AS max_value,
    AVG(pages_per_session) AS avg_value
FROM dbo.Data_cust_Clean;

-- =========================================
-- BUSINESS VALIDATION
-- =========================================
SELECT
    COUNT(*) AS total_valid,

    SUM(
        CASE
            WHEN pages_per_session < 1
            THEN 1
            ELSE 0
        END
    ) AS below_1,

    SUM(
        CASE
            WHEN pages_per_session >= 1
             AND pages_per_session <= 100
            THEN 1
            ELSE 0
        END
    ) AS between_1_100,

    SUM(
        CASE
            WHEN pages_per_session > 100
            THEN 1
            ELSE 0
        END
    ) AS above_100

FROM dbo.Data_cust_Clean
WHERE pages_per_session IS NOT NULL;

-- =========================================
-- INVALID VALUE PAGES PER SESSION
-- =========================================
UPDATE dbo.Data_cust_Clean
SET pages_per_session = NULL
WHERE pages_per_session > 100;

-- Validasi
SELECT
    COUNT(*) AS total_rows,
    COUNT(pages_per_session) AS remaining_valid,
    COUNT(*) - COUNT(pages_per_session) AS null_count
FROM dbo.Data_cust_Clean;

-- =========================================
-- INVALID VALUE - PAGES_PER_SESSION
-- =========================================
-- Business Rule:
-- pages_per_session seharusnya merepresentasikan
-- rata-rata jumlah halaman yang dilihat dalam satu session.
--
-- Hasil profiling:
-- Total non-NULL : 14,677
-- < 1 halaman    : 0
-- 1-100 halaman  : 0
-- > 100 halaman  : 14,677
--
-- Kesimpulan:
-- 100% nilai non-NULL berada di atas 100 halaman
-- sehingga dianggap invalid secara business logic.
--
-- Treatment:
-- Nilai invalid akan diubah menjadi NULL.

-- =========================================
-- PROFILING - TOTAL_SPENT
-- =========================================
SELECT
    MIN(total_spent) AS min_value,
    MAX(total_spent) AS max_value,
    AVG(total_spent) AS avg_value
FROM dbo.Data_cust_Clean;

-- =========================================
-- BUSINESS VALIDATION - TOTAL_SPENT
-- =========================================
SELECT
    COUNT(*) AS total_valid,

    SUM(
        CASE
            WHEN total_spent < 0
            THEN 1
            ELSE 0
        END
    ) AS below_0,

    SUM(
        CASE
            WHEN total_spent >= 0
             AND total_spent < 1000000000
            THEN 1
            ELSE 0
        END
    ) AS below_1_miliar,

    SUM(
        CASE
            WHEN total_spent >= 1000000000
             AND total_spent < 100000000000
            THEN 1
            ELSE 0
        END
    ) AS antara_1_100_miliar,

    SUM(
        CASE
            WHEN total_spent >= 100000000000
            THEN 1
            ELSE 0
        END
    ) AS diatas_100_miliar

FROM dbo.Data_cust_Clean
WHERE total_spent IS NOT NULL;

-- =========================================
-- BUSINESS VALIDATION - TOTAL_SPENT
-- =========================================
-- Mengecek konsistensi antara total_spent
-- dengan avg_order_value.
--
-- Rasio dihitung dengan:
-- total_spent / avg_order_value
--
-- Rasio < 1 menunjukkan total_spent
-- lebih kecil daripada avg_order_value.
-- =========================================

SELECT
    COUNT(*) AS total_data,

    SUM(
        CASE
            WHEN total_spent < avg_order_value
            THEN 1
            ELSE 0
        END
    ) AS total_spent_di_bawah_avg_order,

    SUM(
        CASE
            WHEN total_spent >= avg_order_value
            THEN 1
            ELSE 0
        END
    ) AS total_spent_di_atas_atau_sama

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL;

  -- =========================================
-- CEK NILAI YANG KONSISTEN
-- =========================================

SELECT TOP 20
    customer_id,
    total_spent,
    avg_order_value,
    total_spent / NULLIF(avg_order_value, 0)
        AS rasio_total_dan_avg_order

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND total_spent >= avg_order_value

ORDER BY rasio_total_dan_avg_order DESC;

-- =========================================
-- BUSINESS VALIDATION - TOTAL_SPENT
-- =========================================
-- Mengecek konsistensi total_spent dengan
-- avg_order_value pada customer yang memiliki
-- riwayat pembelian dalam 3 bulan terakhir.
--
-- Jika purchase frequency > 0, maka customer
-- memiliki setidaknya satu transaksi.
--
-- Dalam kondisi tersebut, total_spent yang lebih
-- kecil daripada avg_order_value perlu diperiksa.
-- =========================================
SELECT
    COUNT(*) AS total_customer_dengan_pembelian,

    SUM(
        CASE
            WHEN total_spent < avg_order_value
            THEN 1
            ELSE 0
        END
    ) AS total_tidak_konsisten,

    SUM(
        CASE
            WHEN total_spent >= avg_order_value
            THEN 1
            ELSE 0
        END
    ) AS total_konsisten

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND last_3_month_purchase_freq > 0;

  -- =========================================
-- CEK CONTOH DATA TIDAK KONSISTEN
-- TOTAL_SPENT DAN AVG_ORDER_VALUE
-- =========================================

SELECT TOP 20
    customer_id,
    total_spent,
    avg_order_value,
    last_3_month_purchase_freq
FROM dbo.Data_cust_Clean
WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL
  AND last_3_month_purchase_freq > 0
  AND total_spent < avg_order_value
ORDER BY total_spent ASC;

-- =========================================
-- BUSINESS VALIDATION - AVG_ORDER_VALUE
-- =========================================

SELECT
    COUNT(*) AS total_valid,

    SUM(
        CASE
            WHEN avg_order_value <= 0
            THEN 1
            ELSE 0
        END
    ) AS nilai_tidak_valid,

    SUM(
        CASE
            WHEN avg_order_value > 0
             AND avg_order_value <= 1000000
            THEN 1
            ELSE 0
        END
    ) AS sampai_1_juta,

    SUM(
        CASE
            WHEN avg_order_value > 1000000
             AND avg_order_value <= 100000000
            THEN 1
            ELSE 0
        END
    ) AS antara_1_100_juta,

    SUM(
        CASE
            WHEN avg_order_value > 100000000
            THEN 1
            ELSE 0
        END
    ) AS diatas_100_juta

FROM dbo.Data_cust_Clean
WHERE avg_order_value IS NOT NULL;

-- =========================================
-- CEK RASIO AVG_ORDER_VALUE
-- TERHADAP TOTAL_SPENT
-- =========================================

SELECT TOP 20
    customer_id,
    total_spent,
    avg_order_value,

    avg_order_value / NULLIF(total_spent, 0)
        AS rasio_avg_order_dan_total

FROM dbo.Data_cust_Clean

WHERE total_spent IS NOT NULL
  AND avg_order_value IS NOT NULL

ORDER BY rasio_avg_order_dan_total DESC;

-- =========================================
-- VALIDASI BUSINESS - AVG_ORDER_VALUE
-- =========================================
-- Business Rule:
-- avg_order_value seharusnya merepresentasikan
-- rata-rata nilai transaksi customer.
--
-- Hasil profiling:
-- Total non-NULL : 14.967
-- Nilai <= 0     : 0
-- <= 1 juta      : 0
-- 1-100 juta     : 0
-- > 100 juta     : 14.967
--
-- Hasil validasi:
-- Ditemukan ketidakkonsistenan skala yang signifikan
-- antara avg_order_value dengan total_spent.
--
-- Kesimpulan:
-- Seluruh nilai berada di atas 100 juta dan terdapat
-- perbedaan skala yang ekstrem dengan total_spent.
-- Namun, belum tersedia business rule yang cukup kuat
-- untuk menentukan batas nilai yang valid.
--
-- Treatment:
-- Nilai belum diubah dan tetap dipertahankan.
-- Temuan dicatat sebagai anomali yang memerlukan
-- validasi lebih lanjut terhadap sumber dataset.

-- =========================================
-- PROFILING - LIFETIME_VALUE
-- =========================================
SELECT
    MIN(lifetime_value) AS min_value,
    MAX(lifetime_value) AS max_value,
    AVG(lifetime_value) AS avg_value
FROM dbo.Data_cust_Clean;

-- =========================================
-- MELIHAT NILAI TERKECIL
-- LIFETIME_VALUE
-- =========================================
SELECT TOP 20
    customer_id,
    lifetime_value
FROM dbo.Data_cust_Clean
WHERE lifetime_value IS NOT NULL
ORDER BY lifetime_value ASC;

-- =========================================
-- MELIHAT NILAI TERBESAR
-- LIFETIME_VALUE
-- =========================================
SELECT TOP 20
    customer_id,
    lifetime_value
FROM dbo.Data_cust_Clean
WHERE lifetime_value IS NOT NULL
ORDER BY lifetime_value DESC;

-- =========================================
-- BUSINESS VALIDATION - LIFETIME_VALUE
-- =========================================
-- Business Rule:
-- lifetime_value seharusnya merepresentasikan
-- nilai ekonomi customer selama hubungan dengan bisnis.
--
-- Hasil profiling:
-- Total non-NULL : 14.997
-- Nilai <= 0     : ?
--
-- Kesimpulan:
-- Nilai <= 0 akan dianggap tidak valid
-- apabila ditemukan.
--
-- Treatment:
-- Nilai invalid akan diubah menjadi NULL.

-- =========================================
-- BUSINESS VALIDATION
-- =========================================
SELECT
    COUNT(*) AS total_valid,

    SUM(
        CASE
            WHEN lifetime_value <= 0
            THEN 1
            ELSE 0
        END
    ) AS nilai_tidak_valid,

    SUM(
        CASE
            WHEN lifetime_value > 0
            THEN 1
            ELSE 0
        END
    ) AS nilai_valid

FROM dbo.Data_cust_Clean
WHERE lifetime_value IS NOT NULL;

-- =========================================
-- BUSINESS VALIDATION - LIFETIME_VALUE
-- =========================================
-- Mengecek konsistensi lifetime_value
-- dengan total_spent.
--
-- Business Rule:
-- lifetime_value yang lebih kecil daripada
-- total_spent perlu diperiksa karena LTV
-- seharusnya merepresentasikan nilai customer
-- selama hubungan dengan bisnis.
--
-- Catatan:
-- Kondisi ini merupakan indikasi ketidakkonsistenan,
-- bukan otomatis berarti nilai invalid.
-- =========================================

SELECT
    COUNT(*) AS total_data,

    SUM(
        CASE
            WHEN lifetime_value < total_spent
            THEN 1
            ELSE 0
        END
    ) AS lifetime_dibawah_total_spent,

    SUM(
        CASE
            WHEN lifetime_value >= total_spent
            THEN 1
            ELSE 0
        END
    ) AS lifetime_diatas_atau_sama

FROM dbo.Data_cust_Clean
WHERE lifetime_value IS NOT NULL
  AND total_spent IS NOT NULL;

-- =========================================
-- BUSINESS VALIDATION - LIFETIME_VALUE
-- =========================================
-- Business Rule:
-- lifetime_value seharusnya merepresentasikan
-- nilai ekonomi customer selama hubungan dengan bisnis.
--
-- Hasil profiling:
-- Total non-NULL : 14.997
-- Nilai <= 0     : 0
-- Nilai > 0      : 14.997
--
-- Hasil validasi:
-- 9.273 dari 13.942 data yang dapat dibandingkan
-- memiliki lifetime_value lebih kecil daripada total_spent.
--
-- Kesimpulan:
-- Ditemukan ketidakkonsistenan antara lifetime_value
-- dan total_spent pada sebagian besar data.
-- Namun, ketidakkonsistenan antar-kolom belum cukup
-- untuk menyatakan lifetime_value sebagai nilai invalid.
--
-- Treatment:
-- Nilai lifetime_value tidak diubah dan tetap dipertahankan.

-- =========================================
-- MISSING VALUE - COUPON_CODE
-- =========================================
-- Mengecek hubungan antara coupon_code
-- dengan penggunaan diskon.
-- =========================================
SELECT
    discount_used,
    CASE
        WHEN coupon_code IS NULL THEN 'NULL'
        ELSE 'ADA_COUPON'
    END AS coupon_status,
    COUNT(*) AS jumlah
FROM dbo.Data_cust_Clean
GROUP BY
    discount_used,
    CASE
        WHEN coupon_code IS NULL THEN 'NULL'
        ELSE 'ADA_COUPON'
    END
ORDER BY
    discount_used,
    coupon_status;

-- =========================================
-- ANALISIS MISSING VALUE - COUPON_CODE
-- =========================================
-- Menghitung persentase NULL berdasarkan
-- status penggunaan diskon.
-- =========================================
SELECT
    discount_used,

    COUNT(*) AS jumlah_customer,

    SUM(
        CASE
            WHEN coupon_code IS NULL
            THEN 1
            ELSE 0
        END
    ) AS jumlah_coupon_null,

    CAST(
        SUM(
            CASE
                WHEN coupon_code IS NULL
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS persentase_null

FROM dbo.Data_cust_Clean

GROUP BY discount_used
ORDER BY discount_used;

-- =========================================
-- MISSING VALUE - COUPON_CODE
-- =========================================
-- Business Rule:
-- coupon_code seharusnya merepresentasikan
-- kode kupon yang digunakan oleh customer.
--
-- Hasil profiling:
-- Total NULL : 6.133
--
-- Hasil validasi:
-- discount_used = 0:
-- 3.046 dari 7.583 record memiliki coupon_code NULL
-- (40,17%).
--
-- discount_used = 1:
-- 3.087 dari 7.417 record memiliki coupon_code NULL
-- (41,62%).
--
-- Kesimpulan:
-- NULL pada coupon_code ditemukan baik pada customer
-- yang menggunakan maupun tidak menggunakan diskon.
-- Tidak terdapat informasi yang cukup untuk menentukan
-- kode coupon yang sebenarnya.
--
-- Treatment:
-- Nilai NULL dipertahankan dan tidak dilakukan imputasi
-- untuk menghindari pembuatan data coupon yang tidak valid.

-- =========================================
-- MISSING VALUE - TOTAL_SPENT
-- =========================================
-- Mengecek apakah NULL pada total_spent
-- berhubungan dengan aktivitas pembelian customer.
-- =========================================
SELECT
    CASE
        WHEN last_3_month_purchase_freq = 0
            THEN 'TIDAK ADA PEMBELIAN'
        WHEN last_3_month_purchase_freq > 0
            THEN 'ADA PEMBELIAN'
    END AS status_pembelian,

    COUNT(*) AS jumlah_customer,

    SUM(
        CASE
            WHEN total_spent IS NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_null

FROM dbo.Data_cust_Clean

GROUP BY
    CASE
        WHEN last_3_month_purchase_freq = 0
            THEN 'TIDAK ADA PEMBELIAN'
        WHEN last_3_month_purchase_freq > 0
            THEN 'ADA PEMBELIAN'
    END;

    -- =========================================
-- VALIDASI TOTAL_SPENT
-- CUSTOMER TANPA PEMBELIAN
-- =========================================
-- Mengecek apakah customer yang tidak memiliki
-- pembelian memiliki total_spent = 0.
-- =========================================
SELECT
    COUNT(*) AS total_tanpa_pembelian,

    SUM(
        CASE
            WHEN total_spent IS NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_null,

    SUM(
        CASE
            WHEN total_spent = 0
            THEN 1
            ELSE 0
        END
    ) AS total_spent_nol,

    SUM(
        CASE
            WHEN total_spent > 0
            THEN 1
            ELSE 0
        END
    ) AS total_spent_lebih_dari_nol

FROM dbo.Data_cust_Clean

WHERE last_3_month_purchase_freq = 0;

-- =========================================
-- VALIDASI TOTAL_SPENT NULL
-- BERDASARKAN LAST PURCHASE DATE
-- =========================================
SELECT
    CASE
        WHEN last_purchase_date IS NULL
            THEN 'TIDAK ADA TANGGAL PEMBELIAN'
        ELSE 'ADA TANGGAL PEMBELIAN'
    END AS status_last_purchase,

    COUNT(*) AS jumlah_customer

FROM dbo.Data_cust_Clean

WHERE total_spent IS NULL

GROUP BY
    CASE
        WHEN last_purchase_date IS NULL
            THEN 'TIDAK ADA TANGGAL PEMBELIAN'
        ELSE 'ADA TANGGAL PEMBELIAN'
    END;

    -- =========================================
-- VALIDASI TOTAL_SPENT NULL
-- DENGAN KOLOM FINANSIAL LAIN
-- =========================================
SELECT
    COUNT(*) AS total_total_spent_null,

    SUM(
        CASE
            WHEN avg_order_value IS NULL
            THEN 1
            ELSE 0
        END
    ) AS avg_order_value_null,

    SUM(
        CASE
            WHEN avg_order_value IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS avg_order_value_ada,

    SUM(
        CASE
            WHEN lifetime_value IS NULL
            THEN 1
            ELSE 0
        END
    ) AS lifetime_value_null,

    SUM(
        CASE
            WHEN lifetime_value IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS lifetime_value_ada

FROM dbo.Data_cust_Clean

WHERE total_spent IS NULL;

-- =========================================
-- MISSING VALUE - TOTAL_SPENT
-- =========================================
-- Business Rule:
-- total_spent merepresentasikan total pengeluaran
-- customer.
--
-- Hasil profiling:
-- Total NULL : 1.056
--
-- Hasil validasi:
-- Seluruh 1.056 record memiliki last_purchase_date.
--
-- Pada 1.056 record tersebut:
-- avg_order_value tersedia : 1.054
-- lifetime_value tersedia  : 1.055
--
-- Kesimpulan:
-- Meskipun informasi finansial lain tersedia,
-- tidak terdapat informasi yang cukup untuk
-- menghitung nilai total_spent yang sebenarnya.
--
-- Penggunaan avg_order_value dan
-- last_3_month_purchase_freq sebagai dasar
-- imputasi tidak dilakukan karena periode
-- pengukurannya belum dapat dipastikan sama.
--
-- Treatment:
-- Nilai NULL pada total_spent dipertahankan.
-- Tidak dilakukan imputasi untuk menghindari
-- pembuatan nilai yang tidak berdasarkan data aktual.

-- =========================================
-- MISSING VALUE - AVG_ORDER_VALUE
-- =========================================
-- Mengecek hubungan NULL avg_order_value
-- dengan aktivitas pembelian customer.
-- =========================================
SELECT
    COUNT(*) AS total_avg_order_value_null,

    SUM(
        CASE
            WHEN last_3_month_purchase_freq = 0
            THEN 1
            ELSE 0
        END
    ) AS tidak_ada_pembelian_3_bulan,

    SUM(
        CASE
            WHEN last_3_month_purchase_freq > 0
            THEN 1
            ELSE 0
        END
    ) AS ada_pembelian_3_bulan,

    SUM(
        CASE
            WHEN total_spent IS NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_juga_null,

    SUM(
        CASE
            WHEN total_spent IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_tersedia

FROM dbo.Data_cust_Clean

WHERE avg_order_value IS NULL;

-- =========================================
-- MISSING VALUE - AVG_ORDER_VALUE
-- =========================================
-- Business Rule:
-- avg_order_value merepresentasikan rata-rata
-- nilai transaksi customer.
--
-- Hasil profiling:
-- Total NULL : 33
--
-- Hasil validasi:
-- Tidak ada customer dengan NULL
-- avg_order_value yang memiliki
-- purchase frequency = 0.
--
-- Seluruh 33 customer memiliki aktivitas
-- pembelian dalam 3 bulan terakhir.
--
-- Dari 33 record:
-- total_spent tersedia : 31
-- total_spent NULL     : 2
--
-- Kesimpulan:
-- NULL pada avg_order_value tidak dapat
-- diasumsikan sebagai 0 karena seluruh customer
-- memiliki aktivitas pembelian.
--
-- Nilai avg_order_value juga tidak dihitung
-- menggunakan total_spent / purchase_frequency
-- karena periode dan definisi kedua variabel
-- belum dapat dipastikan sama.
--
-- Treatment:
-- Nilai NULL pada avg_order_value dipertahankan.
-- Tidak dilakukan imputasi untuk menghindari
-- pembuatan nilai transaksi yang tidak berdasarkan
-- data aktual.

-- =========================================
-- MISSING VALUE - LIFETIME_VALUE
-- =========================================
-- Mengecek kondisi customer yang memiliki
-- lifetime_value NULL.
-- =========================================
SELECT
    COUNT(*) AS total_lifetime_value_null,

    SUM(
        CASE
            WHEN total_spent IS NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_juga_null,

    SUM(
        CASE
            WHEN total_spent IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS total_spent_tersedia,

    SUM(
        CASE
            WHEN last_purchase_date IS NULL
            THEN 1
            ELSE 0
        END
    ) AS last_purchase_date_null,

    SUM(
        CASE
            WHEN last_purchase_date IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS last_purchase_date_tersedia

FROM dbo.Data_cust_Clean

WHERE lifetime_value IS NULL;

-- =========================================
-- CLEANING INVALID DATE
-- =========================================
-- last_purchase_date tidak boleh lebih awal
-- daripada signup_date.
--
-- Nilai yang melanggar business rule
-- diubah menjadi NULL karena tanggal
-- sebenarnya tidak dapat ditentukan.
-- =========================================
UPDATE dbo.Data_cust_Clean
SET last_purchase_date = NULL
WHERE last_purchase_date < signup_date;

-- Validasi
SELECT
    COUNT(*) AS jumlah_invalid_date
FROM dbo.Data_cust_Clean
WHERE last_purchase_date < signup_date;

-- =========================================
-- FINAL QUALITY CHECK - JUMLAH DATA
-- =========================================
SELECT
    COUNT(*) AS total_rows
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL QUALITY CHECK - DUPLICATE
-- =========================================
SELECT
    customer_id,
    COUNT(*) AS jumlah
FROM dbo.Data_cust_Clean
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;

-- =========================================
-- FINAL QUALITY CHECK - DATE
-- =========================================
SELECT
    COUNT(*) AS invalid_date
FROM dbo.Data_cust_Clean
WHERE last_purchase_date < signup_date;

-- =========================================
-- FINAL QUALITY CHECK - AGE
-- =========================================
SELECT
    COUNT(*) AS invalid_age
FROM dbo.Data_cust_Clean
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100);

-- =========================================
-- FINAL QUALITY CHECK - SATISFACTION
-- =========================================
SELECT
    COUNT(*) AS invalid_satisfaction
FROM dbo.Data_cust_Clean
WHERE satisfaction_score IS NOT NULL
  AND (satisfaction_score < 1 OR satisfaction_score > 5);

-- =========================================
-- FINAL QUALITY CHECK - AVG_SESSION_TIME
-- =========================================
SELECT
    COUNT(*) AS nilai_tersedia,
    COUNT(*) - COUNT(avg_session_time) AS nilai_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL QUALITY CHECK - PAGES_PER_SESSION
-- =========================================
SELECT
    COUNT(*) AS nilai_tersedia,
    COUNT(*) - COUNT(pages_per_session) AS nilai_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL QUALITY CHECK - NULL
-- =========================================
SELECT
    COUNT(*) - COUNT(customer_id) AS customer_id_null,
    COUNT(*) - COUNT(gender) AS gender_null,
    COUNT(*) - COUNT(age) AS age_null,
    COUNT(*) - COUNT(country) AS country_null,
    COUNT(*) - COUNT(city) AS city_null,
    COUNT(*) - COUNT(signup_date) AS signup_date_null,
    COUNT(*) - COUNT(last_purchase_date) AS last_purchase_date_null,
    COUNT(*) - COUNT(acquisition_channel) AS acquisition_channel_null,
    COUNT(*) - COUNT(device_type) AS device_type_null,
    COUNT(*) - COUNT(subscription_type) AS subscription_type_null,
    COUNT(*) - COUNT(is_premium_user) AS is_premium_user_null,
    COUNT(*) - COUNT(total_visits) AS total_visits_null,
    COUNT(*) - COUNT(avg_session_time) AS avg_session_time_null,
    COUNT(*) - COUNT(pages_per_session) AS pages_per_session_null,
    COUNT(*) - COUNT(email_open_rate) AS email_open_rate_null,
    COUNT(*) - COUNT(email_click_rate) AS email_click_rate_null,
    COUNT(*) - COUNT(total_spent) AS total_spent_null,
    COUNT(*) - COUNT(avg_order_value) AS avg_order_value_null,
    COUNT(*) - COUNT(discount_used) AS discount_used_null,
    COUNT(*) - COUNT(coupon_code) AS coupon_code_null,
    COUNT(*) - COUNT(support_tickets) AS support_tickets_null,
    COUNT(*) - COUNT(refund_requested) AS refund_requested_null,
    COUNT(*) - COUNT(delivery_delay_days) AS delivery_delay_days_null,
    COUNT(*) - COUNT(payment_method) AS payment_method_null,
    COUNT(*) - COUNT(satisfaction_score) AS satisfaction_score_null,
    COUNT(*) - COUNT(nps_score) AS nps_score_null,
    COUNT(*) - COUNT(marketing_spend_per_user) AS marketing_spend_per_user_null,
    COUNT(*) - COUNT(lifetime_value) AS lifetime_value_null,
    COUNT(*) - COUNT(last_3_month_purchase_freq) AS last_3_month_purchase_freq_null,
    COUNT(*) - COUNT(churn) AS churn_null
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL QUALITY CHECK - NUMERIC
-- =========================================
SELECT
    SUM(
        CASE
            WHEN age IS NOT NULL
             AND (age < 18 OR age > 100)
            THEN 1 ELSE 0
        END
    ) AS invalid_age,

    SUM(
        CASE
            WHEN satisfaction_score IS NOT NULL
             AND (satisfaction_score < 1 OR satisfaction_score > 5)
            THEN 1 ELSE 0
        END
    ) AS invalid_satisfaction,

    SUM(
        CASE
            WHEN nps_score IS NOT NULL
             AND (nps_score < 0 OR nps_score > 10)
            THEN 1 ELSE 0
        END
    ) AS invalid_nps,

    SUM(
        CASE
            WHEN total_visits IS NOT NULL
             AND total_visits < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_total_visits,

    SUM(
        CASE
            WHEN support_tickets IS NOT NULL
             AND support_tickets < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_support_tickets,

    SUM(
        CASE
            WHEN delivery_delay_days IS NOT NULL
             AND delivery_delay_days < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_delivery_delay

FROM dbo.Data_cust_Clean;

-- =========================================
-- CEK NILAI INVALID AGE YANG MASIH TERSISA
-- =========================================
SELECT
    age,
    COUNT(*) AS jumlah
FROM dbo.Data_cust_Clean
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100)
GROUP BY age
ORDER BY age;

-- =========================================
-- CLEANING INVALID VALUE - AGE
-- =========================================
-- Nilai age di luar rentang 18-100 dianggap
-- tidak valid.
--
-- Treatment:
-- Nilai invalid diganti dengan median age = 35.
-- =========================================
UPDATE dbo.Data_cust_Clean
SET age = 35
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100);

-- =========================================
-- VALIDASI CLEANING - AGE
-- =========================================
SELECT
    COUNT(*) AS invalid_age
FROM dbo.Data_cust_Clean
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100);

-- =========================================
-- CLEANING INVALID VALUE - AGE
-- =========================================
-- Business Rule:
-- age seharusnya berada pada rentang usia
-- yang wajar untuk customer, yaitu 18-100 tahun.
--
-- Hasil profiling:
-- Ditemukan 516 record dengan nilai age
-- di luar rentang 18-100 tahun.
--
-- Contoh nilai invalid:
-- -4, -2, -1, 0, 2, 3, 4, 5, 6, dan lainnya.
--
-- Kesimpulan:
-- Nilai tersebut dianggap invalid karena
-- tidak merepresentasikan usia customer yang valid.
--
-- Treatment:
-- Nilai age yang invalid diganti dengan
-- median age sebesar 35 tahun.

-- =========================================
-- FINAL QUALITY CHECK - JUMLAH DATA
-- =========================================
-- Memastikan jumlah record tetap sama
-- setelah proses cleaning.
-- =========================================
SELECT
    COUNT(*) AS total_rows
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL QUALITY CHECK - DUPLICATE
-- =========================================
-- Memastikan setiap customer_id hanya
-- memiliki satu record.
-- =========================================
SELECT
    customer_id,
    COUNT(*) AS jumlah_record
FROM dbo.Data_cust_Clean
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY jumlah_record DESC;

-- =========================================
-- FINAL QUALITY CHECK - CUSTOMER_ID
-- =========================================
SELECT
    COUNT(*) AS customer_id_null
FROM dbo.Data_cust_Clean
WHERE customer_id IS NULL;

-- =========================================
-- FINAL QUALITY CHECK - DATE
-- =========================================
-- Memastikan last_purchase_date tidak
-- lebih awal daripada signup_date.
-- =========================================
SELECT
    COUNT(*) AS invalid_date
FROM dbo.Data_cust_Clean
WHERE last_purchase_date < signup_date;

-- =========================================
-- FINAL QUALITY CHECK - BOOLEAN
-- =========================================
-- Memastikan seluruh kolom BIT hanya memiliki
-- nilai 0, 1, atau NULL.
-- =========================================
SELECT
    SUM(
        CASE
            WHEN is_premium_user NOT IN (0,1)
            THEN 1 ELSE 0
        END
    ) AS invalid_is_premium_user,

    SUM(
        CASE
            WHEN discount_used NOT IN (0,1)
            THEN 1 ELSE 0
        END
    ) AS invalid_discount_used,

    SUM(
        CASE
            WHEN refund_requested NOT IN (0,1)
            THEN 1 ELSE 0
        END
    ) AS invalid_refund_requested,

    SUM(
        CASE
            WHEN churn NOT IN (0,1)
            THEN 1 ELSE 0
        END
    ) AS invalid_churn

FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL NULL AUDIT
-- =========================================
-- Mengecek seluruh NULL yang masih terdapat
-- pada dataset setelah proses cleaning.
-- =========================================
SELECT
    COUNT(*) - COUNT(customer_id) AS customer_id_null,
    COUNT(*) - COUNT(gender) AS gender_null,
    COUNT(*) - COUNT(age) AS age_null,
    COUNT(*) - COUNT(country) AS country_null,
    COUNT(*) - COUNT(city) AS city_null,
    COUNT(*) - COUNT(signup_date) AS signup_date_null,
    COUNT(*) - COUNT(last_purchase_date) AS last_purchase_date_null,
    COUNT(*) - COUNT(acquisition_channel) AS acquisition_channel_null,
    COUNT(*) - COUNT(device_type) AS device_type_null,
    COUNT(*) - COUNT(subscription_type) AS subscription_type_null,
    COUNT(*) - COUNT(is_premium_user) AS is_premium_user_null,
    COUNT(*) - COUNT(total_visits) AS total_visits_null,
    COUNT(*) - COUNT(avg_session_time) AS avg_session_time_null,
    COUNT(*) - COUNT(pages_per_session) AS pages_per_session_null,
    COUNT(*) - COUNT(email_open_rate) AS email_open_rate_null,
    COUNT(*) - COUNT(email_click_rate) AS email_click_rate_null,
    COUNT(*) - COUNT(total_spent) AS total_spent_null,
    COUNT(*) - COUNT(avg_order_value) AS avg_order_value_null,
    COUNT(*) - COUNT(discount_used) AS discount_used_null,
    COUNT(*) - COUNT(coupon_code) AS coupon_code_null,
    COUNT(*) - COUNT(support_tickets) AS support_tickets_null,
    COUNT(*) - COUNT(refund_requested) AS refund_requested_null,
    COUNT(*) - COUNT(delivery_delay_days) AS delivery_delay_days_null,
    COUNT(*) - COUNT(payment_method) AS payment_method_null,
    COUNT(*) - COUNT(satisfaction_score) AS satisfaction_score_null,
    COUNT(*) - COUNT(nps_score) AS nps_score_null,
    COUNT(*) - COUNT(marketing_spend_per_user) AS marketing_spend_per_user_null,
    COUNT(*) - COUNT(lifetime_value) AS lifetime_value_null,
    COUNT(*) - COUNT(last_3_month_purchase_freq) AS last_3_month_purchase_freq_null,
    COUNT(*) - COUNT(churn) AS churn_null

FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL CLEANING - HAPUS KOLOM INVALID
-- =========================================
-- avg_session_time dan pages_per_session
-- dihapus dari dataset CLEAN karena seluruh
-- nilainya telah terbukti invalid.
--
-- Hasil profiling:
-- avg_session_time  : 100% NULL
-- pages_per_session : 100% NULL
--
-- Kesimpulan:
-- Kedua kolom tidak memiliki nilai valid
-- yang dapat digunakan untuk analisis.
--
-- Treatment:
-- Kolom dihapus dari Data_cust_Clean.
--
-- Catatan:
-- Dataset RAW tidak diubah.
-- =========================================
ALTER TABLE dbo.Data_cust_Clean
DROP COLUMN
    avg_session_time,
    pages_per_session;

-- =========================================
-- VALIDASI STRUKTUR DATASET CLEAN
-- =========================================
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Data_cust_Clean'
ORDER BY ORDINAL_POSITION;

-- =========================================
-- VALIDASI JUMLAH ROW SETELAH DROP COLUMN
-- =========================================
SELECT
    COUNT(*) AS total_rows
FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL INSPECTION - STRUKTUR DATASET
-- =========================================
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Data_cust_Clean'
ORDER BY ORDINAL_POSITION;

-- =========================================
-- FINAL INSPECTION - BUSINESS RULE
-- =========================================
SELECT
    SUM(
        CASE
            WHEN age IS NOT NULL
             AND (age < 18 OR age > 100)
            THEN 1 ELSE 0
        END
    ) AS invalid_age,

    SUM(
        CASE
            WHEN satisfaction_score IS NOT NULL
             AND (satisfaction_score < 1 OR satisfaction_score > 5)
            THEN 1 ELSE 0
        END
    ) AS invalid_satisfaction,

    SUM(
        CASE
            WHEN nps_score IS NOT NULL
             AND (nps_score < 0 OR nps_score > 10)
            THEN 1 ELSE 0
        END
    ) AS invalid_nps,

    SUM(
        CASE
            WHEN total_visits IS NOT NULL
             AND total_visits < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_total_visits,

    SUM(
        CASE
            WHEN support_tickets IS NOT NULL
             AND support_tickets < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_support_tickets,

    SUM(
        CASE
            WHEN delivery_delay_days IS NOT NULL
             AND delivery_delay_days < 0
            THEN 1 ELSE 0
        END
    ) AS invalid_delivery_delay,

    SUM(
        CASE
            WHEN last_purchase_date IS NOT NULL
             AND signup_date IS NOT NULL
             AND last_purchase_date < signup_date
            THEN 1 ELSE 0
        END
    ) AS invalid_date

FROM dbo.Data_cust_Clean;

-- =========================================
-- FINAL CHECK ROWS AND COLUMNS
-- =========================================
SELECT
    (SELECT COUNT(*)
     FROM dbo.Data_cust_Clean) AS total_rows,

    (SELECT COUNT(*)
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'dbo'
       AND TABLE_NAME = 'Data_cust_Clean') AS total_columns;

-- CHECK TOP 100 DATASET
SELECT TOP 100 *
FROM dbo.Data_cust_Clean;

-- End --