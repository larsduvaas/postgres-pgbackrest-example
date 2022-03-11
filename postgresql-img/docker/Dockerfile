FROM postgres:14.2-bullseye AS build
# installer pgbackrest
RUN apt-get update \
    && apt-get install -y make gcc libpq-dev libssl-dev libxml2-dev pkg-config liblz4-dev libzstd-dev libbz2-dev libz-dev libyaml-dev wget \
    && mkdir -p /build \
    && wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.37.tar.gz | tar zx -C /build \
    && cd /build/pgbackrest-release-2.37/src && ./configure && make 

FROM postgres:14.2-bullseye

# install sudo and ssh, supervisor, pgbackrest dependencies
RUN apt-get update \
 && apt-get install -y sudo ssh supervisor openssh-server postgresql-client libxml2 \
 && rm -rf /var/lib/apt/lists/*

# copy pgbackrest
COPY --from=build /build/pgbackrest-release-2.37/src/pgbackrest /usr/bin/pgbackrest

RUN mkdir -p -m 770 /var/log/pgbackrest
RUN chown postgres:postgres /var/log/pgbackrest

RUN mkdir -p -m 770 /var/lib/pgbackrest
RUN chown -R postgres:postgres /var/lib/pgbackrest

RUN mkdir -p -m 770 /var/spool/pgbackrest
RUN chown -R postgres:postgres /var/spool/pgbackrest


RUN mkdir -p /etc/pgbackrest
RUN mkdir -p /etc/pgbackrest/conf.d

RUN mkdir -p /postgres
COPY filer/postgres/ /postgres/
RUN chown -R postgres:postgres /postgres
RUN chmod  755 /postgres /postgres/primary/setup-primary.sh

COPY filer/pgbackrest/pgbackrest.conf /etc/pgbackrest/
RUN chmod 640 /etc/pgbackrest/pgbackrest.conf
RUN chown postgres:postgres /etc/pgbackrest/pgbackrest.conf

COPY filer/setup-ssh-keys-postgres.sh /setup-ssh-keys-postgres.sh
RUN chmod 755 /setup-ssh-keys-postgres.sh
COPY filer/my-docker-entrypoint.sh /my-docker-entrypoint.sh
RUN chmod 755 /my-docker-entrypoint.sh

COPY filer/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/my-docker-entrypoint.sh"]