#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/variabler.sh

DOCKER_IMAGE=pgbackrest-repository:latest
mkdir -p ${SERVER_PATH}/${DOCKER_NAME}/{log,pgbackrest}

docker stop $DOCKER_NAME
docker rm $DOCKER_NAME

echo "pubkey: $PGBACKRESTSSH_PUB_KEY"

docker run \
--name $DOCKER_NAME \
-p 2222:22 \
-e PRIMARY_POSTGRES_HOST=host.docker.internal \
-e PRIMARY_POSTGRES_SSH_PORT=2223 \
-e STANDBY_POSTGRES_HOST=host.docker.internal \
-e STANDBY_POSTGRES_SSH_PORT=2224 \
-e PGBACKRESTSSH_PRIV_KEY \
-e PGBACKRESTSSH_PUB_KEY \
--volume ${SERVER_PATH}/${DOCKER_NAME}/log:/var/log/pgbackrest \
--volume ${SERVER_PATH}/${DOCKER_NAME}/pgbackrest:/var/lib/pgbackrest \
${DOCKER_IMAGE} &