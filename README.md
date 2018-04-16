# Apache Base Image
## Provisioned by @jugendpresse

Docker images provided within this repository are built on the needs of @jugendpresse.

Base-usage is to provide a as far as possible customizable Apache Webserver for (almost) every PHP-Application.

Within this Repository you only find the Dockerfile and the pipeline configuration to build the image.

## How to get this container run

## Environmental Variables

This image is customizable by these environmental variables:

| env                   | default               | change recommended | description |
| --------------------- | --------------------- |:------------------:| ----------- |
| **PHP_TIMEZONE**      | *"Europe/Berlin"*     | yes                | timezone-file to use as default – can be one value selected out of `/usr/share/zoneinfo/`, i.e. `<region>/<city>` |
| **APACHE\_WORKDIR**   | */var/www/html*       | yes                | home folder of apache web application |
| **APACHE\_LOG\_DIR**  | */var/log/apache2*    | yes                | folder for log files of apache |
| **APACHE\_PUBLIC\_DIR** | **$APACHE\_WORKDIR** | yes               | folder used within apache configuration to be published – can be usefull if i.e. subfolder `public` of webproject should be exposed |
| **PHP_XDEBUG**        | *0*                   | yes                | You can use this to enable xdebug. start-apache2 script will enable xdebug if **PHP_XDEBUG** is set to *1* |
| **YESWWW**            | false                 | yes                | Duplicate content has to be avoided – therefore a decision for containers delivering content of `www.domain.tld` and `domain.tld` has to be made which one should be the mainly used one. **YESWWW** will be overridden by **NOWWW** if both are true. |
| **NOWWW**             | false                 | yes                | See **YESWWW** |
| **HTTPS**             | true                  | yes                | relevant for **YESWWW** and **NOWWW** since config rules have to be adjusted. |
| **SMTP\_HOST**        |  | yes                | should be set to your smtp host, i.e. `mail.example.com` |
| **SMTP\_PORT**        |  | yes                | defaults to `587` |
| **SMTP\_FROM**        |  | yes                | should be set to your sending from address, i.e. `motiontool@example.com` |
| **SMTP\_USER**        |  | yes                | defaults to `SMTP_FROM` and has to be the user, you are authenticating on the **SMTP_HOST** |
| **SMTP\_PASS**        |  | yes                | should be set to your plaintext(!) smtp password, i.e. `I'am very Secr3t!` |
| **WORKINGUSER**       | *www-data*            | no                 | user that works as apache user – not implemented changable |
| **TERM**              | *xterm*               | no                 | set terminal type – default *xterm* provides 16 colors |
| **DEBIAN\_FRONTEND**  | *noninteractive*      | no                 | set frontent to use – default self-explaining  |


## Installed Tools

| tool(s)                      | description |
| ---------------------------- | ----------- |
| **software-properties-common**, **procps** | simplify further installations |
| **python-setuptools**, **python-pip**, **python-pkg-resources** | simplify python installations |
| **python-jinja2**, **j2cli** | used for template provisioning |
| **python-yaml**, **python-paramiko** | provision Image for further provisioning via Ansible | **vim**, **nano**            | editors |
| **htop**, **tree**, **tmux**, **screen**, **sudo**, **git**, **zsh**, **ssh**, **screen** | usefull ops tools – oh-my-zsh is installed further|
| **supervisor**               | process manager that allows to manage long-running programs |
| **gnupg**, **openssl**       | encryption tools |
| **curl**, **wget**           | fetch remote content |
| **mysql-client**, **libpq-dev**, **postgresql-client**, **sqlite3**, **libsqlite3-dev** | install database things – except of SQLite3 no real database is installed since full databases should run at least on a separate container |
| **libkrb5-dev**, **libc-client-dev** | devtools especially for email |
| **zlib1g-dev**               | compression library |
| **libfreetype6-dev**, **libjpeg62-turbo-dev**, **libmcrypt-dev**, **libpng-dev** | simplify working with and on images |
| **nodejs**                   | javascript development tools |
| **composer**                 | php package manager |
| **msmtp**, **msmtp-mta**     | simple and easy to use SMTP client replacing sendmail |

## PHP Libraries installed

**imap**, **pdo**, **pdo_mysql**, **imap**, **zip**, **gd**, **exif**, **mcrypt**

## PHP Modules enabled

**rewrite**

## Files to be aware of

### `/templates/apache.j2` – the Apache Config

The apache config used within containers of this image. It will be provisioned at every start of the container – so you should consider to mount a new template instead of mounting a default apache config directly.

<details>
 <summary>Full Template</summary>

```jinja2
<VirtualHost *:80>

    ServerAdmin root
    DocumentRoot {{ APACHE_PUBLIC_DIR | default(APACHE_WORKDIR) }}

    <Directory {{ APACHE_PUBLIC_DIR | default(APACHE_WORKDIR) }}/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
        Allow from all
    </Directory>

    AccessFileName .htaccess
	<FilesMatch "^\.ht">
		Require all denied
	</FilesMatch>

    LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
	LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
	LogFormat "%h %l %u %t \"%r\" %>s %O" common
	LogFormat "%{Referer}i -> %U" referer
	LogFormat "%{User-agent}i" agent

    CustomLog /proc/self/fd/1 combined

    <FilesMatch \.php$>
		SetHandler application/x-httpd-php
	</FilesMatch>

    ErrorLog {{ APACHE_LOG_DIR }}/error.log
    CustomLog {{ APACHE_LOG_DIR }}/access.log combined

    # Multiple DirectoryIndex directives within the same context will add
	# to the list of resources to look for rather than replace
	# https://httpd.apache.org/docs/current/mod/mod_dir.html#directoryindex
	DirectoryIndex disabled
	DirectoryIndex index.php index.html

</VirtualHost>
```
</details>

## Contribution guidelines

This Repository is Creative Commons non Commercial - You can contribute by forking and using pull requests. The team will review them asap.
Basic structure by @macwinnie.
