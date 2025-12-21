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
WordPress Settings
```yaml
env:
  wp:
    scheme: https
    domainname: wordpress.local
    url: "${scheme}://${domainname}"
    version: "6.9.0"
    locale: en_US
    title: "My WordPress Site"
    admin_user: admin
    admin_password: admin
    debug: "false"

wordpress:
  init:
    enabled: true
  resources:
    requests:
       memory: "128Mi"
       cpu: "50m"
    limits:
       memory: "512Mi"
       cpu: "300m"

persistence:
  wordpress:
    enabled: true
    size: 1Gi
    existingClaim: ""
    keep: true

mariadb:
  enabled: true
  auth:
    enabled: true
    rootPassword: "rootpassword"
    database: "wordpress"
    username: "wordpress"
    password: "wordpress"
    existingSecret: ""
    allowEmptyRootPassword: "false"
    secretKeys:
      rootPasswordKey: mariadb-root-password
      userPasswordKey: mariadb-password
  persistence:
    enabled: true
    storageClass: ""
    accessModes:
      - ReadWriteOnce
    size: 1Gi
  resources:
    requests:
       memory: "128Mi"
       cpu: "20m"
    limits:
       memory: "256Mi"
       cpu: "300m"

nginx:
  resources:
    requests:
       memory: "32Mi"
       cpu: "10m"
    limits:
       memory: "64Mi"
       cpu: "150m"
  service:
    port: 80

ingress:
  enabled: true
  className: "traefik"
  annotations: {}
  hosts:
    - host: wordpress.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
  useHttpsBackend: false
  extraRules: []

memcached:
  enabled: true
  createConfig: true
  nameOverride: ""
  fullnameOverride: ""
  resources:
    requests:
       memory: "15Mi"
       cpu: "5m"
    limits:
       memory: "45Mi"
       cpu: "50m"
```