---
name: sysadmin-expert
description: Expert administration systeme multi-plateforme Linux (Debian/Ubuntu) et IBM i. Specialise BRMS (Backup Recovery and Media Services), strategies sauvegarde/restauration, monitoring et PRA sur les deux plateformes. Couvre BRMS complet (politiques, groupes de controle, medias, planification, recuperation), sauvegarde Linux (borgbackup, restic, rsync, LVM snapshots), comparatif Linux/IBM i. Use when user asks about BRMS, backup strategies, disaster recovery, media management, or comparing Linux and IBM i concepts. Triggers - BRMS, STRMNTBRM, STRBKUBRM, STRRCYBRM, sauvegarde multi-plateforme, PRA, disaster recovery, media rotation, groupe de controle, politique sauvegarde, monitoring mixte, comparatif Linux IBM i. Do NOT use for pure RPG/SQL dev or single-platform questions covered by debian-linux-expert or ibmi-admin-expert.
---

# SysAdmin Expert - Administration Systeme Multi-Plateforme

Skill de reference pour l'administration systeme transversale Linux (Debian/Ubuntu) et IBM i (AS/400).
Specialise dans les strategies de sauvegarde (dont BRMS), la haute disponibilite, le monitoring et l'interoperabilite entre plateformes.

**Complementaire aux skills existants** : Ce skill s'utilise EN COMPLEMENT de `debian-linux-expert` (pour le detail Linux pur) et `ibmi-admin-expert` (pour le detail IBM i pur). Il apporte la vision transversale, BRMS, et les strategies de sauvegarde/restauration avancees.

## Instructions

### Etape 1 : Identifier le domaine et la plateforme

Analyser la demande et classifier :

| Domaine | Plateforme | Reference a lire EN PREMIER |
|---------|------------|----------------------------|
| BRMS - Concepts et architecture | IBM i | `references/brms-architecture.md` |
| BRMS - Politiques et groupes de controle | IBM i | `references/brms-politiques.md` |
| BRMS - Medias et bibliotheques de medias | IBM i | `references/brms-medias.md` |
| BRMS - Planification et automatisation | IBM i | `references/brms-planification.md` |
| BRMS - Recuperation et restauration | IBM i | `references/brms-recuperation.md` |
| Sauvegarde Linux avancee | Linux | `references/linux-sauvegarde-avancee.md` |
| Monitoring multi-plateforme | Les deux | `references/monitoring-multiplateforme.md` |
| Comparatif concepts Linux / IBM i | Les deux | `references/comparatif-linux-ibmi.md` |
| Strategie PRA / Disaster Recovery | Les deux | `references/strategie-pra.md` |

### Etape 2 : Lire les references AVANT de repondre

CRITICAL: Toujours lire le guide de reference correspondant AVANT de generer des commandes ou des explications.
Si le besoin couvre plusieurs domaines, lire TOUS les guides concernes.

### Etape 3 : Appliquer les regles critiques

Regles OBLIGATOIRES dans toute reponse :

1. **Identifier la plateforme** — Toujours preciser si la commande/procedure est pour Linux, IBM i, ou les deux
2. **Commandes completes** — Fournir la syntaxe complete avec parametres importants
3. **Securite avant tout** — Toujours mentionner les implications securite et les precautions
4. **Verification** — Proposer des commandes de verification apres chaque operation
5. **Equivalences** — Quand pertinent, mentionner l'equivalent sur l'autre plateforme
6. **Francais** — Explications et commentaires en francais
7. **Scenarios concrets** — Illustrer avec des cas pratiques d'entreprise
8. **Avertissements** — Toujours prevenir avant les operations destructives ou irreversibles

### Etape 4 : Structurer la reponse

Pour chaque reponse technique :

1. **Contexte** — Plateforme(s) concernee(s) et prerequis
2. **Procedure** — Etapes detaillees avec commandes commentees
3. **Verification** — Comment valider le resultat
4. **Troubleshooting** — Diagnostic en cas de probleme
5. **Equivalence** — Equivalent sur l'autre plateforme si pertinent

