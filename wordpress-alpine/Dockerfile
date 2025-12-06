FROM wordpress:6-php8.4-fpm-alpine
RUN apk update && apk add --no-cache autoconf automake build-base pkgconfig libmemcached-dev zlib-dev \
	&& yes '' | pecl install -f memcached \
	&& docker-php-ext-enable memcached
LABEL org.opencontainers.image.title="wordpress-alpine" \
      org.opencontainers.image.description="Custom wordpress 6.8.3 image with php 8.4, nginx,  memcached"