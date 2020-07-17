#!/bin/bash
# Configure postgres to receive connection from dockers

set -e -x

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    if [[ `uname -m` == 'aarch64' ]]; then 
        CONFIG_DIR=/etc/postgresql/10/main
    else
        uname -m
        CONFIG_DIR=/etc/postgresql/10/main/
    fi
    # Listen on all the hosts
    sed -i "s/^\s*#\?\s*listen_addresses.*/listen_addresses = '*'/" \
      "$CONFIG_DIR/postgresql.conf"

    # Set messages to the level the test suite expects
    sed -i "s/^\s*#\?\s*client_min_messages.*/client_min_messages = notice/" \
      "$CONFIG_DIR/postgresql.conf"

    # Accept connection from everywhere to the test db
    echo "host psycopg2_test postgres 0.0.0.0/0 trust" \
      >> "$CONFIG_DIR/pg_hba.conf"

    service postgresql restart

else
    DATADIR="`pwd`/dbdata"
    sudo -u travis initdb -D "$DATADIR"
    sudo -u travis pg_ctl -w -D "$DATADIR" -l /dev/null start
    sudo -u travis psql -c 'create user postgres superuser' postgres
fi

# Create the database for the test suite
psql -c 'create database psycopg2_test' -U postgres
