# XeGhép247 — Roadmap
Free tier only. Cloudflare Pages là ứng dụng chính thức; GitHub Pages chỉ tài liệu kỹ thuật, ngừng triển khai /demo/ công khai. Ba mảng: ghép hàng, ghép người, ghép ghế du lịch.
- [ ] P0: Scaffold Next.js + Tailwind, Worker, CI đã merge PR #1. Còn lockfile và hosting Cloudflare. Pages tài liệu-only: CI và deploy workflow 46142144924 đạt; HTTP chưa xác minh.
- [ ] P1: SQL draft 13 bảng, PostGIS, GiST, RLS owner-only, exclusion constraint ghế theo chặng; CI database bổ sung. Cần nghiệm thu Supabase local/auth/storage/advisors và tạo migration chính thức.
- [ ] P2: SQL cargo candidate lookup (10km, chiều tuyến, ETA tuyến tính sơ bộ, tải trọng/thể tích), PR #3 đã merge. PR #4 giữ/hủy ghế, PR #5 xác nhận hai bên, PR #6 concurrency, PR #7 giới hạn hành lý theo chặng đã merge. Còn kiểm thử tổng hành lý nhiều ghế, API xác thực và cargo atomic.
- [ ] P3: Ưu tiên API thật và auth email/password, hồ sơ, xe, chuyến, hàng, đặt ghế, match APIs, VND pricing; OTP tùy chọn.
- [ ] P4: UI tài xế/chủ hàng/hành khách/nhà xe/admin, Leaflet/routing cache, ghế du lịch một chiều/khứ hồi, lịch trình nhiều điểm. PR #8–#13 đã merge: mobile-first, cabin 9/16 ghế, giá khứ hồi mẫu, điều hướng vai trò, lịch trình và chọn chặng. CI main dcf2cb1 đạt. Giữ fixture/test nội bộ nhưng không tiếp tục phát hành bản demo công khai. Ưu tiên thay toàn bộ dữ liệu mẫu bằng API xác thực, dữ liệu thật và trạng thái lỗi/rỗng; khi thiếu cấu hình chặn gửi giao dịch. Còn tồn ghế chiều về, giá theo chặng, dashboard có phân quyền, E2E và HTTP smoke.
- [ ] P5: kiểm thử RLS, concurrency, security, CI/CD, deployment; xác minh yêu cầu pháp lý/an toàn trước thương mại.
- [ ] P6: release v0.1.0 sau khi nghiệm thu end-to-end.
- [ ] P7: hoàn thiện từ phản hồi.
Mỗi lượt kiểm tra main/PR/CI trước, thực hiện mã nguồn thực tế, cập nhật roadmap, chỉ merge khi CI đạt. Không lộ secrets, không kích hoạt dịch vụ trả phí, không tuyên bố deployment chưa xác minh.

P4: Chặn tìm chuyến giả, đăng chuyến và đăng nhập khi API chưa sẵn sàng; fixture chuyến chỉ trong tests. Giao diện chi tiết/ghế sẽ nối lại với dữ liệu API thật. Chờ CI và kiểm thử trình duyệt.

P3/P4: thêm kiểm tra health API HTTPS, timeout, xác minh service/database và trạng thái kết nối trên UI. Không mở giao dịch dựa vào health. Chờ CI; API nghiệp vụ và auth vẫn chưa triển khai.
