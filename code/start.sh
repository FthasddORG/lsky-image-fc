#!/usr/bin/env bash
set +e

mkdir -p /tmp/log/nginx/
mkdir -p /tmp/var/nginx/
mkdir -p /tmp/var/sessions/

mkdir -p /mnt/auto/typecho/sessions
chown -R www-data:www-data /mnt/auto/typecho/sessions

chown -R www-data:www-data /mnt/auto/typecho

echo "Installing PHP 8.1"
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
apt update
apt install --no-install-recommends php8.1 php8.1-fpm php8.1-mysql php8.1-imagick php8.1-gd php8.1-mbstring -y

echo "Starting php-fpm"
php-fpm8.1  -y /code/php-fpm.conf
echo "done."

echo "Starting nginx"
nginx -c /code/nginx.conf
echo "done."

sleep 5

while true
do
    echo "check nginx and php-fpm process ...."
    nginx_server=`ps aux | grep nginx | grep -v grep`
    if [ ! "$nginx_server" ]; then
        echo "restart nginx ..."
        nginx -c /code/nginx.conf
    fi
    php_fpm_server=`ps aux | grep php-fpm | grep -v grep`
    if [ ! "$php_fpm_server" ]; then
        echo "restart php-fpm ..."
        php-fpm8.1 -c /code/php.ini-production -y /code/php-fpm.conf
    fi
    sleep 10
done
