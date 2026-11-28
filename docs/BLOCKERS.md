# Các cấu hình cần bổ sung
- GitHub Pages: workflow 46132844474 trên main dcf2cb1 thành công. Chuyển sang xuất tài liệu kỹ thuật, bỏ /demo/ công khai; chờ CI, deploy mới và kiểm tra HTTP.
- Cloudflare: kết nối Pages Free (root frontend, output out), Workers Free; cấu hình token qua secrets, không commit; chưa xác minh URL ứng dụng chính thức.
- Supabase: chọn project Free, kiểm tra schema extension, chạy local/advisors và tạo migration chính thức; cấu hình URL và publishable key, secret chỉ backend.
- API: hoàn thiện xác thực, tìm chuyến, đăng chuyến, ghép hàng và đặt ghế thật; frontend không được gửi giao dịch hoặc hiển thị dữ liệu giả như dữ liệu thật khi thiếu cấu hình.
- Vận hành: bảng giá, hotline, thông tin doanh nghiệp, xác minh giấy phép vận tải/du lịch và bảo vệ dữ liệu trước thương mại.
Không chặn việc viết code/test độc lập; không kích hoạt billing.
