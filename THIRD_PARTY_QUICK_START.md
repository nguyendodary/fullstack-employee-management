# 📦 DATABASE ACCESS PACKAGE - BÊN THỨ BA

## 🚀 BẮT ĐẦU NGAY

### Thông tin kết nối
- **Host:** 172.20.244.179
- **Port:** 3306
- **Database:** employee_management
- **Username:** third_party_viewer
- **Password:** ReadOnlyAccess2024

---

## 🎯 CÁCH KẾT NỐI NHANH NHẤT

### Phương pháp 1: MySQL Workbench (Khuyến nghị)
1. Mở MySQL Workbench
2. Click "+" tạo kết nối mới
3. Điền thông tin:
   - Connection Name: Employee DB
   - Hostname: 172.20.244.179
   - Port: 3306
   - Username: third_party_viewer
   - Password: ReadOnlyAccess2024
   - Default Schema: employee_management
4. Click "Test Connection"
5. Click "OK"

### Phương pháp 2: Command Line
```bash
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -p employee_management
```

---

## 📊 CÁC TRUY VẤN HỮU ÍCH

### Xem tất cả nhân viên
```sql
SELECT * FROM employees;
```

### Đếm số lượng nhân viên
```sql
SELECT COUNT(*) as total_employees FROM employees;
```

### Tìm nhân viên theo tên
```sql
SELECT * FROM employees WHERE first_name LIKE '%John%' OR last_name LIKE '%John%';
```

### Lọc theo phòng ban
```sql
SELECT * FROM employees WHERE department_id = 1;
```

### Sắp xếp theo tuổi
```sql
SELECT * FROM employees ORDER BY age DESC;
```

---

## 💾 XUẤT DỮ LIỆU

### Trong MySQL Workbench:
1. Chạy câu lệnh SELECT
2. Click vào "Export" 
3. Chọn định dạng (CSV, Excel, JSON)

### Command Line:
```bash
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -p employee_management -e "SELECT * FROM employees" > employees_data.csv
```

---

## ⚠️ LƯU Ý QUAN TRỌNG

✅ **ĐƯỢC PHÉP:**
- Xem tất cả dữ liệu trong bảng employees
- Chạy các câu lệnh SELECT
- Export dữ liệu

❌ **KHÔNG ĐƯỢC PHÉP:**
- Thêm dữ liệu (INSERT)
- Sửa dữ liệu (UPDATE)
- Xóa dữ liệu (DELETE)
- Truy cập các bảng khác

---

## 🆘 HỖ TRỢ

Nếu không kết nối được:
1. Kiểm tra kết nối internet
2. Đảm bảo port 3306 không bị chặn
3. Sử dụng đúng thông tin đăng nhập

**Liên hệ hỗ trợ nếu cần:** [Email/Phone của bạn]

---
*Package được tạo ngày: $(date)*
*IP có thể thay đổi - liên hệ nếu mất kết nối*
