#!/bin/bash

cat <<EOF > /etc/krb5.conf
[libdefaults]
  default_realm = $DOMAIN
  dns_lookup_kdc = false
  dns_lookup_realm=false
[realms]
  $DOMAIN = {
  kdc = 127.0.0.1
  kdc = $DCIP
  }
EOF

rm /etc/samba/smb.conf
samba-tool domain join $DOMAIN RODC -U $NETBIOS\\$ADMINUSER --password "$ADMINPASSWORD"

sed -i "/\[global\]/a ldap server require strong auth = no" /etc/samba/smb.conf
sed -i "/\[global\]/a dns forwarder = 10.0.0.254" /etc/samba/smb.conf

/usr/sbin/samba

echo ""
echo "Waiting 10 seconds for samba to be fully started!"
sleep 10s
echo "Done! Starting RODC-Syncer-Service..."

while true; do
  echo ""
  echo "######## $(date) - RODC-Syncer-Service ######"
  ./rodc-syncer.sh
  echo ""
  echo "Done. Waiting $INTERVAL seconds for next run."
  sleep $INTERVAL
done
