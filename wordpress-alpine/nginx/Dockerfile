FROM nginx:alpine
RUN apk update && apk add --no-cache openssl
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=NL/ST=NA/L=NA/O=Local/CN=wordpress.local" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt
LABEL org.opencontainers.image.title="nginx-alpine" \
      org.opencontainers.image.description="Custom nginx alpine image with ssl for wordpress"