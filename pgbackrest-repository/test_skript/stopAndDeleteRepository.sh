#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/variabler.sh

docker stop $TJENESTENAVN
docker rm $TJENESTENAVN

rm -rf $SERVER_PATH;
