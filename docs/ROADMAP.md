# XeGhép247 — Roadmap
Free tier only. Cloudflare Pages ứng dụng chính; GitHub Pages tài liệu/demo phi thương mại. Ba mảng: ghép hàng, ghép người, ghép ghế du lịch.
- [ ] P0: Scaffold Next.js + Tailwind, Worker, demo UI, CI đã merge PR #1 (CI frontend success). Còn lockfile và hosting.
- [ ] P1: SQL draft 13 bảng, PostGIS, GiST, RLS owner-only, exclusion constraint ghế theo chặng; CI database bổ sung. Cần nghiệm thu CI, Supabase local/auth/storage/advisors và tạo migration chính thức.
- [ ] P2: SQL cargo candidate lookup (10km, chiều tuyến, ETA tuyến tính sơ bộ, tải trọng/thể tích), PR #3 đã merge, CI đạt; PR tiếp theo bổ sung transaction giữ/hủy ghế, hết hạn lazy cleanup, kiểm thử SQL. Còn xác nhận hai bên, hành lý, concurrency nhiều session, API xác thực và cargo atomic.
- [ ] P3: auth email/password, hồ sơ, xe, chuyến, hàng, đặt ghế, match APIs, VND pricing; OTP tùy chọn.
- [ ] P4: UI tài xế/chủ hàng/hành khách/nhà xe/admin, Leaflet/routing cache, ghế du lịch một chiều/khứ hồi, lịch trình nhiều điểm.
- [ ] P5: kiểm thử RLS, concurrency, security, CI/CD, deployment; xác minh yêu cầu pháp lý/an toàn trước thương mại.
- [ ] P6: release v0.1.0 sau khi nghiệm thu end-to-end.
- [ ] P7: hoàn thiện từ phản hồi.
Mỗi lượt kiểm tra main/PR/CI trước, thực hiện mã nguồn thực tế, cập nhật roadmap, chỉ merge khi CI đạt. Không lộ secrets, không kích hoạt dịch vụ trả phí, không tuyên bố deployment chưa xác minh.
