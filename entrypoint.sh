#!/bin/sh

make_writable() {
    DIR=$1
    find $DIR -type d -exec chmod 0777 {} \;
    find $DIR -type f -exec chmod 0666 {} \;
}

# Initialize config volume if empty
echo "Initializing config directory"
if [ -f /var/www/html/application/config/config.php ]; then
    echo "Backup of config.php"
    cp /var/www/html/application/config/config.php /tmp/config.php
fi
if [ -f /var/www/html/application/config/security.php ]; then
    echo "Backup of security.php"
    cp /var/www/html/application/config/security.php /tmp/security.php
fi
rm -r /var/www/html/application/config/*
cp -r /defaults/application_config/* /var/www/html/application/config/
if [ -f /tmp/config.php ]; then
    echo "Restoring config.php"
    mv -f /tmp/config.php /var/www/html/application/config/config.php
fi
if [ -f /tmp/security.php ]; then
    echo "Restoring security.php"
    mv -f /tmp/security.php /var/www/html/application/config/security.php
fi
make_writable  /var/www/html/application/config

# Initialize upload volume if empty
if [ ! -f /var/www/html/upload/readme.txt ]; then
    echo "Upload volume looks empty. Initializing with defaults..."
    cp -r /defaults/upload/* /var/www/html/upload/
    make_writable  /var/www/html/upload
fi

echo "$@"

exec docker-php-entrypoint "$@"
