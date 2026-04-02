/* =======================================================================
   SCRIPT 03: PHÂN TÍCH CHỈ SỐ SỐNG CÒN (BASELINE METRICS)
======================================================================= */
USE EcommerceFunnel_D2C;
GO

-- BƯỚC 1: TÍNH TOÁN HIỆU SUẤT PHỄU (CVR TỪNG BƯỚC)
PRINT N'=== 1. TỶ LỆ CHUYỂN ĐỔI CHI TIẾT TỪNG BƯỚC (MICRO-CONVERSION) ===';
WITH Funnel_Base AS (
    SELECT 
        SUM(CAST(visited_website AS FLOAT)) AS S1_Visits,
        SUM(CAST(viewed_product AS FLOAT)) AS S2_Views,
        SUM(CAST(added_to_cart AS FLOAT)) AS S3_Carts,
        SUM(CAST(checkout_started AS FLOAT)) AS S4_Checkouts,
        SUM(CAST(purchase_completed AS FLOAT)) AS S5_Purchases
    FROM dbo.D2C_Funnel_Clean
    WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
)
SELECT 
    '1. Website -> Product View' AS Stage,
    FORMAT(S2_Views / NULLIF(S1_Visits, 0), 'P2') AS Conversion_Rate,
    FORMAT(1 - (S2_Views / NULLIF(S1_Visits, 0)), 'P2') AS Drop_off_Rate
FROM Funnel_Base
UNION ALL
SELECT 
    '2. Product View -> Add to Cart',
    FORMAT(S3_Carts / NULLIF(S2_Views, 0), 'P2'),
    FORMAT(1 - (S3_Carts / NULLIF(S2_Views, 0)), 'P2')
FROM Funnel_Base
UNION ALL
SELECT 
    '3. Add to Cart -> Checkout',
    FORMAT(S4_Checkouts / NULLIF(S3_Carts, 0), 'P2'),
    FORMAT(1 - (S4_Checkouts / NULLIF(S3_Carts, 0)), 'P2')
FROM Funnel_Base
UNION ALL
SELECT 
    '4. Checkout -> Purchase',
    FORMAT(S5_Purchases / NULLIF(S4_Checkouts, 0), 'P2'),
    FORMAT(1 - (S5_Purchases / NULLIF(S4_Checkouts, 0)), 'P2')
FROM Funnel_Base;

-- BƯỚC 2: TÍNH TOÁN DOANH THU & THẤT THOÁT (REVENUE & LEAKAGE)
PRINT N'=== 2. DOANH THU THỰC TẾ VÀ CHI PHÍ CƠ HỘI BỊ MẤT ===';
WITH Financial_Stats AS (
    SELECT 
        SUM(revenue) AS Actual_Revenue,
        SUM(CAST(purchase_completed AS INT)) AS Success_Orders,
        -- Tính AOV (Giá trị đơn trung bình)
        SUM(revenue) / NULLIF(SUM(CAST(purchase_completed AS INT)), 0) AS AOV,
        -- Đếm số người bỏ giỏ hàng (Cart Abandonment)
        COUNT(CASE WHEN drop_off_stage IN ('3. Dropped at Cart', '4. Dropped at Checkout') THEN 1 END) AS Abandoned_Sessions
    FROM dbo.D2C_Funnel_Clean
    WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
)
SELECT 
    FORMAT(Actual_Revenue, 'N0') AS [Tổng Doanh Thu],
    FORMAT(AOV, 'N0') AS [AOV (Đơn trung bình)],
    Abandoned_Sessions AS [Số Giỏ Hàng Bị Bỏ],
    -- Công thức: Tiền mất = Số giỏ bỏ rơi * AOV
    FORMAT(Abandoned_Sessions * AOV, 'N0') AS [Doanh Thu Thất Thoát Ước Tính]
FROM Financial_Stats;
GO