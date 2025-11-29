FROM wordpress:php8.4-fpm-alpine
RUN apk update && apk add --no-cache autoconf automake build-base pkgconfig libmemcached-dev zlib-dev \
	&& yes '' | pecl install -f memcached \
	&& docker-php-ext-enable memcached
