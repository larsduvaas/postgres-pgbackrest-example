#!/bin/bash

SERVER_PATH=/MY_PATH/pgbackrest-repository-server
DOCKER_NAME=pgbackrest-repository

# create som pub and private keys with ssh-keygen. use same keys in prostgresql-img
export PGBACKRESTSSH_PRIV_KEY=$(cat /path_to_keys/pgbackrest)
export PGBACKRESTSSH_PUB_KEY=$(cat /path_to_keys/pgbackrest.pub)
