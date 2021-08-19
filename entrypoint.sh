#!/bin/sh

make_writable() {
    DIR=$1
    find $DIR -type d -exec chmod 0777 {} \;
    find $DIR -type f -exec chmod 0666 {} \;
}

# Initialize config volume if empty
if [ ! -f /var/www/html/application/config/index.html ]; then
    echo "Config volume looks empty. Initializing with defaults..."
    cp -r /defaults/application_config/* /var/www/html/application/config/
    make_writable  /var/www/html/application/config
fi

# Initialize upload volume if empty
if [ ! -f /var/www/html/upload/readme.txt ]; then
    echo "Upload volume looks empty. Initializing with defaults..."
    cp -r /defaults/upload/* /var/www/html/upload/
    make_writable  /var/www/html/upload
fi

echo "$@"

exec docker-php-entrypoint "$@"