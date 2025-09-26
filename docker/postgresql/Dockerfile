# Custom PostgreSQL image compatible with Bitnami Helm charts
# Based on official PostgreSQL image but with Bitnami directory structure and scripts

ARG POSTGRESQL_VERSION=17.6-alpine
FROM postgres:${POSTGRESQL_VERSION}

# Install additional packages for Bitnami compatibility
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash

# Create bitnami user and group
RUN addgroup -g 1001 bitnami && \
    adduser -D -u 1001 -G bitnami -h /opt/bitnami -s /bin/bash bitnami

# Create Bitnami directory structure
RUN mkdir -p /opt/bitnami/postgresql/conf \
    /opt/bitnami/postgresql/logs \
    /opt/bitnami/postgresql/tmp \
    /opt/bitnami/postgresql/secrets \
    /opt/bitnami/postgresql/certs \
    /opt/bitnami/scripts/postgresql \
    /bitnami/postgresql/data \
    /var/run/postgresql \
    && ln -sf /bitnami/postgresql/data /var/lib/postgresql/data

# Ensure docker-entrypoint-initdb.d directory exists
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy Bitnami compatibility scripts
COPY libfs.sh /opt/bitnami/scripts/libfs.sh
COPY liblog.sh /opt/bitnami/scripts/liblog.sh
COPY postgresql-env.sh /opt/bitnami/scripts/postgresql-env.sh
COPY libpostgresql.sh /opt/bitnami/scripts/libpostgresql.sh
COPY postgresql-setup.sh /opt/bitnami/scripts/postgresql/setup.sh
COPY postgresql-entrypoint.sh /opt/bitnami/scripts/postgresql/entrypoint.sh
COPY postgresql-run.sh /opt/bitnami/scripts/postgresql/run.sh

# Make scripts executable
RUN chmod +x /opt/bitnami/scripts/libfs.sh \
    /opt/bitnami/scripts/liblog.sh \
    /opt/bitnami/scripts/postgresql-env.sh \
    /opt/bitnami/scripts/libpostgresql.sh \
    /opt/bitnami/scripts/postgresql/setup.sh \
    /opt/bitnami/scripts/postgresql/entrypoint.sh \
    /opt/bitnami/scripts/postgresql/run.sh

# PostgreSQL binaries are already in the correct location in the official image

# Set correct ownership and permissions
RUN chown -R bitnami:bitnami /opt/bitnami \
    && chown -R bitnami:bitnami /bitnami \
    && chown -R bitnami:bitnami /var/lib/postgresql \
    && chown -R bitnami:bitnami /var/run/postgresql \
    && chmod 755 /var/run/postgresql

# Set environment variables
ENV PGUSER=bitnami \
    PGDATA=/bitnami/postgresql/data \
    POSTGRES_USER=postgres \
    POSTGRES_DB=postgres \
    PATH="/opt/bitnami/postgresql/bin:$PATH"

# Expose PostgreSQL port
EXPOSE 5432

# Set working directory
WORKDIR /opt/bitnami/postgresql

# Run as bitnami user
USER 1001

# Set entrypoint
ENTRYPOINT ["/opt/bitnami/scripts/postgresql/entrypoint.sh"]
CMD ["/opt/bitnami/scripts/postgresql/run.sh"]