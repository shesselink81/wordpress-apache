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
| WordPress FPM | `ghcr.io/shesselink81/wordpress-alpine:v6.9.0.9` |
| Nginx         | `ghcr.io/shesselink81/nginx-alpine:v6.9.0.9`     |
| Init (WP-CLI) | `wordpress:cli-php8.3`                           |
| Database      | `mariadb:12.1.2`                                 |


⚙️ Configuration
All configuration is done via values.yaml.