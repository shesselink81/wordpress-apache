# wordpress-images

Custom wordpress Docker images

Docker Compose apache example:
```console
git clone https://github.com/shesselink81/wordpress-apache.git
cd wordpress-apache
docker compose up -d
```
Docker Compose alpine example:
```console
git clone https://github.com/shesselink81/wordpress-apache.git
cd wordpress-apache/wordpress-alpine
docker compose up -d
```
Helm Chart Alpine:
<https://artifacthub.io/packages/helm/wp-alpine/wordpress-alpine>

Docker images:
<https://github.com/shesselink81?tab=packages&repo_name=wordpress-apache>

Version info:

* Wordpress version:  6.9
* PHP version:        8.3

Installed php extensions:

* memcached: v3.2