# Custom MariaDB image compatible with Bitnami Helm charts
# Based on official MariaDB image but with Bitnami directory structure and scripts

ARG MARIADB_VERSION=12.0.2-ubi
FROM mariadb:${MARIADB_VERSION} AS mariadb-official

# Multi-stage build: Create Bitnami-compatible MariaDB image
FROM debian:bookworm-slim

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    ca-certificates \
    curl \
    gosu \
    gettext-base \
    pwgen \
    tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

# Create bitnami user and group
RUN groupadd -r bitnami --gid=1001 && \
    useradd -r -g bitnami --uid=1001 --home-dir=/opt/bitnami --shell=/bin/bash bitnami

# Create Bitnami directory structure
RUN mkdir -p /opt/bitnami/mariadb/conf \
    /opt/bitnami/mariadb/logs \
    /opt/bitnami/mariadb/tmp \
    /opt/bitnami/mariadb/secrets \
    /opt/bitnami/mariadb/certs \
    /opt/bitnami/mariadb/tde \
    /opt/bitnami/scripts/mariadb \
    /opt/bitnami/scripts/libfs \
    /opt/bitnami/mysqld-exporter/secrets \
    /bitnami/mariadb \
    && ln -sf /var/lib/mysql /bitnami/mariadb \
    && ln -sf /var/log/mysql /opt/bitnami/mariadb/logs

# Copy MariaDB files from official image (if any custom configs exist)
COPY --from=mariadb-official /etc/mysql/ /etc/mysql/

# Create Bitnami-compatible scripts
COPY libfs.sh /opt/bitnami/scripts/libfs.sh
COPY mariadb-setup.sh /opt/bitnami/scripts/mariadb/setup.sh
COPY mariadb-entrypoint.sh /opt/bitnami/scripts/mariadb/entrypoint.sh
COPY mariadb-run.sh /opt/bitnami/scripts/mariadb/run.sh

# Make scripts executable
RUN chmod +x /opt/bitnami/scripts/libfs.sh \
    /opt/bitnami/scripts/mariadb/setup.sh \
    /opt/bitnami/scripts/mariadb/entrypoint.sh \
    /opt/bitnami/scripts/mariadb/run.sh

# Create MariaDB configuration compatibility
RUN ln -sf /etc/mysql/my.cnf /opt/bitnami/mariadb/conf/my.cnf

# Set proper ownership
RUN chown -R bitnami:bitnami /opt/bitnami \
    && chown -R bitnami:bitnami /bitnami \
    && chown -R bitnami:bitnami /var/lib/mysql \
    && chown -R bitnami:bitnami /var/log

# Expose MariaDB port
EXPOSE 3306

# Set working directory
WORKDIR /opt/bitnami/mariadb

# Switch to bitnami user
USER bitnami

# Set entrypoint
ENTRYPOINT ["/opt/bitnami/scripts/mariadb/entrypoint.sh"]
CMD ["/opt/bitnami/scripts/mariadb/run.sh"]