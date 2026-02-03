# Tạo User Chỉ Xem (Read-Only Viewer)

## Tổng Quan
Hệ thống đã được nâng cấp để hỗ trợ các vai trò (roles) khác nhau:
- **ADMIN**: Toàn quyền truy cập và chỉnh sửa
- **USER**: Có thể xem, tạo, sửa, xóa dữ liệu
- **VIEWER**: Chỉ có thể xem dữ liệu, không được phép sửa, xóa hay tạo mới

## Những Thay Đổi Đã Được Thực Hiện

### 1. **Model User** (`User.java`)
- Thêm trường `role` để lưu vai trò của user
- Mặc định tất cả user mới được tạo có role `USER`

### 2. **Enum Role** (`UserRole.java`)
- Tạo enum `UserRole` với 3 vai trò: ADMIN, USER, VIEWER
- Mỗi vai trò có authority tương ứng (ROLE_ADMIN, ROLE_USER, ROLE_VIEWER)

### 3. **Security Configuration** (`SecurityConfig.java`)
- Cập nhật bảo vệ các endpoint:
  - **GET requests**: Mở công khai cho tất cả (giờ đây yêu cầu xác thực)
  - **POST/PUT/DELETE requests**: Chỉ cho phép ADMIN và USER roles

### 4. **Custom User Details Service** (`CustomUserDetailsService.java`)
- Cập nhật để trả về role của user từ database

### 5. **Authentication Controller** (`AuthController.java`)
- Cập nhật endpoint `/authenticate` để trả về role của user khi đăng nhập

## Cách Sử Dụng

### Bước 1: Chạy SQL Script
Thực hiện file `backend/init-viewer-users.sql` trên database MySQL của bạn.

Các user được tạo:
1. **Username**: `viewer` | **Password**: `viewer123`
2. **Username**: `readonly` | **Password**: `readonly123`

### Bước 2: Rebuild Project
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Bước 3: Đăng Nhập với User Viewer
**Request:**
```bash
curl -X POST http://localhost:8080/authenticate \
  -H "Content-Type: application/json" \
  -d '{
    "username": "viewer",
    "password": "viewer123"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "role": "VIEWER",
  "username": "viewer"
}
```

### Bước 4: Sử Dụng JWT Token
User viewer có thể:
- ✅ Xem danh sách nhân viên: `GET /api/employees`
- ✅ Xem chi tiết nhân viên: `GET /api/employees/{id}`
- ✅ Xem danh sách phòng ban: `GET /api/departments`
- ✅ Xem chi tiết phòng ban: `GET /api/departments/{id}`

Nhưng KHÔNG thể:
- ❌ Tạo nhân viên: `POST /api/employees` → Trả về 403 Forbidden
- ❌ Sửa nhân viên: `PUT /api/employees/{id}` → Trả về 403 Forbidden
- ❌ Xóa nhân viên: `DELETE /api/employees/{id}` → Trả về 403 Forbidden
- ❌ Tạo/Sửa/Xóa phòng ban: `POST/PUT/DELETE /api/departments` → Trả về 403 Forbidden

## Frontend Integration (React)

Cập nhật code login để lưu role:

```javascript
// components/Login.js
const handleLogin = async (e) => {
  e.preventDefault();
  try {
    const response = await fetch('http://localhost:8080/authenticate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    
    const data = await response.json();
    
    // Lưu token và role
    localStorage.setItem('token', data.token);
    localStorage.setItem('role', data.role);
    localStorage.setItem('username', data.username);
    
    // Redirect dựa trên role
    if (data.role === 'VIEWER') {
      navigate('/dashboard'); // Chỉ xem được view
    } else {
      navigate('/dashboard'); // Full access
    }
  } catch (error) {
    console.error('Login failed:', error);
  }
};
```

Kiểm tra quyền trên Frontend:

```javascript
// utils/authUtils.js
export const canEditData = () => {
  const role = localStorage.getItem('role');
  return role === 'ADMIN' || role === 'USER';
};

export const canDeleteData = () => {
  const role = localStorage.getItem('role');
  return role === 'ADMIN' || role === 'USER';
};

// Trong component
{canEditData() && <EditButton />}
{canDeleteData() && <DeleteButton />}
```

## Tạo Thêm User Viewer

### Cách 1: Dùng API Register (với role mặc định là USER)
```bash
curl -X POST http://localhost:8080/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newviewer",
    "password": "newpassword123",
    "role": "VIEWER"
  }'
```

### Cách 2: Dùng SQL
```sql
-- Thay đổi mật khẩu theo BCrypt hash của bạn
-- Bạn có thể generate BCrypt hash tại: https://www.bcryptencoder.com
INSERT INTO users (username, password, role) VALUES (
  'newviewer',
  'YOUR_BCRYPT_HASH_HERE',
  'VIEWER'
);
```

## Thay Đổi Mật Khẩu

User có thể thay đổi mật khẩu qua API:

```bash
curl -X POST http://localhost:8080/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "username": "viewer",
    "newPassword": "newpassword123"
  }'
```

## Bảo Mật Quan Trọng

⚠️ **CẢNH BÁO BẢO MẬT**

1. **Thay đổi mật khẩu mặc định ngay sau khi triển khai!**
   - `viewer123` và `readonly123` chỉ là password tạm thời
   
2. **Sử dụng JWT Token**
   - Tất cả request API phải gửi kèm Authorization header:
   ```
   Authorization: Bearer {JWT_TOKEN}
   ```

3. **HTTPS trong Production**
   - Luôn sử dụng HTTPS để bảo vệ JWT token
   
4. **Token Expiration**
   - Cấu hình thời gian hết hạn của token trong `JwtTokenUtil.java`

## Xử Lý Lỗi

### 401 Unauthorized
Có nghĩa là token không hợp lệ hoặc hết hạn. Yêu cầu user đăng nhập lại.

### 403 Forbidden
Có nghĩa là user không có quyền để thực hiện hành động này. 
- Với role `VIEWER`, không được phép POST/PUT/DELETE

## Tóm Tắt Cấp Quyền

| Action | VIEWER | USER | ADMIN |
|--------|--------|------|-------|
| View Employees | ✅ | ✅ | ✅ |
| Create Employee | ❌ | ✅ | ✅ |
| Edit Employee | ❌ | ✅ | ✅ |
| Delete Employee | ❌ | ✅ | ✅ |
| View Departments | ✅ | ✅ | ✅ |
| Create Department | ❌ | ✅ | ✅ |
| Edit Department | ❌ | ✅ | ✅ |
| Delete Department | ❌ | ✅ | ✅ |

## Liên Hệ

Nếu có câu hỏi, hãy liên hệ với team phát triển.
