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
    /bitnami/wordpress \
    && chown -R bitnami:bitnami /opt/bitnami /bitnami

# Configure Apache for port 8080 and proper document root
RUN echo "Listen 8080" > /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|DocumentRoot /var/www/html|DocumentRoot /opt/bitnami/wordpress|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/>|<Directory /opt/bitnami/wordpress/>|' /etc/apache2/apache2.conf && \
    a2enmod rewrite

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-wordpress.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wordpress.sh

# Copy WordPress files to Bitnami location and set up symlinks
RUN cp -a /var/www/html/. /opt/bitnami/wordpress/ && \
    rm -rf /var/www/html && \
    ln -sf /opt/bitnami/wordpress /var/www/html && \
    chown -R bitnami:bitnami /opt/bitnami/wordpress /var/log/apache2 && \
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