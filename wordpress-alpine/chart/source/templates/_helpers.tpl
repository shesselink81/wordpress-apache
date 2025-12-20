{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress-alpine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wordpress-alpine.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wordpress-alpine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wordpress-alpine.labels" -}}
helm.sh/chart: "{{ include "wordpress-alpine.chart" . }}"
{{ include "wordpress-alpine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end }}
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wordpress-alpine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress-alpine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wordpress-alpine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wordpress-alpine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return PVC name:
- existingClaim if set
- otherwise default fullname
*/}}
{{- define "wordpress-alpine.pvcName" -}}
{{- if .Values.persistence.wordpress.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- printf "%s-wp" (include "wordpress-alpine.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "wordpress-alpine.dbpvcName" -}}
{{- if .Values.persistence.db.existingClaim -}}
{{- .Values.persistence.db.existingClaim -}}
{{- else -}}
{{- printf "%s-db" (include "wordpress-alpine.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
MariaDB fullname
*/}}
{{- define "wordpress-alpine.mariadb.fullname" -}}
{{- if .Values.mariadb.fullnameOverride}}
{{- .Values.mariadb.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "mariadb" .Values.mariadb.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
memcached fullname
*/}}
{{- define "wordpress-alpine.memcached.fullname" -}}
{{- if .Values.memcached.fullnameOverride }}
{{- .Values.memcached.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "memcached" .Values.memcached.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Wordpress metrics plugin
*/}}
{{- define "metrics.wordpress-alpine.pluginname" -}}
{{- if and (default false .Values.metrics.wordpress.enabled) (default false .Values.metrics.wordpress.installPlugin) }}
{{- default "slymetrics" .Values.metrics.wordpress.pluginNameOverride | quote }}
{{- else }}
{{- "" | quote }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metrics.wordpress-alpine.fullname" -}}
{{- if .Values.metrics.wordpress.fullnameOverride }}
{{- .Values.metrics.wordpress.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "metrics-wordpress" .Values.metrics.wordpress.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metrics.apache.fullname" -}}
{{- if .Values.metrics.apache.fullnameOverride }}
{{- .Values.metrics.apache.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "metrics-apache" .Values.metrics.apache.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Build a full image reference from registry, repository and tag.
Usage: {{ include "slycharts.image" (dict "image" .Values.image "defaultTag" .Chart.AppVersion) }}
or:    {{ include "slycharts.image" (dict "image" .Values.wordpress.init.image) }}

The image dict should contain:
  - registry: (optional) e.g. "docker.io", "ghcr.io"
  - repository: (required) e.g. "wordpress", "mariadb"
  - tag: (required) e.g. "6.8.3-php8.1-apache" or with digest "6.8.3@sha256:abc123"

Returns: registry/repository:tag (e.g. "docker.io/wordpress:6.8.3-php8.1-apache")
*/}}
{{- define "slycharts.image" -}}
{{- $registry := .image.registry | default "" -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | default .defaultTag | default "latest" -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

