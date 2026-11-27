# XeGhép247 — Roadmap
Free tier only. Cloudflare Pages ứng dụng chính; GitHub Pages tài liệu/demo phi thương mại. Ba mảng: ghép hàng, ghép người, ghép ghế du lịch.
- [ ] P0: Next.js static export + TS + Tailwind, Workers, CI, tài liệu deploy. PR đầu tiên bổ sung scaffold và demo UI; cần CI xanh, lockfile và cấu hình hosting.
- [ ] P1: PostGIS migrations users/vehicles/trips/orders/matches/passenger_bookings/documents/events, lịch du lịch, điểm dừng có thứ tự, seat layout, inventory, reservations, RLS, GiST, ETA.
- [ ] P2: PostGIS corridor 10km, chiều tuyến, ETA, tải trọng/thể tích/ghế; transaction atomic chống double booking, giữ ghế có hạn và hoàn sức chứa idempotent. Pure prefilter/seat interval tests đã viết, chưa thay thế database.
- [ ] P3: auth email/password, hồ sơ, xe, chuyến, hàng, đặt ghế, match APIs, VND pricing; OTP tùy chọn.
- [ ] P4: UI tài xế/chủ hàng/hành khách/nhà xe/admin, Leaflet/routing cache, ghế du lịch một chiều/khứ hồi, lịch trình nhiều điểm.
- [ ] P5: kiểm thử RLS, concurrency, security, CI/CD, deployment; xác minh yêu cầu pháp lý/an toàn trước thương mại.
- [ ] P6: release v0.1.0 sau khi nghiệm thu end-to-end.
- [ ] P7: hoàn thiện từ phản hồi.
Mỗi lượt kiểm tra main/PR/CI trước, thực hiện mã nguồn thực tế, cập nhật roadmap, chỉ merge khi CI đạt. Không lộ secrets, không kích hoạt dịch vụ trả phí, không tuyên bố deployment chưa xác minh.
