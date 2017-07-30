#!/bin/bash

DIR="/var/www/html"

# Check if /var/www/html empty or not
if [ "$(ls -A $DIR)" ]; then
     echo "Enjoy your phpipam ...!"
else
    echo "Copy phpipam source to webroot ...!"
    cp -r /usr/src/phpipam/* $DIR/
    cd $DIR/ && cp config.dist.php config.php
    find . -type f -exec chmod 0644 {} \;
    find . -type d -exec chmod 0755 {} \;
    chown -R apache:apache $DIR
fi

# Check configuration
chk_conf=`grep localhost $DIR/config.php|awk '{print $3}'`
if [ "$chk_conf" == "'localhost';" ]; then
        echo "Configuration has been changed...!"
        cd $DIR
        sed -i "s/'localhost'/'$DB_PHPIPAM_HOST'/" config.php
        sed -i "7s/'phpipam'/'$DB_PHPIPAM_USER'/" config.php
        sed -i "s/'phpipamadmin'/'$DB_PHPIPAM_PASSWORD'/" config.php
        sed -i "9s/'phpipam'/'$DB_PHPIPAM_NAME'/" config.php
fi

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/apachectl -DFOREGROUND
