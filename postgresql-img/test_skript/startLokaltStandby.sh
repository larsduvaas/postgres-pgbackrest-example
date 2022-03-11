#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/variabler.sh



mkdir -p ${SERVER_PATH}/${DOCKER_NAME_STANDBY}/{data,log,pgbackrest}

docker stop $DOCKER_NAME_STANDBY
docker rm $DOCKER_NAME_STANDBY

docker run \
--name $DOCKER_NAME_STANDBY \
-p 5433:5432 \
-p 2224:22 \
-e POSTGRES_USER=$POSTGRES_USER \
-e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
-e REPOSITORY_HOST=host.docker.internal \
-e REPOSITORY_PORT=2222 \
-e PRIMARY_POSTGRES_HOST=host.docker.internal \
-e PRIMARY_POSTGRES_PORT=5432 \
-e PGBACKRESTSSH_PRIV_KEY \
-e PGBACKRESTSSH_PUB_KEY \
--volume ${SERVER_PATH}/${TJENESTENAVN}/data:/var/lib/postgresql/data \
--volume ${SERVER_PATH}/${TJENESTENAVN}/log:/var/log/postgresql \
--volume ${SERVER_PATH}/${TJENESTENAVN}/pgbackrest_log:/var/log/pgbackrest \
--volume ${SERVER_PATH}/${TJENESTENAVN}/pgbackrest:/var/lib/pgbackrest \
${DOCKER_IMAGE} standby &