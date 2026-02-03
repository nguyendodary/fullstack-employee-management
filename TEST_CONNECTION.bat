@echo off
title Database Connection Test
color 0A

echo ========================================
echo  DATABASE CONNECTION TEST
echo ========================================
echo.
echo Testing connection to Employee Database...
echo Host: 172.20.244.179
echo Port: 3306
echo User: third_party_viewer
echo.

echo [1/4] Testing basic connection...
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT 'Connection successful!' as status;" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Connection failed!
    echo Please check:
    echo - Internet connection
    echo - Firewall settings
    echo - Correct credentials
    pause
    exit /b 1
)
echo ✅ Connection successful!

echo.
echo [2/4] Testing data access...
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_employees FROM employees;" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Data access failed!
    pause
    exit /b 1
)
echo ✅ Data access successful!

echo.
echo [3/4] Testing read-only permissions...
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "INSERT INTO employees (first_name, last_name, email, age) VALUES ('Test', 'User', 'test@test.com', 25);" 2>nul
if %errorlevel% equ 0 (
    echo ❌ Write permissions detected - this should not happen!
    pause
    exit /b 1
)
echo ✅ Read-only permissions confirmed!

echo.
echo [4/4] Showing sample data...
mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT id, first_name, last_name, email, age FROM employees LIMIT 5;"

echo.
echo ========================================
echo  ✅ ALL TESTS PASSED!
echo ========================================
echo.
echo You can now access the database using:
echo - MySQL Workbench (recommended)
echo - Command line: mysql -h 172.20.244.179 -P 3306 -u third_party_viewer -p employee_management
echo.
echo See THIRD_PARTY_QUICK_START.md for detailed instructions.
echo.
pause
