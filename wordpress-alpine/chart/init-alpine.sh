#!/bin/bash
set -euo pipefail

echo "=== WordPress init script started ==="

# Zet veilige defaults
export WP_PATH="/var/www/html"

# Controleer database connectie voordat we verdergaan
echo "⏳ Wachten op database (${WORDPRESS_DB_HOST})..."
until mariadb-admin --ssl=FALSE ping -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
  sleep 2
done
echo "✅ Database bereikbaar!"

# Controleer of WP al is geïnstalleerd
if php -d memory_limit=512M /usr/local/bin/wp core is-installed --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
  echo "ℹ️  WordPress is al geïnstalleerd — overslaan van init."
else
  echo "🚀 Nieuwe WordPress installatie gestart..."

  # Download core (indien nog niet aanwezig)
  if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
    echo "⬇️  Downloaden van WordPress (${WP_LOCALE})..."
    php -d memory_limit=512M /usr/local/bin/wp core download --path="${WP_PATH}" --allow-root --version="${WORDPRESS_VERSION}" --force --locale="${WP_LOCALE}"
  fi

  # Config aanmaken als hij nog niet bestaat
  if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "⚙️  Aanmaken wp-config.php..."
    php -d memory_limit=512M /usr/local/bin/wp config create \
      --path="${WP_PATH}" \
      --dbname="${WORDPRESS_DB_NAME}" \
      --dbuser="${WORDPRESS_DB_USER}" \
      --dbpass="${WORDPRESS_DB_PASSWORD}" \
      --dbhost="${WORDPRESS_DB_HOST}" \
      --locale="${WP_LOCALE}" \
      --allow-root
  fi

  # Installatie uitvoeren
  echo "🧩 Installeren van WordPress..."
  php -d memory_limit=512M /usr/local/bin/wp core install \
    --path="${WP_PATH}" \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "✅ WordPress installatie voltooid!"
  # Memcached ondersteuning inschakelen
    echo "💾 Memcached server gevonden, plugin installeren..."
    if ! php -d memory_limit=512M /usr/local/bin/wp plugin is-installed w3-total-cache --path="${WP_PATH}" --allow-root; then
      php -d memory_limit=512M /usr/local/bin/wp plugin install w3-total-cache --activate --allow-root --path="${WP_PATH}"
    else
      php -d memory_limit=512M /usr/local/bin/wp plugin activate w3-total-cache --allow-root --path="${WP_PATH}" || true
    fi

    # Voeg caching aan wp-config toe (indien nog niet aanwezig)
    if ! grep -q "WP_CACHE" "${WP_PATH}/wp-config.php"; then
      echo "define('WP_CACHE', true);" >> "${WP_PATH}/wp-config.php"
    fi

    echo "define('WP_MEMORY_LIMIT', '256M');" >> "${WP_PATH}/wp-config.php"
    echo "define('WP_MAX_MEMORY_LIMIT', '512M');" >> "${WP_PATH}/wp-config.php"

    if ! grep -q "memcached_servers" "${WP_PATH}/wp-config.php"; then
      echo "\$memcached_servers = array( 'default' => array('${MEMCACHED_HOST}:11211') );" >> "${WP_PATH}/wp-config.php"
    fi
    #cp /tmp/cache-config.json "${WP_PATH}/wp-content/w3tc-config/master.php"
    echo "✅ Memcached caching geconfigureerd."

  # Cleanup ongebruikte thema's en plugins
  echo "🧾 Cleanup unused themes"
  wp theme delete $(wp theme list --status=inactive --field=name --path="${WP_PATH}" --allow-root) --path="${WP_PATH}" --allow-root
  echo "✅ Verwijderen van ongebruikte thema's voltooid."
  
  echo "🧾 Enable theme autoupdate"
  wp theme auto-updates enable --all --disabled-only --path="${WP_PATH}" --allow-root

  echo "🧾 Cleanup plugins and enable autoupdate"
  php -d memory_limit=512M /usr/local/bin/wp plugin install updraftplus --activate --allow-root --path="${WP_PATH}"
  php -d memory_limit=512M /usr/local/bin/wp plugin auto-updates enable --all --disabled-only --path="${WP_PATH}" --allow-root
  if php -d memory_limit=512M /usr/local/bin/wp plugin is-installed hello --path="${WP_PATH}" --allow-root; then
      php -d memory_limit=512M /usr/local/bin/wp plugin delete hello --allow-root --path="${WP_PATH}"
  fi
  if php -d memory_limit=512M /usr/local/bin/wp plugin is-installed akismet --path="${WP_PATH}" --allow-root; then
      php -d memory_limit=512M /usr/local/bin/wp plugin delete akismet --allow-root --path="${WP_PATH}"
  fi

fi

# File permissies herstellen
# echo "🧾 Herstellen van permissies..."
# chown -R 82:82 "${WP_PATH}"
# chmod 755 "${WP_PATH}"/*
# find "${WP_PATH}" -type d -exec chmod 755 {} \;
# find "${WP_PATH}" -type f -exec chmod 644 {} \;

# php -d memory_limit=512M /usr/local/bin/wp config list --path="${WP_PATH}" --allow-root

echo "🎉 Init script voltooid!"
