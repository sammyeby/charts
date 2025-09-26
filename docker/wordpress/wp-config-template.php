<?php
define('DB_NAME', getenv('WORDPRESS_DATABASE_NAME') ?: 'wordpress');
define('DB_USER', getenv('WORDPRESS_DATABASE_USER') ?: 'wordpress'); 
define('DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD') ?: '');
define('DB_HOST', getenv('WORDPRESS_DATABASE_HOST') . ':' . (getenv('WORDPRESS_DATABASE_PORT_NUMBER') ?: '3306'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// WordPress salts - should be set via environment variables in production
define('AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'put your unique phrase here');
define('SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'put your unique phrase here');
define('LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'put your unique phrase here');
define('NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'put your unique phrase here');
define('AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'put your unique phrase here');
define('SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'put your unique phrase here');
define('LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'put your unique phrase here');
define('NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'put your unique phrase here');

$table_prefix = getenv('WORDPRESS_TABLE_PREFIX') ?: 'wp_';

define('WP_DEBUG', getenv('WORDPRESS_DEBUG') === 'true');

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';