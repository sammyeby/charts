# Custom WordPress image compatible with Bitnami Helm charts
# Based on official WordPress image but with Bitnami directory structure and scripts

ARG WORDPRESS_VERSION=6.8.2
FROM wordpress:${WORDPRESS_VERSION} AS wordpress-official

# Multi-stage build: Create Bitnami-compatible WordPress image
FROM debian:bookworm-slim

# Install required packages (optimized selection)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php \
    php-cli \
    php-mysql \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    php-curl \
    default-mysql-client \
    ca-certificates \
    curl \
    gosu \
    gettext-base \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

# Create bitnami user and group
RUN groupadd -r bitnami --gid=1001 && \
    useradd -r -g bitnami --uid=1001 --home-dir=/opt/bitnami --shell=/bin/bash bitnami

# Create Bitnami directory structure
RUN mkdir -p /opt/bitnami/wordpress \
    /opt/bitnami/apache/conf \
    /opt/bitnami/apache/logs \
    /opt/bitnami/apache/var/run \
    /opt/bitnami/scripts/wordpress \
    /opt/bitnami/scripts/apache \
    /bitnami/wordpress \
    /opt/bitnami/php/etc \
    && ln -sf /opt/bitnami/wordpress /var/www/html

# Copy WordPress files from official image
COPY --from=wordpress-official /var/www/html /opt/bitnami/wordpress/
COPY --from=wordpress-official /usr/src/wordpress /usr/src/wordpress

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy custom scripts and configurations
COPY setup.sh /opt/bitnami/scripts/wordpress/setup.sh
COPY apache-setup.sh /opt/bitnami/scripts/apache/setup.sh  
COPY entrypoint.sh /opt/bitnami/scripts/wordpress/entrypoint.sh
COPY wp-config-template.php /opt/bitnami/scripts/wordpress/wp-config-template.php

# Make scripts executable
RUN chmod +x /opt/bitnami/scripts/wordpress/setup.sh \
    /opt/bitnami/scripts/apache/setup.sh \
    /opt/bitnami/scripts/wordpress/entrypoint.sh

# Create symbolic links for compatibility
RUN ln -sf /opt/bitnami/wordpress /var/www/html

# Set proper ownership
RUN chown -R bitnami:bitnami /opt/bitnami \
    && chown -R bitnami:bitnami /bitnami

# Configure PHP for Bitnami compatibility  
RUN PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") && \
    echo "expose_php = Off" >> /etc/php/$PHP_VERSION/apache2/php.ini && \
    echo "memory_limit = 256M" >> /etc/php/$PHP_VERSION/apache2/php.ini && \
    echo "upload_max_filesize = 64M" >> /etc/php/$PHP_VERSION/apache2/php.ini && \
    echo "post_max_size = 64M" >> /etc/php/$PHP_VERSION/apache2/php.ini && \
    echo "max_execution_time = 300" >> /etc/php/$PHP_VERSION/apache2/php.ini

# Expose port 8080 (Bitnami default)
EXPOSE 8080

# Set working directory
WORKDIR /opt/bitnami/wordpress

# Switch to bitnami user
USER bitnami

# Set entrypoint
ENTRYPOINT ["/opt/bitnami/scripts/wordpress/entrypoint.sh"]