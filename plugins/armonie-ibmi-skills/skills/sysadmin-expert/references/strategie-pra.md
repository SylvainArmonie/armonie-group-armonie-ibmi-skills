# Strategie PRA / Disaster Recovery Multi-Plateforme

## PRA - Plan de Reprise d'Activite

### Definitions

| Terme | Definition |
|-------|-----------|
| **PRA** | Plan de Reprise d'Activite — procedures pour reprendre apres un sinistre |
| **PCA** | Plan de Continuite d'Activite — maintenir l'activite pendant un incident |
| **RPO** | Recovery Point Objective — perte de donnees maximale acceptable |
| **RTO** | Recovery Time Objective — delai maximal d'indisponibilite acceptable |
| **MTPD** | Maximum Tolerable Period of Disruption — duree maximale d'interruption |
| **BIA** | Business Impact Analysis — analyse d'impact metier |

### Classification des sinistres

| Niveau | Exemples | Impact |
|--------|---------|--------|
| 1 - Mineur | Panne disque, erreur logicielle | Service degrade |
| 2 - Majeur | Panne serveur, corruption donnees | Service interrompu |
| 3 - Critique | Perte salle machine, cyberattaque | Tout est arrete |
| 4 - Catastrophique | Incendie batiment, catastrophe naturelle | Site detruit |

## Matrice RPO / RTO par application

### Modele de classification

```
Criticite    RPO          RTO          Strategie
---------    ---          ---          ---------
Critique     < 1h         < 2h         Replication temps reel + bascule auto
Haute        < 4h         < 8h         Sauvegarde frequente + site secondaire
Moyenne      < 24h        < 24h        Sauvegarde quotidienne + restauration
Basse        < 72h        < 72h        Sauvegarde hebdomadaire
```

### Exemple concret entreprise

```
Application         Plateforme   Criticite   RPO    RTO    Strategie
-----------         ----------   ---------   ---    ---    ---------
ERP Production      IBM i        Critique    1h     2h     BRMS + HA (PowerHA)
Base clients        IBM i        Haute       4h     8h     BRMS quotidien + SAVF
Site web public     Linux        Haute       1h     4h     Borg + replica cloud
Messagerie          Linux        Moyenne     4h     8h     Backup + restoration
Intranet            Linux        Moyenne     24h    24h    Borg quotidien
Archives            IBM i + Linux Basse      72h    72h    BRMS hebdo + rsync
```

## Strategies par plateforme

### IBM i — Niveaux de protection

#### Niveau 1 : Sauvegarde BRMS standard
```
- BRMS avec strategie GFS (Grand-pere/Pere/Fils)
- RPO : 24h (derniere sauvegarde nocturne)
- RTO : 4-24h (selon volume a restaurer)
- Cout : Faible (licence BRMS + medias)

Mise en oeuvre :
1. BRMS configure avec groupes de controle
2. Sauvegarde quotidienne incrementale
3. Sauvegarde hebdomadaire cumulative
4. Sauvegarde mensuelle complete
5. Medias hors-site
6. Test restauration trimestriel
```

#### Niveau 2 : BRMS + Save Files distants
```
- BRMS sauvegarde vers SAVF
- SAVF repliques via FTP/SFTP vers site distant
- RPO : 24h
- RTO : 4-12h (restauration depuis SAVF distant)
- Cout : Moyen (bande passante + stockage distant)

Script de replication SAVF :
FTP RMTSYS(site-dr.entreprise.fr)
  PUT /QSYS.LIB/SAVFBRM.LIB/BKUQUO01.FILE
  QUIT
```

#### Niveau 3 : Haute disponibilite (PowerHA / iCluster / MIMIX)
```
- Replication en temps reel vers systeme secondaire
- Bascule automatique ou manuelle
- RPO : Quasi 0 (secondes)
- RTO : Minutes a 1h
- Cout : Eleve (licence HA + hardware secondaire)

Solutions :
- IBM PowerHA SystemMirror for i
- Syncsort/Precisely MIMIX
- Vision Solutions iCluster / Quick-EDD
```

### Linux — Niveaux de protection

#### Niveau 1 : BorgBackup local + distant
```
- BorgBackup avec deduplication
- Copie vers stockage distant (NAS/S3)
- RPO : 24h
- RTO : 2-8h

Script :
borg create repo::$(date +%Y%m%d) /etc /home /var
rclone sync /backup/borg-repo remote-s3:backup-borg/
```

#### Niveau 2 : Restic + S3 + ReaR
```
- Restic vers S3 (sauvegarde cloud)
- ReaR pour bare metal recovery
- RPO : Selon frequence (jusqu'a horaire)
- RTO : 1-4h

Avantage : restauration possible sur n'importe quel hardware
```

#### Niveau 3 : Replication + Load Balancer
```
- DRBD pour replication bloc
- Pacemaker/Corosync pour clustering
- HAProxy/keepalived pour bascule
- RPO : Quasi 0
- RTO : Secondes a minutes

Cout : Eleve (infrastructure doublee)
```

## Plan de test PRA

### Frequence des tests

