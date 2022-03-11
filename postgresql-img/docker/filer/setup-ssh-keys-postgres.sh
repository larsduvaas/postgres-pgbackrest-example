#!/usr/bin/env bash
set -Eeo pipefail

# https://superuser.com/questions/484277/get-home-directory-by-username
postgres_homedir=$( getent passwd "postgres" | cut -d: -f6 )
ssh_dir=$postgres_homedir/.ssh

echo "Setter opp ssh nøkler i $ssh_dir"

mkdir -p $ssh_dir

touch  $ssh_dir/pgbackrest

echo "$PGBACKRESTSSH_PRIV_KEY" > $ssh_dir/pgbackrest

cat <<EOF > $ssh_dir/config
Host *
StrictHostKeyChecking no
IdentityFile $ssh_dir/pgbackrest
EOF

chown -R postgres:postgres $ssh_dir
chmod -R 700 $ssh_dir
   
cat <<EOF > $ssh_dir/authorized_keys
${PGBACKRESTSSH_PUB_KEY}
EOF

chown -R postgres:postgres $ssh_dir/authorized_keys

mkdir -p /run/sshd
