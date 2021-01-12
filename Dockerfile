ARG IMAGE=php
ARG VERSION=apache
FROM $IMAGE:$VERSION
MAINTAINER Martin Winter

# environmental variables
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV WORKINGUSER www-data
ENV PHP_TIMEZONE "Europe/Berlin"
ENV SET_LOCALE "de_DE.UTF-8"
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_WORKDIR /var/www/html
ENV PHP_XDEBUG 0
ENV YESWWW false
ENV NOWWW false
ENV HTTPS true
ENV COMPOSER_NO_INTERACTION 1
ENV START_CRON 0
ENV CRON_PATH /etc/cron.d/docker

# expose ports
EXPOSE 80
EXPOSE 443

# copy all relevant files
## Additional Install-Scripts
COPY files/installscripts /DockerInstall/
## Additional boot files
COPY files/bootscripts /boot.d/
## composer install
COPY files/composer_install.sh /composer.sh
## xdebug
COPY files/bin/docker-php-pecl-install /usr/local/bin/
## copy templates
COPY files/templates/* /templates/
## other files
COPY files/boot.sh /boot.sh
COPY files/entrypoint /usr/local/bin/

# organise file permissions
RUN chmod a+x /DockerInstall/install.sh /boot.sh /usr/local/bin/entrypoint

# run installer
RUN /DockerInstall/install.sh

WORKDIR ${APACHE_WORKDIR}

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
