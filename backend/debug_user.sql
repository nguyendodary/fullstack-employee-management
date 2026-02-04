-- Kiểm tra database và bảng
SHOW DATABASES;
USE employee_management;
SHOW TABLES;

-- Tạo user với đúng database
CREATE USER IF NOT EXISTS 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';

-- Kiểm tra bảng có tồn tại không
SHOW TABLES LIKE 'employees';

-- Nếu bảng tồn tại, cấp quyền
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';

-- Nếu không có bảng employees, cần kiểm tra lại migration/khởi tạo schema thay vì cấp quyền rộng

FLUSH PRIVILEGES;

-- Kiểm tra user
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Kiểm tra quyền
SHOW GRANTS FOR 'third_party_viewer'@'%';
