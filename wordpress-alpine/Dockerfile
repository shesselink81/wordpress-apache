FROM wordpress:fpm-alpine
RUN apk update && apk add --no-cache autoconf automake build-base pkgconfig libmemcached-dev zlib-dev \
	&& yes '' | pecl install -f memcached \
	&& docker-php-ext-enable memcached \
	&& apk del autoconf automake build-base pkgconfig \
	&& rm -rf /var/cache/apk/*
LABEL org.opencontainers.image.title="wordpress-alpine" \
      org.opencontainers.image.description="Custom wordpress 6.9.0 image with php 8.4, nginx,  memcached"