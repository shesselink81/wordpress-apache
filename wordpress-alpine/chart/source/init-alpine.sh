#!/bin/bash
set -euo pipefail

echo "=== WordPress init script started ==="

# Set safe defaults
export WP_PATH="/var/www/html"

# Check database connectivity before continuing
echo "⏳ Waiting for database (${WORDPRESS_DB_HOST})..."
until mariadb-admin --ssl=FALSE ping -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
  sleep 2
done
echo "✅ Database is reachable!"

# Check if WordPress is already installed
if php -d memory_limit=512M /usr/local/bin/wp core is-installed --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
  echo "ℹ️  WordPress is already installed — skipping init."
else
  echo "🚀 Starting new WordPress installation..."

  # Download core (if not already present)
  if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
    echo "⬇️  Downloading WordPress (${WP_LOCALE})..."
    php -d memory_limit=512M /usr/local/bin/wp core download --path="${WP_PATH}" --allow-root --version="${WORDPRESS_VERSION}" --force --locale="${WP_LOCALE}"
  fi

  # Create config if it does not exist
  if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "⚙️  Creating wp-config.php..."
    php -d memory_limit=512M /usr/local/bin/wp config create \
      --path="${WP_PATH}" \
      --dbname="${WORDPRESS_DB_NAME}" \
      --dbuser="${WORDPRESS_DB_USER}" \
      --dbpass="${WORDPRESS_DB_PASSWORD}" \
      --dbhost="${WORDPRESS_DB_HOST}" \
      --locale="${WP_LOCALE}" \
      --allow-root
  fi

  # Run installation
  echo "🧩 Installing WordPress..."
  php -d memory_limit=512M /usr/local/bin/wp core install \
    --path="${WP_PATH}" \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "✅ WordPress installation completed!"

  # Enable Memcached support
  echo "💾 Memcached server detected, installing plugin..."
  if ! php -d memory_limit=512M /usr/local/bin/wp plugin is-installed w3-total-cache --path="${WP_PATH}" --allow-root; then
    php -d memory_limit=512M /usr/local/bin/wp plugin install w3-total-cache --activate --allow-root --path="${WP_PATH}"
  else
    php -d memory_limit=512M /usr/local/bin/wp plugin activate w3-total-cache --allow-root --path="${WP_PATH}" || true
  fi

  # Add caching to wp-config (if not already present)
  if ! grep -q "WP_CACHE" "${WP_PATH}/wp-config.php"; then
    echo "define('WP_CACHE', true);" >> "${WP_PATH}/wp-config.php"
  fi

  echo "define('WP_MEMORY_LIMIT', '256M');" >> "${WP_PATH}/wp-config.php"
  echo "define('WP_MAX_MEMORY_LIMIT', '512M');" >> "${WP_PATH}/wp-config.php"

  if ! grep -q "memcached_servers" "${WP_PATH}/wp-config.php"; then
    echo "\$memcached_servers = array( 'default' => array('${MEMCACHED_HOST}:11211') );" >> "${WP_PATH}/wp-config.php"
  fi

  echo "✅ Memcached caching configured."

  php -d memory_limit=512M /usr/local/bin/wp option update permalink_structure /%postname%/ --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp total-cache import /tmp/cache-config.json --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp total-cache option set objectcache.engine memcached --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp total-cache option set dbcache.engine memcached --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp total-cache option set dbcache.memcached.servers "${MEMCACHED_HOST}:11211" --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp total-cache option set objectcache.memcached.servers "${MEMCACHED_HOST}:11211" --allow-root --path="${WP_PATH}"
  #php -d memory_limit=512M /usr/local/bin/wp total-cache import /tmp/cache-config.json --allow-root --path="${WP_PATH}"

  echo "✅ W3 Total Cache configuratie toegepast."

  # Cleanup unused themes and plugins
  echo "🧾 Cleaning up unused themes"
  wp theme delete $(wp theme list --status=inactive --field=name --path="${WP_PATH}" --allow-root) --path="${WP_PATH}" --allow-root
  echo "✅ Removal of unused themes completed."
  
  echo "🧾 Enabling theme auto-updates"
  wp theme auto-updates enable --all --disabled-only --path="${WP_PATH}" --allow-root

  echo "🧾 Cleaning up plugins and enabling auto-updates"
  php -d memory_limit=512M /usr/local/bin/wp plugin install updraftplus --activate --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp plugin auto-updates enable --all --disabled-only --path="${WP_PATH}" --allow-root

  if php -d memory_limit=512M /usr/local/bin/wp plugin is-installed hello --path="${WP_PATH}" --allow-root; then
    php -d memory_limit=512M /usr/local/bin/wp plugin delete hello --allow-root --path="${WP_PATH}"
  fi

  if php -d memory_limit=512M /usr/local/bin/wp plugin is-installed akismet --path="${WP_PATH}" --allow-root; then
    php -d memory_limit=512M /usr/local/bin/wp plugin delete akismet --allow-root --path="${WP_PATH}"
  fi
fi

echo "🎉 Init script completed!"
