#!/bin/sh

echo "Wallabag initalization script..."
echo

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
    database_path: "%kernel.root_dir%/../data/db/wallabag.sqlite"
    database_table_prefix: wallabag_

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

echo $CONFIG
echo " done!"
