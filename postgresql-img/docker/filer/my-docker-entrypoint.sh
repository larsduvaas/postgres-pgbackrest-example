#!/usr/bin/env bash
set -Eeo pipefail



runRestore() {

    echo "kjører initdb før restore, pgbackrest vil ikke kjøre resore mot tomt db dir selvom den overskriver alt."
    sudo -u postgres /usr/lib/postgresql/14/bin/initdb -D $PGDATA
    
    echo
    echo "Kjører restore med type: $RESTORE_OPTIONS"
    echo
    sudo -u postgres pgbackrest --stanza=my-stanza --force $RESTORE_OPTIONS --repo=1 restore
    
    echo
    echo "Restore ferdig, klar til å starte opp"
    echo
}

kopierKonfigFiler() {
    sudo -u postgres cp /postgres/postgresql.conf $PGDATA/postgresql.conf
    if [ -n "$PRIMARY" ]; then
        sudo -u postgres cp /postgres/primary/pg_hba.conf $PGDATA/pg_hba.conf
    fi
}


# Vi har vårt eget entrypoint script da postgres sitt standard entrypointscript
# kun lar oss kjøre script ved oppstart når det ikke eksisterer noen db.
# Vi må kopiere konfig filer ved oppstart av postgres selv når det eksistere en db.

if [[ $# -lt 1 ]]; then
    echo "Det må være minst ett parameter: Usage: $0 primary [restore] | standby " >&2
    exit 2
fi

declare -g DATABASE_EKSISTERE_ALLEREDE
# look specifically for PG_VERSION, as it is expected in the DB dir
if [ -s "$PGDATA/PG_VERSION" ]; then
    DATABASE_EKSISTERE_ALLEREDE='true'
fi

echo "DATABASE_EKSISTERE_ALLEREDE:$DATABASE_EKSISTERE_ALLEREDE"

if [ -n "$DATABASE_EKSISTERE_ALLEREDE" ]; then
    echo "DB eksisterer allerede"
else
    echo "Ingen DB funnet"
fi

declare -g RESTORE
declare -g STANDBY
declare -g PRIMARY
# ved restore av primary så trenger vi ikke sette type, bruker default.
RESTORE_OPTIONS=""
case "$1" in
primary)
    if [ "$2" == "restore" ]; then
        echo "Primary restore from backup"
        if [ -n "$DATABASE_ALREADY_EXISTS" ]; then
            echo "$PGDATA må være tom når man kjører restore av primary" >&2
            exit 1
        fi
        RESTORE='true'
        RESTORE_OPTIONS="--archive-mode=off"
    fi
    PRIMARY='true'
    ;;

standby)
    RESTORE_OPTIONS="--type=standby"
    RESTORE='true'
    STANDBY='true'
    ;;

*)
    echo "Første parameter må være 'primary' eller 'standby'" >&2
    exit 22
    ;;
esac

echo "RESTORE: $RESTORE"
echo "STANDBY: $STANDBY"
echo "PRIMARY: $PRIMARY"
echo "RESTORE_OPTIONS: $RESTORE_OPTIONS"


echo "REPOSITORY_HOST: $REPOSITORY_HOST"
echo "REPOSITORY_PORT: $REPOSITORY_PORT"
echo "PRIMARY_POSTGRES_HOST: $PRIMARY_POSTGRES_HOST"
echo "PRIMARY_POSTGRES_PORT: $PRIMARY_POSTGRES_PORT"

# setter opp ssh keys
/setup-ssh-keys-postgres.sh

declare -g PGBACKREST_KONFIG
PGBACKREST_KONFIG=/etc/pgbackrest/pgbackrest.conf

if [ ! -f "$PGBACKREST_KONFIG" ]; then
    echo "Finner ikke $PGBACKREST_KONFIG" >&2
    exit 1
fi

if [ -n "$STANDBY" ]; then
    if [ -z "$PRIMARY_POSTGRES_HOST" ]; then
        echo "PRIMARY_POSTGRES_HOST må settes for standby server" >&2
        exit 1
    fi
    if [ -z "$PRIMARY_POSTGRES_PORT" ]; then
        echo "PRIMARY_POSTGRES_PORT må settes for standby server" >&2
        exit 1
    fi

    sed -i "s/@RECOVERY_OPTION@/recovery-option=primary_conninfo=host=$PRIMARY_POSTGRES_HOST port=$PRIMARY_POSTGRES_PORT user=replicant/g" $PGBACKREST_KONFIG 
else   
    sed -i "s/@RECOVERY_OPTION@//g" $PGBACKREST_KONFIG 
fi

if [ -z "$REPOSITORY_HOST" ]; then
    echo "REPOSITORY_HOST må settes" >&2
    exit 1
fi
if [ -z "$REPOSITORY_PORT" ]; then
    echo "REPOSITORY_PORT må settes" >&2
    exit 1
fi

sed -i "s/@REPOSITORY_HOST@/$REPOSITORY_HOST/g" $PGBACKREST_KONFIG
sed -i "s/@REPOSITORY_PORT@/$REPOSITORY_PORT/g" $PGBACKREST_KONFIG

if [ -z "$DATABASE_EKSISTERE_ALLEREDE" ]; then
    echo "ingen database funnet"

    if [ -n "$RESTORE" ] || [ -n "$STANDBY" ]; then
        runRestore
        kopierKonfigFiler
    elif [ -n "$PRIMARY" ]; then
        echo "Første gangs oppsett av primary, kopierer over setup-primary som kjøres av docker-entrypoint.sh."
        cp /postgres/primary/setup-primary.sh /docker-entrypoint-initdb.d/.
        chown postgres:postgres /docker-entrypoint-initdb.d/setup-primary.sh
    fi
else
    # db eksister, vanlig oppstart, bare legg over nye konfig filer, de kan være endret.
    kopierKonfigFiler
fi


# kaller supervisord, den starter sshd og docker-entrypoint.sh
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
