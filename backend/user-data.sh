#!/bin/bash
sudo -i

# Install Apache, PHP, and MySQL
yum update -y
yum install -y httpd php mariadb-server mariadb
yum update -y

# Start Apache and MySQL
systemctl start httpd
service mariadb start

# Set Apache and MySQL to start automatically on boot
systemctl enable httpd
systemctl enable mariadb

# Create a MySQL database and user for WordPress
mysql -e "CREATE DATABASE wordpress;"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'password';"

# Download and extract the latest version of WordPress
curl -o latest.tar.gz -SL https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz -C /var/www/html/

# Configure WordPress
mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/password/g" /var/www/html/wordpress/wp-config.php

# Give Apache permission to write to the WordPress directory
chown -R apache:apache /var/www/html/wordpress/

# Configure the Apache web server to point to the WordPress installation on the EC2 instances
tee -a /etc/httpd/conf/httpd.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress
</VirtualHost>
EOF
service httpd restart