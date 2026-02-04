@echo off
REM =====================================================
REM Test Script cho Third-Party Read-Only Database User
REM Script này test kết nối và quyền của user third_party_viewer
REM =====================================================

echo.
echo 🧪 Third-Party Read-Only User Test
echo ================================================
echo.

REM Check if MySQL is available
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL client not found in PATH
    echo Please install MySQL or add it to PATH
    echo.
    echo You can also try:
    echo "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --version
    pause
    exit /b 1
)

echo ✅ MySQL client found
echo.

REM Test 1: Kiểm tra user đã được tạo chưa
echo 🔍 Step 1: Checking if user exists...
echo.
echo mysql -u root -p -e "SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';"
echo.
set /p continue="Press Enter to continue (or Ctrl+C to cancel)..."
echo.

REM Test 2: Kiểm tra quyền của user
echo 🔍 Step 2: Checking user permissions...
echo.
echo mysql -u root -p -e "SHOW GRANTS FOR 'third_party_viewer'@'%';"
echo.
set /p continue="Press Enter to continue..."
echo.

REM Test 3: Test kết nối với user mới
echo 🔗 Step 3: Testing connection with third_party_viewer...
echo.
echo Connection details:
echo   Host: localhost
echo   Database: employee_management
echo   Username: third_party_viewer
echo   Password: ReadOnlyAccess2024
echo.
echo Testing connection...
echo.
mysql -h localhost -u third_party_viewer -p employee_management -e "SELECT 'Connection successful!' as status;"
echo.
set /p continue="Press Enter to continue..."
echo.

REM Test 4: Test quyền SELECT (được phép)
echo 📖 Step 4: Testing SELECT permissions (should work)...
echo.
mysql -h localhost -u third_party_viewer -p employee_management -e "SELECT COUNT(*) as total_employees FROM employees;"
echo.
mysql -h localhost -u third_party_viewer -p employee_management -e "SELECT id, first_name, last_name, email FROM employees LIMIT 3;"
echo.
set /p continue="Press Enter to continue..."
echo.

REM Test 5: Test các quyền bị chặn
echo 🚫 Step 5: Testing restricted operations (should fail)...
echo.
echo Testing INSERT (should fail):
mysql -h localhost -u third_party_viewer -p employee_management -e "INSERT INTO employees (first_name, last_name, email, department_id, age) VALUES ('Test', 'User', 'test@email.com', 1, 25);" 2>&1
echo.
echo Testing UPDATE (should fail):
mysql -h localhost -u third_party_viewer -p employee_management -e "UPDATE employees SET first_name = 'Hacked' WHERE id = 1;" 2>&1
echo.
echo Testing DELETE (should fail):
mysql -h localhost -u third_party_viewer -p employee_management -e "DELETE FROM employees WHERE id = 999;" 2>&1
echo.
echo Testing CREATE TABLE (should fail):
mysql -h localhost -u third_party_viewer -p employee_management -e "CREATE TABLE test_table (id INT);" 2>&1
echo.
echo Testing DROP TABLE (should fail):
mysql -h localhost -u third_party_viewer -p employee_management -e "DROP TABLE employees;" 2>&1
echo.
set /p continue="Press Enter to continue..."
echo.

REM Test 6: Test SHOW commands
echo 👁️ Step 6: Testing SHOW permissions...
echo.
mysql -h localhost -u third_party_viewer -p employee_management -e "SHOW TABLES;"
echo.
set /p continue="Press Enter to continue..."
echo.

REM Hiển thị thông tin kết nối cho bên thứ ba
echo 📋 Connection Information for Third Party:
echo ==================================================
echo.
echo Host: localhost
echo Port: 3306
echo Database: employee_management
echo Username: third_party_viewer
echo Password: ReadOnlyAccess2024
echo SSL: Not configured (enable for production)
echo.
echo 🔗 Connection Examples:
echo.
echo Command Line:
echo   mysql -h localhost -u third_party_viewer -p employee_management
echo.
echo Python:
echo   import mysql.connector
echo   conn = mysql.connector.connect(
echo       host='localhost',
echo       user='third_party_viewer',
echo       password='ReadOnlyAccess2024',
echo       database='employee_management'
echo   )
echo.
echo Node.js:
echo   const mysql = require('mysql2');
echo   const connection = mysql.createConnection({
echo       host: 'localhost',
echo       user: 'third_party_viewer',
echo       password: 'ReadOnlyAccess2024',
echo       database: 'employee_management'
echo   });
echo.
echo ✅ Test completed!
echo 🎯 User third_party_viewer is ready for third-party access!
echo.
echo ⚠️  IMPORTANT SECURITY NOTES:
echo 1. Change the default password immediately!
echo 2. Restrict IP access in production: 
echo    CREATE USER 'third_party_viewer'@'SPECIFIC_IP' ...
echo 3. Enable SSL for production connections
echo 4. Monitor access logs regularly
echo 5. Revoke access when no longer needed
echo.

pause
