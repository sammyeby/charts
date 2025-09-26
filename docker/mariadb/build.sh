#!/bin/bash
set -e

# Default MariaDB version
MARIADB_VERSION=${1:-12.0.2-ubi}
IMAGE_NAME="ghcr.io/sammyeby/bitnami-mariadb"

echo "Building custom MariaDB image..."
echo "MariaDB version: $MARIADB_VERSION"
echo "Image name: $IMAGE_NAME:$MARIADB_VERSION"

# Build the image
docker build \
    --build-arg MARIADB_VERSION=$MARIADB_VERSION \
    -t $IMAGE_NAME:$MARIADB_VERSION \
    -t $IMAGE_NAME:latest \
    .

echo "Build completed successfully!"
echo "Built images:"
echo "  - $IMAGE_NAME:$MARIADB_VERSION"
echo "  - $IMAGE_NAME:latest"

echo ""
echo "To test the image locally:"
echo "  docker run -p 3306:3306 \\"
echo "    -e MARIADB_ROOT_PASSWORD=rootpassword \\"
echo "    -e MARIADB_DATABASE=testdb \\"
echo "    -e MARIADB_USER=testuser \\"
echo "    -e MARIADB_PASSWORD=testpassword \\"
echo "    $IMAGE_NAME:$MARIADB_VERSION"

echo ""
echo "To push to registry:"
echo "  docker push $IMAGE_NAME:$MARIADB_VERSION"
echo "  docker push $IMAGE_NAME:latest"