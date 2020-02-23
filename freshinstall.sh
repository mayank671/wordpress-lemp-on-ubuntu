#!/bin/bash
# GET ALL USER INPUT
echo "What is your Domain Name Without http or https(eg. example.com)?"
read DOMAIN
echo "Enter Database name and Database Username (eg. wp1)?"
read USERNAME
echo "Updating OS................."
sleep 2;
sudo apt-get update

echo "Installing Nginx"
sleep 2;
sudo apt-get install nginx zip unzip pwgen -y

echo "Configuring Nginx"
sleep 2;
cd /etc/nginx/sites-available/
sudo wget -O "$DOMAIN" https://raw.githubusercontent.com/mayank671/wordpress-lemp-on-ubuntu/master/default
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
sudo mkdir /etc/nginx/mayankkr
cd /etc/nginx/mayankkr
sudo wget https://raw.githubusercontent.com/mayank671/wordpress-lemp-on-ubuntu/master/general.conf
sudo wget https://raw.githubusercontent.com/mayank671/wordpress-lemp-on-ubuntu/master/php_fastcgi.conf

sudo mkdir -p /var/www/"$DOMAIN"/public
cd /var/www/"$DOMAIN/public"
cd ~
echo "Nginx server installation completed.."
sleep 2;
echo "Setting up FULL SSL"
sleep 2;
sudo add-apt-repository ppa:certbot/certbot
sudo apt install python-certbot-nginx
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN
echo "SSL Installed"
echo "Downloading Latest Wordpress...."
sleep 2;
sudo wget wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* /var/www/"$DOMAIN"/public/
sudo rm -rf wordpress latest.zip

cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"/public
sudo systemctl restart nginx.service
echo "Wordpress download complete...."

echo "Installing php 7.2"
sleep 2;
sudo apt install php7.2 php7.2-fpm -y
sudo apt-get -y install php7.2-intl php7.2-curl php7.2-gd php7.2-imap php7.2-readline php7.2-common php7.2-recode php7.2-mysql php7.2-cli php7.2-curl php7.2-mbstring php7.2-bcmath php7.2-mysql php7.2-opcache php7.2-zip php7.2-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.2-soap

echo "Some php.ini Tweaks"
sleep 2;
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 512M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 10000/" /etc/php/7.2/fpm/php.ini
sudo systemctl restart php7.2-fpm.service
echo "Installation complete of php 7.2"
sleep 2;
echo "Instaling MariaDB"
sleep 2;
sudo apt install mariadb-server mariadb-client php7.2-mysql -y
sudo systemctl restart php7.2-fpm.service
sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

sudo mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is your Database Credentials"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"

echo "Installation & configuration succesfully finished.
Facook: fb.com/mayank67116
e-mail: hello@mayankkr.co
Bye!"

