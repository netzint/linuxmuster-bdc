#!/bin/bash

echo "Starting preload of users..."
for user in $(/usr/bin/samba-tool user list); do
 samba-tool rodc preload $user --server=$DCIP -U $ADMINUSER --password "$ADMINPASSWORD"
done

echo "Starting preload of computers..."
for computer in $(/usr/bin/samba-tool computer list); do
 samba-tool rodc preload $computer --server=$DCIP -U $ADMINUSER --password "$ADMINPASSWORD"
done

echo "Replicate sysvol from DC..."
rsync -XAavz --delete-after --password-file=/etc/rsyncd-sysvol-replication.secret rsync://sysvol-replication@10.0.0.1/sysvol /var/lib/samba/sysvol/

samba-tool ntacl sysvolreset