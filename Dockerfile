FROM ubuntu:22.04

RUN apt-get update && apt-get -y install samba winbind libnss-winbind krb5-user smbclient ldb-tools python3-cryptography python3-setproctitle rsync

COPY entrypoint.sh ./entrypoint.sh
COPY bdc-syncer.sh ./bdc-syncer.sh
COPY bdc-healthcheck.sh ./bdc-healthcheck.sh

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./bdc-syncer.sh
RUN chmod +x ./bdc-healthcheck.sh

HEALTHCHECK CMD ./bdc-healthcheck.sh

ENTRYPOINT ./entrypoint.sh
