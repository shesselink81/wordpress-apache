FROM wordpress:7.0.1-php8.4-fpm-alpine
RUN apk update && apk add --no-cache autoconf automake build-base pkgconfig libmemcached-dev zlib-dev \
	&& yes '' | pecl install -f memcached \
	&& docker-php-ext-enable memcached \
	&& apk del autoconf automake build-base pkgconfig \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /etc/apache2 \
	&& unset APACHE_CONFDIR \
	&& unset APACHE_ENVVARS
LABEL org.opencontainers.image.title="wordpress-alpine" \
      org.opencontainers.image.description="Custom wordpress 7.0.1 image with php 8.5, nginx,  memcached"