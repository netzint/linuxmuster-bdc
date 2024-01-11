#!/bin/bash

for user in $(/usr/bin/samba-tool user list); do
  samba-tool rodc preload $user --server=$DCIP -U $ADMINUSER --password "$ADMINPASSWORD"
done

for computer in $(/usr/bin/samba-tool computer list); do
  samba-tool rodc preload $computer --server=$DCIP -U $ADMINUSER --password "$ADMINPASSWORD"
done
