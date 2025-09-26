# Minimal PostgreSQL image compatible with Bitnami Helm charts
# Based on official PostgreSQL with minimal Bitnami compatibility layer

ARG POSTGRESQL_VERSION=17
FROM postgres:${POSTGRESQL_VERSION}

# Install minimal packages needed for Bitnami compatibility
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Create bitnami user and group
RUN groupadd -r bitnami --gid=1001 && \
    useradd -r -g bitnami --uid=1001 --home-dir=/opt/bitnami --shell=/bin/bash bitnami

# Create minimal Bitnami directory structure
RUN mkdir -p /opt/bitnami/postgresql/conf \
    /opt/bitnami/postgresql/logs \
    /bitnami/postgresql \
    && ln -sf /var/lib/postgresql/data /bitnami/postgresql/data

# Create minimal entrypoint script for environment variable mapping
COPY docker-entrypoint.sh /usr/local/bin/postgresql-entrypoint.sh
RUN chmod +x /usr/local/bin/postgresql-entrypoint.sh

# Set proper ownership for bitnami paths
RUN chown -R bitnami:bitnami /opt/bitnami

# Expose PostgreSQL port
EXPOSE 5432

# Set working directory
WORKDIR /opt/bitnami/postgresql

# Use custom entrypoint that maps Bitnami variables to PostgreSQL variables
ENTRYPOINT ["/usr/local/bin/postgresql-entrypoint.sh"]
CMD ["postgres"]