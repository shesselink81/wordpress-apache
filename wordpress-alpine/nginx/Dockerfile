FROM nginx:stable-alpine-slim
# Kopieer nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Rechten
RUN chown -R nginx:nginx /etc/nginx

RUN apk update && apk add --no-cache openssl
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=NL/ST=NA/L=NA/O=Local/CN=wordpress.local" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt \
    && rm -rf /etc/apache2 \
	&& unset APACHE_CONFDIR \
	&& unset APACHE_ENVVARS \
    && chown -R 101:101 /etc/nginx/ssl \
    && chmod 755 /etc/nginx/ssl
LABEL org.opencontainers.image.title="nginx-alpine" \
      org.opencontainers.image.description="Custom nginx alpine image with ssl for wordpress"
USER nginx