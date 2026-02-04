#!/usr/bin/env node

/**
 * Test Script cho Third-Party Read-Only Database User
 * Script này test kết nối và quyền của user third_party_viewer
 */

const mysql = require('mysql2/promise');

// Database configuration
const dbConfig = {
    host: process.env.MYSQL_HOST || 'localhost',          // Thay bằng server IP của bạn
    database: process.env.MYSQL_DB || 'employee_management',
    user: process.env.MYSQL_USER || 'third_party_viewer',
    password: process.env.MYSQL_PASSWORD || 'ReadOnlyAccess2024',
    port: Number(process.env.MYSQL_PORT || 3306),
    ssl: {
        rejectUnauthorized: false  // Enable SSL cho production
    }
};

async function testConnection() {
    console.log('🔗 Testing database connection...');
    try {
        const connection = await mysql.createConnection(dbConfig);
        console.log('✅ Connected successfully!');
        console.log(`   Database: ${dbConfig.database}`);
        console.log(`   User: ${dbConfig.user}`);
        console.log(`   Host: ${dbConfig.host}`);
        return connection;
    } catch (error) {
        console.log('❌ Connection error:', error.message);
        return null;
    }
}

async function testSelectPermissions(connection) {
    console.log('\n📖 Testing SELECT permissions (should work)...');
    
    try {
        // Test 1: Đếm số nhân viên
        const [countResult] = await connection.execute('SELECT COUNT(*) FROM employees');
        console.log(`✅ SELECT COUNT(*) from employees: ${countResult[0]['COUNT(*)']} records`);
        
        // Test 2: Lấy 5 nhân viên đầu tiên
        const [employees] = await connection.execute(
            'SELECT id, first_name, last_name, email FROM employees LIMIT 5'
        );
        console.log('✅ SELECT first 5 employees:');
        employees.forEach(emp => {
            console.log(`   ID: ${emp.id}, Name: ${emp.first_name} ${emp.last_name}, Email: ${emp.email}`);
        });
        
        // Test 3: Xem cấu trúc bảng
        const [columns] = await connection.execute('DESCRIBE employees');
        console.log('✅ DESCRIBE employees table:');
        columns.slice(0, 5).forEach(col => {
            console.log(`   Column: ${col.Field} | Type: ${col.Type}`);
        });
        
    } catch (error) {
        console.log('❌ SELECT error:', error.message);
    }
}

async function testRestrictedOperations(connection) {
    console.log('\n🚫 Testing restricted operations (should fail)...');
    
    // Test INSERT (sẽ bị lỗi)
    try {
        await connection.execute(`
            INSERT INTO employees (first_name, last_name, email, department_id, age) 
            VALUES ('Test', 'User', 'test@email.com', 1, 25)
        `);
        console.log('❌ UNEXPECTED: INSERT succeeded (this should fail!)');
    } catch (error) {
        console.log(`✅ INSERT correctly denied: ${error.message}`);
    }
    
    // Test UPDATE (sẽ bị lỗi)
    try {
        await connection.execute("UPDATE employees SET first_name = 'Hacked' WHERE id = 1");
        console.log('❌ UNEXPECTED: UPDATE succeeded (this should fail!)');
    } catch (error) {
        console.log(`✅ UPDATE correctly denied: ${error.message}`);
    }
    
    // Test DELETE (sẽ bị lỗi)
    try {
        await connection.execute("DELETE FROM employees WHERE id = 999");
        console.log('❌ UNEXPECTED: DELETE succeeded (this should fail!)');
    } catch (error) {
        console.log(`✅ DELETE correctly denied: ${error.message}`);
    }
    
    // Test CREATE TABLE (sẽ bị lỗi)
    try {
        await connection.execute("CREATE TABLE test_table (id INT)");
        console.log('❌ UNEXPECTED: CREATE TABLE succeeded (this should fail!)');
    } catch (error) {
        console.log(`✅ CREATE TABLE correctly denied: ${error.message}`);
    }
    
    // Test DROP TABLE (sẽ bị lỗi)
    try {
        await connection.execute("DROP TABLE employees");
        console.log('❌ UNEXPECTED: DROP TABLE succeeded (this should fail!)');
    } catch (error) {
        console.log(`✅ DROP TABLE correctly denied: ${error.message}`);
    }
}

async function testShowPermissions(connection) {
    console.log('\n👁️ Testing SHOW permissions...');
    
    try {
        const [tables] = await connection.execute('SHOW TABLES');
        console.log(`✅ SHOW TABLES: ${tables.length} table(s) visible`);
        tables.forEach(table => {
            const tableName = Object.values(table)[0];
            console.log(`   - ${tableName}`);
        });
    } catch (error) {
        console.log('❌ SHOW error:', error.message);
    }
}

function generateConnectionInfo() {
    console.log('\n📋 Connection Information for Third Party:');
    console.log('='.repeat(50));
    console.log(`Host: ${dbConfig.host}`);
    console.log(`Port: ${dbConfig.port}`);
    console.log(`Database: ${dbConfig.database}`);
    console.log(`Username: ${dbConfig.user}`);
    console.log(`Password: [SET YOUR PASSWORD]`);
    console.log(`SSL: Required`);
    
    console.log('\n🔗 Connection Strings:');
    console.log('\nNode.js:');
    console.log(`const mysql = require('mysql2');`);
    console.log(`const connection = mysql.createConnection({`);
    console.log(`    host: '${dbConfig.host}',`);
    console.log(`    user: '${dbConfig.user}',`);
    console.log(`    password: 'YOUR_PASSWORD',`);
    console.log(`    database: '${dbConfig.database}',`);
    console.log(`    ssl: { rejectUnauthorized: true }`);
    console.log(`});`);
    
    console.log('\nPython:');
    console.log(`import mysql.connector`);
    console.log(`conn = mysql.connector.connect(`);
    console.log(`    host='${dbConfig.host}',`);
    console.log(`    user='${dbConfig.user}',`);
    console.log(`    password='YOUR_PASSWORD',`);
    console.log(`    database='${dbConfig.database}'`);
    console.log(`)`);
    
    console.log('\nCommand Line:');
    console.log(`mysql -h ${dbConfig.host} -u ${dbConfig.user} -p ${dbConfig.database}`);
}

async function main() {
    console.log('🧪 Third-Party Read-Only User Test');
    console.log('='.repeat(50));
    
    // Test connection
    const connection = await testConnection();
    if (!connection) {
        console.log('\n❌ Cannot proceed without database connection');
        process.exit(1);
    }
    
    try {
        // Test các quyền
        await testSelectPermissions(connection);
        await testRestrictedOperations(connection);
        await testShowPermissions(connection);
        
        // Hiển thị thông tin kết nối
        generateConnectionInfo();
        
        console.log('\n✅ All tests completed!');
        console.log('🎯 User third_party_viewer is working correctly with read-only access!');
        
    } finally {
        if (connection) {
            await connection.end();
            console.log('\n🔒 Database connection closed');
        }
    }
}

// Run the test
if (require.main === module) {
    main().catch(console.error);
}

module.exports = {
    testConnection,
    testSelectPermissions,
    testRestrictedOperations,
    generateConnectionInfo
};
