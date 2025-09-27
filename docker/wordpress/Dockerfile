# Bitnami-compatible WordPress image
# Simple drop-in replacement for ghcr.io/sammyeby/bitnami-wordpress
# Built: 2025-09-27 with dynamic version support

ARG WORDPRESS_VERSION=6.8.2
FROM wordpress:${WORDPRESS_VERSION}

# Install minimal required packages (only what's absolutely needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create bitnami user and directories
RUN groupadd -r bitnami --gid=1001 && \
    useradd -r -g bitnami --uid=1001 --home-dir=/opt/bitnami --shell=/bin/bash bitnami

# Create Bitnami-compatible directory structure
RUN mkdir -p /opt/bitnami/wordpress \
    /opt/bitnami/scripts \
    /opt/bitnami/apache/conf \
    /opt/bitnami/apache/logs \
    /opt/bitnami/apache/var/run \
    /opt/bitnami/php/etc \
    /opt/bitnami/php/tmp \
    /opt/bitnami/php/var \
    /bitnami/wordpress \
    && chown -R bitnami:bitnami /opt/bitnami /bitnami

# Configure Apache for port 8080 and proper document root
RUN echo "Listen 8080" > /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|DocumentRoot /var/www/html|DocumentRoot /opt/bitnami/wordpress|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/>|<Directory /opt/bitnami/wordpress/>|' /etc/apache2/apache2.conf && \
    a2enmod rewrite

# Copy Bitnami scripts
COPY liblog.sh /opt/bitnami/scripts/liblog.sh
COPY libfs.sh /opt/bitnami/scripts/libfs.sh
RUN chmod +x /opt/bitnami/scripts/liblog.sh /opt/bitnami/scripts/libfs.sh

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-wordpress.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wordpress.sh

# Set up PHP configuration (copy from system PHP)
RUN cp -r /usr/local/etc/php/* /opt/bitnami/php/etc/ 2>/dev/null || true && \
    mkdir -p /opt/bitnami/php/etc/conf.d && \
    mkdir -p /opt/bitnami/php/var && \
    mkdir -p /opt/bitnami/php/tmp && \
    echo "; Bitnami PHP configuration" > /opt/bitnami/php/etc/common.conf

# Set up Apache logs with symlinks to stdout/stderr (matching Bitnami naming)
RUN ln -sf /dev/stdout /opt/bitnami/apache/logs/access_log && \
    ln -sf /dev/stderr /opt/bitnami/apache/logs/error_log

# Create Apache configuration directories
RUN mkdir -p /opt/bitnami/apache/conf /opt/bitnami/apache/var/run

# Copy WordPress files to Bitnami location and set up symlinks
RUN cp -a /var/www/html/. /opt/bitnami/wordpress/ && \
    rm -rf /var/www/html && \
    ln -sf /opt/bitnami/wordpress /var/www/html && \
    chown -R bitnami:bitnami /opt/bitnami/wordpress /var/log/apache2 /opt/bitnami && \
    chmod -R 755 /var/log/apache2

# Set working directory
WORKDIR /opt/bitnami/wordpress

# Switch to bitnami user
USER bitnami

# Expose port 8080
EXPOSE 8080

# Use our custom entrypoint
ENTRYPOINT ["docker-entrypoint-wordpress.sh"]
CMD ["apache2-foreground"]