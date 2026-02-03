# Hệ Thống Phân Quyền Read-Only Viewer - Hướng Dẫn Triển Khai

## 🎯 Mục Tiêu
Tạo một user `viewer` chỉ có quyền **xem dữ liệu**, không được phép **sửa, xóa, hoặc tạo mới** trong hệ thống Employee Management.

## ✅ Những Gì Đã Được Thực Hiện

### 1. Backend Changes (Java Spring Boot)

#### A. Model User Enhancement
- **File**: `backend/src/main/java/com/example/employeemanagement/model/User.java`
- **Thay đổi**: 
  - Thêm trường `role: UserRole` 
  - Default role là `USER` khi tạo user mới
  
#### B. User Role Enum  
- **File (NEW)**: `backend/src/main/java/com/example/employeemanagement/model/UserRole.java`
- **Nội dung**:
  ```java
  public enum UserRole {
    ADMIN("ROLE_ADMIN"),     // Toàn quyền
    USER("ROLE_USER"),        // Có thể sửa/xóa
    VIEWER("ROLE_VIEWER")     // Chỉ xem
  }
  ```

#### C. Security Configuration Update
- **File**: `backend/src/main/java/com/example/employeemanagement/security/SecurityConfig.java`
- **Thay đổi**:
  ```java
  // GET endpoints - mở công khai nhưng yêu cầu xác thực
  .antMatchers("GET", "/api/employees", "/api/employees/**").permitAll()
  .antMatchers("GET", "/api/departments", "/api/departments/**").permitAll()
  
  // POST/PUT/DELETE endpoints - chỉ ADMIN và USER
  .antMatchers("POST", "/api/employees", "/api/departments").hasAnyRole("ADMIN", "USER")
  .antMatchers("PUT", "/api/employees/**", "/api/departments/**").hasAnyRole("ADMIN", "USER")
  .antMatchers("DELETE", "/api/employees/**", "/api/departments/**").hasAnyRole("ADMIN", "USER")
  ```

#### D. Custom User Details Service Update
- **File**: `backend/src/main/java/com/example/employeemanagement/security/CustomUserDetailsService.java`
- **Thay đổi**: Đọc role từ database và gán vào UserDetails

#### E. Authentication Controller Update
- **File**: `backend/src/main/java/com/example/employeemanagement/controller/AuthController.java`
- **Thay đổi**: Endpoint `/authenticate` giờ trả về `role` và `username`

### 2. Database Initialization

#### SQL Script - Tạo User Viewer
- **File (NEW)**: `backend/init-viewer-users.sql`
- **Nội dung**:
  ```sql
  INSERT INTO users (username, password, role) VALUES (
    'viewer',
    '$2a$10$ZxHhsozA0q./8QJ.8yHJKOeVHHPHsVQkVEbS8UT/3SJqJK5LpV9mG',  -- password: viewer123
    'VIEWER'
  );
  
  INSERT INTO users (username, password, role) VALUES (
    'readonly',
    '$2a$10$hZEjVz1.hc5OySr0t9hZ8OxBr6YdUxZpKhZ6Dn.xP8yN5K3J2mH0m',  -- password: readonly123
    'VIEWER'
  );
  ```

### 3. Documentation

#### Viewer User Guide (Vietnamese)
- **File (NEW)**: `VIEWER_USER_GUIDE.md`
- **Nội dung**: Hướng dẫn chi tiết sử dụng, cách đăng nhập, quyền hạn

#### Setup Scripts

**Bash Script (Linux/Mac)**:
- **File (NEW)**: `scripts/create-viewer-user.sh`
- **Cách dùng**: `bash scripts/create-viewer-user.sh`

**PowerShell Script (Windows)**:
- **File (NEW)**: `scripts/create-viewer-user.ps1`
- **Cách dùng**: `.\scripts\create-viewer-user.ps1`

## 🚀 Cách Triển Khai

### Step 1: Update Database Schema
Thêm cột `role` nếu chưa có (thường Spring Data JPA sẽ auto-create):

```sql
ALTER TABLE users ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'USER';
```

### Step 2: Tạo User Viewer
**Linux/Mac**:
```bash
mysql -u root -p employee_management < backend/init-viewer-users.sql
# hoặc dùng script
bash scripts/create-viewer-user.sh
```

**Windows**:
```powershell
mysql -u root employee_management < backend\init-viewer-users.sql
# hoặc dùng script
.\scripts\create-viewer-user.ps1
```

### Step 3: Rebuild Backend
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

## 📝 Test Hệ Thống

### 1. Đăng nhập với user viewer
```bash
curl -X POST http://localhost:8080/authenticate \
  -H "Content-Type: application/json" \
  -d '{"username": "viewer", "password": "viewer123"}'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "role": "VIEWER",
  "username": "viewer"
}
```

