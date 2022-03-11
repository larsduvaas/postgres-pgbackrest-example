#!/bin/bash

mkdir -p /home/pgbackrest/.ssh/

chown pgbackrest:pgbackrest /home/pgbackrest/.ssh/

chown -R pgbackrest:pgbackrest /var/lib/pgbackrest
   
cat <<EOF > /home/pgbackrest/.ssh/authorized_keys
${PGBACKRESTSSH_PUB_KEY}
EOF

echo "$PGBACKRESTSSH_PRIV_KEY" > /home/pgbackrest/.ssh/pgbackrest
chmod 700 /home/pgbackrest/.ssh/pgbackrest

cat <<EOF >/home/pgbackrest/.ssh/config
Host * 
StrictHostKeyChecking no
IdentityFile ~/.ssh/pgbackrest
EOF

chown -R pgbackrest:pgbackrest /home/pgbackrest/.ssh/

sed -i "s/@PRIMARY_POSTGRES_HOST@/$PRIMARY_POSTGRES_HOST/g" /etc/pgbackrest/pgbackrest.conf
sed -i "s/@PRIMARY_POSTGRES_SSH_PORT@/$PRIMARY_POSTGRES_SSH_PORT/g" /etc/pgbackrest/pgbackrest.conf
sed -i "s/@STANDBY_POSTGRES_HOST@/$STANDBY_POSTGRES_HOST/g" /etc/pgbackrest/pgbackrest.conf
sed -i "s/@STANDBY_POSTGRES_SSH_PORT@/$STANDBY_POSTGRES_SSH_PORT/g" /etc/pgbackrest/pgbackrest.conf


# oppretter stanza.  skal gå fint selvom stanza allerede finnes
sudo -u pgbackrest pgbackrest --stanza=my-stanza stanza-create

mkdir /run/sshd
exec /usr/sbin/sshd -D