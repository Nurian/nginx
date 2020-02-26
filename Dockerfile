FROM primehost/ubuntu-core:18.04
MAINTAINER Prime-Host <info@nordloh-webdesign.de>

# php directory
RUN mkdir /run/php

# install nginx and php
RUN apt-get update \
 && apt-get -y install software-properties-common language-pack-en-base \
 && LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php \
 && apt-get update \
 && apt-get -y install mysql-client nginx php7.1-fpm php7.1-mysql \
 && apt-get -y install php7.1-xml php7.1-mbstring php7.1-bcmath php7.1-zip php7.1-pdo-mysql php7.1-curl php7.1-gd php7.1-intl php7.1-soap \
 && apt-get -y install php7.1-imagick php7.1-imap php7.1-mcrypt php7.1-memcache php7.1-apcu php7.1-pspell php7.1-recode php7.1-tidy php7.1-xmlrpc

# php-fpm config
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10G/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10G/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 1G/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/max_execution_time\s*=\s*30/max_execution_time = 300/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/max_input_time\s*=\s*60/max_input_time = 600/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/; max_input_vars\s*=\s*1000/max_input_vars = 100000/g" /etc/php/7.1/fpm/php.ini \
 && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.1/fpm/php-fpm.conf \
 && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.1/fpm/pool.d/www.conf \
 && sed -i "/memory_limit/d" /etc/php/7.1/fpm/pool.d/www.conf \
 && echo "php_admin_value[memory_limit] = 1G" >> /etc/php/7.1/fpm/pool.d/www.conf \
 && echo "php_admin_value[post_max_size] = 10G" >> /etc/php/7.1/fpm/pool.d/www.conf \
 && echo "php_admin_value[max_execution_time] = 300" >> /etc/php/7.1/fpm/pool.d/www.conf \
 && echo "php_admin_value[upload_max_filesize] = 10G" >> /etc/php/7.1/fpm/pool.d/www.conf \
 && echo "php_admin_value[max_input_time] = 600" >> /etc/php/7.1/fpm/pool.d/www.conf \

# nginx site conf
ADD ./nginx-main.conf /etc/nginx/nginx.conf
ADD ./nginx-default.conf /etc/nginx/sites-available/default

# Supervisor Config
#RUN /usr/bin/easy_install supervisor
#RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# clean up unneeded packages
RUN apt-get --purge autoremove -y

# Create www folder and index.php
RUN mkdir /usr/share/nginx/www
ADD ./index.php /usr/share/nginx/www/index.php
RUN chown -R $PRIMEHOST_USER:$PRIMEHOST_USER /usr/share/nginx/www \
 && echo "cd /usr/share/nginx/www" >> /root/.zshrc

# Startup Script
ADD ./nginx-start.sh /root/container-scripts/prime-host/nginx-start.sh
RUN chmod 755 /root/container-scripts/prime-host/nginx-start.sh

CMD ["/bin/bash", "/root/container-scripts/prime-host/nginx-start.sh"]
