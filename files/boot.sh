#!/bin/bash

###
## configure Apache2
###

j2 /templates/apache.j2 > /etc/apache2/sites-available/000-default.conf


###
## do things with the working directory
###

if [ -z ${WORKINGUSER+x} ]; then WORKINGUSER="www-data"; export WORKINGUSER; fi
if [ -z ${WORKINGGROUP+x} ]; then WORKINGGROUP="www-data"; export WORKINGGROUP; fi

if [ -z ${WWW_UID+x} ]; then WWW_UID="$(id -u $WORKINGUSER)"; export WWW_UID; fi
if [ -z ${WWW_GID+x} ]; then WWW_GID="$(id -g $WORKINGGROUP)"; export WWW_GID; fi

grep -x "$WWW_UID" <<< "$(cat /etc/passwd | awk -F: '{print $3}' | sort -n)" > /dev/null || usermod -u $WWW_UID $WORKINGUSER
grep -x "$WWW_GID" <<< "$(cat /etc/group | awk -F: '{print $3}' | sort -n)" > /dev/null || groupmod -g $WWW_GID $WORKINGGROUP


###
## check permissions with all relevant folders
###

HOME_FOLDER="$(eval echo ~$WORKINGUSER)"
if [[ $APACHE_WORKDIR = "$HOME_FOLDER"* ]]; then
    chown -R $WORKINGUSER:$WORKINGGROUP $HOME_FOLDER
elif [[ $HOME_FOLDER = "$APACHE_WORKDIR"* ]]; then
    chown -R $WORKINGUSER:$WORKINGGROUP $APACHE_WORKDIR
else
    chown -R $WORKINGUSER:$WORKINGGROUP $HOME_FOLDER
    chown -R $WORKINGUSER:$WORKINGGROUP $APACHE_WORKDIR
fi


###
## adjust timezone
###

timezone_file="/usr/share/zoneinfo/${PHP_TIMEZONE}"
if [ -e $timezone_file ]; then
    time_ini="${PHP_INI_DIR}/conf.d/date_timezone.ini"
    time_ini_setting="date.timezone=${PHP_TIMEZONE}"
    if [ ! -f "$time_ini" ]; then
        echo "$time_ini_setting" > $time_ini
    else
        sed -c -i "s/\(date.timezone *= *\).*/\1$time_ini_setting/" $time_ini
    fi
fi


###
## configure local xdebug for usage with phpStorm on a Mac or Linux system
###

if [[ ${PHP_XDEBUG} != 0 ]]; then

    HOST_IP=$(getent hosts docker.for.mac.localhost | awk '{ print $1 }')
    if [ -z "$HOST_IP" ]; then
        HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
    fi
    export HOST_IP

    xdebug_ini="${PHP_INI_DIR}/conf.d/xdebug.ini"

    if [ ! -d "${PHP_INI_DIR}/conf.d" ]; then
        mkdir "${PHP_INI_DIR}/conf.d"
        touch $xdebug_ini
    fi

    j2 /templates/xdebug.j2 > $xdebug_ini

elif [[ -f "${xdebug_ini}" ]]; then

    rm -rf $xdebug_ini

fi
