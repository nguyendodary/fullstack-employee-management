#!/bin/bash

# Script tạo user Read-Only Viewer
# Yêu cầu: MySQL client được cài đặt

# Cấu hình kết nối database
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD=""
DB_NAME="employee_management"
DB_PORT="3306"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║     Tạo User Read-Only Viewer cho Hệ Thống           ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL client không được cài đặt${NC}"
    echo "Vui lòng cài đặt MySQL client trước"
    exit 1
fi

echo -e "${YELLOW}📋 Cấu hình kết nối Database:${NC}"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Execute SQL script
echo -e "${YELLOW}⏳ Đang tạo user viewer...${NC}"

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" ${DB_PASSWORD:+-p"$DB_PASSWORD"} "$DB_NAME" << EOF
-- Tạo user read-only viewer
INSERT INTO users (username, password, role) VALUES (
  'viewer',
  '\$2a\$10\$ZxHhsozA0q./8QJ.8yHJKOeVHHPHsVQkVEbS8UT/3SJqJK5LpV9mG',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';

-- Tạo user readonly (tùy chọn)
INSERT INTO users (username, password, role) VALUES (
  'readonly',
  '\$2a\$10\$hZEjVz1.hc5OySr0t9hZ8OxBr6YdUxZpKhZ6Dn.xP8yN5K3J2mH0m',
  'VIEWER'
) ON DUPLICATE KEY UPDATE role = 'VIEWER';

-- Kiểm tra
SELECT username, role FROM users WHERE role = 'VIEWER';
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tạo user thành công!${NC}"
    echo ""
    echo -e "${GREEN}📝 Thông tin user viewer:${NC}"
    echo "  Username: viewer"
    echo "  Password: viewer123"
    echo "  Role: VIEWER (Read-Only)"
    echo ""
    echo -e "${GREEN}📝 Thông tin user readonly:${NC}"
    echo "  Username: readonly"
    echo "  Password: readonly123"
    echo "  Role: VIEWER (Read-Only)"
    echo ""
    echo -e "${YELLOW}⚠️  QUAN TRỌNG:${NC}"
    echo "  - Thay đổi password mặc định ngay sau lần đăng nhập đầu tiên!"
    echo "  - User viewer chỉ có thể xem dữ liệu, không thể sửa/xóa"
    echo ""
    echo -e "${YELLOW}🔗 Test đăng nhập:${NC}"
    echo "  curl -X POST http://localhost:8080/authenticate \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"username\": \"viewer\", \"password\": \"viewer123\"}'"
else
    echo -e "${RED}❌ Lỗi tạo user!${NC}"
    echo "Vui lòng kiểm tra:"
    echo "  - Kết nối database"
    echo "  - Thông tin đăng nhập MySQL"
    echo "  - Database '$DB_NAME' đã tồn tại"
    exit 1
fi
