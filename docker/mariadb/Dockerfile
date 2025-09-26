# Minimal MariaDB image compatible with Bitnami Helm charts
# Based on official MariaDB with minimal Bitnami compatibility layer

ARG MARIADB_VERSION=12.0.2
FROM mariadb:${MARIADB_VERSION}

# Install minimal packages needed for Bitnami compatibility
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Create bitnami user and group
RUN groupadd -r bitnami --gid=1001 && \
    useradd -r -g bitnami --uid=1001 --home-dir=/opt/bitnami --shell=/bin/bash bitnami

# Create minimal Bitnami directory structure
RUN mkdir -p /opt/bitnami/mariadb/conf \
    /opt/bitnami/mariadb/logs \
    /bitnami/mariadb \
    && ln -sf /var/lib/mysql /bitnami/mariadb/data \
    && ln -sf /etc/mysql/my.cnf /opt/bitnami/mariadb/conf/my.cnf

# Create minimal entrypoint script for environment variable mapping
COPY docker-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# Set proper ownership for bitnami paths
RUN chown -R bitnami:bitnami /opt/bitnami

# Expose MariaDB port
EXPOSE 3306

# Set working directory
WORKDIR /opt/bitnami/mariadb

# Use custom entrypoint that maps Bitnami variables to MariaDB variables
ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mariadbd"]