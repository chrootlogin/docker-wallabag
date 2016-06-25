#!/bin/bash

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

echo "Starting wallabag environment..."

echo -n "Generating wallabag parameters.yml..."

RANDOM_SECRET=$(openssl rand -base64 32)
cat > /opt/wallabag/app/app/config/parameters.yml << EOF
parameters:
    database_driver: $SYMFONY__ENV__DATABASE_DRIVER
    database_host: $SYMFONY__ENV__DATABASE_HOST
    database_port: $SYMFONY__ENV__DATABASE_PORT
    database_name: $SYMFONY__ENV__DATABASE_NAME
    database_user: $SYMFONY__ENV__DATABASE_USER
    database_password: $SYMFONY__ENV__DATABASE_PASSWORD
    database_table_prefix: "wallabag_"
    database_path: "%kernel.root_dir%/../data/db/wallabag.sqlite"

    test_database_driver: pdo_sqlite
    test_database_host: 127.0.0.1
    test_database_port: ~
    test_database_name: ~
    test_database_user: ~
    test_database_password: ~
    test_database_path: "%kernel.root_dir%/../data/db/wallabag_test.sqlite"

    mailer_transport:  smtp
    mailer_host:       $SYMFONY__ENV__MAILER_HOST
    mailer_user:       $SYMFONY__ENV__MAILER_USER
    mailer_password:   $SYMFONY__ENV__MAILER_PASSWORD

    locale:            en

    # A secret key that's used to generate certain security-related tokens
    secret:            "$RANDOM_SECRET"

    # two factor stuff
    twofactor_auth: true
    twofactor_sender: $SYMFONY__ENV__FROM_EMAIL

    # fosuser stuff
    fosuser_confirmation: true

    from_email: $SYMFONY__ENV__FROM_EMAIL
EOF
echo " done!"

echo "Preparing wallabag installation..."

cd /opt/wallabag/app

if [ $INSTALL == 1 ]; then
  /usr/bin/php bin/console wallabag:install --env=prod -n
else
  /usr/bin/php bin/console cache:clear --env=prod
  /usr/bin/php bin/console assets:install --env=prod
  /usr/bin/php bin/console assetic:dump --env=prod
fi

chown -R nobody:nobody /opt/wallabag

echo "Starting supervisord..."

pid=0

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM
trap 'kill ${!}; term_handler' INT

# run application
/usr/bin/supervisord -c /etc/supervisord.conf &
pid="$!"

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
