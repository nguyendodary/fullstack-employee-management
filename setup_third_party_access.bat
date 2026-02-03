@echo off
echo Creating read-only user for third party access...

docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword employee_management < backend/create_user_simple.sql

echo User created successfully!
echo.
echo Connection info for third party:
echo Host: [Your IP Address]
echo Port: 3306
echo Database: employee_management
echo Username: third_party_viewer
echo Password: ReadOnlyAccess2024
echo.
echo Testing connection...
python backend/test_readonly_user.py
pause
