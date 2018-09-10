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

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/apachectl -DFOREGROUND
