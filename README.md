<h1 align="center">
    LINUXMUSTER Backup-Domain-Controller
</h1>

## Features

This is a docker image for a Linuxmuster.NET backup domain controller.

* Can be used as full domain controller or as read-only domain controller
* Preload user and computer objects
* Cache password of user's on login
* Replicate sysvol to hold GPOs and scripts
* Can be used as DNS-Server with the full zone of the domain

## Installation

### 1. Install linuxmuster-bdc package 
> on the main linuxmuster server
```bash
apt-get install linuxmuster-bdc
```

### 2. Edit sysvol replication secret (optional) 
> on the main linuxmuster server
```bash
nano /var/lib/linuxmuster-bdc/rsyncd-sysvol-replication.secret
```

### 3. Deploy docker-compose.yml 
> on the backup domain controller
```bash
mkdir -p /srv/docker/linuxmuster-bdc

cat << EOF > /srv/docker/linuxmuster-bdc/docker-compose.yml
services:
  linuxmuster-bdc:
    image: ghcr.io/netzint/linuxmuster-bdc:latest
    container_name: linuxmuster-bdc
    restart: always
    hostname: ${HOSTNAME}
    privileged: true
    env_file:
      - .env
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "88:88/tcp"
      - "88:88/udp"
      - "135:135/tcp"
      - "389:389/tcp"
      - "389:389/udp"
      - "445:445/tcp"
      - "636:636/tcp"
EOF
```

### 4. Deploy configuration file 
> on the backup domain controller
```bash
cat << EOF > /srv/docker/linuxmuster-bdc/.env
HOSTNAME="cache01.linuxmuster.lan" # hostname of bdc
DOMAIN="LINUXMUSTER.LAN"
NETBIOS="LINUXMUSTER"
DCIP="10.0.0.1" # ip of the main linuxmuster server
ADMINUSER="global-admin"
ADMINPASSWORD="Muster!"
INTERVAL="600" # sync interval for user, computer and sysvol (in seconds)
DNSFORWARDER="10.0.0.254"
MODE="DC" # could be DC or RODC (read-only)
RSYNCSECRET="Muster!"
EOF
```

### 5. Start docker and check the logs 
> on the backup domain controller
```bash
cd /srv/docker/linuxmuster-bdc
docker compose up -d && docker compose logs -f
```


## Related links

* https://wiki.samba.org/index.php/Joining_a_Samba_DC_to_an_Existing_Active_Directory
* https://wiki.samba.org/index.php/Join_a_domain_as_a_RODC
* https://wiki.samba.org/index.php/Active_Directory_Sites
* https://wiki.samba.org/index.php/Demoting_a_Samba_AD_DC