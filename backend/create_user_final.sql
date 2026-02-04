CREATE USER 'third_party_viewer'@'%' IDENTIFIED BY 'ReadOnlyAccess2024';
GRANT SELECT ON employee_management.employees TO 'third_party_viewer'@'%';
FLUSH PRIVILEGES;
