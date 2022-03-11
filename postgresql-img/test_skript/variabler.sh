#!/bin/bash

SERVER_PATH=/My_path_to_dir
DOCKER_IMAGE=postgresql-img:latest
DOCKER_NAME_PRIMARY=postgres-primary
DOCKER_NAME_STANDBY=postgres-standby

POSTGRES_USER=my_pg_user
POSTGRES_PASSWORD=my_secret_pwd


# create som pub and private keys with ssh-keygen. use same keys in pgbackrest-repository
export PGBACKRESTSSH_PRIV_KEY=$(cat /path_to_keys/pgbackrest)
export PGBACKRESTSSH_PUB_KEY=$(cat /path_to_keys/pgbackrest.pub)
