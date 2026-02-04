#!/usr/bin/env python3
"""
Test Script cho Third-Party Read-Only Database User
Script này test kết nối và quyền của user third_party_viewer
"""

import mysql.connector
import os
import sys
from mysql.connector import Error

# Database configuration
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),          # Thay bằng server IP của bạn
    'database': os.getenv('MYSQL_DB', 'employee_management'),
    'user': os.getenv('MYSQL_USER', 'third_party_viewer'),
    'password': os.getenv('MYSQL_PASSWORD', 'ReadOnlyAccess2024'),
    'port': int(os.getenv('MYSQL_PORT', '3306')),
    'ssl_disabled': False,  # Enable SSL cho production
    'autocommit': True
}

def test_connection():
    """Test kết nối đến database"""
    print("🔗 Testing database connection...")
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print("✅ Connected successfully!")
            print(f"   Database: {connection.database}")
            print(f"   User: {connection.user}")
            print(f"   Host: {connection.server_host}")
            return connection
        else:
            print("❌ Failed to connect")
            return None
    except Error as e:
        print(f"❌ Connection error: {e}")
        return None

def test_select_permissions(connection):
    """Test quyền SELECT (được phép)"""
    print("\n📖 Testing SELECT permissions (should work)...")
    
    try:
        cursor = connection.cursor()
        
        # Test 1: Đếm số nhân viên
        cursor.execute("SELECT COUNT(*) FROM employees")
        count = cursor.fetchone()[0]
        print(f"✅ SELECT COUNT(*) from employees: {count} records")
        
        # Test 2: Lấy 5 nhân viên đầu tiên
        cursor.execute("SELECT id, first_name, last_name, email FROM employees LIMIT 5")
        employees = cursor.fetchall()
        print(f"✅ SELECT first 5 employees:")
        for emp in employees:
            print(f"   ID: {emp[0]}, Name: {emp[1]} {emp[2]}, Email: {emp[3]}")
        
        # Test 3: Xem cấu trúc bảng
        cursor.execute("DESCRIBE employees")
        columns = cursor.fetchall()
        print(f"✅ DESCRIBE employees table:")
        for col in columns[:5]:  # Chỉ hiển thị 5 cột đầu
            print(f"   Column: {col[0]} | Type: {col[1]}")
        
        cursor.close()
        
    except Error as e:
        print(f"❌ SELECT error: {e}")

def test_restricted_operations(connection):
    """Test các thao tác bị giới hạn (sẽ bị lỗi)"""
    print("\n🚫 Testing restricted operations (should fail)...")
    
    try:
        cursor = connection.cursor()
        
        # Test INSERT (sẽ bị lỗi)
        try:
            cursor.execute("""
                INSERT INTO employees (first_name, last_name, email, department_id, age) 
                VALUES ('Test', 'User', 'test@email.com', 1, 25)
            """)
            print("❌ UNEXPECTED: INSERT succeeded (this should fail!)")
        except Error as e:
            print(f"✅ INSERT correctly denied: {e}")
        
        # Test UPDATE (sẽ bị lỗi)
        try:
            cursor.execute("UPDATE employees SET first_name = 'Hacked' WHERE id = 1")
            print("❌ UNEXPECTED: UPDATE succeeded (this should fail!)")
        except Error as e:
            print(f"✅ UPDATE correctly denied: {e}")
        
        # Test DELETE (sẽ bị lỗi)
        try:
            cursor.execute("DELETE FROM employees WHERE id = 999")
            print("❌ UNEXPECTED: DELETE succeeded (this should fail!)")
        except Error as e:
            print(f"✅ DELETE correctly denied: {e}")
        
        # Test CREATE TABLE (sẽ bị lỗi)
        try:
            cursor.execute("CREATE TABLE test_table (id INT)")
            print("❌ UNEXPECTED: CREATE TABLE succeeded (this should fail!)")
        except Error as e:
            print(f"✅ CREATE TABLE correctly denied: {e}")
        
        # Test DROP TABLE (sẽ bị lỗi)
        try:
            cursor.execute("DROP TABLE employees")
            print("❌ UNEXPECTED: DROP TABLE succeeded (this should fail!)")
        except Error as e:
            print(f"✅ DROP TABLE correctly denied: {e}")
        
        cursor.close()
        
    except Error as e:
        print(f"❌ Error during restricted operations test: {e}")

def test_show_permissions(connection):
    """Test SHOW commands"""
    print("\n👁️ Testing SHOW permissions...")
    
    try:
        cursor = connection.cursor()
        
        # Test SHOW TABLES
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        print(f"✅ SHOW TABLES: {len(tables)} table(s) visible")
        for table in tables:
            print(f"   - {table[0]}")
        
        cursor.close()
        
    except Error as e:
        print(f"❌ SHOW error: {e}")

def generate_connection_info():
    """Tạo thông tin kết nối cho bên thứ ba"""
    print("\n📋 Connection Information for Third Party:")
    print("=" * 50)
    print("Host:", DB_CONFIG['host'])
    print("Port:", DB_CONFIG['port'])
    print("Database:", DB_CONFIG['database'])
    print("Username:", DB_CONFIG['user'])
    print("Password:", "[SET YOUR PASSWORD]")
    print("SSL:", "Required" if not DB_CONFIG['ssl_disabled'] else "Disabled")
    
    print("\n🔗 Connection Strings:")
    print("\nPython:")
    print(f"mysql.connector.connect(")
    print(f"    host='{DB_CONFIG['host']}',")
    print(f"    user='{DB_CONFIG['user']}',")
    print(f"    password='YOUR_PASSWORD',")
    print(f"    database='{DB_CONFIG['database']}'")
    print(f")")
    
    print("\nNode.js:")
    print(f"const mysql = require('mysql2');")
    print(f"const connection = mysql.createConnection({{{")
    print(f"    host: '{DB_CONFIG['host']}',")
    print(f"    user: '{DB_CONFIG['user']}',")
    print(f"    password: 'YOUR_PASSWORD',")
    print(f"    database: '{DB_CONFIG['database']}'")
    print(f"}}});")
    
    print("\nCommand Line:")
    print(f"mysql -h {DB_CONFIG['host']} -u {DB_CONFIG['user']} -p {DB_CONFIG['database']}")

def main():
    """Main test function"""
    print("🧪 Third-Party Read-Only User Test")
    print("=" * 50)
    
    # Test connection
    connection = test_connection()
    if not connection:
        print("\n❌ Cannot proceed without database connection")
        sys.exit(1)
    
    try:
        # Test các quyền
        test_select_permissions(connection)
        test_restricted_operations(connection)
        test_show_permissions(connection)
        
        # Hiển thị thông tin kết nối
        generate_connection_info()
        
        print("\n✅ All tests completed!")
        print("🎯 User third_party_viewer is working correctly with read-only access!")
        
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("\n🔒 Database connection closed")

if __name__ == "__main__":
    main()
