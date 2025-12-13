# Helm Chart: wordpress-alpine (generated from docker-compose)

Dit chart bevat 4 Kubernetes workloads:
- **db** (MariaDB)
- **wordpress-init** (Job i.p.v. service)
- **wordpress-fpm** (PHP-FPM container)
- **nginx** (frontend)

Alle config uit jouw docker-compose is verwerkt.

---
## Chart.yaml
```yaml
apiVersion: v2
name: wordpress-alpine
version: 0.1.0
description: WordPress FPM + Nginx + Init + MariaDB (alpine)
type: application
```

---
## values.yaml
```yaml
image:
  fpm: shesselink81/wordpress-alpine:latest
  nginx: shesselink81/wordpress-nginx-alpine:latest
  init: wordpress:cli-php8.4
  db: mariadb:10.11

env:
  mysql:
    user: wordpress
    password: wordpress
    database: wordpress

  wp:
    scheme: https
    domainname: example.com
    version: "6.7.1"

persistence:
  wordpress:
    enabled: true
    size: 5Gi
  db:
    enabled: true
    size: 5Gi

service:
  nginx:
    port: 80
```

---
## templates/db-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-db
spec:
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: mariadb
          image: {{ .Values.image.db }}
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "rootpass"
            - name: MYSQL_USER
              value: {{ .Values.env.mysql.user | quote }}
            - name: MYSQL_PASSWORD
              value: {{ .Values.env.mysql.password | quote }}
            - name: MYSQL_DATABASE
              value: {{ .Values.env.mysql.database | quote }}
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: dbdata
      volumes:
        - name: dbdata
          persistentVolumeClaim:
            claimName: {{ include "wordpress-alpine.fullname" . }}-db-pvc
```

---
## templates/db-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-db-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: {{ .Values.persistence.db.size }}
```

---
## templates/wordpress-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-wp-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: {{ .Values.persistence.wordpress.size }}
```

---
## templates/wordpress-init-job.yaml
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-init
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: init
          image: {{ .Values.image.init }}
          command: ["/bin/bash", "/tmp/init.sh"]
          env:
            - name: WORDPRESS_DB_HOST
              value: "db"
            - name: WORDPRESS_DB_USER
              value: {{ .Values.env.mysql.user | quote }}
            - name: WORDPRESS_DB_PASSWORD
              value: {{ .Values.env.mysql.password | quote }}
            - name: WORDPRESS_DB_NAME
              value: {{ .Values.env.mysql.database | quote }}
          volumeMounts:
            - name: wordpress
              mountPath: /var/www/html
            - name: init-script
              mountPath: /tmp/init.sh
              subPath: init.sh
      volumes:
        - name: wordpress
          persistentVolumeClaim:
            claimName: {{ include "wordpress-alpine.fullname" . }}-wp-pvc
        - name: init-script
          configMap:
            name: {{ include "wordpress-alpine.fullname" . }}-init-config
```

---
## templates/init-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-init-config
data:
  init.sh: |-
{{ (.Files.Get "init-alpine.sh") | indent 4 }}
```

---
## templates/wordpress-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-fpm
spec:
  selector:
    matchLabels:
      app: wordpress-fpm
  template:
    metadata:
      labels:
        app: wordpress-fpm
    spec:
      containers:
        - name: fpm
          image: {{ .Values.image.fpm }}
          env:
            - name: WP_DB_HOST
              value: "db"
            - name: WP_DB_USER
              value: {{ .Values.env.mysql.user | quote }}
            - name: WP_DB_PASSWORD
              value: {{ .Values.env.mysql.password | quote }}
            - name: WP_DB_NAME
              value: {{ .Values.env.mysql.database | quote }}
            - name: WP_URL
              value: "{{ .Values.env.wp.scheme }}://{{ .Values.env.wp.domainname }}"
            - name: WORDPRESS_VERSION
              value: {{ .Values.env.wp.version | quote }}
          volumeMounts:
            - mountPath: /var/www/html
              name: wordpress
      volumes:
        - name: wordpress
          persistentVolumeClaim:
            claimName: {{ include "wordpress-alpine.fullname" . }}-wp-pvc
```

---
## templates/nginx-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: {{ .Values.image.nginx }}
          ports:
            - containerPort: {{ .Values.service.nginx.port }}
          volumeMounts:
            - mountPath: /var/www/html
              name: wordpress
            - mountPath: /etc/nginx/conf.d/default.conf
              name: nginxconf
              subPath: default.conf
      volumes:
        - name: wordpress
          persistentVolumeClaim:
            claimName: {{ include "wordpress-alpine.fullname" . }}-wp-pvc
        - name: nginxconf
          configMap:
            name: {{ include "wordpress-alpine.fullname" . }}-nginx-config
```

---
## templates/nginx-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-nginx-config
data:
  default.conf: |-
{{ (.Files.Get "nginx/default.conf") | indent 4 }}
```

---
## templates/nginx-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "wordpress-alpine.fullname" . }}-nginx
spec:
  selector:
    app: nginx
  ports:
    - port: {{ .Values.service.nginx.port }}
      targetPort: {{ .Values.service.nginx.port }}
      protocol: TCP
```

---
## NOTES.txt
```txt
Install:
  helm install wp ./

Nginx exposed on Service.
MariaDB + PVC.
WordPress init via Job.
```

