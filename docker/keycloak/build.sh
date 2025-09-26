#!/bin/bash
set -e

# Default Keycloak version
KEYCLOAK_VERSION=${1:-26.3.5}
IMAGE_NAME="ghcr.io/sammyeby/bitnami-keycloak"

echo "Building custom Keycloak image..."
echo "Keycloak version: $KEYCLOAK_VERSION"
echo "Image name: $IMAGE_NAME:$KEYCLOAK_VERSION"

# Build the image
docker build \
    --build-arg KEYCLOAK_VERSION=$KEYCLOAK_VERSION \
    -t $IMAGE_NAME:$KEYCLOAK_VERSION \
    -t $IMAGE_NAME:latest \
    .

echo "Build completed successfully!"
echo "Built images:"
echo "  - $IMAGE_NAME:$KEYCLOAK_VERSION"
echo "  - $IMAGE_NAME:latest"

echo ""
echo "To test the image locally:"
echo "  docker run --rm $IMAGE_NAME:$KEYCLOAK_VERSION /opt/keycloak/bin/kc.sh --version"

echo ""
echo "To run with admin user:"
echo "  docker run -d --name keycloak-test \\"
echo "    -p 8080:8080 \\"
echo "    -e KEYCLOAK_ADMIN_USER=admin \\"
echo "    -e KEYCLOAK_ADMIN_PASSWORD=admin123 \\"
echo "    $IMAGE_NAME:$KEYCLOAK_VERSION"

echo ""
echo "To push to registry:"
echo "  docker push $IMAGE_NAME:$KEYCLOAK_VERSION"
echo "  docker push $IMAGE_NAME:latest"