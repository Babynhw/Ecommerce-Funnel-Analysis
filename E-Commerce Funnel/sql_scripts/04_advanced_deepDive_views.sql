/* =======================================================================
   SCRIPT 04: HỆ THỐNG VIEW PHÂN TÍCH ĐA CHIỀU (DEEP-DIVE VIEWS)
======================================================================= */
USE EcommerceFunnel_D2C;
GO

-- VIEW 1: HIỆU SUẤT THEO KÊNH (CHANNEL)
CREATE OR ALTER VIEW vw_Analysis_Channel AS
SELECT 
    channel_clean,
    COUNT(*) AS Total_Sessions,
    FORMAT(SUM(CAST(purchase_completed AS INT)) * 1.0 / COUNT(*), 'P2') AS CVR,
    SUM(revenue) AS Total_Revenue,
    SUM(revenue) / COUNT(*) AS ARPS -- Revenue Per Session
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
GROUP BY channel_clean;
GO

-- VIEW 2: KHÁCH CŨ VS KHÁCH MỚI (USER TYPE)
CREATE OR ALTER VIEW vw_Analysis_UserType AS
SELECT 
    user_type,
    COUNT(*) AS Sessions,
    FORMAT(SUM(CASE WHEN drop_off_stage = '1. Bounced' THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P2') AS Bounce_Rate,
    FORMAT(SUM(CAST(purchase_completed AS INT)) * 1.0 / COUNT(*), 'P2') AS CVR,
    SUM(revenue) / NULLIF(SUM(CAST(purchase_completed AS INT)), 0) AS AOV
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
GROUP BY user_type;
GO

-- VIEW 3: LỖI TRẢI NGHIỆM THIẾT BỊ (DEVICE UX)
CREATE OR ALTER VIEW vw_Analysis_Device AS
SELECT 
    device,
    COUNT(*) AS Sessions,
    FORMAT(SUM(CASE WHEN drop_off_stage = '4. Dropped at Checkout' THEN 1 ELSE 0 END) * 1.0 / 
           NULLIF(SUM(CAST(checkout_started AS INT)), 0), 'P2') AS Checkout_Abandon_Rate
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
GROUP BY device;
GO

-- VIEW 4: SỨC MẠNH MÃ GIẢM GIÁ (PROMOTION)
CREATE OR ALTER VIEW vw_Analysis_Promotion AS
SELECT 
    discount_applied,
    COUNT(*) AS Sessions,
    FORMAT(SUM(CAST(purchase_completed AS INT)) * 1.0 / COUNT(*), 'P2') AS CVR,
    AVG(order_value) AS Avg_Order_Value
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
GROUP BY discount_applied;
GO

-- VIEW 5: PHÂN TÍCH VÙNG MIỀN (GEOGRAPHY)
CREATE OR ALTER VIEW vw_Analysis_Geography AS
SELECT 
    region,
    COUNT(*) AS Orders,
    SUM(revenue) AS Revenue,
    FORMAT(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM dbo.D2C_Funnel_Clean WHERE is_duplicate = 0), 'N2') + '%' AS Revenue_Share
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_purchase_completed = 1 AND is_outlier = 0
GROUP BY region;
GO

-- VIEW 6: DỮ LIỆU ĐỂ VẼ BIỂU ĐỒ PHỄU (FUNNEL STEPS)
CREATE OR ALTER VIEW vw_Analysis_Funnel_Steps AS
WITH Raw_Steps AS (
    SELECT 
        SUM(CAST(visited_website AS INT)) AS [Step 1],
        SUM(CAST(viewed_product AS INT)) AS [Step 2],
        SUM(CAST(added_to_cart AS INT)) AS [Step 3],
        SUM(CAST(checkout_started AS INT)) AS [Step 4],
        SUM(CAST(purchase_completed AS INT)) AS [Step 5]
    FROM dbo.D2C_Funnel_Clean
    WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
)
SELECT Stage, User_Count
FROM (
    SELECT '1. Visit' AS Stage, [Step 1] AS User_Count FROM Raw_Steps UNION ALL
    SELECT '2. View', [Step 2] FROM Raw_Steps UNION ALL
    SELECT '3. Cart', [Step 3] FROM Raw_Steps UNION ALL
    SELECT '4. Checkout', [Step 4] FROM Raw_Steps UNION ALL
    SELECT '5. Purchase', [Step 5] FROM Raw_Steps
) t;
GO

-- VIEW 7: CHI TIẾT ĐIỂM RỚT (DROP-OFF DETAILS)
CREATE OR ALTER VIEW vw_Analysis_DropOff_Details AS
SELECT 
    drop_off_stage,
    channel_clean,
    device,
    COUNT(*) AS User_Lost_Count,
    FORMAT(COUNT(*) * 1.0 / (SELECT COUNT(*) FROM dbo.D2C_Funnel_Clean WHERE is_duplicate = 0), 'P2') AS Percent_of_Total
FROM dbo.D2C_Funnel_Clean
WHERE is_duplicate = 0 AND is_funnel_anomaly = 0 AND is_outlier = 0
GROUP BY drop_off_stage, channel_clean, device;
GO