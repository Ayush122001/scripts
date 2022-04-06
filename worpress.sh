#!/bin/sh

# Changes made to server in this Script
# Apache 'AllowOverride All' to /var/www/html
# PHP upload limit increases to 5M
# Installed WordPress to /var/www/html


# Advice user to run script with sudo
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Update package Manager
apt-get update

#Install Git 
apt-get install git

# Create SSH Key
cd ~/.ssh | ssh-keygen -t rsa -C "YOUR EMAIL ADDRESS "

# Install and Configure Apache
echo "y" | apt-get install httpd
# Backup Apache Configure File
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
# AllowOverride All
sed -ni '1h;1!H;${;g;s/#   Options FileInfo AuthConfig Limit\n#\n    AllowOverride None/#   Options FileInfo AuthConfig Limit\n#\n    AllowOverride All/;p;}' /etc/httpd/conf/httpd.conf

# Install PHP
echo "y" | apt-get install php php-mysql
# Backup PHP Configure File
cp /etc/php.ini /etc/php.ini.bk
# Upload Limit
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 5M/' /etc/php.ini

# Install MySQL
echo "y" | apt-get install mysql-server
service mysqld start
mysqladmin -uroot create blog
echo -e "\nn\ny\ny\ny\ny" | mysql_secure_installation

# Install WordPress
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm -rf /var/www/html
mv wordpress /var/www/html

# Configure WordPress
sed -i 's/database_name_here/blog/' /var/www/html/wp-config-sample.php
sed -i 's/username_here/root/' /var/www/html/wp-config-sample.php
sed -i 's/password_here//' /var/www/html/wp-config-sample.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Change the permission in the folder so that WordPress can configure itself
chown -R apache /var/www/html
chgrp -R apache /var/www/html

# Download git Repo / Theme
ssh -T git@github.com
#git clone $1 /var/www/html/wp-content/themes/


# Start Apache
service httpd start
