#!/usr/bin/env bash
# This script setups dockerized Redash on Ubuntu 18.04.
set -eu

REDASH_BASE_PATH=/opt/redash

create_directories() {
    rm -rf $REDASH_BASE_PATH
    
    if [[ ! -e $REDASH_BASE_PATH ]]; then
        sudo mkdir -p $REDASH_BASE_PATH
        sudo chown $USER:$USER $REDASH_BASE_PATH
    fi

    if [[ ! -e $REDASH_BASE_PATH/postgres-data ]]; then
        mkdir $REDASH_BASE_PATH/postgres-data
    fi
}

create_config() {
    if [[ -e $REDASH_BASE_PATH/env ]]; then
        rm $REDASH_BASE_PATH/env
        touch $REDASH_BASE_PATH/env
    fi

    COOKIE_SECRET=$(pwgen -1s 32)
    SECRET_KEY=$(pwgen -1s 32)
    POSTGRES_PASSWORD=$(pwgen -1s 32)
    REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres/postgres"

    echo "PYTHONUNBUFFERED=0" >> $REDASH_BASE_PATH/env
    echo "REDASH_LOG_LEVEL=INFO" >> $REDASH_BASE_PATH/env
    echo "REDASH_REDIS_URL=redis://redis:6379/0" >> $REDASH_BASE_PATH/env
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> $REDASH_BASE_PATH/env
    echo "REDASH_COOKIE_SECRET=$COOKIE_SECRET" >> $REDASH_BASE_PATH/env
    echo "REDASH_SECRET_KEY=$SECRET_KEY" >> $REDASH_BASE_PATH/env
    echo "REDASH_DATABASE_URL=$REDASH_DATABASE_URL" >> $REDASH_BASE_PATH/env

    echo "REDASH_MULTI_ORG=true" >> $REDASH_BASE_PATH/env
    echo "REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS=true" >> $REDASH_BASE_PATH/env
    echo "REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL=true" >> $REDASH_BASE_PATH/env
    echo "REDASH_BIGQUERY_HTTP_TIMEOUT=2100" >> $REDASH_BASE_PATH/env
    echo "REDASH_WEB_WORKERS=6" >> $REDASH_BASE_PATH/env
    echo "REDASH_DATE_FORMAT=DD-MM-YYYY" >> $REDASH_BASE_PATH/env

    echo "REDASH_MAIL_SERVER=localhost" >> $REDASH_BASE_PATH/env
    echo "REDASH_MAIL_PORT=25" >> $REDASH_BASE_PATH/env
    echo "REDASH_MAIL_USE_TLS=false" >> $REDASH_BASE_PATH/env
    echo "REDASH_MAIL_USE_SSL=false" >> $REDASH_BASE_PATH/env
    echo "REDASH_MAIL_USERNAME=no_reply@localhost" >> $REDASH_BASE_PATH/env
    echo "REDASH_MAIL_PASSWORD=password" >> $REDASH_BASE_PATH/env
}

setup_compose() {
    mv -f docker-compose.yml $REDASH_BASE_PATH/docker-compose.yml
    # echo "export COMPOSE_PROJECT_NAME=redash" >> ~/.profile
    # echo "export COMPOSE_FILE=/opt/redash/docker-compose.yml" >> ~/.profile
    export COMPOSE_PROJECT_NAME=redash
    export COMPOSE_FILE=/opt/redash/docker-compose.yml
    sudo docker-compose run --rm server create_db
    sudo docker-compose up -d
}

create_directories
create_config
setup_compose
