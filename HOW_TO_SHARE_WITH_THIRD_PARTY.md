# Hướng Dẫn Chia Sẻ Database Cho Bên Thứ Ba

## Bước 1: Khởi động lại Docker Container

Sau khi cập nhật docker-compose.yml, khởi động lại MySQL container:

```bash
docker-compose down
docker-compose up -d mysql
```

## Bước 2: Tạo User Read-Only

Chạy script SQL để tạo user `third_party_viewer`:

```bash
# Sử dụng MySQL client trong container
docker exec -it $(docker-compose ps -q mysql) mysql -u root -p'password' employee_management < backend/create-readonly-db-user.sql
```

Hoặc kết nối trực tiếp:
```bash
mysql -h localhost -P 3306 -u root -p'password' employee_management < backend/create-readonly-db-user.sql
```

## Bước 3: Cung cấp thông tin kết nối cho bên thứ ba

### Thông tin kết nối:
- **Host:** IP address của máy chủ (hoặc domain nếu có)
- **Port:** 3306
- **Database:** employee_management
- **Username:** third_party_viewer
- **Password:** [Thay đổi mật khẩu mặc định]

### Lấy IP address của máy chủ:
```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
# hoặc
hostname -I
```

## Bước 4: Kiểm tra kết nối từ bên ngoài

Bên thứ ba có thể kiểm tra kết nối bằng các cách sau:

### 1. Sử dụng MySQL Command Line
```bash
mysql -h [IP_CUA_BAN] -P 3306 -u third_party_viewer -p employee_management
```

### 2. Sử dụng Python script
```bash
python backend/test_readonly_user.py
```

### 3. Sử dụng Node.js script
```bash
node backend/test_readonly_user.js
```

### 4. Sử dụng Windows batch file
```cmd
backend\test_readonly_user.bat
```

## Bước 5: Cấu hình bảo mật (QUAN TRỌNG)

### 1. Thay đổi mật khẩu mặc định
```sql
-- Kết nối với quyền root
ALTER USER 'third_party_viewer'@'%' IDENTIFIED BY 'MatKhauMoiManh!';
FLUSH PRIVILEGES;
```

### 2. Giới hạn IP (nếu cần)
```sql
-- Chỉ cho phép từ IP cụ thể
DROP USER 'third_party_viewer'@'%';
CREATE USER 'third_party_viewer'@'[IP_CUA_BEN_THU_BA]' IDENTIFIED BY 'MatKhauMoiManh!';
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'[IP_CUA_BEN_THU_BA]';
FLUSH PRIVILEGES;
```

### 3. Kích hoạt SSL (nếu cần)
```sql
-- Kiểm tra SSL status
SHOW VARIABLES LIKE 'have_ssl';
```

## Bước 6: Cung cấp tài liệu cho bên thứ ba

Gửi file `THIRD_PARTY_DB_ACCESS_GUIDE.md` cho bên thứ ba cùng với thông tin kết nối.

## Lưu ý quan trọng:

1. **Firewall:** Đảm bảo port 3306 được mở trên firewall
2. **Network:** Bên thứ ba cần có quyền truy cập mạng đến máy chủ của bạn
3. **Security:** Luôn thay đổi mật khẩu mặc định
4. **Monitoring:** Theo dõi log truy cập của user `third_party_viewer`

## Kiểm tra firewall trên Windows:
```cmd
# Mở port 3306 cho MySQL
netsh advfirewall firewall add rule name="MySQL" dir=in action=allow protocol=TCP localport=3306
```

## Xem log truy cập:
```sql
-- Xem các kết nối hiện tại
SHOW PROCESSLIST;

-- Xem log (nếu đã bật)
SHOW VARIABLES LIKE 'general_log%';
```