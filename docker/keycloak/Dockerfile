# Custom Keycloak image compatible with Bitnami Helm charts
# Based on official Keycloak image but with Bitnami directory structure and scripts

ARG KEYCLOAK_VERSION=26.3.5

# Stage 1: Build stage with full OS for installing dependencies
FROM registry.access.redhat.com/ubi9/ubi:latest AS builder

# Install required packages
RUN dnf update -y && dnf install -y --allowerasing \
    ca-certificates \
    curl \
    bash \
    shadow-utils \
    wget \
    tar \
    && dnf clean all

# Download and install gosu
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        'x86_64') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64'; sha256='bbc4136d03ab138b1ad66fa4fc051bafc6cc7ffae632b069a53657279a450de3' ;; \
        'aarch64') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-arm64'; sha256='c3805a85d17f4454c23d7059bcb97e1ec1af272b90126e79ed002342de08389b' ;; \
        *) echo >&2 "error: unsupported architecture: $arch"; exit 1 ;; \
    esac; \
    wget -O /usr/local/bin/gosu "$url"; \
    echo "$sha256 */usr/local/bin/gosu" | sha256sum -c -; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

# Stage 2: Final image based on official Keycloak
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

# Redeclare ARG for this stage
ARG KEYCLOAK_VERSION=26.3.5

# Set environment variables
ENV KEYCLOAK_VERSION=${KEYCLOAK_VERSION}
ENV BITNAMI_APP_NAME=keycloak
ENV BITNAMI_IMAGE_VERSION=${KEYCLOAK_VERSION}

# Switch to root user for setup
USER 0

# Copy gosu from builder stage
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu

# Create keycloak user and group with specific UID/GID for Bitnami compatibility
RUN groupadd -r keycloak --gid=1001 2>/dev/null || true && \
    useradd -r -g keycloak --uid=1001 --home-dir=/opt/bitnami/keycloak --shell=/bin/bash keycloak 2>/dev/null || true

# Create Bitnami directory structure
RUN mkdir -p /opt/bitnami/keycloak/conf \
    /opt/bitnami/keycloak/data \
    /opt/bitnami/keycloak/lib/quarkus \
    /opt/bitnami/keycloak/providers \
    /opt/bitnami/keycloak/themes \
    /opt/bitnami/keycloak/logs \
    /opt/bitnami/keycloak/tmp \
    /opt/bitnami/scripts \
    /bitnami/keycloak/data \
    /bitnami/keycloak/conf \
    /bitnami/keycloak/logs

# Create symbolic links for Bitnami compatibility
RUN ln -sf /opt/keycloak/bin /opt/bitnami/keycloak/bin && \
    ln -sf /opt/keycloak/lib /opt/bitnami/keycloak/lib && \
    ln -sf /opt/keycloak/providers /opt/bitnami/keycloak/providers/default && \
    ln -sf /opt/keycloak/themes /opt/bitnami/keycloak/themes/default

# Copy Bitnami compatibility scripts
COPY liblog.sh /opt/bitnami/scripts/liblog.sh
COPY keycloak-env.sh /opt/bitnami/scripts/keycloak-env.sh
COPY keycloak-setup.sh /opt/bitnami/scripts/keycloak-setup.sh
COPY keycloak-run.sh /opt/bitnami/scripts/keycloak-run.sh
COPY keycloak-entrypoint.sh /opt/bitnami/scripts/keycloak-entrypoint.sh

# Set executable permissions on scripts
RUN chmod +x /opt/bitnami/scripts/*.sh

# Set proper ownership for all directories
RUN chown -R keycloak:keycloak /opt/bitnami/keycloak \
    /bitnami/keycloak \
    /opt/bitnami/scripts

# Create default keycloak.conf if it doesn't exist
RUN touch /opt/bitnami/keycloak/conf/keycloak.conf && \
    chown keycloak:keycloak /opt/bitnami/keycloak/conf/keycloak.conf

# Set the working directory
WORKDIR /opt/bitnami/keycloak

# Switch to keycloak user
USER keycloak

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /opt/keycloak/bin/kc.sh show-config || exit 1

# Expose ports
EXPOSE 8080 8443 9000

# Set the entrypoint
ENTRYPOINT ["/opt/bitnami/scripts/keycloak-entrypoint.sh"]

# Default command
CMD ["keycloak-run.sh"]