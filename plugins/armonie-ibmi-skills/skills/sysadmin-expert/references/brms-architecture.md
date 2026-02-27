# BRMS - Architecture et Concepts Fondamentaux

## Qu'est-ce que BRMS ?

BRMS (Backup Recovery and Media Services) est le produit IBM sous licence (5770-BR1) qui fournit une solution integree de sauvegarde, restauration et gestion des medias pour IBM i. Il remplace et depasse les commandes SAV/RST classiques en apportant automatisation, traçabilite et planification.

## Pourquoi BRMS plutot que SAV/RST classiques ?

| Aspect | SAV/RST classique | BRMS |
|--------|-------------------|------|
| Planification | Manuelle (WRKJOBSCDE) | Calendrier integre |
| Gestion medias | Manuelle (INZTAP, suivi papier) | Automatique (rotation, expiration) |
| Traçabilite | Limitee (logs manuels) | Historique complet |
| Restauration | Manuelle (identifier media + commande) | Assistee (STRRCYBRM) |
| Rapport PRA | A creer manuellement | STRRCYBRM OPTION(*REPORT) |
| Incrementale | SAVCHGOBJ (limitee) | Politiques *CUML et *INCR |
| Complexite | Simple mais laborieux | Plus complexe mais puissant |

## Architecture BRMS

### Les 4 piliers de BRMS

```
BRMS
├── 1. POLITIQUES (Policies)
│   ├── Politique de sauvegarde (Backup Policy)
│   │   └── Definit QUOI sauvegarder et COMMENT
│   ├── Politique de media (Media Policy)
│   │   └── Definit la RETENTION et la ROTATION
│   └── Politique de deplacement (Move Policy)
│       └── Definit le deplacement HORS-SITE
│
├── 2. GROUPES DE CONTROLE (Control Groups)
│   ├── Groupe de sauvegarde
│   │   └── Orchestre une sequence de sauvegardes
│   └── Groupe d'archivage
│       └── Pour l'archivage long terme
│
├── 3. MEDIAS (Media Management)
│   ├── Bibliotheques de medias (Media Libraries)
│   ├── Inventaire des volumes
│   ├── Inscription / Expiration
│   └── Localisation (sur site / hors site)
│
└── 4. RECUPERATION (Recovery)
    ├── Rapport de recuperation
    ├── Procedure de restauration assistee
    └── Tests de restauration
```

### Objets BRMS dans QUSRBRM

BRMS stocke toutes ses donnees dans la bibliotheque **QUSRBRM**. Cette bibliotheque contient :

- **Q1A*** — Fichiers de politique de sauvegarde
- **Q1AMEDI*** — Inventaire des medias
- **Q1ACTLG*** — Informations des groupes de controle
- **Q1ANET*** — Configuration reseau BRMS
- **Q1ASYS*** — Configuration systeme BRMS
- **Q1ACAL*** — Calendrier BRMS

**ATTENTION** : Ne JAMAIS modifier directement les fichiers de QUSRBRM. Utiliser uniquement les commandes BRMS.

## Installation et initialisation

### Prerequis
```
-- Verifier si BRMS est installe
DSPPTF LICPGM(5770BR1)

-- Si pas installe, restaurer depuis le media d'installation
RSTLICPGM LICPGM(5770BR1) DEV(OPT01)
```

### Premiere initialisation
```
-- Initialiser BRMS (a faire UNE SEULE FOIS)
INZBRM

-- Configurer les valeurs systeme BRMS
GO BRMS
-- Option 1 : Politiques de sauvegarde
-- Option 2 : Groupes de controle
-- Option 3 : Medias
-- Option 8 : Configuration
```

### Configuration initiale recommandee

1. **Inscrire les medias** — Ajouter tous les volumes de bandes ou SAVF
2. **Creer les politiques** — Au minimum une politique de sauvegarde et une politique de medias
3. **Configurer la maintenance** — Planifier STRMNTBRM en quotidien
4. **Creer les groupes de controle** — Organiser les sauvegardes par type
5. **Tester** — Lancer une sauvegarde de test et verifier le rapport de recuperation

