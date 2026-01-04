#!/bin/bash

###############################################################################
#                     WORDPRESS WEB SERVER INSTALLER
#                        Ubuntu Server 24.04 Edition
#
#  This script installs a complete LAMP stack:
#    • Apache (web server)
#    • MySQL (database server)
#    • PHP (backend language)
#    • WordPress (CMS)
#
#  It guides the user step-by-step through:
#    • System update
#    • LAMP installation
#    • Database creation
#    • WordPress download & configuration
#    • Apache virtual host setup
#
#  NOTE:
#    • Run this script as ROOT or with sudo.
#    • Make sure ports 80 and 443 are available.
###############################################################################

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "           WORDPRESS WEB SERVER INSTALLATION SCRIPT\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

###############################################################################
# STEP 1 — Update the system
###############################################################################
printf "[1/6] Updating system packages...\n"
sudo apt update && sudo apt upgrade -y
printf "✓ System updated.\n\n"

###############################################################################
# STEP 2 — Install Apache, MySQL, and PHP
###############################################################################
printf "[2/6] Installing Apache, MySQL, and PHP...\n"
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y
printf "✓ LAMP stack installed.\n\n"

###############################################################################
# STEP 3 — Create MySQL Database and User
###############################################################################
printf "[3/6] Creating MySQL database for WordPress...\n"
printf "Enter the name of the WordPress database: "
read db

printf "Enter the MySQL username to create: "
read userName

printf "Enter the password for this MySQL user: "
read passWord

# Create database, user, and grant privileges
sudo mysql -e "
CREATE DATABASE $db DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER '$userName'@'localhost' IDENTIFIED BY '$passWord';
GRANT ALL PRIVILEGES ON $db.* TO '$userName'@'localhost';
FLUSH PRIVILEGES;"

printf "✓ Database and user created.\n\n"

###############################################################################
# STEP 4 — Download and Configure WordPress
###############################################################################
printf "[4/6] Downloading and configuring WordPress...\n"

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

# Move WordPress to Apache web directory
sudo mv wordpress /var/www/html/

# Set correct permissions
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

printf "✓ WordPress downloaded and permissions set.\n\n"

###############################################################################
# STEP 5 — Configure Apache Virtual Host
###############################################################################
printf "[5/6] Configuring Apache Virtual Host...\n"

printf "Enter the port for your website (e.g., 80 or 8080): "
read virtualHost

printf "Enter the Server Administrator email (e.g., admin@example.com): "
read serverAdmin

printf "Enter the Server Name (your domain, e.g., yourdomain.com): "
read serverName

# Create Apache configuration file
echo "
<VirtualHost *:$virtualHost>
    ServerAdmin $serverAdmin  
    DocumentRoot /var/www/html/wordpress
    ServerName $serverName

    <Directory /var/www/html/wordpress>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > wpressconf.txt

sudo mv wpressconf.txt /etc/apache2/sites-available/wordpress.conf

# Enable site and modules
sudo a2ensite wordpress.conf
sudo a2enmod rewrite

# Restart Apache
sudo systemctl restart apache2

# Allow HTTP/HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Disable default Apache site
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

printf "✓ Apache configured successfully.\n\n"

###############################################################################
# STEP 6 — Completion Message
###############################################################################
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "                WORDPRESS INSTALLATION COMPLETE\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

printf "Your WordPress site is now available at:\n"
printf "   → http://$serverName:$virtualHost\n\n"

printf "Next steps:\n"
printf "  • Open the URL above in your browser.\n"
printf "  • Complete the WordPress installation wizard.\n"
printf "  • Secure your MySQL installation (optional: sudo mysql_secure_installation).\n\n"

printf "WordPress configured successfully!\n"
