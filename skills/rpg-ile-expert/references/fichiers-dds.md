# Fichiers DDS : PF, LF et DSPF

Guide de création des fichiers physiques, logiques et écrans sur IBM i.

## Fichier Physique (PF)

Le fichier physique contient les données. C'est l'équivalent d'une table SQL.

### Structure de base

```dds
                R RACEFMT
                  NORACE         4  0       COLHDG('N°')
                  DTRACE          L         COLHDG('DATE')
                  TPRACE         3          COLHDG('TYPE COURSE')
                  NMRACE        30          COLHDG('NOM COURSE')
                  GRRACE         1          COLHDG('ROUTE/TT')
                  DSRACE         3S 0       COLHDG('DISTANCE')
                  T1RACE          T         COLHDG('RÉSULTAT')
                  P3RACE         4S 0       COLHDG('POSITION')
                  AVRACE         4S 2       COLHDG('MOYENNE')
                  FORME          3
                  VAINQUEUR     10
                K NORACE
```

### Types de données

| Code | Type | Exemple | Description |
|------|------|---------|-------------|
| `A` ou rien | Caractère | `NOM 30` | Alphanumérique |
| `S` | Zoned | `4S 0` | Numérique zoné |
| `P` | Packed | `7P 2` | Numérique packé |
| `B` | Binaire | `4B 0` | Binaire |
| `L` | Date | `DTRACE L` | Date |
| `T` | Heure | `T1RACE T` | Heure |
| `Z` | Timestamp | `TSTAMP Z` | Horodatage |

### Mots-clés PF

```dds
                  NORACE    4S 0  COLHDG('Numéro')
                                  TEXT('Numéro de course')
                                  EDTCDE(Z)
                  
                  DTRACE     L    DATFMT(*ISO)
                  
                  MONTANT   9P 2  EDTCDE(1)
                  
                  CODE      10    DFT('DEFAUT')
                                  VALUES('VAL1' 'VAL2' 'VAL3')
```

## Fichier Logique (LF)

Le fichier logique définit une vue sur un fichier physique avec une clé d'accès.

### LF simple avec clé

```dds
                R RACEFMT                   PFILE(RACEP)
                K NORACE
```

### LF avec clé composite

```dds
                R RACEFMT                   PFILE(RACEP)
                K TPRACE
                K DTRACE
                K NORACE
```

### LF avec sélection

```dds
                R RACEFMT                   PFILE(RACEP)
                S TPRACE                    COMP(EQ 'MAR')
                K DTRACE
```

### LF avec tri descendant

```dds
                R RACEFMT                   PFILE(RACEP)
                K DTRACE                    DESCEND
```

### LF sans doublons (UNIQUE)

```dds
                                            UNIQUE
                R RACEFMT                   PFILE(RACEP)
                K TPRACE
```

## Fichier Écran (DSPF)

### Structure générale

```dds
     A                                      DSPSIZ(24 80 *DS3)
     A                                      REF(MABIB/MONPF)
     A                                      INDARA
     A                                      HELP
     A                                      ALTHELP(CA01)
```

### Format d'enregistrement simple

```dds
     A          R FMT1
     A                                      CA03(03)
     A                                      CA12(12)
     A                                  1 30'Mon Application'
     A                                      COLOR(WHT)
     A                                  1  2USER
     A                                      COLOR(BLU)
     A                                  1 73DATE
     A                                      EDTCDE(Y)
     A            ZONE1         10A  B  5 20
     A            ZONE2     R        B  6 20REFFLD(FICHIER/CHAMP)
```

### Positions des zones

```
     A            NOMZONE      10A  B  5 20
                  │            │   │  │  │
                  │            │   │  │  └─ Colonne (1-80)
                  │            │   │  └──── Ligne (1-24)
                  │            │   └─────── B=Input/Output, I=Input, O=Output, H=Hidden
                  │            └─────────── Type et longueur
                  └──────────────────────── Nom de la zone
```

### Types de zones

| Code | Description |
|------|-------------|
| `B` | Input/Output (saisie et affichage) |
| `I` | Input only (saisie uniquement) |
| `O` | Output only (affichage uniquement) |
| `H` | Hidden (caché) |

### Couleurs

```dds
     A                                  5 10'Texte'
     A                                      COLOR(WHT)   Blanc
     A                                      COLOR(GRN)   Vert
     A                                      COLOR(BLU)   Bleu
     A                                      COLOR(RED)   Rouge
     A                                      COLOR(YLW)   Jaune
     A                                      COLOR(TRQ)   Turquoise
     A                                      COLOR(PNK)   Rose
```

### Attributs d'affichage

```dds
     A                                      DSPATR(HI)   Haute intensité
     A                                      DSPATR(UL)   Souligné
     A                                      DSPATR(RI)   Vidéo inverse
     A                                      DSPATR(BL)   Clignotant
     A                                      DSPATR(PC)   Curseur positionné
```

### Touches de fonction

```dds
     A          R FMT1
     A                                      CA03(03)      F3 active IN03
     A                                      CA12(12)      F12 active IN12
     A                                      CF23(23)      F23 avec données
     A                                      ROLLUP(39)    Page Down
     A                                      ROLLDOWN(38)  Page Up
```

### Référence à un fichier physique

```dds
     A                                      REF(MABIB/MONPF)
     A          R FMT1
     A            EZONE     R        B  5 20REFFLD(MONPF/CHAMPF)
```

## Sous-fichier (SFL)

### Format SFL (lignes du sous-fichier)

