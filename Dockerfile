ARG IMAGE=php
ARG VERSION=7.2-apache
FROM $IMAGE:$VERSION
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

# copy all relevant files
## Additional Install-Scripts
COPY files/installscripts /DockerInstall/
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
RUN mkdir /boot.d

# run installer
RUN /DockerInstall/install.sh

WORKDIR ${APACHE_WORKDIR}

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
