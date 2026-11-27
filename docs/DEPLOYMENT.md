# Triển khai miễn phí
## Cloudflare Pages (ứng dụng)
Kết nối repo GitHub, chọn main, root frontend, build npm run build, output out, Node 22. Chỉ cấu hình Free; không bật billing. Hiện chưa kết nối project Cloudflare.
## GitHub Pages (tài liệu phi thương mại)
Settings > Pages > Source: GitHub Actions. Workflow pages.yml chỉ xuất thư mục docs; không chạy giao dịch thương mại.
## Workers
backend/wrangler.toml: cấu hình health endpoint. Chưa triển khai API nghiệp vụ. Sau khi cấu hình Wrangler và tài khoản Free, triển khai backend; không ghi token vào Git.
## Supabase
Chưa có database/migration. Cần cấu hình project Free, RLS, PostGIS, xác thực email và storage private trước khi kết nối. Không đưa service key lên frontend.
## Kiểm thử
cd frontend && npm install && npm test && npm run build. CI hiện dùng npm install vì chưa có lockfile; tạo và commit lockfile đã kiểm tra trước release.
