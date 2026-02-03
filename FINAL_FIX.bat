@echo off
echo Fixing database access issue...

echo Step 1: Checking database tables...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword employee_management -e "SHOW TABLES;"

echo.
echo Step 2: Creating user...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "CREATE USER IF NOT EXISTS 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';"

echo.
echo Step 3: Granting permissions (employees table only)...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';"

echo.
echo Step 4: Flushing privileges...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "FLUSH PRIVILEGES;"

echo.
echo Step 5: Testing connection...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT 'SUCCESS: Connection works!' as status;" 2>nul || echo Connection test failed

echo.
echo Step 6: Testing table access...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SHOW TABLES;" 2>nul || echo Table access failed

echo.
echo Step 7: Testing data access...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_records FROM employees;" 2>nul || echo Data access failed - table may not exist

echo.
echo === SETUP COMPLETED ===
echo.
echo Connection info:
echo Host: 172.20.244.179
echo Port: 3306
echo Database: employee_management
echo Username: third_party_viewer
echo Password: ReadOnlyAccess2024
echo.
pause
