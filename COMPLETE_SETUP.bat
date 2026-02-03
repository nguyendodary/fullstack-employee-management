@echo off
echo Starting complete application setup...

echo Step 1: Stopping all containers...
docker-compose down

echo Step 2: Starting all services...
docker-compose up -d

echo Step 3: Waiting for services to start...
timeout /t 30

echo Step 4: Checking database tables...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword employee_management -e "SHOW TABLES;"

echo Step 5: Creating read-only user...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "CREATE USER IF NOT EXISTS 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';"

echo Step 6: Granting permissions...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';"

echo Step 7: Flushing privileges...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "FLUSH PRIVILEGES;"

echo Step 8: Testing connection...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT 'SUCCESS: Connection works!' as status;" 2>nul || echo Connection failed

echo Step 9: Testing data access...
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_employees FROM employees;" 2>nul || echo Data access failed

echo.
echo === COMPLETE SETUP FINISHED ===
echo.
echo Application should be running at:
echo - Frontend: http://localhost:3000
echo - Backend: http://localhost:8080
echo.
echo Third party connection info:
echo Host: 172.20.244.179
echo Port: 3306
echo Database: employee_management
echo Username: third_party_viewer
echo Password: ReadOnlyAccess2024
echo.
pause
