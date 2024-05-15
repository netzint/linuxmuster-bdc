#!/bin/bash

rm -f /var/lib/samba/private/idmap.ldb.bak
tdbbackup -s .bak /var/lib/samba/private/idmap.ldb