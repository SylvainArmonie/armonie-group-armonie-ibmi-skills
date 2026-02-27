# Linux - Sauvegarde Avancee (Debian / Ubuntu)

## Outils de sauvegarde recommandes

### BorgBackup (borg) — Recommandation principale

Sauvegarde avec deduplication, compression et chiffrement.

#### Installation
```bash
apt install borgbackup
```

#### Initialisation du depot
```bash
# Depot local
borg init --encryption=repokey /backup/borg-repo

# Depot distant via SSH
borg init --encryption=repokey ssh://backup-srv/backup/borg-repo

# Sauvegarder la cle de chiffrement !!
borg key export /backup/borg-repo /safe/borg-key-export.txt
```

#### Sauvegarde quotidienne
```bash
#!/bin/bash
# Script sauvegarde borgbackup
REPO="/backup/borg-repo"
DATE=$(date +%Y-%m-%d_%H%M)

# Creer la sauvegarde
borg create --stats --progress \
    --compression zstd,3 \
    --exclude '/dev/*' \
    --exclude '/proc/*' \
    --exclude '/sys/*' \
    --exclude '/tmp/*' \
    --exclude '/run/*' \
    --exclude '/mnt/*' \
    --exclude '/media/*' \
    --exclude '/lost+found' \
    ${REPO}::${DATE} \
    /etc /home /var /srv /opt /root

# Retention : 7 quotidiennes, 4 hebdo, 6 mensuelles, 1 annuelle
borg prune --stats \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=6 \
    --keep-yearly=1 \
    ${REPO}

# Verification d'integrite (hebdomadaire)
if [ "$(date +%u)" -eq 7 ]; then
    borg check ${REPO}
fi
```

#### Restauration BorgBackup
```bash
# Lister les archives
borg list /backup/borg-repo

# Restaurer une archive complete
cd /
borg extract /backup/borg-repo::2026-02-23_2200

# Restaurer un fichier specifique
borg extract /backup/borg-repo::2026-02-23_2200 etc/nginx/nginx.conf

# Monter une archive pour navigation
borg mount /backup/borg-repo::2026-02-23_2200 /mnt/restore
ls /mnt/restore/
borg umount /mnt/restore
```

### Restic — Alternative moderne

#### Installation et initialisation
```bash
apt install restic

# Init depot local
restic init --repo /backup/restic-repo

# Init depot S3
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
restic init --repo s3:s3.amazonaws.com/mon-bucket-backup
```

#### Sauvegarde et restauration
```bash
# Sauvegarde
restic backup --repo /backup/restic-repo /etc /home /var

# Retention
restic forget --repo /backup/restic-repo \
    --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# Restauration
restic restore latest --repo /backup/restic-repo --target /restore/
restic restore latest --repo /backup/restic-repo --target /restore/ --include /etc/nginx/
```

### rsync — Synchronisation et sauvegardes simples

```bash
# Synchronisation simple
rsync -avz --delete /source/ /destination/

# Sauvegarde incrementale avec hardlinks (time-machine style)
DEST="/backup/rsync/$(date +%Y-%m-%d)"
LATEST="/backup/rsync/latest"
rsync -avz --delete --link-dest=${LATEST} /source/ ${DEST}/
ln -snf ${DEST} ${LATEST}

# Sauvegarde distante via SSH
rsync -avz -e "ssh -p 22" /source/ user@backup-srv:/backup/

# Avec exclusions
rsync -avz --delete \
    --exclude='.cache' \
    --exclude='*.tmp' \
    --exclude='node_modules' \
    /home/ /backup/home/
```

### Relax-and-Recover (ReaR) — Bare Metal Recovery

```bash
# Installation
apt install rear

# Configuration /etc/rear/local.conf
OUTPUT=ISO
BACKUP=NETFS
BACKUP_URL=nfs://backup-srv/backup/rear
OUTPUT_URL=nfs://backup-srv/backup/rear/iso

# Creer le media de restauration + sauvegarde
rear mkbackup

# Restauration : booter sur l'ISO generee
# Puis suivre l'assistant de restauration
```

## Snapshots LVM avant sauvegarde

### Creer un snapshot
```bash
# Verifier l'espace disponible dans le VG
vgs

# Creer un snapshot (preallouer au moins 20% de la taille du LV)
lvcreate --snapshot --name snap_data --size 10G /dev/vg0/lv_data

# Monter le snapshot en lecture seule
mkdir -p /mnt/snap_data
mount -o ro /dev/vg0/snap_data /mnt/snap_data

# Sauvegarder depuis le snapshot (donnees coherentes)
borg create /backup/borg-repo::$(date +%Y%m%d) /mnt/snap_data/

# Demonter et supprimer le snapshot
umount /mnt/snap_data
lvremove -f /dev/vg0/snap_data
```

