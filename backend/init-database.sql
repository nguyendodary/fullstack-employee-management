-- ============================================
-- INITIALIZE DATABASE FOR EMPLOYEE MANAGEMENT
-- ============================================

USE employee_management;

-- Create departments table
CREATE TABLE IF NOT EXISTS departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    department_id BIGINT,
    age INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Create users table for application
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'USER'
);

-- Insert sample departments
INSERT INTO departments (name) VALUES 
    ('IT'),
    ('HR'),
    ('Sales'),
    ('Marketing'),
    ('Finance')
ON DUPLICATE KEY UPDATE name = name;

-- Insert sample employees
INSERT INTO employees (first_name, last_name, email, department_id, age) VALUES 
    ('John', 'Doe', 'john.doe@company.com', 1, 28),
    ('Jane', 'Smith', 'jane.smith@company.com', 2, 32),
    ('Michael', 'Johnson', 'michael.johnson@company.com', 3, 35),
    ('Emily', 'Williams', 'emily.williams@company.com', 4, 26),
    ('David', 'Brown', 'david.brown@company.com', 5, 41),
    ('Sarah', 'Davis', 'sarah.davis@company.com', 1, 29),
    ('James', 'Miller', 'james.miller@company.com', 2, 33),
    ('Jennifer', 'Wilson', 'jennifer.wilson@company.com', 3, 27),
    ('Robert', 'Moore', 'robert.moore@company.com', 4, 38),
    ('Lisa', 'Taylor', 'lisa.taylor@company.com', 5, 31)
ON DUPLICATE KEY UPDATE first_name = first_name;

-- Insert admin user (password: admin123)
INSERT INTO users (username, password, role) VALUES 
    ('admin', '$2a$10$N9z8QXgKwG5r8QYF.XF3j.xh6aQXm8Rzv4Kq8R.v3qE8QYF.XF3j', 'ADMIN'),
    ('viewer', '$2a$10$N9z8QXgKwG5r8QYF.XF3j.xh6aQXm8Rzv4Kq8R.v3qE8QYF.XF3j', 'VIEWER')
ON DUPLICATE KEY UPDATE username = username;

-- Show created tables
SHOW TABLES;

-- Show data counts
SELECT 'Departments' as table_name, COUNT(*) as record_count FROM departments
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees
UNION ALL
SELECT 'Users', COUNT(*) FROM users;
