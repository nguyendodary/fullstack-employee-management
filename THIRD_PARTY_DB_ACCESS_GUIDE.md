# Hướng Dẫn Chia Sẻ Database Access Cho Bên Thứ Ba

## 🎯 Mục Tiêu
Tạo một MySQL user cấp thấp cho bên thứ ba truy cập trực tiếp vào database với quyền **chỉ đọc** (read-only) một bảng cụ thể.

Yêu cầu ở đây là **chỉ xem được duy nhất bảng `employees`**. Tất cả bảng khác (ví dụ `departments`, `users`, ...) đều **không được xem**.

## 📋 Yêu Cầu
- MySQL Server đang chạy
- Database `employee_management` đã tồn tại
- Quyền admin trên MySQL để tạo user

## 🚀 Bước 1: Tạo User Read-Only

### Chạy SQL Script
```bash
mysql -u root -p < backend/create-readonly-db-user.sql
```

### Hoặc chạy thủ công:
```sql
-- 1. Tạo user mới (thay password)
CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';

-- 2. Cấp quyền chỉ đọc trên bảng employees
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';

-- 3. Áp dụng thay đổi
FLUSH PRIVILEGES;
```

## 🔐 Bước 2: Cấu Hình Bảo Mật

### 2.1 Giới hạn IP Access (Rất quan trọng!)
Thay vì cho phép tất cả IP (`%`), hãy giới hạn chỉ IP cụ thể:

```sql
-- Xóa user cũ
DROP USER 'third_party_viewer'@'%';

-- Tạo user với IP cụ thể
CREATE USER 'third_party_viewer'@'192.168.1.100' IDENTIFIED BY 'ReadOnlyAccess2024';
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'192.168.1.100';
FLUSH PRIVILEGES;
```

### 2.2 Sử dụng SSL (Production)
```sql
-- Yêu cầu SSL connection
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%' REQUIRE SSL;
```

## 📡 Bước 3: Cung Cấp Thông Tin Cho Bên Thứ Ba

### Thông tin cần cung cấp:
```
Host: your-server-ip-or-domain
Port: 3306 (MySQL default)
Database: employee_management
Username: third_party_viewer
Password: [password bạn đã tạo]
SSL: Required (nếu đã cấu hình)
```

### Connection String Examples:

**MySQL Command Line:**
```bash
mysql -h your-server-host -u third_party_viewer -p employee_management
```

**Python (mysql-connector):**
```python
import mysql.connector

conn = mysql.connector.connect(
    host="your-server-host",
    user="third_party_viewer",
    password="ReadOnlyAccess2024",
    database="employee_management",
    ssl_disabled=False  # Enable SSL
)
```

**Node.js (mysql2):**
```javascript
const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: 'your-server-host',
    user: 'third_party_viewer',
    password: 'ReadOnlyAccess2024',
    database: 'employee_management',
    ssl: {
        rejectUnauthorized: true
    }
});
```

**PHP (PDO):**
```php
$dsn = "mysql:host=your-server-host;dbname=employee_management;charset=utf8mb4";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => true,
];

try {
    $pdo = new PDO($dsn, 'third_party_viewer', 'ReadOnlyAccess2024', $options);
} catch (PDOException $e) {
    throw new PDOException($e->getMessage(), (int)$e->getCode());
}
```

## ✅ Bước 4: Test Quyền Truy Cập

### Commands được phép:
```sql
-- Xem danh sách bảng (chỉ thấy bảng được cấp quyền)
SHOW TABLES;

-- Đọc dữ liệu từ bảng employees
SELECT * FROM employees;
SELECT COUNT(*) FROM employees;
SELECT * FROM employees WHERE department_id = 1;

-- Xem cấu trúc bảng
DESCRIBE employees;
SHOW COLUMNS FROM employees;
```

### Commands không được phép (sẽ bị lỗi):
```sql
-- Truy cập bảng khác
SELECT * FROM departments;                         -- ERROR 1142 / 1146

-- Thêm dữ liệu mới
INSERT INTO employees (...) VALUES (...);          -- ERROR 1142

-- Sửa dữ liệu
UPDATE employees SET first_name = 'John' WHERE id = 1;  -- ERROR 1142

-- Xóa dữ liệu
DELETE FROM employees WHERE id = 1;                -- ERROR 1142

-- Tạo bảng mới
CREATE TABLE test (...);                           -- ERROR 1142

-- Xóa bảng
DROP TABLE employees;                              -- ERROR 1142

-- Truncate table
TRUNCATE TABLE employees;                          -- ERROR 1142
```

## 🔍 Bước 5: Monitor & Logging

### 5.1 Enable MySQL Query Log
```sql
-- Kiểm tra log đang bật
SHOW VARIABLES LIKE 'general_log%';

-- Bật log (tạm thời)
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/general.log';
```

### 5.2 Monitor User Activity
```sql
-- Xem các kết nối hiện tại
SHOW PROCESSLIST;

-- Xem thông tin user
SELECT User, Host, db FROM information_schema.processlist WHERE User = 'third_party_viewer';
```

## 🚨 Bước 6: Thu Hồi Quyền (Khi Cần)

### Revoke tất cả quyền:
```sql
-- Xóa user hoàn toàn
DROP USER 'third_party_viewer'@'%';

-- Hoặc chỉ revoke quyền SELECT
REVOKE SELECT ON employee_management.employees FROM 'third_party_viewer'@'%';
FLUSH PRIVILEGES;
```

### Script revoke sẵn có trong `backend/revoke-readonly-db-user.sql`

## 📊 Bảng Quyền Hạn

| Action | Quyền | Mô tả |
|--------|-------|-------|
| `SELECT` | ✅ | Đọc dữ liệu từ bảng employees |
| `INSERT` | ❌ | Thêm dữ liệu mới |
| `UPDATE` | ❌ | Sửa dữ liệu hiện có |
| `DELETE` | ❌ | Xóa dữ liệu |
| `CREATE` | ❌ | Tạo bảng mới |
| `ALTER` | ❌ | Đổi cấu trúc bảng |
| `DROP` | ❌ | Xóa bảng |
| `INDEX` | ❌ | Tạo/thay đổi index |
| `REFERENCES` | ❌ | Tạo foreign key |
| `TRIGGER` | ❌ | Tạo trigger |

## 🔧 Troubleshooting

### Error: "Access denied for user"
- Kiểm tra username/password
- Kiểm tra IP restriction
- Đảm bảo user đã được tạo

### Error: "Can't connect to MySQL server"
- Kiểm tra firewall
- Kiểm tra MySQL port (3306)
- Kiểm tra network connectivity

### Error: "SELECT command denied to user"
- Kiểm tra quyền đã được cấp
- Chạy `SHOW GRANTS FOR 'third_party_viewer'@'%';`

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra MySQL error logs
2. Test với user admin trước
3. Kiểm tra network/firewall
4. Xem lại script tạo user

---
**⚠️ CẢNH BÁO BẢO MẬT:**
- Luôn thay đổi password mặc định
- Giới hạn IP access trong production
- Sử dụng SSL connection
- Monitor access logs thường xuyên
- Thu hồi quyền khi không còn cần thiết
