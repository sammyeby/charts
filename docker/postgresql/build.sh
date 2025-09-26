#!/bin/bash
set -e

# Default PostgreSQL version
POSTGRESQL_VERSION=${1:-17.6-alpine}
IMAGE_NAME="ghcr.io/sammyeby/bitnami-postgresql"

echo "Building custom PostgreSQL image..."
echo "PostgreSQL version: $POSTGRESQL_VERSION"
echo "Image name: $IMAGE_NAME:$POSTGRESQL_VERSION"

# Build the image
docker build \
    --build-arg POSTGRESQL_VERSION=$POSTGRESQL_VERSION \
    -t $IMAGE_NAME:$POSTGRESQL_VERSION \
    -t $IMAGE_NAME:latest \
    .

echo "Build completed successfully!"
echo "Built images:"
echo "  - $IMAGE_NAME:$POSTGRESQL_VERSION"
echo "  - $IMAGE_NAME:latest"

echo ""
echo "To test the image locally:"
echo "  docker run -p 5432:5432 \\"
echo "    -e POSTGRES_PASSWORD=password \\"
echo "    -e POSTGRES_DATABASE=testdb \\"
echo "    -e POSTGRES_USER=testuser \\"
echo "    $IMAGE_NAME:$POSTGRESQL_VERSION"

echo ""
echo "To push to registry:"
echo "  docker push $IMAGE_NAME:$POSTGRESQL_VERSION"
echo "  docker push $IMAGE_NAME:latest"