## Aide-memoire rapide BRMS

### Commandes BRMS essentielles

| Commande | Description |
|----------|-------------|
| GO BRMS | Menu principal BRMS |
| STRMNTBRM | Maintenance BRMS (a lancer quotidiennement) |
| STRBKUBRM | Demarrer une sauvegarde BRMS |
| STRRCYBRM | Demarrer une recuperation BRMS |
| INZBRM | Initialiser BRMS (premiere installation) |
| WRKPCYBRM | Gerer les politiques de sauvegarde |
| WRKMLBBRM | Gerer les bibliotheques de medias |
| WRKMEDIBRM | Gerer les medias (bandes, volumes) |
| WRKCTLGBRM | Gerer les groupes de controle |
| WRKCALBRM | Gerer le calendrier BRMS |
| DSPMEDIBRM | Afficher les informations d'un media |
| ADDMEDIBRM | Ajouter un media a BRMS |
| MOVMEDBRM | Deplacer un media (gestion hors-site) |
| SETMEDBRM | Definir la politique d'expiration d'un media |
| WRKSPRBRM | Gerer les fichiers spoules sauvegardes |
| PRTRPTBRM | Imprimer un rapport BRMS |
| STRRCYBRM OPTION(*REPORT) | Generer un rapport de recuperation (sans executer) |

### Sauvegarde Linux - Commandes essentielles

| Commande | Description |
|----------|-------------|
| rsync -avz --delete src/ dest/ | Synchronisation incrementale |
| borgbackup create | Sauvegarde deduplication + chiffrement |
| restic backup /chemin | Sauvegarde incrementale rapide |
| lvcreate --snapshot | Snapshot LVM avant sauvegarde |
| tar czf backup.tar.gz /chemin | Archive compressee |
| rclone sync src remote:dest | Synchronisation vers cloud/S3 |
| duplicity /src file:///dest | Sauvegarde chiffree incrementale |
| timeshift --create | Snapshot systeme (type Time Machine) |

## Mapping rapide des concepts Linux ↔ IBM i

| Concept | Linux (Debian/Ubuntu) | IBM i (AS/400) |
|---------|----------------------|----------------|
| Sauvegarde systeme | rsync, borgbackup, tar | SAVSYS, SAVLIB, BRMS |
| Sauvegarde incrementale | rsync --link-dest, restic | BRMS avec *CUML / *INCR |
| Gestion medias | mt, mtx, bacula | BRMS WRKMEDIBRM |
| Planification | cron, systemd-timer | BRMS calendrier, WRKJOBSCDE |
| Restauration | rsync, borg extract | RSTLIB, STRRCYBRM |
| Disaster Recovery | PRA via scripts + docs | STRRCYBRM OPTION(*REPORT) |
| Monitoring systeme | Prometheus + Grafana | WRKACTJOB, WRKSYSSTS, Navigator |
| Logs centralises | journald, rsyslog, ELK | DSPLOG, DSPJOBLOG, QAUDJRN |
| Gestion utilisateurs | useradd, passwd, PAM | CRTUSRPRF, CHGUSRPRF |
| Firewall | nftables, ufw | Regles de filtrage IP (*IPFTR) |
| Service management | systemd | Sous-systemes (STRSBS/ENDSBS) |
| Stockage | LVM, Btrfs, ZFS | ASP, IASP |
| Haute disponibilite | DRBD, Pacemaker, keepalived | PowerHA (iCluster, MIMIX, Quick-EDD) |

## Arbre de decision - Strategie de sauvegarde

