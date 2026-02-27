# BRMS - Planification et Automatisation

## Calendrier BRMS

### Concept du calendrier
Le calendrier BRMS permet de planifier automatiquement l'execution des groupes de controle selon un planning defini (quotidien, hebdomadaire, mensuel).

### Gestion du calendrier
```
-- Acceder au calendrier BRMS
WRKCALBRM

-- Creer un calendrier
-- Via GO BRMS → Option 4 (Calendrier) → F6 (Creer)
```

### Structure d'un calendrier

```
Calendrier : PLANPROD (Plan de production)
Type : *BKU (Sauvegarde)

Jour        Groupe de controle  Heure
---------   ------------------  -----
Lundi       QUOTIDIEN           22:00
Mardi       QUOTIDIEN           22:00
Mercredi    QUOTIDIEN           22:00
Jeudi       QUOTIDIEN           22:00
Vendredi    QUOTIDIEN           22:00
Samedi      HEBDO               20:00
1er du mois MENSUEL             18:00
```

### Configuration du calendrier pas a pas

```
1. Creer les groupes de controle :
   WRKCTLGBRM TYPE(*BKU) → F6 (Creer)
   - QUOTIDIEN : sauvegardes incrementales
   - HEBDO : sauvegardes cumulatives
   - MENSUEL : sauvegardes completes

2. Creer le calendrier :
   WRKCALBRM → F6 (Creer)
   - Nom : PLANPROD
   - Type : *BKU

3. Ajouter les entrees au calendrier :
   Pour chaque jour/groupe, ajouter une entree

4. Activer le calendrier :
   WRKCALBRM → Option 8 (Activer)
```

## Planification via Job Scheduler (WRKJOBSCDE)

En complement ou en remplacement du calendrier BRMS, on peut utiliser le Job Scheduler natif IBM i.

### Planifier la maintenance BRMS
```
ADDJOBSCDE JOB(BRMMAINT)
            CMD(STRMNTBRM)
            FRQ(*WEEKLY)
            SCDDAY(*ALL)
            SCDTIME('215000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Maintenance BRMS quotidienne')
```

### Planifier la sauvegarde quotidienne
```
ADDJOBSCDE JOB(BRMQUOT)
            CMD(STRBKUBRM CTLGRP(QUOTIDIEN))
            FRQ(*WEEKLY)
            SCDDAY(*MON *TUE *WED *THU *FRI)
            SCDTIME('220000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Sauvegarde BRMS quotidienne L-V')
```

### Planifier la sauvegarde hebdomadaire
```
ADDJOBSCDE JOB(BRMHEBDO)
            CMD(STRBKUBRM CTLGRP(HEBDO))
            FRQ(*WEEKLY)
            SCDDAY(*SAT)
            SCDTIME('200000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Sauvegarde BRMS hebdomadaire samedi')
```

### Planifier la sauvegarde mensuelle
```
ADDJOBSCDE JOB(BRMMENSU)
            CMD(STRBKUBRM CTLGRP(MENSUEL))
            FRQ(*MONTHLY)
            SCDDATE(*MONTHSTR)
            SCDTIME('180000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Sauvegarde BRMS mensuelle 1er du mois')
```

### Planifier le rapport de recuperation
```
ADDJOBSCDE JOB(BRMRCYRPT)
            CMD(STRRCYBRM OPTION(*REPORT) ACTION(*REPORT))
            FRQ(*WEEKLY)
            SCDDAY(*MON)
            SCDTIME('060000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Rapport recuperation BRMS hebdomadaire')
```

### Planifier le deplacement des medias
```
ADDJOBSCDE JOB(BRMMOV)
            CMD(MOVMEDBRM OPTION(*MOVE))
            FRQ(*WEEKLY)
            SCDDAY(*MON *WED *FRI)
            SCDTIME('080000')
            JOBQ(QBATCH)
            USER(QSECOFR)
            TEXT('Deplacement medias BRMS')
```

## Automatisation avancee

### Programme CL d'orchestration BRMS

