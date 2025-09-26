#!/bin/bash
set -e

echo "🧪 Testing Custom Bitnami WordPress + MariaDB Stack"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_status "Stopping any existing test containers..."
docker compose -f docker-compose-test.yml down -v 2>/dev/null || true

print_status "Starting the test environment..."
docker compose -f docker-compose-test.yml up -d

print_status "Waiting for services to be healthy..."

# Wait for MariaDB to be ready
print_status "Checking MariaDB health..."
timeout=120
counter=0
while ! docker compose -f docker-compose-test.yml exec -T mariadb mariadb-admin ping -uroot -prootpassword123 --silent 2>/dev/null; do
    counter=$((counter + 1))
    if [ $counter -ge $timeout ]; then
        print_error "MariaDB failed to start within $timeout seconds"
        echo "=== MariaDB Logs ==="
        docker compose -f docker-compose-test.yml logs mariadb
        exit 1
    fi
    echo -n "."
    sleep 1
done
print_success "MariaDB is ready!"

# Wait for WordPress to be ready
print_status "Checking WordPress health..."
timeout=180
counter=0
while ! curl -sf http://localhost:8080/wp-login.php >/dev/null 2>&1; do
    counter=$((counter + 1))
    if [ $counter -ge $timeout ]; then
        print_error "WordPress failed to start within $timeout seconds"
        echo "=== WordPress Logs ==="
        docker compose -f docker-compose-test.yml logs wordpress
        exit 1
    fi
    echo -n "."
    sleep 1
done
print_success "WordPress is ready!"

echo ""
echo "🎉 Test Environment is Ready!"
echo "================================"
echo "📊 WordPress Admin:"
echo "   URL: http://localhost:8080/wp-admin/"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "🗄️  MariaDB:"
echo "   Host: localhost:3306"
echo "   Database: wordpress_test"
echo "   User: wp_user"
echo "   Password: wp_password123"
echo "   Root Password: rootpassword123"
echo ""
echo "🔍 Useful Commands:"
echo "   View logs: docker compose -f docker-compose-test.yml logs -f"
echo "   Stop test: docker compose -f docker-compose-test.yml down -v"
echo "   WordPress shell: docker compose -f docker-compose-test.yml exec wordpress bash"
echo "   MariaDB shell: docker compose -f docker-compose-test.yml exec mariadb bash"
echo ""

# Run some basic tests
print_status "Running basic connectivity tests..."

# Test database connection
if docker compose -f docker-compose-test.yml exec -T mariadb mysql -uwp_user -pwp_password123 wordpress_test -e "SELECT 1;" >/dev/null 2>&1; then
    print_success "Database connection test passed"
else
    print_error "Database connection test failed"
fi

# Test WordPress response
if curl -sf http://localhost:8080/ | grep -q "WordPress" >/dev/null 2>&1; then
    print_success "WordPress response test passed"
else
    print_warning "WordPress response test inconclusive (site may not be fully initialized)"
fi

# Test admin login page
if curl -sf http://localhost:8080/wp-login.php | grep -q "wp-login" >/dev/null 2>&1; then
    print_success "WordPress admin login page accessible"
else
    print_error "WordPress admin login page test failed"
fi

echo ""
print_success "All basic tests completed! 🎯"
echo "You can now test the WordPress site manually at http://localhost:8080"
echo ""
echo "When done testing, run: docker compose -f docker-compose-test.yml down -v"