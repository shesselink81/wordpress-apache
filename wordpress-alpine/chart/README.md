# WordPress Alpine Helm Chart

A production-ready **WordPress Helm chart** running on **Alpine Linux**, using:

- **WordPress FPM**
- **Nginx**
- **Init container (WP-CLI)**
- **MariaDB**
- Optional **Memcached**
- Optional **Ingress (Traefik compatible)**

📦 Helm repo:  
https://shesselink81.github.io/wordpress-apache/wordpress-alpine/chart/

## 🚀 Quick Start

### Add the Helm Repository

```bash
helm repo add wp-alpine https://shesselink81.github.io/wordpress-apache/wordpress-alpine/chart
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