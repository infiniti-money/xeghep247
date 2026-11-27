# Các cấu hình cần bổ sung
- GitHub Pages: Settings > Pages > Source: GitHub Actions. Workflow hiện báo lỗi; chỉ dùng cho tài liệu phi thương mại.
- Cloudflare: kết nối Pages Free (root frontend, output out), Workers Free; cấu hình token qua secrets, không commit.
- Supabase: chọn project Free, kiểm tra schema extension, chạy local/advisors và tạo migration chính thức; cấu hình URL và publishable key, secret chỉ backend.
- Vận hành: bảng giá, hotline, thông tin doanh nghiệp, xác minh giấy phép vận tải/du lịch và bảo vệ dữ liệu trước thương mại.
Không chặn việc viết code/test độc lập; không kích hoạt billing.
