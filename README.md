# DevOps Portfolio — Nguyễn Hoàng Long

## Overview

Portfolio kỹ thuật cho vị trí **DevOps Engineer / Cloud Engineer**. Trang gồm:

- 5 case study có sơ đồ kiến trúc: AWS Cloud Office, CI/CD Platform, Kubernetes Platform, Observability Stack, DevSecOps Pipeline.
- Architecture Lab tương tác.
- CI/CD pipeline mô phỏng.
- Production Troubleshooting Lab.
- Skill matrix theo mức độ trưởng thành.
- Trang Resume tại `#/resume`, in ra PDF được.

Mọi thông tin chưa xác thực đều hiển thị nhãn `[TODO — USER INPUT REQUIRED]`. Repo không chứa kinh nghiệm, số liệu hay kết quả giả.

## Architecture

```
Developer ── git push ──► GitHub ──► GitHub Actions
                                      ├── validate   (html-validate)
                                      ├── security   (gitleaks, Trivy config)
                                      ├── docker     (build, smoke test, Trivy image)
                                      ├── deploy     (GitHub Pages, chỉ nhánh main)
                                      └── health-check (curl trang production)
```

Website là một trang tĩnh (`index.html`), không có backend và không có database. Nội dung nằm trong các object JS ở đầu thẻ `<script>`, gồm `CONFIG`, `SKILLS`, `PROJECTS`, `STAGES`, `INCIDENTS` và `NOTES`.

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Frontend | HTML, CSS, Vanilla JS, Lucide Icons, Geist + JetBrains Mono |
| Container | Docker multi-stage, `nginx-unprivileged` (non-root, read-only rootfs) |
| CI/CD | GitHub Actions |
| Security | gitleaks, Trivy (config + image), security headers, CSP |
| Hosting | GitHub Pages (hoặc bất kỳ máy chủ nào chạy Docker) |

## Local Development

```bash
git clone https://github.com/<username>/<username>.github.io.git
cd <username>.github.io
python3 -m http.server 8080      # mở http://localhost:8080
```

## Docker

```bash
cp .env.example .env
docker compose up --build -d
curl http://localhost:8080/health   # -> ok
docker compose down
```

## CI/CD

File `.github/workflows/ci-cd.yml` chạy theo hai luồng:

- **Pull Request:** validate → security → docker build + smoke test + image scan.
- **Push lên `main`:** chạy toàn bộ các bước trên → deploy GitHub Pages → health check production.

Cài đặt một lần: vào **Settings → Pages → Source**, chọn **GitHub Actions**.

## Deployment

1. Tạo repo public tên `<username>.github.io`.
2. Push toàn bộ thư mục này lên nhánh `main`.
3. Trong `index.html`, `robots.txt` và `sitemap.xml`, thay `USERNAME` bằng username thật. Bước CI sẽ cảnh báo nếu còn sót.
4. Nếu dùng tên miền riêng, thêm file `CNAME` và cấu hình DNS theo hướng dẫn của GitHub Pages.

## Environment Variables

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `PORT` | `8080` | Cổng publish khi chạy `docker compose` |

Site tĩnh không cần secret. Không commit file `.env`.

## Security

- Không hard-code credential. Workflow chỉ dùng `GITHUB_TOKEN` do GitHub cấp và OIDC cho Pages.
- Container chạy non-root, root filesystem chỉ đọc, có `HEALTHCHECK`.
- Nginx gửi kèm các header bảo mật: CSP, X-Frame-Options, nosniff, Referrer-Policy.
- Form liên hệ:
  - validate dữ liệu ở phía client;
  - có honeypot chống bot và giới hạn 30 giây giữa hai lần gửi;
  - không chèn dữ liệu người dùng vào HTML (chống XSS);
  - không có backend nên không có bề mặt injection.
- GitHub API được gọi không cần token. Không bao giờ đặt token vào frontend.

## Monitoring

- Endpoint `GET /health` (nginx) dùng cho Docker HEALTHCHECK và load balancer.
- Job `health-check` kiểm tra trang production sau mỗi lần deploy.

## Troubleshooting

| Triệu chứng | Kiểm tra |
|---|---|
| Pages trả 404 | Settings → Pages → Source phải là **GitHub Actions**; repo phải public |
| Job `validate` fail | Chạy `npx html-validate@8 index.html` ở máy local để xem lỗi |
| Job `security` fail | Đọc log gitleaks / Trivy; xoá secret khỏi lịch sử Git nếu lỡ commit |
| Container không healthy | `docker logs <container>` ; `docker exec <container> wget -qO- localhost:8080/health` |
| Icon không hiển thị | Kiểm tra CDN jsdelivr có bị chặn; trang vẫn dùng được nhờ text dự phòng |

## Roadmap

- [ ] Điền `CONFIG.github` và `CONFIG.cvUrl`.
- [ ] Xác nhận mức kỹ năng (các mục `TODO — CONFIRM`).
- [ ] Hoàn thành lab cho từng project, gắn link GitHub và demo, điền Responsibilities / Challenges / Result.
- [ ] Điền Root Cause / Resolution cho các incident từ lab thật.
- [ ] Viết bài cho mục DevOps Knowledge.
- [ ] Thêm ảnh OpenGraph (`og:image`).
- [ ] Đo Lighthouse và tối ưu.
- [ ] (Tuỳ chọn) chuyển sang Next.js + TypeScript khi nội dung blog đủ lớn.