```cl
/* Programme : BRMORCH - Orchestration complete BRMS         */
/* Auteur : Sylvain AKTEPE - NOTOS/Armonie                   */
/* Description : Lance la sequence complete de sauvegarde     */

PGM PARM(&TYPBKU)

DCL VAR(&TYPBKU)  TYPE(*CHAR) LEN(10)  /* *QUOT *HEBD *MENS */
DCL VAR(&DATJOUR) TYPE(*CHAR) LEN(8)
DCL VAR(&HEURE)   TYPE(*CHAR) LEN(6)
DCL VAR(&MSGID)   TYPE(*CHAR) LEN(7)
DCL VAR(&MSGDTA)  TYPE(*CHAR) LEN(256)

/* Recuperer date et heure */
RTVJOBA DATE(&DATJOUR)
RTVSYSVAL SYSVAL(QTIME) RTNVAR(&HEURE)

/* Envoyer message de debut */
SNDMSG MSG('BRMS: Debut sauvegarde ' *CAT &TYPBKU +
            *TCAT ' le ' *CAT &DATJOUR *TCAT +
            ' a ' *CAT &HEURE) +
       TOMSGQ(QSYSOPR)

/* 1. Maintenance BRMS (toujours en premier) */
STRMNTBRM
MONMSG MSGID(CPF0000) EXEC(DO)
  SNDMSG MSG('BRMS ERREUR: Maintenance echouee') +
         TOMSGQ(QSYSOPR)
  GOTO CMDLBL(FIN)
ENDDO

/* 2. Lancer la sauvegarde selon le type */
SELECT
  WHEN COND(&TYPBKU *EQ '*QUOT') THEN(DO)
    STRBKUBRM CTLGRP(QUOTIDIEN)
    MONMSG MSGID(CPF0000) EXEC(GOTO CMDLBL(ERREUR))
  ENDDO

  WHEN COND(&TYPBKU *EQ '*HEBD') THEN(DO)
    STRBKUBRM CTLGRP(HEBDO)
    MONMSG MSGID(CPF0000) EXEC(GOTO CMDLBL(ERREUR))
  ENDDO

  WHEN COND(&TYPBKU *EQ '*MENS') THEN(DO)
    STRBKUBRM CTLGRP(MENSUEL)
    MONMSG MSGID(CPF0000) EXEC(GOTO CMDLBL(ERREUR))
    /* Generer le rapport de recuperation apres mensuelle */
    STRRCYBRM OPTION(*REPORT) ACTION(*REPORT)
    MONMSG MSGID(CPF0000)
  ENDDO

  OTHERWISE CMD(DO)
    SNDMSG MSG('BRMS ERREUR: Type inconnu ' *CAT &TYPBKU) +
           TOMSGQ(QSYSOPR)
    GOTO CMDLBL(FIN)
  ENDDO
ENDSELECT

/* Succes */
SNDMSG MSG('BRMS: Sauvegarde ' *CAT &TYPBKU +
            *TCAT ' terminee avec succes') +
       TOMSGQ(QSYSOPR)
GOTO CMDLBL(FIN)

/* Gestion erreur */
ERREUR:
  RCVMSG MSGTYPE(*LAST) MSGID(&MSGID) MSGDTA(&MSGDTA)
  SNDMSG MSG('BRMS ERREUR: Sauvegarde ' *CAT &TYPBKU +
              *TCAT ' echouee - ' *CAT &MSGID +
              *TCAT ' ' *CAT &MSGDTA) +
         TOMSGQ(QSYSOPR)

FIN:
ENDPGM
```

### Notifications par email apres sauvegarde

```cl
/* Envoyer un email de notification apres la sauvegarde */
/* Necessite configuration SMTP sur IBM i (STRTCPSVR *SMTP) */

SNDSMTPEMM RCP(('admin@entreprise.fr' *PRI))
            SUBJECT('BRMS - Rapport sauvegarde ' *CAT &TYPBKU)
            NOTE('La sauvegarde BRMS de type ' *CAT &TYPBKU +
                 ' s est terminee. Verifier le joblog pour +
                 les details.')
            CONTENT(*HTML)
```

## Fenetre de sauvegarde

### Concept
La fenetre de sauvegarde est la periode pendant laquelle le systeme est disponible pour les operations de sauvegarde. Optimiser cette fenetre est crucial.

### Facteurs impactant la duree

