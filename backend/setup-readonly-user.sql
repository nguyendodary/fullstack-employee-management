-- ============================================
-- CREATE READ-ONLY USER FOR THIRD PARTY ACCESS
-- ============================================

-- Drop existing user if exists
DROP USER IF EXISTS 'third_party_viewer'@'%';
DROP USER IF EXISTS 'third_party_viewer'@'localhost';

-- Create new read-only user
CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';

-- Grant SELECT permission on employees table only
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';

-- Do not grant access to any other tables

-- Apply changes
FLUSH PRIVILEGES;

-- Verify user creation
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Show granted permissions
SHOW GRANTS FOR 'third_party_viewer'@'%';
