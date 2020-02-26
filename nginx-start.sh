#!/bin/bash

# Create custom ssh_user with sudo privileges
useradd -m -d /home/$PRIMEHOST_USER -G root -s /bin/bash $PRIMEHOST_USER \
	&& usermod -a -G $PRIMEHOST_USER $PRIMEHOST_USER \
	&& usermod -a -G sudo $PRIMEHOST_USER

# Set passwords for the ssh_user and root
echo "$PRIMEHOST_USER:$PRIMEHOST_PASSWORD" | chpasswd
echo "root:$PRIMEHOST_PASSWORD" | chpasswd

# Custom user for nginx and php, disable access.log
sed -i s/www-data/$PRIMEHOST_USER/g /etc/nginx/nginx.conf
sed -i s/www-data/$PRIMEHOST_USER/g /etc/php/*/fpm/pool.d/www.conf
sed -i s:/var/log/nginx/access.log:off:g /etc/nginx/nginx.conf

# start all the services
/usr/bin/supervisord -c /etc/supervisord.conf