| Facteur | Impact | Optimisation |
|---------|--------|-------------|
| Volume de donnees | Plus de donnees = plus long | Sauvegardes incrementales |
| Vitesse du media | Bande < VTL < SSD | Upgrade media |
| Compression | Reduit le volume a ecrire | Activer la compression |
| Reseau | Limite si sauvegarde distante | Lien dedie ou compression |
| Sous-systemes actifs | Verrouillages possibles | Arreter les sous-systemes applicatifs |
| Nombre de fichiers | Impact sur le catalogage | Regrouper si possible |

### Recommandations pour reduire la fenetre

1. **Sauvegardes incrementales/cumulatives** en semaine, complete le week-end
2. **VTL** au lieu de bandes physiques (10x plus rapide)
3. **Compression** materielle activee sur le peripherique
4. **SAVACTLIB/SAVACTWAIT** : sauvegarder sans arreter les sous-systemes (save-while-active)
5. **Parallelisme** : plusieurs lecteurs ou SAVF simultanes
6. **Flash Copy / Instant Copy** : snapshot SAN pour sauvegarde sans impact

### Save While Active (sauvegarde a chaud)

BRMS supporte la sauvegarde sans arreter les applications :

```
Dans le groupe de controle, specifier :
- Save active : *LIB ou *SYSDFN
- Wait time : 120 (secondes d'attente pour un checkpoint)
- Save active message queue : *NONE ou QSYSOPR

Attention : Save While Active necessite la journalisation
            des fichiers physiques pour garantir la coherence.
```

## Supervision des sauvegardes

### Verification post-sauvegarde
```
-- Verifier le statut du dernier groupe de controle
WRKCTLGBRM TYPE(*BKU)
-- Colonne "Dernier statut" : doit etre *COMPLETED

-- Verifier le joblog de la sauvegarde
WRKJOB JOB(STRBKUBRM)
-- Option 4 → Joblog

-- Verifier les messages operateur
DSPMSG MSGQ(QSYSOPR)
```

### Alertes et monitoring
```
-- Messages BRMS a surveiller dans QSYSOPR :
BRM1xxx → Messages informatifs BRMS
BRM2xxx → Avertissements BRMS
BRM3xxx → Erreurs BRMS
BRM40xx → Erreurs media
BRM50xx → Erreurs de recuperation

-- Surveiller via programme CL ou outil de monitoring
-- Filtrer les messages BRM* dans la MSGQ QSYSOPR
```

## Coordination sauvegarde IBM i et Linux

### Scenario : sauvegarde coordonnee

```
Timeline nocturne coordonnee :

20:00 - Linux : Snapshot LVM des bases de donnees
20:15 - Linux : borgbackup des applications
21:00 - Linux : Sauvegarde terminee, notification
21:00 - IBM i : STRMNTBRM (maintenance BRMS)
21:30 - IBM i : STRBKUBRM CTLGRP(QUOTIDIEN)
23:00 - IBM i : Sauvegarde terminee, notification
23:00 - Linux : rsync des sauvegardes vers stockage distant
23:30 - IBM i : MOVMEDBRM (si jour de deplacement)
00:00 - Verification croisee des deux plateformes
```

### Script de coordination (Linux → IBM i)
```bash
#!/bin/bash
# Script Linux : coordonner avec IBM i via SSH
# Prerequis : cle SSH configuree vers IBM i

IBMI_HOST="ibmi-prod.entreprise.fr"
IBMI_USER="QSECOFR"

# 1. Sauvegarde Linux
echo "$(date) - Debut sauvegarde Linux"
borgbackup create /backup/repo::$(date +%Y%m%d) /app /data
BKU_RC=$?

if [ $BKU_RC -eq 0 ]; then
    echo "$(date) - Sauvegarde Linux OK, lancement IBM i"
    # 2. Declencher sauvegarde IBM i via SSH
    ssh ${IBMI_USER}@${IBMI_HOST} \
        "SBMJOB CMD(CALL PGM(BRMLIB/BRMORCH) PARM('*QUOT')) \
         JOB(BRMQUOT) JOBQ(QBATCH)"
else
    echo "$(date) - ERREUR sauvegarde Linux (rc=$BKU_RC)"
    # Envoyer alerte
    mail -s "ALERTE: Sauvegarde Linux echouee" admin@entreprise.fr <<< "Erreur borgbackup rc=$BKU_RC"
fi
```
