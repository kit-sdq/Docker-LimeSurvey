# Acquisition of resources
FROM alpine:latest as builder
WORKDIR /tmp/work
RUN VERSION=3.27.13+210823 && \
    wget -O limesurvey.zip https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/$VERSION.zip || true && \
    wget -O limesurvey.zip https://download.limesurvey.org/lts-releases/limesurvey$VERSION.zip || true && \
    mkdir extracted && \
    unzip -d extracted limesurvey.zip && \
    mv extracted/* limesurvey

# Actual image definition
FROM php:7-apache

# Install dependencies
RUN apt-get update && \
    apt-get install -y libpq-dev libzip-dev libpng-dev libldap2-dev libc-client-dev libkrb5-dev libjpeg-dev libfreetype6-dev && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql pdo_pgsql gd ldap imap zip && \
    rm -rf /var/lib/apt/lists/*

# Copy limesurvey code
COPY --from=builder /tmp/work/limesurvey/ /var/www/html
COPY --from=builder /tmp/work/limesurvey/upload /defaults/upload
COPY --from=builder /tmp/work/limesurvey/application/config /defaults/application_config

# Make directories writable
RUN rm -r /var/www/html/upload/* /var/www/html/application/config/* && \
    chmod -R 777 /var/www/html/upload /var/www/html/application/config && \
    find /var/www/html/tmp -type d -exec chmod 0777 {} \; && \
    find /var/www/html/tmp -type f -exec chmod 0666 {} \;

# Add volumes for persistent data
VOLUME ["/var/www/html/upload", "/var/www/html/application/config"]

# Add entrypoint script
COPY ./entrypoint.sh /usr/local/bin/limesurvey-entrypoint
ENTRYPOINT ["limesurvey-entrypoint"]

# Use default command to run foreground
CMD ["apache2-foreground"]
