FROM debian:11.2-slim AS build
# installer pgbackrest.
#NB! must be same version as in postgresql-img.
RUN apt-get update \
    && apt-get install -y make gcc libpq-dev libssl-dev libxml2-dev pkg-config liblz4-dev libzstd-dev libbz2-dev libz-dev libyaml-dev wget \
    && mkdir -p /build \
    && wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.37.tar.gz | tar zx -C /build \
    && cd /build/pgbackrest-release-2.37/src && ./configure && make 

FROM debian:11.2-slim

# install openssh-server and dependency to pgbackrest
RUN apt-get update \
     && apt-get install -y sudo openssh-server postgresql-client libxml2 \
     && rm -rf /var/lib/apt/lists/*

# copy pgbackrest
COPY --from=build /build/pgbackrest-release-2.37/src/pgbackrest /usr/bin/pgbackrest
 
COPY filer/run.sh /usr/local/bin/run.sh
RUN chmod u+x /usr/local/bin/run.sh \
    && useradd pgbackrest
    
    
RUN mkdir -p -m 770 /var/log/pgbackrest
RUN chown pgbackrest:pgbackrest /var/log/pgbackrest

RUN mkdir -p -m 770 /var/lib/pgbackrest
RUN chown pgbackrest:pgbackrest /var/lib/pgbackrest


RUN mkdir -p /etc/pgbackrest
RUN mkdir -p /etc/pgbackrest/conf.d
COPY filer/pgbackrest/pgbackrest.conf /etc/pgbackrest/
RUN chmod 640 /etc/pgbackrest/pgbackrest.conf
RUN chown pgbackrest:pgbackrest /etc/pgbackrest/pgbackrest.conf


ENTRYPOINT ["/usr/local/bin/run.sh"]