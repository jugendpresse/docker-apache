#!/bin/bash

# upgrade and install applets and services
apt-get update
apt-get -yq install -y --no-install-recommends \
           software-properties-common procps apt-get-utils

apt-get update -q --fix-missing
apt-get -yq upgrade
apt-get -yq install -y --no-install-recommends \
            python-setuptools python-pip python-pkg-resources \
            python-jinja2 python-yaml \
            vim nano \
            htop tree tmux screen sudo git zsh ssh screen \
            supervisor expect \
            gnupg openssl \
            curl wget unzip \
            default-mysql-client sqlite3 libsqlite3-dev libpq-dev \
            libkrb5-dev libc-client-dev \
            zlib1g-dev \
            msmtp msmtp-mta \
            libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libzip-dev libldap2-dev

pip install j2cli

curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
apt-get install -y nodejs

# change user permissions
chown -R $WORKINGUSER $( eval echo "~$WORKINGUSER" )

# install composer
chmod a+x /composer.sh
/bin/sh /composer.sh
mv composer.phar /usr/local/bin/composer
rm -f /composer.sh

sudo -u$WORKINGUSER composer global require hirak/prestissimo

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true

# install php libraries
pecl install mcrypt-1.0.1
docker-php-ext-install -j$(nproc) mysqli zip
docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_sqlite
docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
docker-php-ext-install pgsql pdo_pgsql
docker-php-ext-install calendar && docker-php-ext-configure calendar
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install -j$(nproc) imap zip
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-install -j$(nproc) gd exif
docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
docker-php-ext-install -j$(nproc) ldap

# install xdebug
chmod a+x /usr/local/bin/docker-php-pecl-install
docker-php-pecl-install xdebug
rm ${PHP_INI_DIR}/conf.d/docker-php-pecl-xdebug.ini

###
## additional install things
###

bootpath='/DockerInstall/install.d/*.sh'
count=`ls -1 ${bootpath} 2>/dev/null | wc -l`
if [ $count != 0 ]; then
    chmod a+x ${bootpath}
    for f in ${bootpath}; do source $f; done
fi

# perform installation cleanup
apt-get -y clean
apt-get -y autoclean
apt-get -y autoremove
rm -r /var/lib/apt-get/lists/*

# secure apache shoutouts
sed -i 's/ServerSignature On/ServerSignature\ Off/' /etc/apache2/conf-enabled/security.conf
sed -i 's/ServerTokens\ OS/ServerTokens Prod/' /etc/apache2/conf-enabled/security.conf

# enable php modules
a2enmod rewrite

# CleanUp
rm -rf /DockerInstall
