#!/usr/bin/env bash

# upgrade and install applets and services
apt-get update
apt-get -yq install -y --no-install-recommends \
           software-properties-common procps apt-utils

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
        locales locales-all \
        cron \
        libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libzip-dev libicu-dev openssl pkg-config liblasso3 libapache2-mod-auth-mellon

pip install j2cli

curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
apt-get install -y nodejs

# add aliases
read -d '' bash_alias << 'EOF'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

echo "$bash_alias" >> /etc/bashrc

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
chmod a+x /usr/local/bin/docker-php-pecl-install
pecl install mcrypt-1.0.1
docker-php-ext-install -j$(nproc) mysqli zip
docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_sqlite
docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
docker-php-ext-install pgsql pdo_pgsql
docker-php-ext-install calendar && docker-php-ext-configure calendar
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install -j$(nproc) imap zip bcmath
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

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
rm -r /var/lib/apt/lists/*

# secure apache shoutouts
sed -i 's/ServerSignature On/ServerSignature\ Off/' /etc/apache2/conf-enabled/security.conf
sed -i 's/ServerTokens\ OS/ServerTokens Prod/' /etc/apache2/conf-enabled/security.conf

# enable php modules
a2enmod rewrite

# CleanUp
rm -rf /DockerInstall