## La maintenance BRMS : STRMNTBRM

**CRITICAL** : STRMNTBRM est LA commande la plus importante de BRMS. Elle DOIT etre lancee quotidiennement.

### Ce que fait STRMNTBRM

1. Met a jour l'historique des sauvegardes
2. Expire les medias selon les politiques de retention
3. Met a jour les informations de localisation des medias
4. Nettoie les entrees obsoletes
5. Synchronise les informations reseau (si multi-systeme)

### Planification recommandee
```
-- Soumettre STRMNTBRM quotidiennement via WRKJOBSCDE
ADDJOBSCDE JOB(BRMMAINT)
              CMD(STRMNTBRM)
              FRQ(*WEEKLY)
              SCDDAY(*ALL)
              SCDTIME('230000')
              JOBQ(QBATCH)
              USER(QSECOFR)
```

### Verification de la maintenance
```
-- Verifier le joblog du dernier STRMNTBRM
WRKJOB JOB(BRMMAINT) OPTION(*JOBLOG)

-- Verifier la date de derniere maintenance
WRKPCYBRM TYPE(*MED)
-- La date de derniere expiration est affichee
```

## Flux de travail BRMS typique

```
Quotidien :
1. STRMNTBRM (maintenance)
2. STRBKUBRM CTLGRP(QUOTIDIEN) (sauvegarde quotidienne)
3. Verifier les resultats dans DSPLOG / DSPJOBLOG

Hebdomadaire :
1. STRBKUBRM CTLGRP(HEBDO) (sauvegarde hebdomadaire)
2. MOVMEDBRM (deplacement medias hors-site)
3. Verification rapport de recuperation

Mensuel :
1. STRBKUBRM CTLGRP(MENSUEL) (sauvegarde complete)
2. STRRCYBRM OPTION(*REPORT) (rapport de recuperation)
3. Test de restauration partiel

Annuel :
1. SAVSYS complet via BRMS
2. Test de restauration complet
3. Revue des politiques de retention
```

## Integration avec les sauvegardes classiques

BRMS peut coexister avec les commandes SAV/RST classiques, mais il est recommande de centraliser :

- **Centraliser via BRMS** : Toutes les sauvegardes passent par BRMS pour la traçabilite
- **Mode mixte** : BRMS pour les sauvegardes planifiees, SAV/RST pour les operations ponctuelles
- **Migration** : Passer progressivement de SAV/RST pur vers BRMS

### Enregistrer une sauvegarde classique dans BRMS
Si une sauvegarde est faite via SAVLIB directement, BRMS peut la connaitre si le media est inscrit dans BRMS. La maintenance (STRMNTBRM) mettra a jour l'historique.

## Glossaire BRMS

| Terme | Definition |
|-------|-----------|
| **Politique (Policy)** | Ensemble de regles definissant comment sauvegarder et gerer les medias |
| **Groupe de controle (Control Group)** | Sequence ordonnee d'elements a sauvegarder avec leurs politiques |
| **Media** | Support physique ou logique de sauvegarde (bande, cartouche, SAVF, VTL) |
| **Bibliotheque de medias (Media Library)** | Peripherique robotise gerant plusieurs medias (3573, TS4300) |
| **Volume** | Identifiant unique d'un media (6 caracteres max) |
| **Retention** | Duree pendant laquelle un media ne peut pas etre reutilise |
| **Expiration** | Date a partir de laquelle un media peut etre reinitialise |
| **Deplacement (Move)** | Transfert d'un media vers un emplacement hors-site |
| **Rapport de recuperation** | Document listant toutes les etapes pour restaurer un systeme |
| **VTL (Virtual Tape Library)** | Bibliotheque de bandes virtuelle (disk-based) |
| **SAVF (Save File)** | Fichier de sauvegarde sur disque IBM i |