```dds
     A          R SFL1                      SFL
     A            OPT            1A  I  7  2
     A            ENORACE   R        O  7  4REFFLD(RACEFMT/NORACE)
     A            EDTRACE   R        O  7  9REFFLD(RACEFMT/DTRACE)
     A            ENMRACE   R        O  7 21REFFLD(RACEFMT/NMRACE)
     A  70                                  COLOR(RED)
     A  71                                  COLOR(WHT)
```

### Format CTL (contrôle du sous-fichier)

```dds
     A          R CTL1                      SFLCTL(SFL1)
     A                                      CA03(03)
     A                                      CA06(06)
     A N90                                  ROLLUP(39)
     A                                      OVERLAY
     A                                      SFLCSRRRN(&SFLRRN)
     A  32                                  SFLDSP
     A N31                                  SFLDSPCTL
     A  31                                  SFLCLR
     A  90                                  SFLEND(*MORE)
     A                                      SFLSIZ(0015)
     A                                      SFLPAG(0014)
     A            SFLRRN         5S 0H
     A            RRN1           4S 0H      SFLRCDNBR
```

### Mots-clés SFL

| Mot-clé | Description |
|---------|-------------|
| `SFL` | Déclare un format sous-fichier |
| `SFLCTL(nom)` | Format de contrôle du SFL |
| `SFLSIZ(n)` | Taille totale du SFL |
| `SFLPAG(n)` | Lignes par page |
| `SFLDSP` | Afficher le SFL (conditionné) |
| `SFLDSPCTL` | Afficher le contrôle |
| `SFLCLR` | Vider le SFL |
| `SFLEND` | Indicateur fin de fichier |
| `SFLRCDNBR` | Numéro d'enregistrement à afficher |
| `SFLCSRRRN` | RRN où se trouve le curseur |
| `SFLNXTCHG` | Forcer modification pour READC |
| `ROLLUP` | Activer Page Down |

## Fenêtres (WINDOW)

```dds
     A          R FMTFEN
     A                                      WINDOW(*DFT 10 50)
     A                                      CA03(03)
     A                                      CA12(12)
     A                                      WDWBORDER((*COLOR WHT) (*CHAR '<->!-
     A                                      !<->'))
     A                                      WDWTITLE((*TEXT 'Ma Fenêtre') (*C-
     A                                      OLOR WHT))
     A            ZONE1         20A  B  3  5
```

### Sous-fichier dans une fenêtre

```dds
     A          R SF2CTL                    SFLCTL(SFL2)
     A                                      WINDOW(4 5 17 40 *NOMSGLIN *NORSTCSR)
     A                                      WDWBORDER((*COLOR BLU) (*DSPATR RI))
     A                                      WDWTITLE((*TEXT 'Sélection') (*COLOR WHT))
     A                                      WDWTITLE((*TEXT 'F12=Retour') *BOTTOM)
     A                                      RMVWDW
```

## Messages d'erreur

### Dans le DSPF

```dds
     A            EZONE     R        B  5 20REFFLD(FICHIER/CHAMP)
     A  57                                  ERRMSGID(RAC0057 *LIBL/RACEMSG)
```

### Avec COMP (validation)

```dds
     A            ENOM          30A  B 10 20
     A                                      COMP(NE ' ')
     A  75                                  ERRMSGID(ERR0001 *LIBL/MSGF 75)
```

### Ligne de message

```dds
     A  58  LIGNEMSG      80   M
```

## Format ASSUME

Format jamais affiché, utilisé pour éviter les problèmes d'affichage initial.

```dds
     A          R FANTOME
     A                                      ASSUME
     A                                  1  3' '
```

## Aide en ligne (HLPPNLGRP)

```dds
     A                                      HLPTITLE('Aide du programme')
     A          H                           HLPPNLGRP(GENERAL MONHLP)
     A                                      HLPARA(01 001 02 024)
     A          H                           HLPPNLGRP(ZONE1 MONHLP)
     A                                      HLPARA(05 020 05 040)
```

## Déclaration en RPG

### Fichier avec options multiples

```rpgle
dcl-f RACEL1 disk usage(*update : *delete : *output)
                  infds(FichierDS)
                  recno(rang)
                  keyed
                  usropn;
```

### Mots-clés DCL-F

| Mot-clé | Description |
|---------|-------------|
| `disk` | Fichier base de données |
| `workstn` | Fichier écran |
| `printer` | Fichier d'impression |
| `keyed` | Accès par clé |
| `usage(...)` | *input, *output, *update, *delete |
| `usropn` | Ouverture manuelle |
| `infds(ds)` | DS d'information fichier |
| `recno(var)` | Variable de numéro relatif |
| `rename(old:new)` | Renommer le format |
| `prefix(p_)` | Préfixer les zones |
| `alias` | Utiliser les noms longs |
| `sfile(sfl:rrn)` | Déclarer un sous-fichier |
```

## Compilation

### Fichier physique

```cl
CRTPF FILE(MABIB/MONPF) SRCFILE(MABIB/QDDSSRC)
```

### Fichier logique

```cl
CRTLF FILE(MABIB/MONLF) SRCFILE(MABIB/QDDSSRC)
```

### Fichier écran

```cl
CRTDSPF FILE(MABIB/MONDSPF) SRCFILE(MABIB/QDDSSRC)
```

### Programme RPG

```cl
CRTSQLRPGI OBJ(MABIB/MONPGM) SRCFILE(MABIB/QRPGLESRC)
           COMMIT(*NONE) DBGVIEW(*SOURCE)
```
