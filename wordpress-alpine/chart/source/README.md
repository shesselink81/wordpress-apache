# WordPress Alpine Helm Chart

A production-ready **WordPress Helm chart** running on **Alpine Linux**, using:

- **WordPress FPM**
- **Nginx**
- **Init container (WP-CLI)**
- **MariaDB**
- Optional **Memcached**
- Optional **Ingress (Traefik compatible)**

📦 Helm repo:  
https://wp.charts.hessel.cloud/

📦 Helm Chart:  
https://artifacthub.io/packages/helm/wordpress-alpine/wordpress-alpine

## 🚀 Quick Start

### Add the Helm Repository

```bash
helm repo add wp-alpine https://wp.charts.hessel.cloud/
helm repo update
helm install my-wordpress wp-alpine/wordpress-alpine
```

🧠 Architecture

This chart deploys:

- WordPress PHP-FPM (Alpine)
- Nginx as frontend
- Init container using WP-CLI (WordPress setup & config)
- MariaDB (Alpine)
- Optional Memcached (via dependency)
- Persistent volumes for:
- - WordPress files
- - Database data

🐳 Container Images
| Component     | Image                                            |
| ------------- | ------------------------------------------------ |
| WordPress FPM | `ghcr.io/shesselink81/wordpress-alpine:v7.0.0.1` |
| Nginx         | `ghcr.io/shesselink81/nginx-alpine:v7.0.0.1`     |
| Init (WP-CLI) | `wordpress:cli-php8.5`                           |
| Database      | `mariadb:12.3.2`                                 |


⚙️ Configuration

All configuration is done via values.yaml.

Example values.yaml:
```yaml
env:
  wp:
    admin_user: admin
    debug: 'false'
    domainname: wp.example.com
    locale: en_US
    scheme: https
    title: My WordPress Site
    url: ${scheme}://${domainname}
    version: 7.0.0

hostAliases:
  enabled: false
  entries:
    - ip: "10.10.10.10"
      hostnames:
        - "wordpress.local"

httproute:
  enabled: true
  gateway:
    name: traefik-gateway
    namespace: traefik
  hostnames:
    - wp.example.com
  path: /

mariadb:
  auth:
    enabled: true
  enabled: true

secrets:
  mariadb:
    rootPassword: db-root-pw
    userPassword: db-user-pw
  wordpress:
    password: admin

wordpress:
  auth:
    username: db-user
  init:
    enabled: true
```