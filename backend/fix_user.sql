-- Kiểm tra user hiện tại
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Xóa user cũ nếu có
DROP USER IF EXISTS 'third_party_viewer'@'%';
DROP USER IF EXISTS 'third_party_viewer'@'localhost';

-- Tạo lại user với đúng cấu hình
CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024!';

-- Cấp quyền SELECT trên bảng employees
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Kiểm tra lại
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Kiểm tra quyền
SHOW GRANTS FOR 'third_party_viewer'@'%';
