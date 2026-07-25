FROM wordpress:7.0.2-php8.4-fpm-alpine
ARG WORDPRESS_VERSION
ARG WP_LOCALE
ENV WP_PATH="/var/www/html"
RUN apk update && apk add --no-cache mariadb-client autoconf automake build-base pkgconfig libmemcached-dev zlib-dev curl \
	&& yes '' | pecl install -f memcached \
	&& curl -fSL "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" -o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp \
	&& php -d memory_limit=512M /usr/local/bin/wp core download --path="${WP_PATH}" --allow-root --version="${WORDPRESS_VERSION}" --force --locale="${WP_LOCALE}" \
	&& docker-php-ext-enable memcached \
	&& apk del autoconf automake build-base pkgconfig \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /etc/apache2 \
	&& unset APACHE_CONFDIR \
	&& unset APACHE_ENVVARS
LABEL org.opencontainers.image.title="wordpress-alpine" \
      org.opencontainers.image.description="Custom wordpress 7.0.2 image with php 8.5, nginx,  memcached"
