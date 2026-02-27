# Écrans 5250 et Sous-fichiers en RPG III

## Table des matières
1. [Fichiers DSPF - Principes](#fichiers-dspf)
2. [Déclaration en spécification F](#declaration-spec-f)
3. [Structure DDS d'un écran DSPF](#structure-dds)
4. [Instructions écran en RPG III](#instructions-ecran)
5. [Gestion des touches de fonction](#touches-fonction)
6. [Sous-fichiers (SFL)](#sous-fichiers)
7. [Pattern CRUD complet avec écran](#pattern-crud)
8. [Pattern sous-fichier complet](#pattern-sous-fichier)

---

## 1. Fichiers DSPF - Principes

Un **Display File** (DSPF) est un fichier d'affichage 5250 qui définit les écrans interactifs sur IBM i. Il contient un ou plusieurs **formats d'enregistrement** (record formats) qui décrivent la disposition des champs à l'écran.

**Caractéristiques** :
- Défini en DDS (Data Description Specifications) avec le type source DSPF
- Compilé avec la commande `CRTDSPF`
- Chaque format = un écran ou une partie d'écran
- Supporte les touches de fonction (CF/CA), couleurs, attributs d'affichage
- Peut contenir des sous-fichiers (SFL) pour les listes

---

## 2. Déclaration en spécification F

### Écran simple (lecture + écriture)
```
     FECRANCLICF  E                    WORKSTN
```
- **Nom** (col 7-14) : ECRANCLICF (nom du fichier DSPF)
- **Type** (col 15) : C (Combined = lecture + écriture)
- **Désignation** (col 16) : F (Full procedural)
- **Format** (col 19) : E (Externally described)
- **Device** (col 40-46) : WORKSTN

### Écran avec sous-fichier
```
     FECRANSFLCF  E                    WORKSTN
     F                                        KSFL1  SFL1CTL
```
- Ligne 1 : déclaration du fichier WORKSTN
- Ligne 2 : continuation avec **KSFILE** → associe le format SFL (SFL1) à son contrôle (SFL1CTL)
  - Col 54-59 : nom du format SFL
  - La suite : nom du format SFLCTL

**Syntaxe KSFILE en spec F continuation** :
```
     F                                        KSFL1  SFL1CTL
```
Positions :
- Col 7 : F (continuation)
- Col 54-59 : nom du format sous-fichier
- Après : nom du format contrôle

---

## 3. Structure DDS d'un écran DSPF

### Syntaxe DDS de base
```
     A          R FMT1                      CF03(03 'Quitter')
     A                                      CF06(06 'Créer')
     A                                      CF12(12 'Retour')
     A                                  1  2'Titre de l écran'
     A                                      DSPATR(HI)
     A            NOMCLI    R        B  5 10
     A            PRECLI    R        B  6 10
     A            TELCLI    R        B  7 10
```

**Éléments clés DDS** :
- **R** en col 17 : définit un format d'enregistrement
- **CF03/CA03** : touche de fonction (CF = renvoie données, CA = ne renvoie pas)
- **Ligne,Col** : position à l'écran (ex: 5 10 = ligne 5, colonne 10)
- **B** (col 38) : champ Both (entrée + sortie, modifiable)
- **O** (col 38) : champ Output only (affichage seul)
- **I** (col 38) : champ Input only (saisie seule)
- **R** après le nom : référence au fichier (prend la définition du PF)
- **DSPATR** : attribut d'affichage (HI=surbrillance, RI=inverse, UL=souligné)

### Couleurs DDS
```
     A                                      COLOR(GRN)
     A                                      COLOR(WHT)
     A                                      COLOR(RED)
     A                                      COLOR(YLW)
     A                                      COLOR(BLU)
     A                                      COLOR(PNK)
     A                                      COLOR(TRQ)
```

### Attributs conditionnels
```
     A  99                                  DSPATR(RI)
     A  99                                  COLOR(RED)
```
→ Si l'indicateur 99 est actif, le champ s'affiche en inverse rouge

### Exemple DSPF complet avec 3 formats

**Format 1 - Écran de saisie (recherche)** :
```
     A          R FMT1                      CF03(03 'Quitter')
     A                                      CF06(06 'Créer')
     A                                  1 30'GESTION SOLDATS'
     A                                      DSPATR(HI)
     A                                  3  2'Numéro :'
     A            IDSOL     R        B  3 12
     A                                 23  2'F3=Quitter'
     A                                      COLOR(BLU)
     A                                 23 15'F6=Créer'
     A                                      COLOR(BLU)
```

**Format 2 - Modification/Suppression** :
```
     A          R FMT2                      CF03(03 'Quitter')
     A                                      CF12(12 'Retour')
     A                                      CF13(13 'Modifier')
     A                                      CF23(23 'Supprimer')
     A                                  1 30'DETAIL SOLDAT'
     A            IDSOL     R        O  3 12
     A            NOMSOL    R        B  5 12
     A            PRESOL    R        B  6 12
     A            GRDSOL    R        B  7 12
```

**Format 3 - Création** :
```
     A          R FMT3                      CF03(03 'Quitter')
     A                                      CF06(06 'Valider')
     A                                      CF12(12 'Retour')
     A                                  1 30'CREATION SOLDAT'
     A            NOMSOL    R        B  5 12
     A            PRESOL    R        B  6 12
     A            GRDSOL    R        B  7 12
```

---

## 4. Instructions écran en RPG III

### EXFMT - Affichage + Lecture (le plus utilisé)
```
     C                     EXFMTFMT1
```
**Fonctionnement** : Fait un WRITE (affiche l'écran) suivi d'un READ (attend la saisie utilisateur). Équivalent à :
```
     C                     WRITEFMT1
     C                     READ FMT1
```

**Usage** : C'est l'instruction la plus courante pour les écrans interactifs. Le programme s'arrête et attend que l'utilisateur appuie sur Entrée ou une touche de fonction.

### WRITE - Affichage seul
```
     C                     WRITEFMT1
```
**Usage** : Affiche un format sans attendre de réponse. Utilisé pour :
- Afficher un en-tête avant un sous-fichier
- Écrire une ligne dans un sous-fichier
- Afficher un message sans attendre

### READ - Lecture seul
```
     C                     READ FMT1
```
**Usage** : Attend la saisie utilisateur sans réafficher l'écran. Utilisé après un WRITE séparé.

---

## 5. Gestion des touches de fonction

### Méthode 1 : Indicateurs numériques (01-24)

Dans le DDS :
```
     A                                      CF03(03 'Quitter')
     A                                      CF06(06 'Créer')
     A                                      CF12(12 'Retour')
```

Dans le RPG III :
```
     C                     EXFMTFMT1
     C   03                SETON                     LR
     C   03                RETRN
     C   06                EXSR CREER
     C   12                EXSR RETOUR
```

Les indicateurs 03, 06, 12 sont automatiquement positionnés par le DSPF quand l'utilisateur appuie sur la touche correspondante.

### Méthode 2 : Indicateurs lettres (*INKA-*INKY)

Dans le DDS :
```
     A                                      CA03(03 'Quitter')
     A                                      CA06(06 'Créer')
     A                                      CA12(12 'Retour')
```

Dans le RPG III :
```
     C                     EXFMTFMT1
     C           *INKC     IFEQ '1'
     C* F3 = Quitter
     C                     SETON                     LR
     C                     RETRN
     C                     ENDIF
     C           *INKF     IFEQ '1'
     C* F6 = Créer
     C                     EXSR CREER
     C                     ENDIF
```

### Table des indicateurs lettres
| Indicateur | Touche | Indicateur | Touche |
|-----------|--------|-----------|--------|
| *INKA | F1 | *INKN | F14 |
| *INKB | F2 | *INKP | F15 |
| *INKC | F3 | *INKQ | F16 |
| *INKD | F4 | *INKR | F17 |
| *INKE | F5 | *INKS | F18 |
| *INKF | F6 | *INKT | F19 |
| *INKG | F7 | *INKU | F20 |
| *INKH | F8 | *INKV | F21 |
| *INKI | F9 | *INKW | F22 |
| *INKJ | F10 | *INKX | F23 |
| *INKK | F11 | *INKY | F24 |
| *INKL | F12 | | |
| *INKM | F13 | | |

---

## 6. Sous-fichiers (SFL)

### Principe

Un sous-fichier affiche une **liste** d'enregistrements à l'écran sous forme de tableau scrollable. Il se compose de :
- **Format SFL** : définit une ligne du sous-fichier
- **Format SFLCTL** : contrôle l'affichage du sous-fichier (en-tête, pagination)

### Structure DDS sous-fichier

**Format SFL (une ligne)** :
```
     A          R SFL1                      SFL
     A            OPT       1A  B  8  2
     A            NUMCLI    R     O  8  5
     A            NOMCLI    R     O  8 12
     A            PRECLI    R     O  8 30
```

**Format SFLCTL (contrôle)** :
```
     A          R SFL1CTL                   SFLCTL(SFL1)
     A                                      SFLSIZ(0015)
     A                                      SFLPAG(0014)
     A  31                                  SFLDSP
     A  32                                  SFLDSPCTL
     A  33                                  SFLCLR
     A  30                                  SFLEND
     A                                      CF03(03 'Quitter')
     A                                  1 30'LISTE DES CLIENTS'
     A                                  6  2'Opt'
     A                                  6  5'Numéro'
     A                                  6 12'Nom'
     A                                  6 30'Prénom'
```

**Mots-clés SFL essentiels** :
| Mot-clé | Rôle | Indicateur type |
|---------|------|-----------------|
| SFL | Marque le format comme sous-fichier | - |
| SFLCTL(SFL1) | Associe le contrôle au SFL | - |
| SFLSIZ(0015) | Nombre total de lignes en mémoire | - |
| SFLPAG(0014) | Nombre de lignes affichées par page | - |
| SFLDSP | Affiche le sous-fichier | 31 |
| SFLDSPCTL | Affiche le contrôle (en-tête) | 32 |
| SFLCLR | Vide le sous-fichier | 33 |
| SFLEND | Affiche "Fin" ou "+" en bas | 30 |

### Gestion des indicateurs sous-fichier en RPG III

**Initialisation (vider le SFL)** :
```
     C                     SETON                     33
     C                     WRITESFL1CTL
     C                     SETOF                     33
```
- Indicateur 33 ON → SFLCLR actif → vide le sous-fichier
- WRITE du contrôle effectue le nettoyage
- Indicateur 33 OFF → désactive SFLCLR

**Chargement du SFL** :
```
     C                     Z-ADD0        RRN    40
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C                     ADD  1        RRN
     C                     WRITESFL1
     C                     READ CLIENT                   90
     C                     ENDDO
```
- RRN = Relative Record Number (numéro de ligne dans le SFL)
- Chaque WRITE SFL1 ajoute une ligne au sous-fichier

**Affichage du SFL** :
```
     C           RRN       IFGT 0
     C                     SETON                     3031
     C                     ELSE
     C                     SETOF                     31
     C                     SETON                     30
     C                     ENDIF
     C                     SETON                     32
     C                     WRITESFL1CTL
     C                     READ SFL1CTL
```
- Si RRN > 0 (il y a des données) : activer 30 (SFLEND) et 31 (SFLDSP)
- Sinon : désactiver 31 (pas d'affichage SFL)
- Toujours activer 32 (SFLDSPCTL) pour l'en-tête
- WRITE + READ du contrôle affiche et attend

**Lecture des modifications (READC)** :
```
     C                     READCSFL1                     90
     C           *IN90     DOWEQ'0'
     C* Traiter la ligne modifiée par l'utilisateur
     C           OPT       IFEQ '2'
     C* Option 2 = Modifier
     C                     EXSR MODIF
     C                     ENDIF
     C           OPT       IFEQ '4'
     C* Option 4 = Supprimer
     C                     EXSR SUPPR
     C                     ENDIF
     C                     READCSFL1                     90
     C                     ENDDO
```

---

## 7. Pattern CRUD complet avec écran

Basé sur le programme psoldat.rpg - Gestion de soldats avec 3 formats d'écran.

```
     FSOLDAT  UF  E           K        DISK                    A
     FESOLDAT CF  E                    WORKSTN
     C* ============================================
     C* BOUCLE PRINCIPALE
     C* ============================================
     C           *INKC     DOWEQ'0'
     C                     EXFMTFMT1
     C* F3 = Quitter
     C           *INKC     IFEQ '1'
     C                     LEAVE
     C                     ENDIF
     C* F6 = Créer nouveau
     C           *INKF     IFEQ '1'
     C                     EXSR CREER
     C                     ELSE
     C* Recherche par ID
     C           IDSOL     CHAINSOLDAT                   90
     C           *IN90     IFEQ '0'
     C* Trouvé → afficher détail
     C                     EXSR DETAIL
     C                     ELSE
     C* Non trouvé → message erreur
     C                     ENDIF
     C                     ENDIF
     C                     ENDDO
     C                     SETON                     LR
     C* ============================================
     C* SOUS-PROGRAMME : AFFICHER DETAIL (FMT2)
     C* ============================================
     C           DETAIL    BEGSR
     C                     EXFMTFMT2
     C* F13 = Modifier
     C           *INKM     IFEQ '1'
     C                     UPDATSOLDF
     C                     ENDIF
     C* F23 = Supprimer
     C           *INKX     IFEQ '1'
     C                     DELETSOLDF
     C                     ENDIF
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : CREATION (FMT3)
     C* ============================================
     C           CREER     BEGSR
     C                     EXFMTFMT3
     C* F6 = Valider la création
     C           *INKF     IFEQ '1'
     C* Auto-incrémenter l'ID
     C           *HIVAL    SETLLSOLDAT
     C                     READPSOLDAT                   91
     C           *IN91     IFEQ '0'
     C                     ADD  1        IDSOL
     C                     ELSE
     C                     Z-ADD1        IDSOL
     C                     ENDIF
     C                     WRITESOLDF
     C                     ENDIF
     C                     ENDSR
```

---

## 8. Pattern sous-fichier complet

Basé sur le programme arm400.rpg - Liste avec sous-fichier.

```
     FCLIENT  UF  E           K        DISK                    A
     FECRANSFLCF  E                    WORKSTN
     F                                        KSFL1  SFL1CTL
     C* ============================================
     C* CHARGEMENT DU SOUS-FICHIER
     C* ============================================
     C                     EXSR CHARGE
     C* ============================================
     C* BOUCLE PRINCIPALE
     C* ============================================
     C   03      DOWEQ*OFF
     C* Afficher le SFL
     C           RRN       IFGT 0
     C                     SETON                     3031
     C                     ELSE
     C                     SETOF                     31
     C                     SETON                     30
     C                     ENDIF
     C                     SETON                     32
     C                     WRITESFL1CTL
     C                     READ SFL1CTL
     C* Vérifier F3
     C   03                LEAVE
     C* Traiter les options
     C                     EXSR TRAOPT
     C* Recharger le SFL
     C                     EXSR CHARGE
     C                     ENDDO
     C                     SETON                     LR
     C* ============================================
     C* SOUS-PROGRAMME : CHARGER LE SFL
     C* ============================================
     C           CHARGE    BEGSR
     C* Vider le SFL
     C                     SETON                     33
     C                     WRITESFL1CTL
     C                     SETOF                     33
     C* Remplir le SFL
     C                     Z-ADD0        RRN    40
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C                     ADD  1        RRN
     C                     MOVEL*BLANKS  OPT
     C                     WRITESFL1
     C                     READ CLIENT                   90
     C                     ENDDO
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : TRAITER LES OPTIONS
     C* ============================================
     C           TRAOPT    BEGSR
     C                     READCSFL1                     90
     C           *IN90     DOWEQ'0'
     C           OPT       IFEQ '2'
     C* Option 2 = Modifier
     C                     EXSR MODIF
     C                     ENDIF
     C           OPT       IFEQ '4'
     C* Option 4 = Supprimer
     C           NUMCLI    CHAINCLIENT                   91
     C           *IN91     IFEQ '0'
     C                     DELETCLIENTF
     C                     ENDIF
     C                     ENDIF
     C                     READCSFL1                     90
     C                     ENDDO
     C                     ENDSR
```

---

## Résumé des opérations écran

| Opération | Rôle | Usage |
|-----------|------|-------|
| EXFMT format | WRITE + READ (affiche et attend) | Écrans interactifs |
| WRITE format | Affiche sans attendre | En-têtes, lignes SFL |
| READ format | Attend saisie sans réafficher | Après WRITE séparé |
| READC formatSFL | Lit les lignes modifiées du SFL | Traitement des options |

## Compilation

**DSPF** :
```
CRTDSPF FILE(BIBLIO/ECRAN) SRCFILE(BIBLIO/QDDSSRC)
```

**Programme RPG III avec écran** :
```
CRTRPGPGM PGM(BIBLIO/PROG) SRCFILE(BIBLIO/QRPGSRC)
```
