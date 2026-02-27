# Comparatif Concepts Linux ↔ IBM i

## Guide de correspondance pour administrateurs multi-plateforme

Ce document aide a passer d'un monde a l'autre en mappant les concepts equivalents.

## Architecture systeme

| Concept | Linux (Debian/Ubuntu) | IBM i (AS/400) |
|---------|----------------------|----------------|
| Noyau / OS | Kernel Linux | SLIC + MI (Machine Interface) |
| Shell | bash, zsh | Commande CL, QShell, PASE |
| Gestionnaire services | systemd | Sous-systemes (SBS) |
| Processus / travaux | process (PID) | Job (nom/utilisateur/numero) |
| Utilisateur root | root (UID 0) | QSECOFR (*ALLOBJ *SECADM) |
| Elevation privileges | sudo / run0 | QSECOFR ou *SECADM |
| Fichiers config | /etc/ (fichiers texte) | Valeurs systeme (DSPSYSVAL) |
| Variable environnement | export VAR=val | SYSVAL, DTAARA, ENVVAR |
| Redemarrage | reboot / systemctl reboot | PWRDWNSYS OPTION(*IMMED) RESTART(*YES) |
| Arret | shutdown -h now | PWRDWNSYS OPTION(*CNTRLD) DELAY(600) |

## Gestion des services

| Action | Linux | IBM i |
|--------|-------|-------|
| Lister services actifs | systemctl list-units --type=service | WRKSBS + WRKACTJOB |
| Demarrer un service | systemctl start nginx | STRSBS SBSD(LIB/MONSBSD) |
| Arreter un service | systemctl stop nginx | ENDSBS SBS(MONSBS) OPTION(*CNTRLD) |
| Activer au demarrage | systemctl enable nginx | CHGSYSVAL SYSVAL(QSTRUPPGM) / autostart SBS |
| Voir les logs d'un service | journalctl -u nginx | DSPJOBLOG / DSPLOG |
| Relancer un service | systemctl restart nginx | ENDSBS + STRSBS |
| Statut d'un service | systemctl status nginx | DSPSBSD + WRKACTJOB SBS(x) |

## Gestion des utilisateurs

| Action | Linux | IBM i |
|--------|-------|-------|
| Creer utilisateur | useradd -m user | CRTUSRPRF USRPRF(USER) |
| Supprimer utilisateur | userdel -r user | DLTUSRPRF USRPRF(USER) |
| Changer mot de passe | passwd user | CHGUSRPRF USRPRF(USER) PASSWORD(xxx) |
| Lister utilisateurs | cat /etc/passwd, getent passwd | DSPAUTUSR, WRKUSRPRF *ALL |
| Groupes | groupadd, usermod -aG | *GRPPRF dans CRTUSRPRF |
| Droits fichier | chmod, chown, ACL | GRTOBJAUT, EDTOBJAUT |
| Connexions actives | who, w, last | WRKACTJOB, WRKOBJLCK |
| Bloquer un utilisateur | usermod -L user | CHGUSRPRF STATUS(*DISABLED) |
| Politique mot de passe | /etc/login.defs, PAM | QPWDEXPITV, QPWDMINLEN, QPWDRULES |

## Systeme de fichiers et stockage

| Concept | Linux | IBM i |
|---------|-------|-------|
| Systeme de fichiers | ext4, XFS, Btrfs, ZFS | Stockage a niveau unique (single-level storage) |
| Arborescence | / (root), /home, /var... | QSYS.LIB (bibliotheques), IFS (/) |
| Repertoire | /chemin/dossier | Bibliotheque (LIB) ou repertoire IFS |
| Fichier | fichier regulier | Objet (*FILE, *PGM, *DTAARA...) |
| Lister fichiers | ls -la | WRKOBJ, WRKLNK (IFS) |
| Espace disque | df -h, lsblk | WRKDSKSTS, WRKSYSSTS (%ASP) |
| Partitions | fdisk, parted | ASP, IASP |
| LVM | pvcreate, vgcreate, lvcreate | ASP (concepts similaires) |
| Snapshot | lvcreate --snapshot | Flash Copy (SAN), SAVLIB |
| Montage | mount /dev/sda1 /mnt | ADDLIBLE (concept different) |
| Recherche | find, locate | WRKOBJ, DSPOBJD, SQL sur SYSTABLES |

## Reseau

| Action | Linux | IBM i |
|--------|-------|-------|
| Configuration IP | ip addr, /etc/network | CFGTCP, WRKTCPSTS |
| Table de routage | ip route | CFGTCP option 2 |
| Ports en ecoute | ss -tulnp | WRKTCPSTS OPTION(*CNN) |
| DNS | /etc/resolv.conf, resolvectl | CFGTCP option 12 |
| Ping | ping | PING |
| Traceroute | traceroute | TRACEROUTE |
| Firewall | nftables (nft) | Regles filtrage IP (*IPFTR) |
| SSH | openssh-server | STRTCPSVR *SSHD |
| FTP | vsftpd | STRTCPSVR *FTP |
| NFS | nfs-kernel-server | STRNFSSVR |
| Nom d'hote | hostnamectl | CFGTCP option 12 |