| Type de test | Frequence | Duree | Participants |
|-------------|-----------|-------|-------------|
| Revue documentaire | Trimestriel | 2h | Equipe IT |
| Test partiel (1 appli) | Mensuel | 4h | Equipe IT + metier |
| Test complet (1 plateforme) | Semestriel | 1 jour | Equipe IT + direction |
| Exercice grandeur nature | Annuel | 2 jours | Tous |

### Checklist test PRA

#### Avant le test
- [ ] Rapport de recuperation BRMS a jour (STRRCYBRM *REPORT)
- [ ] Documentation Linux de restauration a jour
- [ ] Medias de sauvegarde disponibles (bandes + SAVF + borg)
- [ ] Hardware de test operationnel (LPAR IBM i + VM Linux)
- [ ] Equipe de test identifiee et disponible
- [ ] Scenarios de test definis et valides

#### Pendant le test — IBM i
- [ ] IPL depuis media d'installation (si test complet)
- [ ] Restauration systeme via STRRCYBRM
- [ ] Verification des sous-systemes (WRKSBS)
- [ ] Verification des services TCP/IP
- [ ] Test des applications metier
- [ ] Chronometrage de chaque etape

#### Pendant le test — Linux
- [ ] Restauration depuis BorgBackup / Restic
- [ ] Boot via ReaR (si bare metal)
- [ ] Verification des services (systemctl)
- [ ] Test de connectivite reseau
- [ ] Test des applications web
- [ ] Chronometrage de chaque etape

#### Apres le test
- [ ] Rapport de test redige (durees, problemes, actions)
- [ ] Actions correctives identifiees
- [ ] Mise a jour de la documentation PRA
- [ ] Communication a la direction
- [ ] Planification des corrections

## Documentation PRA

### Contenu minimum du document PRA

```
1. Inventaire des systemes
   - Liste des serveurs Linux (nom, IP, role, criticite)
   - Liste des partitions IBM i (nom, IP, role, criticite)
   - Dependencies entre systemes

2. Contacts d'urgence
   - Equipe IT (nom, tel, astreinte)
   - Direction (notification)
   - Fournisseurs (IBM support, hebergeur, prestataires)

3. Procedures de restauration
   - IBM i : Rapport BRMS (STRRCYBRM *REPORT) + procedures manuelles
   - Linux : Scripts de restauration + documentation borg/restic/ReaR

4. Matrice RPO/RTO
   - Par application et par plateforme

5. Historique des tests
   - Date, type, resultats, actions correctives

6. Schemas reseau et architecture
   - Plans reseau, VLAN, interconnexions
   - Architecture applicative
```

### Ou stocker le PRA ?

| Emplacement | Avantage | Inconvenient |
|-------------|----------|-------------|
| Wiki interne | Facile a mettre a jour | Indisponible si sinistre |
| Document imprime hors-site | Toujours accessible | Difficile a maintenir |
| Cloud securise | Accessible partout | Dependance internet |
| Coffre-fort | Tres securise | Peu accessible |

**Recommandation** : Combinaison wiki interne + copie PDF hors-site + cloud securise.

## Coordination IBM i et Linux en cas de sinistre

### Ordre de restauration recommande

```
Phase 1 : Infrastructure (0-2h)
  1. Reseau (switches, routeurs, DNS)
  2. Stockage (SAN/NAS si partage)

Phase 2 : Serveurs critiques (2-8h)
  3. IBM i — Systeme d'exploitation (STRRCYBRM *SYSTEM)
  4. IBM i — Donnees applicatives (STRRCYBRM *ALLUSR)
  5. Linux — Serveurs web/API (borg extract + systemctl)

Phase 3 : Services (8-16h)
  6. IBM i — Verification services (TCP/IP, sous-systemes)
  7. Linux — Verification services (nginx, postgresql, etc.)
  8. Tests applicatifs

Phase 4 : Finalisation (16-24h)
  9. Verification securite (autorisations, firewall)
  10. Tests utilisateurs metier
  11. Communication reprise normale
```

### Communication de crise

```
T+0    : Detection du sinistre → Alerte equipe IT
T+15mn : Evaluation de l'impact → Decision activation PRA
T+30mn : Notification direction + metier
T+1h   : Point de situation #1
T+2h   : Point de situation #2
T+Xh   : Points reguliers jusqu'a restauration
T+fin  : Communication reprise normale
```

## Bonnes pratiques PRA multi-plateforme

1. **Un seul PRA** — Document unique couvrant TOUTES les plateformes
2. **Proprietaire identifie** — Une personne responsable de la mise a jour
3. **Tests reguliers** — Un PRA non teste est un PRA qui ne marche pas
4. **Automatiser** — Scripts de restauration testes et versionnes
5. **Hors-site** — Toujours des copies de sauvegarde hors du site principal
6. **Independance** — Le PRA doit etre accessible MEME si le systeme principal est en panne
7. **Formation** — Toute l'equipe doit connaitre les procedures
8. **Revue post-incident** — Apres chaque incident, ameliorer le PRA
9. **Budget** — Le PRA a un cout, le presenter comme une assurance
10. **Direction** — Impliquer la direction dans les decisions RPO/RTO
