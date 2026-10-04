# syntax=docker/dockerfile:1
# Stage 1: kiểm tra file tĩnh (fail sớm nếu thiếu file)
FROM alpine:3.20 AS verify
WORKDIR /site
COPY index.html robots.txt sitemap.xml ./
RUN test -s index.html && grep -q "</html>" index.html

# Stage 2: runtime nginx không chạy bằng root
FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=verify /site/ /usr/share/nginx/html/
USER 101
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1
