/* =======================================================================
   SCRIPT 02: LÀM SẠCH SÂU, LỌC TRÙNG LẶP & BÁO CÁO CHẤT LƯỢNG (ULTIMATE FIXED)
======================================================================= */
USE EcommerceFunnel_D2C;
GO

-- 1. TẠO BẢNG CLEAN VỚI CÁC TRƯỜNG TRACKING NÂNG CAO
DROP TABLE IF EXISTS dbo.D2C_Funnel_Clean;
GO

CREATE TABLE dbo.D2C_Funnel_Clean (
    user_id              NVARCHAR(100) NOT NULL,
    session_id           NVARCHAR(150) NOT NULL,
    [date]               DATE,
    [month]              NVARCHAR(20),
    channel_raw          NVARCHAR(50),
    channel_clean        NVARCHAR(50), 
    campaign_type        NVARCHAR(50),
    device               NVARCHAR(50),
    user_type            NVARCHAR(50),
    region               NVARCHAR(50),
    
    visited_website      BIT,
    viewed_product       BIT,
    added_to_cart        BIT,
    checkout_started     BIT,
    purchase_completed   BIT,
    
    discount_applied     DECIMAL(18,2),
    order_value          DECIMAL(18,2),
    revenue              DECIMAL(18,2),

    -- FEATURE ENGINEERING & FLAG (Cắm cờ)
    drop_off_stage       NVARCHAR(50), 
    revenue_category     NVARCHAR(50), 
    is_duplicate         BIT,          -- Cờ đánh dấu dòng trùng lặp
    is_funnel_anomaly    BIT,          
    anomaly_reason       NVARCHAR(255),
    is_outlier           BIT           
);
GO

-- 2. XỬ LÝ DỮ LIỆU, BẮT TRÙNG LẶP & BẮT LỖI
WITH CTE_Dedup AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(
            PARTITION BY session_id 
            ORDER BY [date] DESC 
        ) AS row_num
    FROM dbo.Staging_D2C_Funnel
    WHERE session_id IS NOT NULL 
),
CTE_Base AS (
    SELECT 
        TRIM(user_id) AS user_id, 
        TRIM(session_id) AS session_id, 
        TRY_CAST([date] AS DATE) AS [date], 
        TRIM([month]) AS [month], 
        TRIM(channel) AS channel_raw,
        
        CASE 
            WHEN NULLIF(TRIM(channel), '') IS NULL THEN 'Unknown'
            WHEN LOWER(TRIM(channel)) = 'paid ads' THEN 'Paid Ads'
            WHEN LOWER(TRIM(channel)) = 'organic' THEN 'Organic'
            WHEN LOWER(TRIM(channel)) = 'social' THEN 'Social'
            WHEN LOWER(TRIM(channel)) = 'email' THEN 'Email'
            ELSE TRIM(channel) 
        END AS channel_clean,

        LOWER(TRIM(campaign_type)) AS campaign_type, 
        LOWER(TRIM(device)) AS device, 
        LOWER(TRIM(user_type)) AS user_type, 
        TRIM(region) AS region,
        
        CASE WHEN LOWER(TRIM(visited_website)) = 'yes' THEN 1 ELSE 0 END AS visited_website,
        CASE WHEN LOWER(TRIM(viewed_product)) = 'yes' THEN 1 ELSE 0 END AS viewed_product,
        CASE WHEN LOWER(TRIM(added_to_cart)) = 'yes' THEN 1 ELSE 0 END AS added_to_cart,
        CASE WHEN LOWER(TRIM(checkout_started)) = 'yes' THEN 1 ELSE 0 END AS checkout_started,
        CASE WHEN LOWER(TRIM(purchase_completed)) = 'yes' THEN 1 ELSE 0 END AS purchase_completed,
        
        CASE WHEN NULLIF(TRIM(discount_applied), '') IS NULL OR LOWER(TRIM(discount_applied)) = 'no' THEN 0.00 ELSE TRY_CAST(TRIM(discount_applied) AS DECIMAL(18,2)) END AS discount_applied,
        CASE WHEN NULLIF(TRIM(order_value), '') IS NULL OR LOWER(TRIM(order_value)) = 'no' THEN 0.00 ELSE TRY_CAST(TRIM(order_value) AS DECIMAL(18,2)) END AS order_value,
        CASE WHEN NULLIF(TRIM(revenue), '') IS NULL OR LOWER(TRIM(revenue)) = 'no' THEN 0.00 ELSE TRY_CAST(TRIM(revenue) AS DECIMAL(18,2)) END AS revenue,
        
        CASE WHEN row_num > 1 THEN 1 ELSE 0 END AS is_duplicate
    FROM CTE_Dedup
)
-- [SỬA LỖI Ở ĐÂY]: Khai báo chính xác từng cột nhận dữ liệu thay vì dùng SELECT *
INSERT INTO dbo.D2C_Funnel_Clean (
    user_id, session_id, [date], [month], channel_raw, channel_clean, campaign_type, device, user_type, region,
    visited_website, viewed_product, added_to_cart, checkout_started, purchase_completed,
    discount_applied, order_value, revenue,
    drop_off_stage, revenue_category, is_duplicate, is_funnel_anomaly, anomaly_reason, is_outlier
)
SELECT 
    user_id, session_id, [date], [month], channel_raw, channel_clean, campaign_type, device, user_type, region,
    visited_website, viewed_product, added_to_cart, checkout_started, purchase_completed,
    discount_applied, order_value, revenue,
    
    -- XÁC ĐỊNH DROP-OFF
    CASE 
        WHEN purchase_completed = 1 THEN '5. Purchased'
        WHEN checkout_started = 1 THEN '4. Dropped at Checkout'
        WHEN added_to_cart = 1 THEN '3. Dropped at Cart'
        WHEN viewed_product = 1 THEN '2. Dropped at Product'
        WHEN visited_website = 1 THEN '1. Bounced'
        ELSE '0. Unknown'
    END AS drop_off_stage,

    -- PHÂN LOẠI DOANH THU 
    CASE 
        WHEN revenue > 20000 THEN 'Extremely High (Exclude)'
        WHEN revenue > 8000 THEN 'High Value / Suspicious'
        WHEN revenue > 0 THEN 'Normal Transaction'
        ELSE 'No Revenue'
    END AS revenue_category,

    is_duplicate, -- Trả cột cờ trùng lặp về đúng vị trí thứ 21

    -- BẮT LỖI LOGIC PHỄU
    CASE 
        WHEN purchase_completed = 1 AND added_to_cart = 0 THEN 1
        WHEN checkout_started = 1 AND viewed_product = 0 THEN 1
        WHEN added_to_cart = 1 AND viewed_product = 0 THEN 1
        ELSE 0 
    END AS is_funnel_anomaly,

    -- LƯU LẠI LÝ DO LỖI 
    CASE 
        WHEN purchase_completed = 1 AND added_to_cart = 0 THEN 'Error: Mua hàng nhưng không có sự kiện Add to Cart'
        WHEN checkout_started = 1 AND viewed_product = 0 THEN 'Error: Checkout nhưng không có sự kiện View Product'
        WHEN added_to_cart = 1 AND viewed_product = 0 THEN 'Error: Thêm vào giỏ nhưng không View Product'
        ELSE 'Valid'
    END AS anomaly_reason,

    -- BẮT OUTLIER 
    CASE 
        WHEN revenue > 20000 THEN 1 
        WHEN revenue < 0 THEN 1
        ELSE 0 
    END AS is_outlier