### Script complet snapshot + sauvegarde
```bash
#!/bin/bash
set -euo pipefail

VG="vg0"
LV="lv_data"
SNAP_NAME="snap_backup"
SNAP_SIZE="10G"
MOUNT="/mnt/snap_backup"
REPO="/backup/borg-repo"

# 1. Creer snapshot
echo "Creation snapshot..."
lvcreate --snapshot --name ${SNAP_NAME} --size ${SNAP_SIZE} /dev/${VG}/${LV}

# 2. Monter
mkdir -p ${MOUNT}
mount -o ro /dev/${VG}/${SNAP_NAME} ${MOUNT}

# 3. Sauvegarder
echo "Sauvegarde borgbackup..."
borg create --stats --compression zstd,3 \
    ${REPO}::$(date +%Y-%m-%d_%H%M) \
    ${MOUNT}/

# 4. Nettoyer
umount ${MOUNT}
lvremove -f /dev/${VG}/${SNAP_NAME}

echo "Sauvegarde terminee."
```

## Sauvegarde des bases de donnees

### PostgreSQL
```bash
# Dump complet
pg_dumpall -U postgres | gzip > /backup/pg_full_$(date +%Y%m%d).sql.gz

# Dump d'une base
pg_dump -U postgres mabase | gzip > /backup/mabase_$(date +%Y%m%d).sql.gz

# WAL archiving (Point In Time Recovery)
# Dans postgresql.conf :
# archive_mode = on
# archive_command = 'cp %p /backup/pg_wal/%f'
# wal_level = replica
```

### MariaDB / MySQL
```bash
# Dump complet
mysqldump --all-databases --single-transaction | gzip > /backup/mysql_full_$(date +%Y%m%d).sql.gz

# Dump d'une base
mysqldump --single-transaction mabase | gzip > /backup/mabase_$(date +%Y%m%d).sql.gz

# Mariabackup (sauvegarde a chaud)
mariabackup --backup --target-dir=/backup/mariabackup/
mariabackup --prepare --target-dir=/backup/mariabackup/
```

## Sauvegarde vers stockage distant

### rclone — Multi-cloud
```bash
# Installation
apt install rclone

# Configuration
rclone config
# Suivre l'assistant pour configurer S3, Google Drive, Azure, etc.

# Synchronisation vers S3
rclone sync /backup/borg-repo remote-s3:mon-bucket/borg/

# Synchronisation vers Google Drive
rclone sync /backup/ remote-gdrive:backups/

# Avec chiffrement
rclone sync /backup/ remote-crypt:backups/
```

## Systemd timers pour planification

```ini
# /etc/systemd/system/backup-daily.service
[Unit]
Description=Sauvegarde quotidienne BorgBackup
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-borg.sh
User=root
Nice=19
IOSchedulingClass=best-effort
IOSchedulingPriority=7

# /etc/systemd/system/backup-daily.timer
[Unit]
Description=Timer sauvegarde quotidienne

[Timer]
OnCalendar=*-*-* 22:00:00
Persistent=true
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
```

```bash
# Activer le timer
systemctl daemon-reload
systemctl enable --now backup-daily.timer

# Verifier
systemctl list-timers backup-daily
journalctl -u backup-daily.service
```

## Verification et monitoring des sauvegardes

```bash
# Verifier l'integrite BorgBackup
borg check /backup/borg-repo

# Lister les archives avec tailles
borg list --format '{archive:<30} {time} {size:>15}' /backup/borg-repo

# Verifier l'anciennete de la derniere sauvegarde
LAST=$(borg list --last 1 --format '{time}' /backup/borg-repo)
echo "Derniere sauvegarde : ${LAST}"

# Script d'alerte si sauvegarde trop ancienne
#!/bin/bash
MAX_AGE_HOURS=26
LAST_EPOCH=$(date -d "$(borg list --last 1 --format '{time}' /backup/borg-repo)" +%s)
NOW_EPOCH=$(date +%s)
AGE_HOURS=$(( (NOW_EPOCH - LAST_EPOCH) / 3600 ))
if [ $AGE_HOURS -gt $MAX_AGE_HOURS ]; then
    echo "ALERTE: Derniere sauvegarde il y a ${AGE_HOURS}h" | \
        mail -s "ALERTE BACKUP" admin@entreprise.fr
fi
```
