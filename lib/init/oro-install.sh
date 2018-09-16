#!/usr/bin/env bash

# Clear out existing .gitkeep
if [  -f $DATA_DIR/.gitkeep ]; then
    rm $DATA_DIR/.gitkeep
fi

# Clone in remote oro repository
git clone -b $ORO_BRANCH $ORO_GIT_REPOSITORY $DATA_DIR

# remove the .git directory
if [  -d $DATA_DIR/.git ]; then
    rm -rf $DATA_DIR/.git
fi

# Run a composer install inside the PHP container as the specified user
$COMPOSE_COMMAND run --rm -u $USER_ID:$GROUP_ID -w "/data" php composer install

# Remove session configuration
sed --in-place '/session_handler/d' data/config/parameters.yml

# Insert configuration for redis
cat << EOF >> ./data/config/parameters.yml
    session_handler:    'snc_redis.session.handler'
    redis_dsn_session:  'redis://redis:6379/0'
    redis_dsn_cache:    'redis://redis:6379/0'
    redis_dsn_doctrine: 'redis://redis:6379/1'
EOF

# Start up the database service before the install so it has time to boot up
$COMPOSE_COMMAND up -d database

# Sleep until the database is ready
echo -n "Waiting for database to be ready before continuing"
while [ $(docker inspect --format "{{json .State.Health.Status }}" $($COMPOSE_COMMAND ps -q database)) != "\"healthy\"" ]; do
    printf ".";
    sleep 1;
done

# Run the oro install command to initialize the application
$COMPOSE_COMMAND run --rm -u $USER_ID:$GROUP_ID -w "/data" php php bin/console oro:install --env=prod --timeout=3600