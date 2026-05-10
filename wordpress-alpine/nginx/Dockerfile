FROM dhi.io/nginx:1
COPY nginx.conf /etc/nginx/nginx.conf
COPY selfsigned.crt /etc/nginx/ssl/selfsigned.crt
COPY selfsigned.key /etc/nginx/ssl/selfsigned.key
LABEL org.opencontainers.image.title="nginx-dhi" \
      org.opencontainers.image.description="Custom nginx image with ssl for wordpress"
USER nginx