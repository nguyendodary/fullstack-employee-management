#!/bin/bash

echo "Testing read-only user access..."

echo ""
echo "1. Testing connection with third_party_viewer user..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT 'Connection successful!' as status;"

echo ""
echo "2. Testing SELECT permission on employees table..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) as total_employees FROM employees LIMIT 1;"

echo ""
echo "3. Testing INSERT permission (should fail)..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "INSERT INTO employees (first_name, last_name, email, age) VALUES ('Test', 'User', 'test@example.com', 25);" 2>/dev/null || echo "INSERT correctly denied"

echo ""
echo "4. Testing UPDATE permission (should fail)..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "UPDATE employees SET first_name = 'Test' WHERE id = 1;" 2>/dev/null || echo "UPDATE correctly denied"

echo ""
echo "5. Testing DELETE permission (should fail)..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "DELETE FROM employees WHERE id = 1;" 2>/dev/null || echo "DELETE correctly denied"

echo ""
echo "6. Testing access to other tables (should fail)..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u third_party_viewer -pReadOnlyAccess2024 employee_management -e "SELECT COUNT(*) FROM departments;" 2>/dev/null || echo "Access to departments correctly denied"

echo ""
echo "7. Showing user permissions..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "SELECT User, Host, Select_priv, Insert_priv, Update_priv, Delete_priv FROM mysql.user WHERE User = 'third_party_viewer';"

echo ""
echo "8. Showing granted privileges..."
docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword mysql -e "SELECT * FROM mysql.db WHERE User = 'third_party_viewer';"

echo ""
echo "=== Test completed! ==="
echo ""
echo "Connection info for third party:"
echo "Host: 172.20.244.179"
echo "Port: 3306"
echo "Database: employee_management"
echo "Username: third_party_viewer"
echo "Password: ReadOnlyAccess2024"
echo ""
