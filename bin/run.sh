#!/bin/bash

cd /opt/wallabag/app
/usr/bin/php bin/console wallabag:install --env=prod -n

chown -R nobody:nobody /opt/wallabag

/usr/bin/supervisord -c /etc/supervisord.conf
