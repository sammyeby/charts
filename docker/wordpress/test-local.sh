#!/bin/bash
set -e

echo "Testing custom WordPress image locally..."

# Start a simple MariaDB container for testing
echo "Starting MariaDB container..."
docker run -d \
    --name test-mariadb \
    -e MYSQL_ROOT_PASSWORD=rootpassword \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=wordpress \
    -e MYSQL_PASSWORD=testpassword \
    -p 3306:3306 \
    mariadb:11.7

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
sleep 10

# Start the WordPress container
echo "Starting WordPress container..."
docker run -d \
    --name test-wordpress \
    -e MARIADB_HOST=host.docker.internal \
    -e MARIADB_DATABASE=wordpress \
    -e MARIADB_USER=wordpress \
    -e MARIADB_PASSWORD=testpassword \
    -e WORDPRESS_USERNAME=admin \
    -e WORDPRESS_PASSWORD=admin123 \
    -e WORDPRESS_EMAIL=admin@example.com \
    -e WORDPRESS_BLOG_NAME="Test WordPress Site" \
    -p 8080:8080 \
    ghcr.io/sammyeby/bitnami-wordpress:6.8.2

echo "Containers started!"
echo "WordPress should be available at: http://localhost:8080"
echo ""
echo "To check logs:"
echo "  docker logs test-wordpress"
echo "  docker logs test-mariadb"
echo ""
echo "To stop and cleanup:"
echo "  docker stop test-wordpress test-mariadb"
echo "  docker rm test-wordpress test-mariadb"