#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# Configure Apache to listen on port 8080
echo "Listen 8080" > /etc/apache2/ports.conf

# Configure Apache for WordPress
cat > /etc/apache2/sites-available/wordpress.conf << 'APACHE_CONF'
<VirtualHost *:8080>
    DocumentRoot /opt/bitnami/wordpress
    
    <Directory /opt/bitnami/wordpress>
        AllowOverride All
        Require all granted
        
        # WordPress pretty permalinks
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteBase /
            RewriteRule ^index\.php$ - [L]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule . /index.php [L]
        </IfModule>
    </Directory>
    
    # Logging
    ErrorLog /opt/bitnami/apache/logs/error.log
    CustomLog /opt/bitnami/apache/logs/access.log combined
</VirtualHost>
APACHE_CONF

# Enable required Apache modules
a2enmod rewrite
a2enmod php

# Disable default Apache site and enable WordPress site
a2dissite 000-default
a2ensite wordpress

echo "Apache setup completed"