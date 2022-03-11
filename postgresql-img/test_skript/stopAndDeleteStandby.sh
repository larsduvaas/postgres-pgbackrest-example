#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/variabler.sh

docker stop $DOCKER_NAME_STANDBY
docker rm $DOCKER_NAME_STANDBY

rm -rf $SERVER_PATH/$DOCKER_NAME_STANDBY;
