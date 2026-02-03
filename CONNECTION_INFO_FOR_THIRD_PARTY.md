# THÔNG TIN KẾT NỐI DATABASE CHO BÊN THỨ BA

## 📋 Thông tin kết nối
- **Host:** 172.20.244.179
- **Port:** 3306
- **Database:** employee_management
- **Username:** third_party_viewer
- **Password:** ReadOnlyAccess2024

## 🔐 Quyền truy cập
- ✅ Chỉ có quyền SELECT (đọc dữ liệu)
- ✅ Chỉ được truy cập bảng employees
- ❌ Không có quyền INSERT, UPDATE, DELETE
- ❌ Không thể truy cập các bảng khác

## 📄 File hướng dẫn
Đính kèm file: `THIRD_PARTY_DB_ACCESS_GUIDE.md`

## 🧪 Cách kiểm tra kết nối

### Sử dụng MySQL Workbench (Khuyến nghị)
1. Mở MySQL Workbench
2. Click vào "+" để tạo kết nối mới
3. Đặt tên kết nối: "Employee Management DB"
4. **Hostname:** 172.20.244.179
5. **Port:** 3306
6. **Username:** third_party_viewer
7. **Password:** ReadOnlyAccess2024
8. **Default Schema:** employee_management
9. Click "Test Connection" để kiểm tra
10. Click "OK" để lưu

Sau khi kết nối, bạn có thể:
- Xem bảng employees trong sidebar
- Chạy câu lệnh SELECT trong Query Editor
- **Không thể** thực hiện INSERT/UPDATE/DELETE

### Sử dụng MySQL Command Line
```bash
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -p employee_management
```

### Sử dụng Python
```python
import mysql.connector

conn = mysql.connector.connect(
    host="172.20.244.179",
    port=3306,
    user="third_party_viewer",
    password="ReadOnlyAccess2024",
    database="employee_management"
)

cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM employees")
result = cursor.fetchone()
print(f"Total employees: {result[0]}")
conn.close()
```

### Sử dụng Node.js
```javascript
const mysql = require('mysql2/promise');

const connection = await mysql.createConnection({
  host: '172.20.244.179',
  port: 3306,
  user: 'third_party_viewer',
  password: 'ReadOnlyAccess2024',
  database: 'employee_management'
});

const [rows] = await connection.execute('SELECT COUNT(*) FROM employees');
console.log(`Total employees: ${rows[0]['COUNT(*)']}`);
await connection.end();
```

## ⚠️ Lưu ý quan trọng
1. Chỉ có thể truy cập từ mạng có kết nối đến IP 172.20.244.179
2. Port 3306 đã được mở trên firewall
3. Mọi thao tác ghi (INSERT/UPDATE/DELETE) sẽ bị từ chối
4. Chỉ có thể xem dữ liệu trong bảng employees

## 🆘 Hỗ trợ
Nếu gặp vấn đề kết nối, vui lòng kiểm tra:
- Kết nối mạng đến IP 172.20.244.179
- Port 3306 có thể truy cập được không
- Sử dụng đúng username và password

---
*Thông tin được tạo vào: $(date)*
*IP có thể thay đổi nếu máy chủ khởi động lại*
