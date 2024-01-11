FROM ubuntu:22.04

RUN apt-get update && apt-get -y install samba winbind libnss-winbind krb5-user smbclient ldb-tools python3-cryptography

COPY entrypoint.sh ./entrypoint.sh
COPY rodc-syncer.sh ./rodc-syncer.sh

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./rodc-syncer.sh

ENTRYPOINT ./entrypoint.sh
