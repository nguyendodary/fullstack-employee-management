-- SQL script to create read-only viewer user
-- This script creates a user account that can only view data, not modify it
-- Default credentials: username=viewer, password=viewer123 (change this after first login!)

-- Insert read-only viewer user (password is hashed using BCrypt)
-- Password: viewer123
-- BCrypt hash: $2a$10$ZxHhsozA0q./8QJ.8yHJKOeVHHPHsVQkVEbS8UT/3SJqJK5LpV9mG
INSERT INTO users (username, password, role) VALUES (
  'viewer',
  '$2a$10$ZxHhsozA0q./8QJ.8yHJKOeVHHPHsVQkVEbS8UT/3SJqJK5LpV9mG',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';

-- Optional: Create additional read-only users
-- Password: readonly123
-- BCrypt hash: $2a$10$hZEjVz1.hc5OySr0t9hZ8OxBr6YdUxZpKhZ6Dn.xP8yN5K3J2mH0m
INSERT INTO users (username, password, role) VALUES (
  'readonly',
  '$2a$10$hZEjVz1.hc5OySr0t9hZ8OxBr6YdUxZpKhZ6Dn.xP8yN5K3J2mH0m',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';
