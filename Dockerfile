#FROM wordpress:6-php8.4-apache
FROM wordpress:beta-6.9-RC3-php8.4-apache
RUN apt-get update && apt-get install -y libmemcached-dev libssl-dev zlib1g-dev \
	&& pecl install memcached-3.2.0 \
	&& docker-php-ext-enable memcached
ARG WP_DOMAINNAME
ENV WP_DOMAINNAME=$WP_DOMAINNAME
RUN echo "ServerName $WP_DOMAINNAME" >> /etc/apache2/conf-available/servername.conf \
    && a2enconf servername
# SSL
RUN a2enmod ssl rewrite headers
RUN mkdir -p /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=NL/ST=NA/L=NA/O=Local/CN=$WP_DOMAINNAME" \
    -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/selfsigned.key \
    -out /etc/apache2/ssl/selfsigned.crt
COPY wordpress-ssl.conf /etc/apache2/sites-available/wordpress-ssl.conf
RUN chown www-data:www-data /etc/apache2/ssl/selfsigned.key /etc/apache2/ssl/selfsigned.crt
RUN a2ensite wordpress-ssl.conf
EXPOSE 80 443