```
Besoin de sauvegarde identifie
│
├── Plateforme IBM i ?
│   ├── BRMS installe ?
│   │   ├── OUI → Utiliser BRMS (voir references/brms-*)
│   │   └── NON → Sauvegarde classique (SAVLIB/SAVOBJ/SAVSYS)
│   │             Envisager installation BRMS (RSTLICPGM 5770-BR1)
│   ├── Type de sauvegarde ?
│   │   ├── Systeme complet → SAVSYS + SAVLIB LIB(*ALLUSR) + SAVSECDTA + SAVDLO
│   │   ├── Applicatif → SAVLIB ou BRMS groupe de controle applicatif
│   │   ├── Incrementale → BRMS *CUML ou *INCR
│   │   └── Objets specifiques → SAVOBJ ou SAVCHGOBJ
│   └── Restauration ?
│       ├── BRMS → STRRCYBRM (generer rapport d'abord)
│       └── Classique → RSTLIB, RSTOBJ, RSTAUT
│
├── Plateforme Linux ?
│   ├── Systeme complet → borgbackup / restic + LVM snapshot
│   ├── Fichiers/repertoires → rsync incremental + rotation
│   ├── Base de donnees → pg_dump / mysqldump + WAL archiving
│   ├── Vers cloud/distant → rclone / restic + S3
│   └── Bare metal restore → Relax-and-Recover (ReaR)
│
└── Multi-plateforme ?
    ├── Strategie unifiee → Documenter les deux dans un PRA commun
    ├── Planification → Coordonner les fenetres de sauvegarde
    ├── Stockage → NAS/SAN partage ou cloud centralise
    └── Tests → Tester la restauration des DEUX plateformes regulierement
```

## Troubleshooting rapide

### BRMS - Problemes courants

| Probleme | Diagnostic | Solution |
|----------|-----------|----------|
| BRMS ne demarre pas | DSPPTF LICPGM(5770BR1) | Verifier installation et PTF |
| Media non reconnu | DSPMEDIBRM + DSPTAP | Verifier initialisation et inscription |
| Sauvegarde echoue | DSPLOG + DSPJOBLOG du job BRM | Analyser le message d'erreur |
| Media expire trop tot | WRKPCYBRM → retention | Ajuster la politique de retention |
| Groupe de controle ne s'execute pas | WRKCTLGBRM → statut | Verifier calendrier et sequencement |
| Rapport recuperation incomplet | STRRCYBRM OPTION(*REPORT) | Verifier que STRMNTBRM est lance regulierement |

### Linux - Problemes courants

| Probleme | Diagnostic | Solution |
|----------|-----------|----------|
| rsync lent | iostat, iftop | Verifier I/O disque et bande passante |
| borgbackup lock | borg break-lock | Supprimer le verrou obsolete |
| Espace insuffisant | df -h, du -sh | Purger anciennes sauvegardes, rotation |
| Cron ne s'execute pas | journalctl -u cron | Verifier syntaxe crontab et PATH |
| Snapshot LVM plein | lvs, dmsetup status | Etendre ou supprimer le snapshot |
| Restauration partielle | Logs de l'outil utilise | Verifier integrite avec checksums |

## Prerequis

### IBM i (pour BRMS)
- IBM i 7.3 ou superieur
- Licence BRMS (5770-BR1) installee et activee
- Autorisations *ALLOBJ et *SAVSYS pour les operations de sauvegarde
- STRMNTBRM lance quotidiennement (idealement via job schedule)
- Au moins un peripherique de sauvegarde configure (bande, SAVF, ou virtual tape)

### Linux (Debian/Ubuntu)
- Debian 12+ ou Ubuntu 22.04+
- Outils de sauvegarde installes (borgbackup, restic, rsync selon strategie)
- Acces root ou sudo pour les sauvegardes systeme
- Espace de stockage suffisant (local, NAS, ou cloud)

## Performance Notes

- CRITICAL: Toujours lire les references AVANT de repondre
- Pour les questions BRMS detaillees, commencer par `references/brms-architecture.md`
- Pour les comparatifs, lire `references/comparatif-linux-ibmi.md`
- Ce skill complete (ne remplace PAS) debian-linux-expert et ibmi-admin-expert
- Pour les questions purement Linux ou purement IBM i sans aspect transversal ni BRMS, les skills dedies restent plus adaptes
