FROM wordpress:7.0.2-php8.4-fpm-alpine
ARG WORDPRESS_VERSION="7.0.2"
ARG WP_LOCALE="en_US"
ENV WP_PATH="/var/www/html"
RUN apk update && apk add --no-cache mariadb-client autoconf automake build-base pkgconfig libmemcached-dev zlib-dev \
	&& yes '' | pecl install -f memcached \
	&& docker-php-ext-enable memcached \
	&& apk del autoconf automake build-base pkgconfig \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /etc/apache2 \
	&& unset APACHE_CONFDIR \
	&& unset APACHE_ENVVARS
LABEL org.opencontainers.image.title="wordpress-alpine" \
      org.opencontainers.image.description="Custom wordpress 7.0.2 image with php 8.5, nginx,  memcached"
USER 82:82