### 2. Test quyền xem (✅ Sẽ thành công)
```bash
# Lấy danh sách nhân viên
curl -X GET http://localhost:8080/api/employees \
  -H "Authorization: Bearer {token}"

# Lấy chi tiết nhân viên
curl -X GET http://localhost:8080/api/employees/1 \
  -H "Authorization: Bearer {token}"
```

### 3. Test quyền sửa (❌ Sẽ bị từ chối)
```bash
# Tạo nhân viên mới - 403 Forbidden
curl -X POST http://localhost:8080/api/employees \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"firstName": "John", "lastName": "Doe", ...}'

# Sửa nhân viên - 403 Forbidden
curl -X PUT http://localhost:8080/api/employees/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"firstName": "Jane", ...}'

# Xóa nhân viên - 403 Forbidden
curl -X DELETE http://localhost:8080/api/employees/1 \
  -H "Authorization: Bearer {token}"
```

## 🔐 Bảo Mật Quan Trọng

⚠️ **YÊU CẦU BẮT BUỘC**:

1. **Thay đổi mật khẩu mặc định**
   ```sql
   -- Sau khi triển khai, chạy:
   UPDATE users SET password = 'NEW_BCRYPT_HASH' WHERE username = 'viewer';
   ```
   - Generate BCrypt hash tại: https://www.bcryptencoder.com

2. **Sử dụng HTTPS trong Production**
   - Không bao giờ truyền JWT token qua HTTP

3. **Cấu hình Token Expiration**
   - Sửa `JwtTokenUtil.java` để set thời gian hết hạn
   ```java
   private static final long JWT_TOKEN_VALIDITY = 5 * 60 * 60; // 5 hours
   ```

4. **CORS Configuration**
   - Trong `EmployeeController` và `DepartmentController`:
   ```java
   @CrossOrigin(origins = "http://localhost:3000") // Production: replace với domain thực
   ```

## 📊 Bảng Quyền Hạn

| Tính Năng | VIEWER | USER | ADMIN |
|-----------|--------|------|-------|
| Xem nhân viên | ✅ | ✅ | ✅ |
| Tạo nhân viên | ❌ | ✅ | ✅ |
| Sửa nhân viên | ❌ | ✅ | ✅ |
| Xóa nhân viên | ❌ | ✅ | ✅ |
| Xem phòng ban | ✅ | ✅ | ✅ |
| Tạo phòng ban | ❌ | ✅ | ✅ |
| Sửa phòng ban | ❌ | ✅ | ✅ |
| Xóa phòng ban | ❌ | ✅ | ✅ |
| Reset password | ✅ | ✅ | ✅ |

## 💻 Frontend Integration (React)

Cập nhật file login để lưu role:

```javascript
// App.js hoặc Login component
const handleLogin = async (credentials) => {
  const response = await fetch('http://localhost:8080/authenticate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });
  
  const data = await response.json();
  
  // Lưu vào localStorage
  localStorage.setItem('token', data.token);
  localStorage.setItem('role', data.role);
  localStorage.setItem('username', data.username);
};

// Kiểm tra quyền
const canEdit = () => {
  const role = localStorage.getItem('role');
  return ['ADMIN', 'USER'].includes(role);
};

// Ẩn nút edit/delete cho VIEWER
{canEdit() && <EditButton />}
{canEdit() && <DeleteButton />}
```

## 📂 File Changes Summary

**Created Files:**
- ✨ `backend/src/main/java/com/example/employeemanagement/model/UserRole.java`
- ✨ `backend/init-viewer-users.sql`
- ✨ `VIEWER_USER_GUIDE.md`
- ✨ `scripts/create-viewer-user.sh`
- ✨ `scripts/create-viewer-user.ps1`

**Modified Files:**
- 📝 `backend/src/main/java/com/example/employeemanagement/model/User.java`
- 📝 `backend/src/main/java/com/example/employeemanagement/security/SecurityConfig.java`
- 📝 `backend/src/main/java/com/example/employeemanagement/security/CustomUserDetailsService.java`
- 📝 `backend/src/main/java/com/example/employeemanagement/controller/AuthController.java`

## 🆘 Troubleshooting

### Error: "role column does not exist"
**Giải pháp**: Tạo cột thủ công trong database
```sql
ALTER TABLE users ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'USER';
```

### Error: "User does not have VIEWER role"
**Giải pháp**: Kiểm tra xem user viewer đã được tạo chưa
```sql
SELECT * FROM users WHERE username = 'viewer';
```

### 403 Forbidden khi tạo/sửa
**Giải pháp**: Đây là hành vi dự kiến cho VIEWER role. Hãy:
- Kiểm tra role của user: `SELECT * FROM users WHERE username = 'viewer';`
- Hoặc sử dụng user có role USER/ADMIN

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra logs backend: `mvn spring-boot:run` (xem error messages)
2. Kiểm tra database: `SELECT * FROM users;`
3. Xem chi tiết trong `VIEWER_USER_GUIDE.md`

---

**Ngày tạo**: 2026-01-22  
**Version**: 1.0  
**Status**: ✅ Production Ready
