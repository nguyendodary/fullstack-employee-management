-- =====================================================
-- TẠO DATABASE USER CHỈ ĐỌC (READ-ONLY) CHO BÊN THỨ BA
-- =====================================================
-- Script này tạo một MySQL user với quyền chỉ đọc dữ liệu
-- User có thể truy cập trực tiếp vào database nhưng không thể sửa/xóa

-- 1. Tạo user mới với password mạnh
-- Thay 'ReadOnlyAccess2024' bằng password của bạn
DROP USER IF EXISTS 'third_party_viewer'@'%';
DROP USER IF EXISTS 'third_party_viewer'@'localhost';
CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';

-- 2. Cấp quyền SELECT trên bảng employees (chỉ xem bảng nhân viên)
SET @employees_table_exists := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = 'employee_management'
    AND table_name = 'employees'
);

SET @grant_sql := IF(
  @employees_table_exists = 1,
  "GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%'",
  "SELECT 'ERROR: table employee_management.employees does not exist. Create schema first (start backend or run backend/init-database.sql).' AS message"
);

PREPARE stmt FROM @grant_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Không cấp quyền cho bất kỳ bảng nào khác ngoài employees

-- 4. Flush privileges để áp dụng thay đổi
FLUSH PRIVILEGES;

-- =====================================================
-- XÁC NHẬN QUYỀN ĐÃ CẤP
-- =====================================================

-- Kiểm tra user đã được tạo
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Kiểm tra quyền của user
SHOW GRANTS FOR 'third_party_viewer'@'%';

-- =====================================================
-- TEST KẾT NỐI (CHẠY BÊN THỨ BA)
-- =====================================================
/*
mysql -h your-server-host -u third_party_viewer -p employee_management

-- Sau khi kết nối, test các lệnh:
SHOW TABLES;                    -- Chỉ thấy bảng được cấp quyền
SELECT * FROM employees;        -- ✅ Được phép
SELECT * FROM departments;      -- ❌ Không được phép (nếu chưa cấp quyền)
INSERT INTO employees ...;      -- ❌ Bị từ chối
UPDATE employees SET ...;       -- ❌ Bị từ chối
DELETE FROM employees;          -- ❌ Bị từ chối
*/

-- =====================================================
-- BẢO MẬT QUAN TRỌNG
-- =====================================================

-- 1. THAY ĐỔI PASSWORD MẶC ĐỊNH NGAY LẬP TỨC!
-- 2. Giới hạn IP truy cập thay vì dùng '%' (tất cả IP):
--    CREATE USER 'third_party_viewer'@'192.168.1.100' IDENTIFIED BY 'password';
-- 3. Sử dụng SSL connection cho production
-- 4. Monitor access logs thường xuyên

-- =====================================================
-- QUYỀN HẠN HIỆN TẠI CỦA USER
-- =====================================================
-- ✅ Được phép:
--    - SELECT từ bảng employees
--    - SHOW DATABASES (chỉ thấy các database có quyền)
--    - SHOW TABLES (chỉ thấy bảng được cấp quyền)

-- ❌ Không được phép:
--    - INSERT, UPDATE, DELETE
--    - CREATE, ALTER, DROP
--    - INDEX, REFERENCES
--    - CREATE TEMPORARY TABLES
--    - LOCK TABLES
--    - CREATE VIEW
--    - SHOW CREATE TABLE
--    - TRUNCATE TABLE
