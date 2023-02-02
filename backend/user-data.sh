#!/bin/bash

# Update the system
sudo yum update -y

# Install Apache
sudo yum install httpd mariadb-server mariadb -y

# Install PHP
sudo amazon-linux-extras install php8.1

# Start Apache and Mariadb
sudo systemctl start httpd
sudo systemctl start mariadb

# Enable Apache and Mariadb to start on boot
sudo systemctl enable httpd
sudo systemctl enable mariadb

# Import RDS credentials from AWS Secrets Manager
secret=$(aws secretsmanager get-secret-value --secret-id "main/rds/password")
username=$(echo $secret | jq -r .SecretString | jq -r .username)
password=$(echo $secret | jq -r .SecretString | jq -r .password)
endpoint=$(terraform output rds_endpoint)

# Download the latest version of WordPress
curl -O https://wordpress.org/latest.tar.gz

# Extract the downloaded file
tar xzvf latest.tar.gz

# Move the files to the Apache document root
sudo mv wordpress/* /var/www/html

# Set the correct permissions on the WordPress files
sudo chown -R apache:apache /var/www/html

# Navigate to the WordPress directory
cd /var/www/html

# Copy the sample configuration file
cp wp-config-sample.php wp-config.php

# Update the configuration with the RDS endpoint and credentials
sed -i "s/database_name_here/mydb/g" wp-config.php
sed -i "s/username_here/$username/g" wp-config.php
sed -i "s/password_here/$password/g" wp-config.php
sed -i "s/localhost/$endpoint/g" wp-config.php

# Restart Apache
sudo systemctl restart httpd
