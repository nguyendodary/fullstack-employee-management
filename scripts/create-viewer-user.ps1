# PowerShell Script - Tạo User Read-Only Viewer
# Yêu cầu: MySQL được cài đặt và thêm vào PATH

param(
    [string]$DBHost = "localhost",
    [int]$DBPort = 3306,
    [string]$DBUser = "root",
    [string]$DBPassword = "",
    [string]$DBName = "employee_management"
)

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║     Tạo User Read-Only Viewer cho Hệ Thống           ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

# Kiểm tra MySQL được cài đặt
Write-Host "📋 Cấu hình kết nối Database:" -ForegroundColor Yellow
Write-Host "  Host: $DBHost"
Write-Host "  Port: $DBPort"
Write-Host "  Database: $DBName"
Write-Host "  User: $DBUser"
Write-Host ""

Write-Host "⏳ Đang tạo user viewer..." -ForegroundColor Yellow

# Tạo SQL script tạm thời
$sqlScript = @"
-- Tạo user read-only viewer
INSERT INTO users (username, password, role) VALUES (
  'viewer',
  '\$2a\$10\$ZxHhsozA0q./8QJ.8yHJKOeVHHPHsVQkVEbS8UT/3SJqJK5LpV9mG',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';

-- Tạo user readonly (tùy chọn)
INSERT INTO users (username, password, role) VALUES (
  'readonly',
  '\$2a\$10\$hZEjVz1.hc5OySr0t9hZ8OxBr6YdUxZpKhZ6Dn.xP8yN5K3J2mH0m',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';

-- Kiểm tra
SELECT username, role FROM users WHERE role = 'VIEWER';
"@

# Lưu SQL script vào file tạm
$tempFile = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.sql'
Set-Content -Path $tempFile -Value $sqlScript -Encoding UTF8

try {
    # Thực thi SQL script
    $mysqlCmd = "mysql"
    $mysqlArgs = @("-h", $DBHost, "-P", $DBPort, "-u", $DBUser)
    
    if ($DBPassword) {
        $mysqlArgs += @("-p$DBPassword")
    }
    
    $mysqlArgs += $DBName

    & $mysqlCmd $mysqlArgs < $tempFile

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Tạo user thành công!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Thông tin user viewer:" -ForegroundColor Green
        Write-Host "  Username: viewer"
        Write-Host "  Password: viewer123"
        Write-Host "  Role: VIEWER (Read-Only)"
        Write-Host ""
        Write-Host "📝 Thông tin user readonly:" -ForegroundColor Green
        Write-Host "  Username: readonly"
        Write-Host "  Password: readonly123"
        Write-Host "  Role: VIEWER (Read-Only)"
        Write-Host ""
        Write-Host "⚠️  QUAN TRỌNG:" -ForegroundColor Yellow
        Write-Host "  - Thay đổi password mặc định ngay sau lần đăng nhập đầu tiên!"
        Write-Host "  - User viewer chỉ có thể xem dữ liệu, không thể sửa/xóa"
        Write-Host ""
        Write-Host "🔗 Test đăng nhập:" -ForegroundColor Yellow
        Write-Host "  curl -X POST http://localhost:8080/authenticate \"
        Write-Host "    -H 'Content-Type: application/json' \"
        Write-Host "    -d '{""username"": ""viewer"", ""password"": ""viewer123""}'"
    } else {
        Write-Host "❌ Lỗi tạo user!" -ForegroundColor Red
        Write-Host "Vui lòng kiểm tra:"
        Write-Host "  - Kết nối database"
        Write-Host "  - Thông tin đăng nhập MySQL"
        Write-Host "  - Database '$DBName' đã tồn tại"
        exit 1
    }
} finally {
    # Xóa file tạm
    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
}
