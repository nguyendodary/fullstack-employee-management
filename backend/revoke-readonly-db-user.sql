-- =====================================================
-- THU HỒI QUYỀN DATABASE USER CHO BÊN THỨ BA
-- =====================================================
-- Script này thu hồi quyền truy cập của user third_party_viewer
-- Sử dụng khi không muốn bên thứ ba truy cập nữa

-- 1. Thu hồi quyền SELECT trên bảng employees
REVOKE SELECT ON employee_management.employees FROM 'third_party_viewer'@'%';

-- 2. Thu hồi quyền SELECT trên bảng departments (nếu đã cấp)
-- REVOKE SELECT ON employee_management.departments FROM 'third_party_viewer'@'%';

-- 3. Flush privileges để áp dụng thay đổi
FLUSH PRIVILEGES;

-- =====================================================
-- XÓA USER HOÀN TOÀN (KHUYẾN KHÍCH)
-- =====================================================
-- Nếu muốn xóa user hoàn toàn thay vì chỉ thu hồi quyền:

-- DROP USER 'third_party_viewer'@'%';

-- =====================================================
-- KIỂM TRA USER ĐÃ ĐỂ XÓA/THU HỒI CHƯA
-- =====================================================

-- Kiểm tra user còn tồn tại không
SELECT User, Host FROM mysql.user WHERE User = 'third_party_viewer';

-- Kiểm tra quyền còn lại
SHOW GRANTS FOR 'third_party_viewer'@'%';

-- =====================================================
-- LOGGING & AUDIT
-- =====================================================
-- Ghi lại action đã thực hiện (nếu có audit table)
/*
INSERT INTO admin_actions (action, target_user, performed_by, performed_at)
VALUES ('REVOKE_READ_ONLY_ACCESS', 'third_party_viewer', CURRENT_USER(), NOW());
*/

-- =====================================================
-- THÔNG BÁO
-- =====================================================
-- Sau khi chạy script này:
-- ✅ User third_party_viewer không thể truy cập database nữa
-- ✅ Tất cả quyền đã bị thu hồi
-- ✅ Database được bảo vệ an toàn

-- Lưu ý: Nếu chỉ REVOKE mà không DROP USER:
-- - User vẫn tồn tại nhưng không có quyền
-- - Có thể cấp lại quyền sau này nếu cần
-- - Khuyến khích DROP USER để cleanup hoàn toàn
