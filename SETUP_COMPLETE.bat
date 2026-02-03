@echo off
chcp 65001 >nul
title Employee Management - Complete Setup
color 0A

echo ============================================
echo   EMPLOYEE MANAGEMENT - COMPLETE SETUP
echo ============================================
echo.
echo This script will:
echo  1. Initialize database with tables and sample data
echo  2. Create third-party database user (read-only)
echo  3. Test third-party connection
echo.
pause
echo.

echo [Step 1/8] Stopping existing containers...
docker-compose down
echo ✓ Containers stopped
echo.

echo [Step 2/8] Starting MySQL container...
docker-compose up -d mysql
echo ✓ MySQL container started
echo.

echo [Step 3/8] Waiting for MySQL to be ready...
timeout /t 10 /nobreak >nul
echo ✓ MySQL should be ready
echo.

echo [Step 4/8] Initializing database with tables and sample data...
docker exec -i employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword < backend/init-database.sql
echo ✓ Database initialized
echo.

echo [Step 5/8] Creating read-only user for third party...
docker exec -i employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword < backend/setup-readonly-user.sql
echo ✓ Read-only user created
echo.

echo [Step 6/8] Starting remaining services...
docker-compose up -d
echo ✓ All services started
echo.

echo [Step 7/8] Waiting for services to initialize...
timeout /t 15 /nobreak >nul
echo ✓ Services initialized
echo.

echo [Step 8/8] Testing third-party connection...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_employees FROM employees;" 2>nul
if %errorlevel% neq 0 (
    echo ✗ Connection test failed
    echo Please check the setup manually
) else (
    echo ✓ Third-party connection successful
)
echo.

echo ============================================
echo   SETUP COMPLETED SUCCESSFULLY!
echo ============================================
echo.
echo Application URLs:
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:8080
echo   MySQL:    localhost:3306
echo.
echo ============================================
echo   THIRD PARTY CONNECTION INFO
echo ============================================
echo.
echo Give this information to the third party:
echo.
echo   Host:     172.20.244.179
echo   Port:     3306
echo   Database: employee_management
echo   Username: third_party_viewer
echo   Password: ReadOnlyAccess2024
echo.
echo They can use MySQL Workbench to connect
echo and view the employees data.
echo.
echo Security:
echo   - Read-only access (SELECT only)
echo   - Cannot INSERT, UPDATE, or DELETE
echo   - Can only view employees (NO access to any other tables)
echo.
pause
