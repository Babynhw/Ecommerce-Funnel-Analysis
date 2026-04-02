/* =======================================================================
   SCRIPT 01: KHỞI TẠO DATABASE VÀ BẢNG STAGING (RAW DATA)
   Mục đích: Tạo môi trường và bảng chứa dữ liệu thô nhập từ CSV
======================================================================= */

-- 1. Tạo Database (Nếu chưa có)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EcommerceFunnel_D2C')
BEGIN
    CREATE DATABASE EcommerceFunnel_D2C;
END
GO

USE EcommerceFunnel_D2C;
GO

-- 2. Xóa bảng Staging cũ nếu đã tồn tại để tránh rác
DROP TABLE IF EXISTS dbo.Staging_D2C_Funnel;
GO

-- 3. Tạo bảng Staging (Hứng dữ liệu thô từ Kaggle)
-- Lưu ý: Mọi trường đều để NVARCHAR để import an toàn, không bị crash do sai kiểu
CREATE TABLE dbo.Staging_D2C_Funnel (
    user_id              NVARCHAR(255),
    session_id           NVARCHAR(255),
    [date]               NVARCHAR(100),
    [month]              NVARCHAR(50),
    channel              NVARCHAR(100),
    campaign_type        NVARCHAR(100),
    device               NVARCHAR(100),
    user_type            NVARCHAR(100),
    region               NVARCHAR(100),
    
    visited_website      NVARCHAR(50),
    viewed_product       NVARCHAR(50),
    added_to_cart        NVARCHAR(50),
    checkout_started     NVARCHAR(50),
    purchase_completed   NVARCHAR(50),
    
    discount_applied     NVARCHAR(100),
    order_value          NVARCHAR(100),
    revenue              NVARCHAR(100)
);
GO

PRINT '=== Script 1: Đã tạo xong Database và Bảng Staging. Vui lòng Import file CSV vào bảng dbo.Staging_D2C_Funnel trước khi chạy Script 2 ===';