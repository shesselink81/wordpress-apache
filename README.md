# wordpress-apache

Custom wordpress Docker image

Docker Compose example:

```console
curl -sSL https://raw.githubusercontent.com/shesselink81/wordpress-apache/main/docker-compose.yml > docker-compose.yml
docker-compose up -d
```
Helm Chart:
<https://artifacthub.io/packages/helm/slybase-wordpress/wordpress>

Docker images:
<https://github.com/shesselink81/wordpress-apache/pkgs/container/wordpress-apache>

Version info:

* Wordpress version:  6.8
* Apache version:     2.4
* PHP version:        8.4

Installed php extensions:

* memcached v3.2
* imagick v3.8