@echo off
echo Fixing third_party user...

echo Step 1: Creating user...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';"

echo Step 2: Granting permissions...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';"

echo Step 3: Flushing privileges...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "FLUSH PRIVILEGES;"

echo Step 4: Testing connection...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT 'SUCCESS: Connection works!' as status;"

echo Step 5: Testing data access...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_employees FROM employees;"

echo.
echo === USER SETUP COMPLETED ===
echo.
echo Connection info:
echo Host: 172.20.244.179
echo Port: 3306
echo Database: employee_management
echo Username: third_party_viewer
echo Password: ReadOnlyAccess2024
echo.
pause
