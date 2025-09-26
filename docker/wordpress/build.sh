#!/bin/bash
set -e

# Default WordPress version
WORDPRESS_VERSION=${1:-6.8.2}
IMAGE_NAME="ghcr.io/sammyeby/bitnami-wordpress"

echo "Building custom WordPress image..."
echo "WordPress version: $WORDPRESS_VERSION"
echo "Image name: $IMAGE_NAME:$WORDPRESS_VERSION"

# Build the image
docker build \
    --build-arg WORDPRESS_VERSION=$WORDPRESS_VERSION \
    -t $IMAGE_NAME:$WORDPRESS_VERSION \
    -t $IMAGE_NAME:latest \
    .

echo "Build completed successfully!"
echo "Built images:"
echo "  - $IMAGE_NAME:$WORDPRESS_VERSION"
echo "  - $IMAGE_NAME:latest"

echo ""
echo "To test the image locally:"
echo "  docker run -p 8080:8080 \\"
echo "    -e MARIADB_HOST=your-db-host \\"
echo "    -e MARIADB_DATABASE=wordpress \\"
echo "    -e MARIADB_USER=wordpress \\"
echo "    -e MARIADB_PASSWORD=your-password \\"
echo "    $IMAGE_NAME:$WORDPRESS_VERSION"

echo ""
echo "To push to registry:"
echo "  docker push $IMAGE_NAME:$WORDPRESS_VERSION"
echo "  docker push $IMAGE_NAME:latest"