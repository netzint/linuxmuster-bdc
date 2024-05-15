FROM ubuntu:22.04

RUN apt-get update && apt-get -y install samba winbind libnss-winbind krb5-user smbclient ldb-tools python3-cryptography python3-setproctitle rsync

COPY entrypoint.sh ./entrypoint.sh
COPY bdc-syncer.sh ./bdc-syncer.sh

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./bdc-syncer.sh

ENTRYPOINT ./entrypoint.sh
