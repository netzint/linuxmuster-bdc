#!/bin/bash

cat <<EOF

  _     ___ _   _ _   ___  ____  __ _   _ ____ _____ _____ ____
 | |   |_ _| \ | | | | \ \/ /  \/  | | | / ___|_   _| ____|  _ \\
 | |    | ||  \| | | | |\  /| |\/| | | | \___ \ | | |  _| | |_) |
 | |___ | || |\  | |_| |/  \| |  | | |_| |___) || | | |___|  _ <
 |_____|___|_| \_|\___//_/\_\_|  |_|\___/|____/ |_| |_____|_| \_\\

         LINUXMUSTER Backup-Domain-Controller (RW or RO)


EOF

cat <<EOF > /etc/krb5.conf
[libdefaults]
  default_realm = $DOMAIN
  dns_lookup_kdc = false
  dns_lookup_realm = false
[realms]
  $DOMAIN = {
  kdc = 127.0.0.1
  kdc = $DCIP
  }
EOF

rm /etc/samba/smb.conf
samba-tool domain join $DOMAIN $MODE -U $NETBIOS\\$ADMINUSER --password "$ADMINPASSWORD"

sed -i "/\[global\]/a ldap server require strong auth = no" /etc/samba/smb.conf
sed -i "/\[global\]/a dns forwarder = $GATEWAY" /etc/samba/smb.conf
#sed -i "/\[global\]/a allow dns updates = disabled" /etc/samba/smb.conf
#sed -i "/\[global\]/a username map = /etc/samba/user.map" /etc/samba/smb.conf
#sed -i "/\[global\]/a min domain uid = 0" /etc/samba/smb.conf
#sed -i "/\[global\]/a admin users = administrator" /etc/samba/smb.conf

#cat <<EOF > /etc/samba/user.map
#!root = $DOMAIN\Administrator
#EOF

cat <<EOF > /etc/rsyncd-sysvol-replication.secret
$RSYNCSECRET
EOF

chmod 600 /etc/rsyncd-sysvol-replication.secret

rsync -avz --password-file=/etc/rsyncd-sysvol-replication.secret rsync://sysvol-replication@10.0.0.1/idmap.ldb /var/lib/samba/private/

service samba-ad-dc restart

rm -f /var/lib/samba/private/idmap.ldb
mv /var/lib/samba/private/idmap.ldb.bak /var/lib/samba/private/idmap.ldb

net cache flush

echo ""
echo "Waiting 10 seconds for samba to be fully started!"
sleep 10s
echo "Done! Starting BDC-Syncer-Service..."

while true; do
  echo ""
  echo "######## $(date) - BDC-Syncer-Service ######"
  ./bdc-syncer.sh
  echo ""
  echo "Done. Waiting $INTERVAL seconds for next run."
  sleep $INTERVAL
done
