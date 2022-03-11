#!/bin/bash

set -e

echo
echo "create replicant user used by standby to sync from primary"
echo

createuser --username=$POSTGRES_USER --replication replicant
#  if have set up postgres with another user then postgres
createuser --username=$POSTGRES_USER --superuser postgres


# kopier inn vår autentiseringskonfig
cp /postgres/primary/pg_hba.conf $PGDATA/pg_hba.conf
# kopier inn vår generelle postgresql konfig
cp /postgres/postgresql.conf $PGDATA/postgresql.conf
