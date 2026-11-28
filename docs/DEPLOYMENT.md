# Triển khai miễn phí
## Cloudflare Pages (ứng dụng chính thức)
Kết nối repo GitHub, chọn main, root frontend, build npm run build, output out, Node 22. Chỉ cấu hình Free; không bật billing. Chưa xác minh project Cloudflare được kết nối.
Không triển khai UI dữ liệu mẫu thành ứng dụng vận hành thực tế. Trước production, thay dữ liệu mẫu bằng API xác thực và giao dịch thật, cấu hình database, thực hiện kiểm thử E2E và chặn giao dịch khi thiếu cấu hình.
## GitHub Pages (tài liệu kỹ thuật)
Settings > Pages > Source: GitHub Actions. Workflow pages.yml chỉ xuất tài liệu docs, không xuất frontend/out. Không triển khai /demo/ hoặc giao dịch thương mại. Bản demo công khai cũ chỉ được coi là đã gỡ sau khi workflow mới deploy thành công và kiểm tra HTTP.
## Workers
backend/wrangler.toml: khung API. Hoàn thiện API nghiệp vụ và xác thực trước khi triển khai. Cấu hình tài khoản Free, không ghi token vào Git.
## Supabase
Cần cấu hình project Free, RLS, PostGIS, xác thực email và storage private trước khi kết nối. Không đưa service key lên frontend.
## Kiểm thử
cd frontend && npm install && npm test && npm run build. Tạo và commit lockfile đã kiểm tra trước release. Giữ fixture nội bộ cho unit/E2E; không công bố fixture như dữ liệu thật.
