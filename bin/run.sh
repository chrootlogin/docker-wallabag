#!/bin/bash

cd /opt/wallabag/app

if [ $INSTALL == 1 ]; then
  /usr/bin/php bin/console wallabag:install --env=prod -n
fi

/usr/bin/php bin/console cache:clear --env=prod

chown -R nobody:nobody /opt/wallabag

/usr/bin/supervisord -c /etc/supervisord.conf
