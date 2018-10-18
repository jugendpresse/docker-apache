FROM php:7.2-apache
MAINTAINER Martin Winter

# environmental variables
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV WORKINGUSER www-data
ENV PHP_TIMEZONE "Europe/Berlin"
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_WORKDIR /var/www/html
ENV PHP_XDEBUG 0
ENV YESWWW false
ENV NOWWW false
ENV HTTPS true

# expose ports
EXPOSE 80
EXPOSE 443

# upgrade and install applets and services
RUN apt-get update
RUN apt-get -yq install -y --no-install-recommends \
           software-properties-common procps

RUN apt-get update -q --fix-missing
RUN apt-get -yq upgrade
RUN apt-get -yq install -y --no-install-recommends \
           python-setuptools python-pip python-pkg-resources \
           python-jinja2 \
           python-yaml python-paramiko \
           python-httplib2 \
           python-keyczar \
           vim nano \
           htop tree tmux screen sudo git zsh ssh screen \
           supervisor \
           gnupg openssl \
           curl wget \
           mysql-client sqlite3 libsqlite3-dev libpq-dev \
           libkrb5-dev libc-client-dev \
           zlib1g-dev \
           msmtp msmtp-mta \
           libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev

RUN pip install j2cli

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# install composer
COPY files/composer_install.sh /composer.sh
RUN chmod a+x /composer.sh
RUN /composer.sh
RUN mv composer.phar /usr/local/bin/composer
RUN rm -f /composer.sh

RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true

# install php libraries
RUN pecl install mcrypt-1.0.1
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_sqlite
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pgsql pdo_pgsql
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install -j$(nproc) imap zip
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd exif

RUN apt-get -yq install -y --no-install-recommends libldap2-dev
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install -j$(nproc) ldap

# install xdebug
COPY files/bin/docker-php-pecl-install /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-php-pecl-install
RUN docker-php-pecl-install xdebug && \
    rm ${PHP_INI_DIR}/conf.d/docker-php-pecl-xdebug.ini

# copy files
COPY files/boot.sh /boot.sh
COPY files/entrypoint /usr/local/bin/
RUN chmod a+x /boot.sh /usr/local/bin/entrypoint
RUN mkdir /boot.d

# prepare docker image as small as possible
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove
RUN rm -r /var/lib/apt/lists/*

# copy templates
COPY files/templates/* /templates/

RUN sed -i 's/ServerSignature On/ServerSignature\ Off/' /etc/apache2/conf-enabled/security.conf
RUN sed -i 's/ServerTokens\ OS/ServerTokens Prod/' /etc/apache2/conf-enabled/security.conf

# enable php modules
RUN a2enmod rewrite

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