## Sauvegarde et restauration

| Action | Linux | IBM i |
|--------|-------|-------|
| Sauvegarde complete | borgbackup, tar, rsync | SAVSYS, SAVLIB LIB(*ALLUSR), BRMS |
| Sauvegarde incrementale | rsync --link-dest, restic | SAVCHGOBJ, BRMS *INCR |
| Sauvegarde cumulative | borgbackup (naturellement) | BRMS *CUML |
| Restauration fichier | borg extract, rsync | RSTOBJ, STRRCYBRM |
| Restauration systeme | ReaR, debootstrap | RSTLIB, STRRCYBRM *SYSTEM |
| Gestion medias | mt, mtx, bacula | BRMS WRKMEDIBRM |
| Planification | systemd timer, cron | BRMS calendrier, WRKJOBSCDE |
| Rapport PRA | Documentation manuelle | STRRCYBRM OPTION(*REPORT) |
| Sauvegarde a chaud | LVM snapshot + sauvegarde | SAVACT(*LIB) — Save While Active |

## Journalisation et audit

| Concept | Linux | IBM i |
|---------|-------|-------|
| Logs systeme | journald (journalctl) | QHST (DSPLOG) |
| Logs application | /var/log/, syslog | DSPJOBLOG, MSGQ |
| Audit securite | auditd, /var/log/auth.log | QAUDJRN (journal d'audit) |
| Rotation logs | logrotate | Recepteurs de journaux (CHGJRN) |
| Centralisation | rsyslog → ELK/Loki | QSYSOPR + monitoring |
| Journal BD | WAL (PostgreSQL), binlog (MySQL) | Journalisation PF (STRJRNPF) |

## Performance et diagnostic

| Action | Linux | IBM i |
|--------|-------|-------|
| CPU temps reel | top, htop, btop | WRKACTJOB, WRKSYSACT |
| Memoire | free -h, vmstat | WRKSYSSTS |
| I/O disque | iostat, iotop | WRKDSKSTS |
| Reseau | iftop, nethogs | WRKTCPSTS |
| Processus bloque | strace -p PID | WRKJOB → option 7 (messages) |
| Profiling | perf, strace | PEX (Performance Explorer) |
| Statistiques systeme | sar (sysstat) | Collection Services |
| Diagnostic boot | systemd-analyze | QHST apres IPL |

## Securite

| Concept | Linux | IBM i |
|---------|-------|-------|
| Controle d'acces | DAC (chmod) + MAC (AppArmor) | Autorite objet + profil groupe |
| Chiffrement disque | LUKS | Non natif (chiffrement SAN/VTL) |
| Firewall | nftables | Regles filtrage IP |
| Audit | auditd | QAUDJRN |
| MFA / 2FA | PAM + TOTP | Produits tiers (Assure, Powertech) |
| Patch management | apt update + unattended-upgrades | PTF (DSPPTF, INSPTF, SNDPTFORD) |
| Analyse vulnerabilite | Lynis, OpenSCAP | Powertech Authority Broker |
| Durcissement | CIS Benchmarks Debian | IBM i Security Guide |

## Automatisation

| Concept | Linux | IBM i |
|---------|-------|-------|
| Script | Bash, Python | CL (CLLE), QShell, PASE |
| Planification | cron, systemd timer | WRKJOBSCDE |
| Orchestration | Ansible | Ansible for IBM i (via PASE) |
| CI/CD | GitLab CI, GitHub Actions | RDi, iProjects, Bob |
| Configuration as Code | Ansible playbooks | CL programs |
| Package manager | apt, pip | RSTLICPGM, yum (PASE) |

## Equivalences de commandes courantes

| Besoin | Linux | IBM i |
|--------|-------|-------|
| "Qui suis-je ?" | whoami, id | DSPJOB (voir utilisateur courant) |
| "Quelle heure ?" | date | DSPSYSVAL SYSVAL(QDATETIME) |
| "Espace disque" | df -h | WRKDSKSTS |
| "Memoire libre" | free -h | WRKSYSSTS |
| "Processus/jobs actifs" | ps aux, top | WRKACTJOB |
| "Redemarrer un service" | systemctl restart svc | ENDSBS + STRSBS |
| "Voir les logs" | journalctl -f | DSPMSG QSYSOPR, DSPLOG |
| "Trouver un fichier" | find / -name "*.conf" | WRKOBJ OBJ(*ALL/MONOBJ) OBJTYPE(*ALL) |
| "Copier un fichier" | cp src dest | CRTDUPOBJ, CPYF, CPY (IFS) |
| "Envoyer un message" | wall "message" | SNDBRKMSG MSG('message') TOMSGQ(*ALLWS) |
| "Voir la config reseau" | ip addr show | WRKTCPSTS OPTION(*IFC) |
| "Installer un paquet" | apt install pkg | RSTLICPGM / yum install (PASE) |
| "Mettre a jour" | apt upgrade | INSPTF (appliquer PTF) |