FROM CTE_Base;
GO

/* =======================================================================
   3. XUẤT BÁO CÁO KIỂM TOÁN DỮ LIỆU (DATA AUDIT REPORT)
======================================================================= */
PRINT N'=== BÁO CÁO CHẤT LƯỢNG LÀM SẠCH DỮ LIỆU ===';

SELECT 
    N'1. Tổng số dòng dữ liệu thô (Raw Data)' AS Metrics, 
    COUNT(*) AS Row_Count,
    '100.00%' AS Percentage_of_Total
FROM dbo.Staging_D2C_Funnel

UNION ALL

SELECT 
    N'2. Dòng bị Trùng lặp (Duplicate Sessions)', 
    COUNT(*),
    FORMAT(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean), 0), 'P2')
FROM dbo.D2C_Funnel_Clean 
WHERE is_duplicate = 1

UNION ALL

SELECT 
    N'3. Lỗi Logic Phễu (Bị ngược luồng/Mất sự kiện)', 
    COUNT(*),
    FORMAT(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean), 0), 'P2')
FROM dbo.D2C_Funnel_Clean 
WHERE is_funnel_anomaly = 1 AND is_duplicate = 0

UNION ALL

SELECT 
    N'4. Đơn hàng Suspicious (> 8,000)', 
    COUNT(*),
    FORMAT(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean), 0), 'P2')
FROM dbo.D2C_Funnel_Clean 
WHERE revenue_category = 'High Value / Suspicious' AND is_duplicate = 0

UNION ALL

SELECT 
    N'5. Outlier cần loại trừ (> 20,000 hoặc Doanh thu âm)', 
    COUNT(*),
    FORMAT(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean), 0), 'P2')
FROM dbo.D2C_Funnel_Clean 
WHERE is_outlier = 1 AND is_duplicate = 0

UNION ALL

SELECT 
    N'6. DỮ LIỆU SẠCH SẴN SÀNG PHÂN TÍCH (Valid Rows)', 
    COUNT(*),
    FORMAT(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean), 0), 'P2')
FROM dbo.D2C_Funnel_Clean 
WHERE is_funnel_anomaly = 0 
  AND is_outlier = 0 
  AND is_duplicate = 0; 
GO

PRINT N'=== MẪU CÁC DÒNG BỊ LỖI LOGIC ===';
SELECT TOP 5 session_id, viewed_product, added_to_cart, checkout_started, purchase_completed, anomaly_reason
FROM dbo.D2C_Funnel_Clean
WHERE is_funnel_anomaly = 1;