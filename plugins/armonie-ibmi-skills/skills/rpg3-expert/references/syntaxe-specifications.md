# Syntaxe et Specifications RPG III (RPG/400)

Guide complet de la syntaxe positionnelle du RPG III sur IBM i.
Enrichi avec la documentation officielle IBM RPG/400 Help.

## Table des matieres

1. [Structure generale](#structure-generale)
2. [Specification H - Controle](#specification-h)
3. [Specification F - Fichiers](#specification-f)
4. [Specification E - Tableaux](#specification-e)
5. [Specification I - Entree et Data Structures](#specification-i)
6. [Specification C - Traitement](#specification-c)
7. [Specification O - Sortie](#specification-o)
8. [Indicateurs](#indicateurs)
9. [Conditions IFxx](#conditions-ifxx)
10. [Structure SELEC/WHxx](#selec-whxx)
11. [Boucles DOWxx/DOUxx/DO](#boucles)
12. [LEAVE et ITER](#leave-iter)
13. [GOTO et TAG](#goto-tag)
14. [Operateurs AND/OR](#operateurs-logiques)
15. [Instructions arithmetiques](#instructions-arithmetiques)
16. [Instructions de chaines](#instructions-chaines)
17. [CAT - Concatenation](#cat-concatenation)

---

## Structure generale

Le RPG III est un langage positionnel. Chaque ligne de code a une structure fixe basee sur les colonnes :

```
Col 1-5   : Numero de sequence (optionnel, gere par SEU)
Col 6     : Type de specification (H, F, E, L, I, C, O)
Col 7     : * = commentaire
Col 7-80  : Contenu selon le type de specification
```

**Ordre obligatoire des specifications** : H, F, E, L, I, C, O

Un commentaire est une ligne avec `*` en colonne 7 :
```
     * Ceci est un commentaire en RPG III
```

---

## Specification H

La specification H definit les parametres globaux du programme. Rarement utilisee en RPG/400 car ces parametres sont specifies lors de la compilation (CRTRPGPGM).

Positions importantes :
- Position 15 : Debug (1 = active DEBUG et DUMP)
- Position 18 : Symbole monetaire (vide = $)
- Position 19 : Format de date (M = MM/JJ/AA, D = JJ/MM/AA, Y = AA/MM/JJ)

---

## Specification F

Declare les fichiers utilises dans le programme. OBLIGATOIRE pour chaque fichier.

### Structure des colonnes

```
Col 6     : F
Col 7-14  : Nom du fichier (1 a 8 caracteres)
Col 15    : Type d'acces (I=Input, O=Output, U=Update, C=Combined)
Col 16    : Designation (F=Full procedural, P=Primary, S=Secondary, T=Table)
Col 17    : End of file (E=peut terminer avant fin)
Col 18    : Sequence
Col 19    : Format (E=Externe DDS, F=Programme)
Col 20-23 : (reservees, vides)
Col 24-27 : Longueur enregistrement (si format programme F)
Col 28-30 : (reservees)
Col 31    : Type de cle (K=Keyed externe, A=Alpha, P=Packed)
Col 40-46 : Device (DISK, WORKSTN, PRINTER, SEQ, SPECIAL)
Col 54-59 : Nom routine si SPECIAL
Col 66    : A = Addition (fichier en ajout si Update)
```

### Exemples de declarations de fichiers

```
     * Fichier DISK externe en lecture avec cle
     FCLIENT  IF  E           K        DISK
     * Fichier DISK externe en lecture et mise a jour avec cle
     FCLIENT  UF  E           K        DISK
     * Fichier DISK externe en lecture, MAJ et ajout
     FCLIENT  UF  E           K        DISK                      A
     * Fichier ecran (WORKSTN) - Combined, Full procedural, Externe
     FECRANCLICF  E                    WORKSTN
     * Fichier ecran avec sous-fichier (KSFILE)
     FEAS400  CF  E                    WORKSTN
     F                                        LIGNE KSFILE SFL1
     * Fichier imprimante
     FIMPRICLIO   E             25     PRINTER
```

### Regles cles

- En RPG III, utiliser **F** (Full Procedural) en position 16 : le fichier est controle par le programme.
- Pour un fichier ecran (WORKSTN), le type est **C** (Combined) car il lit et ecrit.
- **K** en position 31 signifie acces par cle pour les fichiers externes (DDS).
- **A** en position 66 autorise l'ajout de nouveaux enregistrements sur un fichier en Update.

---

## Specification E

Declare les tableaux (arrays) et tables. Trois modes de chargement :

### Tableau charge a la compilation
Les donnees sont en fin de source apres `**`.
```
     E                    MSG     1   5 70
     E                    FM     12  12  2
```
- `MSG` : nom du tableau, 1 tableau par enregistrement source, 5 postes, 70 caracteres chacun
- `FM` : 12 postes par enregistrement, 12 postes total, 2 decimales (numerique)

### Tableau charge a l'execution
```
     E                    TBC         2 10
```
- `TBC` : 2 postes, 10 caracteres chacun, charge dynamiquement pendant l'execution

### Tableau charge avant execution (lie a un fichier)
```
     E                    TVA        10  4 2
```
- `TVA` : 10 postes, 4 caracteres, 2 decimales

### Donnees de compilation (fin de source)
```
** MSG
Le nom est obligatoire
Le cp est obligatoire
La ville est obligatoire
Le mobile est obligatoire
** FM
312831303130313130313031
```

---

## Specification I

Definit les structures de donnees (Data Structures) et les buffers d'entree.

### Data Structure
```
     IDARINV      DS
     I                                        1   4 AA
     I                                        5   6 MM
     I                                        7   8 JJ
```
- `DARINV` : nom de la data structure
- `DS` : mot-cle Data Structure
- Sous-champs definis par positions (debut-fin) et nom

---

## Specification C

Coeur du programme. Contient toutes les instructions de traitement.

### Structure des colonnes

```
Col 6     : C
Col 7-8   : Indicateur de controle de niveau (L1-L9, LR, SR)
Col 9-17  : Indicateurs de condition (3 indicateurs de 2 positions, prefixe N pour negatif)
             Col 9-11  : Indicateur 1 (ex: 90, N90)
             Col 12-14 : Indicateur 2
             Col 15-17 : Indicateur 3
Col 18-27 : Factor 1
Col 28-32 : Code operation (ADD, SUB, IFEQ, READ, CHAIN, SETON, etc.)
Col 33-42 : Factor 2
Col 43-48 : Zone resultat (Result Field)
Col 49-51 : Longueur zone resultat
Col 52    : Nombre de decimales
Col 53    : H = half-adjust (arrondi), P = padding, N = no lock
Col 54-55 : Indicateur Hi (positif) / NR (non trouve)
Col 56-57 : Indicateur Lo (negatif) / ER (erreur)
Col 58-59 : Indicateur Eq (egal/zero/fin de fichier)
Col 60-74 : Commentaires
```

---

## Indicateurs

Les indicateurs sont des booleens (0 ou 1) numerotes de 01 a 99 plus des indicateurs speciaux.

### Indicateurs generaux (01-99)
```
     * Activer l'indicateur 10
     C                     SETON                     10
     * Activer les indicateurs 10 ET 14
     C                     SETON                     10  14
     * Desactiver les indicateurs 05, 07, 88
     C                     SETOF                     050788
```

### Indicateurs speciaux
- **LR** : Last Record - fin du programme
- **1P** : First Page - premiere page
- **OF** : Overflow - debordement impression
- **MR** : Match Record
- **L1-L9** : Niveaux de rupture

### Indicateurs de touches de fonction (*INKA a *INKY)
```
Indicateur  Touche     Indicateur  Touche
*INKA       F1         *INKN       F14
*INKB       F2         *INKP       F15
*INKC       F3         *INKQ       F16
*INKD       F4         *INKR       F17
*INKE       F5         *INKS       F18
*INKF       F6         *INKT       F19
*INKG       F7         *INKU       F20
*INKH       F8         *INKV       F21
*INKI       F9         *INKW       F22
*INKJ       F10        *INKX       F23
*INKK       F11        *INKY       F24
*INKL       F12
*INKM       F13
```

### Manipulation des indicateurs comme variables
```
     * Tester un indicateur avec IF
     C           *IN62     IFEQ '1'
     C                     EXSR EGAL
     C                     ENDIF
     * Affecter un indicateur directement
     C                     MOVE '1'       *IN99
     C                     MOVE '0'       *INKD
     C                     MOVE *ON       *IN25
     C                     MOVE *OFF      *IN03
     * Manipuler un bloc d'indicateurs avec MOVEA
     C                     MOVEA'0000'    *IN,30
     C                     MOVEA*ZEROS    *IN
```

### Conditionner une instruction avec un indicateur
```
     * L'instruction ne s'execute que si l'indicateur 03 est actif
     C   03                LEAVE
     * L'instruction s'execute si l'indicateur 90 est a 0 (N = negatif)
     C  N90                DSPLY
```

---

## Conditions IFxx

L'instruction IFxx teste une relation entre Factor 1 et Factor 2.

### Syntaxe officielle IBM
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| IFXX    | Comparand     | Comparand       |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

### Suffixes de comparaison
| Code | Signification |
|------|---------------|
| IFEQ | Egal a |
| IFNE | Different de |
| IFLT | Inferieur a |
| IFLE | Inferieur ou egal a |
| IFGT | Superieur a |
| IFGE | Superieur ou egal a |

### Exemples (doc IBM)
```
     C* IF simple avec ENDIF
     C           FLDA      IFEQ FLDB                          IF EQUAL
     C           :
     C                     ENDIF

     C* IF avec ELSE
     C           FLDA      IFEQ FLDB                          IF EQUAL
     C           :
     C                     ELSE                                IF NOT EQUAL
     C           :
     C                     ENDIF

     C* IF avec conditions combinées ANDxx et ORxx
     C           FLDA      IFEQ FLDB
     C           FLDA      ANDGTFLDC
     C           FLDD      OREQ FLDE
     C           FLDD      ANDGTFLDF
     C           :
     C                     ENDIF
```
→ Exécuté si (FLDA = FLDB ET FLDA > FLDC) OU (FLDD = FLDE ET FLDD > FLDF)

### Regles
- Factor 1 et Factor 2 doivent etre de meme type (tous deux numeriques ou tous deux alpha).
- Toujours terminer par ENDIF.
- ELSE est optionnel.
- Les indicateurs de condition sur ENDIF doivent etre vides.
- Possibilite d'indenter les IF/ELSE pour la lisibilite.

---

## SELEC/WHxx

Structure de selection multiple (equivalent d'un CASE ou switch).

### Syntaxe officielle IBM
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| SELEC   |               |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
| WHXX    | Comparand     | Comparand       |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

### Structure complete
```
     C                     SELEC
     C           X         WHEQ 1
     C                     Z-ADDA        B
     C                     MOVE C        D
     C           Y         WHEQ 2
     C           X         ANDLT10
     C           :                                            seq 2
     C                     OTHER
     C           :                                            seq 3
     C                     ENDSL
```

### Regles (doc IBM)
- Apres SELEC, le controle passe au premier WHxx dont la condition est vraie
- **Une seule** branche WHxx s'execute (la premiere qui correspond)
- WHxx peut etre suivi de ANDxx et ORxx pour des conditions complexes
- Un groupe WHxx peut etre **vide** (aucune instruction entre deux WHxx)
- OTHER est optionnel (cas par defaut si aucun WHxx ne correspond)
- ENDSL termine le groupe SELEC
- Les groupes SELEC peuvent etre **imbriques**
- Pas d'indicateurs de condition autorises sur WHxx dans les total calculations

### Exemple imbrique (doc IBM)
```
     C                     SELEC
     C           EMPTYP    WHEQ 'C'
     C           EMPTYP    OREQ 'T'
     C                     Z-ADD0        DAYS
     C           EMPTYP    WHEQ 'R'
     C                     Z-ADD14       DAYS
     C* SELEC imbriqué pour les années d'ancienneté
     C                     SELEC
     C           YEARS     WHLT 2
     C           YEARS     WHLE 5
     C                     ADD  5        DAYS
     C           YEARS     WHLE 10
     C                     ADD  10       DAYS
     C                     OTHER
     C                     ADD  20       DAYS
     C                     ENDSL
     C* Fin du SELEC imbriqué
     C           EMPTYP    WHEQ 'S'
     C                     Z-ADD5        DAYS
     C                     ENDSL
```

### Exemple complexe avec CHAIN et gestion CRUD (doc IBM)
```
     C           RSCDE     CHAINFILE                      50
     C                     SELEC
     C           *INKC     WHEQ *ON
     C                     EXSR QUIT
     C           ACODE     WHEQ 'A'
     C           *IN50     ANDEQ*ON
     C                     WRITEREC
     C           ACODE     WHEQ 'A'
     C           *IN50     ANDEQ*OFF
     C           ACREC     ANDEQ'D'
     C           ACODE     OREQ 'D'
     C           *IN50     ANDEQ*OFF
     C           ACREC     ANDEQ'A'
     C                     MOVE ACODE   ACREC
     C                     UPDATREC
     C           ACODE     WHEQ 'C'
     C           *IN50     ANDEQ*OFF
     C           ACREC     ANDEQ'A'
     C                     UPDATREC
     C                     OTHER
     C                     EXSR ERROR
     C                     ENDSL
```

### Alternative : CAS/ENDCS
CAS appelle un sous-programme selon la condition :
```
     C           OPT       CASEQ'C'       CREER
     C           OPT       CASEQ'M'       MODIF
     C           OPT       CASEQ'S'       SUPP
     C                     CAS            ERREUR
     C                     ENDCS
```
- Le dernier CAS sans condition sert de `default` (OTHER).

---

## Boucles

### DOWxx - Tant que (While)

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| DOWXX   | Comparand     | Comparand       |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

Execute tant que la condition est vraie. **La condition est testee AVANT** la premiere execution du groupe.

**Deroulement detaille (doc IBM)** :
1. Si les indicateurs de condition sur DOWxx sont satisfaits → etape 2. Sinon → apres ENDDO (etape 6)
2. Compare Factor 1 et Factor 2. Si la condition xx n'existe PAS → apres ENDDO. Si elle existe → etape 3
3. Execute les operations du groupe DO
4. Si les indicateurs sur ENDDO ne sont pas satisfaits → apres ENDDO. Sinon → etape 5
5. ENDDO retourne à l'étape 2 (les indicateurs de DOWxx ne sont PAS retestés)
6. Suite du programme

**Exemples** :
```
     C* Boucle tant que FLDA < FLDB
     C           FLDA      DOWLTFLDB
     C                     MULT 2.08    FLDA
     C                     ENDDO

     C* Boucle avec conditions multiples (ORxx)
     C           FLDA      DOWLTFLDB
     C           FLDA      ORLT FLDC
     C                     MULT 2.08    FLDA
     C                     ENDDO
```
→ Boucle tant que FLDA < FLDB OU FLDA < FLDC

```
     C* Pattern classique lecture fichier
     C           *IN90     DOWEQ'0'
     C           PRECLI    DSPLY
     C                     READ CLIENT                   90
     C                     ENDDO
```

### DOUxx - Jusqu'a ce que (Until)

Execute **au moins une fois**, puis teste la condition. Boucle tant que la condition n'est PAS vraie.

**Deroulement detaille (doc IBM)** :
1. Si les indicateurs de condition sur DOUxx sont satisfaits → etape 2. Sinon → apres ENDDO
2. DOUxx passe directement aux operations (PAS de test de condition ici)
3. Execute les operations du groupe DO
4. Si les indicateurs sur ENDDO ne sont pas satisfaits → apres ENDDO. Sinon → etape 5
5. ENDDO teste la condition xx. Si la condition EXISTE → le groupe est fini → apres ENDDO. Si elle n'existe PAS → retour etape 3

**Exemples** :
```
     C* Boucle au moins une fois, s'arrête quand FLDA = FLDB
     C           FLDA      DOUEQFLDB
     C                     SUB  1       FLDA
     C                     ENDDO

     C* Boucle avec conditions combinees ANDxx/ORxx
     C           FLDA      DOUEQFLDB
     C           FLDC      ANDEQFLDD
     C           FLDE      OREQ 100
     C                     SUB  1       FLDA
     C                     ADD  1       FLDC
     C                     ADD  5       FLDE
     C                     ENDDO
```
→ S'arrête quand (FLDA = FLDB ET FLDC = FLDD) OU FLDE = 100

### DO - Boucle comptee

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| DO      | Starting      | Limit value     | Index          |               |
|         | value         |                 | value          |               |
*---------*---------------*-----------------*----------------*---------------*
```

- **Factor 1** : valeur de depart (defaut = 1). Numerique sans decimale.
- **Factor 2** : valeur limite (defaut = 1). Numerique sans decimale.
- **Resultat** : variable index. Doit etre assez grand pour contenir la limite + l'increment.
- **Factor 2 de ENDDO** : valeur d'increment (defaut = 1)

**Deroulement detaille en 7 etapes (doc IBM)** :
1. Si les indicateurs de condition sur DO sont satisfaits → etape 2. Sinon → apres ENDDO (etape 7)
2. La valeur de depart (Factor 1) est copiee dans l'index (Result)
3. Si l'index > limite → apres ENDDO (etape 7). Sinon → etape 4
4. Execute les operations du groupe DO
5. Si les indicateurs de condition sur ENDDO ne sont pas satisfaits → apres ENDDO (etape 7). Sinon → etape 6
6. ENDDO ajoute l'increment a l'index → retour etape 3 (indicateurs DO PAS retestes)
7. Suite du programme

**Exemples** :
```
     C* Boucle 10 fois (1 a 10), index X
     C   17                DO   10        X       30       DO 10 TIMES
     C           :
     C                     ENDDO

     C* Boucle de 2 a 20, pas de 2 (10 iterations)
     C           2         DO   20        X       30       DO 10 TIMES
     C           :
     C           50        ENDDO2
```
→ Avec factor 1 = 2, factor 2 = 20, increment ENDDO = 2, l'index prend les valeurs 2, 4, 6, 8, 10, 12, 14, 16, 18, 20.

**⚠ Important** :
- L'index, l'increment, la limite et les indicateurs peuvent etre modifies **a l'interieur** de la boucle
- Un groupe DO ne peut PAS couvrir a la fois les detail et total calculations

### Suffixes de comparaison pour DOW/DOU
| Code | Condition |
|------|-----------|
| DOWEQ | Tant que Factor 1 = Factor 2 |
| DOWNE | Tant que Factor 1 ≠ Factor 2 |
| DOWLT | Tant que Factor 1 < Factor 2 |
| DOWLE | Tant que Factor 1 ≤ Factor 2 |
| DOWGT | Tant que Factor 1 > Factor 2 |
| DOWGE | Tant que Factor 1 ≥ Factor 2 |

---

## LEAVE et ITER

### LEAVE - Sortir d'une boucle

**Rôle** : Transfere le controle de l'interieur d'un groupe DO vers l'instruction **apres** le ENDDO. N'incremente PAS l'index.

Dans les boucles imbriquees, LEAVE sort uniquement du niveau le plus interne.

**Exemple - Boucle infinie avec sortie sur 'q'** :
```
     C           2         DOWNE1
     C           :
     C           ANSWER    IFEQ 'q'
     C                     LEAVE
     C                     ENDIF
     C           :
     C                     ENDDO
     C                     Z-ADDA        B
```

**Exemple - LEAVE dans boucles imbriquees** :
```
     C           FLDA      DOUEQFLDB
     C           NUM       DOWLT10
     C           *IN01     IFEQ *ON
     C                     SETON                     99
     C                     LEAVE
     C           :
     C                     ENDIF
     C                     ENDDO
     C   99                LEAVE
     C           :
     C                     ENDDO
```
→ Le premier LEAVE sort du DOW interne. Le second LEAVE (conditionne par 99) sort du DOU externe.

### ITER - Iterer (passer a l'iteration suivante)

**Rôle** : Transfere le controle vers le **ENDDO** de la boucle en cours (pas apres, mais AU ENDDO). La condition de la boucle est reevaluee.

ITER affecte la boucle la plus interne.

**Exemple** :
```
     C           FLDA      DOUEQFLDB
     C           :
     C           NUM       DOWLT10
     C           *IN01     IFEQ *ON
     C                     LEAVE
     C                     ENDIF
     C                     EXSR PROC1
     C           *IN12     IFEQ *OFF
     C                     ITER                                ITER
     C                     ENDIF
     C                     EXSR PROC2
     C                     ENDDO                               Inner ENDDO
     C                     Z-ADD20       RSLT   20             Z-ADD
     C           :
     C                     ENDDO                               Outer ENDDO
```
→ Si *IN01 = ON, LEAVE sort du DOW interne vers Z-ADD. Si *IN12 = OFF, ITER saute PROC2 et retourne au ENDDO interne pour retester la condition DOW.

---

## GOTO et TAG

### GOTO - Branchement

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| GOTO    |               | Label           |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Rôle** : Branche le programme vers une etiquette (TAG). Factor 2 contient le nom du label cible.

### TAG - Etiquette

**Syntaxe** :
```
     C           label     TAG
```
Factor 1 contient le nom de l'etiquette. Doit etre un nom symbolique unique.

### Regles de branchement
- De detail vers detail : ✅
- De detail vers total : ✅
- De total vers total : ✅
- **De total vers detail : ❌ INTERDIT**
- D'un sous-programme vers detail/total : ✅ (mais deconseille)
- De l'exterieur vers un TAG/ENDSR dans un sous-programme : ❌ INTERDIT

**⚠ Le branchement peut creer des boucles infinies** si la logique n'est pas maitrisee.

### Exemples (doc IBM)
```
     C* Branchement conditionne par des indicateurs
     C   10                GOTO RTN1
     C   15                GOTO RTN2
     C           RTN1      TAG
     C           :
     C   20                GOTO END
     C           :
     C           END       TAG
     CL1                   GOTO RTN2
     CL1        RTN2      TAG
```

### Usage typique : gestion d'erreur avec CHAIN
```
     C           KEY       CHAINCLIENT                   60
     C   60                GOTO NOTFND
     C* ... traitement si trouvé ...
     C                     GOTO ENDPGM
     C           NOTFND    TAG
     C           'NOT FOUND'DSPLY
     C           ENDPGM    TAG
     C                     SETON                     LR
```

**⚠ Bonne pratique** : Preferer IFxx/ELSE/ENDIF et DOWxx/LEAVE a GOTO/TAG pour la lisibilite du code.

---

## Operateurs logiques

### ANDxx
Combine deux conditions (toutes doivent etre vraies) :
```
     C           *INKC     IFGT '1'
     C           *IN99     ANDEQ'0'
     C                     Z-ADD0         J
     C                     ENDIF
```

### ORxx
Au moins une condition doit etre vraie :
```
     C           TELEP     IFGT *BLANKS
     C           MOBIL     OREQ *BLANKS
     C                     Z-ADD0         J
     C                     ENDIF
```

ANDxx et ORxx s'utilisent immediatement apres un IFxx, DOWxx, DOUxx ou WHxx.

---

## Instructions arithmetiques

### ADD - Addition
```
     C           5         ADD  3         X                X = 5+3 = 8
     C                     ADD  3         X                X = X+3
     C           X         ADD  3         X                X = X+3
```

### SUB - Soustraction
```
     C           5         SUB  3         J                J = 5-3 = 2
     C                     SUB  3         J                J = J-3
```

### MULT - Multiplication
```
     C           5         MULT 3         J                J = 5*3 = 15
     C                     MULT 3         J                J = J*3
```

### DIV - Division
```
     C           5         DIV  3         J                J = 5/3 = 1
```

### MVR - Reste de division
Doit suivre IMMEDIATEMENT un DIV :
```
     C           X         DIV  I         J
     C                     MVR            RESTE   82
```

### Z-ADD - Mise a zero et addition

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| Z-ADD   |               | Addend          | Sum            | + - Z         |
| (1/2)   |               |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

Factor 2 est additionne a un champ de zeros. Le resultat remplace la zone resultat (equivalent d'une affectation).
```
     C                     Z-ADD0         I                I = 0
     C                     Z-ADD10        STOCK   50       STOCK = 10
```
Position 53 : H pour half-adjust (arrondi).

### Z-SUB - Mise a zero et soustraction
Remplace la valeur avec inversion du signe :
```
     C                     Z-SUB3         I       52       I = -3
```

### COMP - Comparaison

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| COMP    | Comparand     | Comparand       |                | HI LO EQ      |
*---------*---------------*-----------------*----------------*---------------*
```

Compare Factor 1 et Factor 2. Factor 1 et Factor 2 doivent etre de meme type (tous deux char ou tous deux num).
Au moins un indicateur resultant doit etre specifie. Ne PAS specifier le meme indicateur pour les 3 conditions.

- Col 54-55 (Hi) : Factor 1 > Factor 2
- Col 56-57 (Lo) : Factor 1 < Factor 2
- Col 58-59 (Eq) : Factor 1 = Factor 2

**Exemples (doc IBM)** :
```
     C* FLDA=100, FLDB=105, FLDC=100, FLDD='ABC', FLDE='ABCDE'
     C* Indicateur 12 ON (FLDA < FLDB) ; 11 et 13 OFF
     C           FLDA      COMP FLDB                      111213
     C* Indicateur 15 ON (100 < 105) ; 14 OFF
     C           FLDA      COMP FLDB                      141516
     C* Indicateur 19 ON (100 = 100) ; 17 OFF
     C           FLDA      COMP FLDC                      171819
     C* Indicateur 21 ON ('ABC' < 'ABCDE') ; 20 et 22 OFF
     C           FLDD      COMP FLDE                      202122
```

---

## Instructions de chaines

### MOVE - Copie alignee a droite

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| MOVE    |               | Source field     | Target field   | + - ZB        |
| (P)     |               |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

Transfere les caracteres de Factor 2 vers le resultat en **commencant par la droite**.

**Comportement selon les longueurs** :
- Factor 2 **plus court** que le resultat : les caracteres a gauche du resultat sont **inchanges** (sauf si P est specifie)
- Factor 2 **plus long** que le resultat : les caracteres a gauche de Factor 2 sont **tronques**
- Avec **P** (position 53) : le resultat est **padde a gauche** avec des blancs (char) ou zeros (num)

**Exemples** :
```
     C                     MOVE 'TOTO'    ZON15  15
     * ZON15 = '           TOTO' (les 11 premiers caracteres inchanges)
     C                     MOVE *BLANKS   ZON15
     * Avec P : le resultat est pad a gauche
     C                     MOVE 'XYZ'     FLD8  8 P
     * FLD8 = '     XYZ' (5 blancs + XYZ)
```

### MOVEL - Copie alignee a gauche

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| MOVEL   |               | Source field     | Target field   | + - ZB        |
| (P)     |               |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

Transfere les caracteres de Factor 2 vers le resultat en **commencant par la gauche**.

**Comportement selon les longueurs** :
- Factor 2 **plus court** que le resultat : les caracteres a droite du resultat sont **inchanges** (sauf si P)
- Factor 2 **plus long** que le resultat : les caracteres a droite de Factor 2 sont **tronques**
- Avec **P** : le resultat est **padde a droite** avec des blancs (char) ou zeros (num)

**Regles de signe (MOVE et MOVEL)** :
- Vers un champ numerique : le signe du resultat est conserve, sauf si Factor 2 est aussi long ou plus long (le signe de Factor 2 est utilise)
- Char vers numerique : si la zone du dernier caractere de Factor 2 est X'D' (negatif), le resultat est negatif

```
     C                     MOVEL'TOTO'    ZON15
     * ZON15 = 'TOTO           ' (les 11 derniers caracteres inchanges)
     C                     MOVEL'Hello'   MSG   5
     * MSG = 'Hello'
```

### MOVEA - Transfert vers/depuis un tableau
```
     C                     MOVEA*ZEROS    TVA
     C                     MOVEA*ZEROS    TVA,X
     C                     MOVEA*BLANKS   TXT
     C                     MOVEA'HELLO !!'TBC,2
```

### DSPLY - Affichage console
```
     C           HELLO     DSPLY
     C                     'MSG' DSPLY
```

### CLEAR - Remise a zero d'une variable ou format
```
     C                     CLEARMES
```

### Constantes speciales
- `*BLANKS` : chaine vide (espaces)
- `*ZEROS` : zeros
- `*LOVAL` : plus petite valeur possible
- `*HIVAL` : plus grande valeur possible
- `*ON` : '1'
- `*OFF` : '0'
- `*BLANK` : un caractere espace
- `*ZERO` : zero numerique
- `*ALL` : repete un caractere (*ALL'*' remplit d'etoiles)

---

## CAT - Concatenation

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| CAT (P) | Source string  | Source string   | Target         |               |
|         | 1             | 2: number of    | string         |               |
|         |               | blanks          |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Rôle** : Concatene la chaine de Factor 2 a la fin de la chaine de Factor 1 et place le resultat dans la zone resultat.

**Factor 1 (optionnel)** : premiere chaine. Si absent, le resultat est utilise.
**Factor 2 (obligatoire)** : deuxieme chaine. Format : `chaine:nombre_de_blancs`
- Si un `:` est specifie, le nombre de blancs est obligatoire
- Si pas de `:`, la concatenation inclut les blancs finaux de Factor 1

**Position 53 = P** : padde le resultat a droite avec des blancs si le resultat est plus long que la concatenation.

### Exemples (doc IBM)

```
     C* Concatener LAST a NAME avec 1 blanc entre eux
     C* NAME='Mr.   ', LAST='Smith '
     C* Resultat TEMP = 'Mr.bSmith' (b = blanc)
     C                     MOVE 'Mr. '   NAME    6
     C                     MOVE 'Smith ' LAST    6
     C           NAME      CAT  LAST:1   TEMP    9

     C* Concatener 'RPG' et '/400' → 'RPG/400'
     C                     MOVE '/400'   STRING  4
     C           'RPG'     CAT  STRING   TEMP    7

     C* Avec P : pad a droite, resultat 10 chars
     C* TEMP = 'RPG/400bbb' (b = blancs)
     C                     MOVE *ALL'*'  TEMP   10
     C                     MOVE '/400'   STRING  4
     C           'RPG'     CAT  STRING   TEMP    P

     C* Troncation si resultat trop court
     C* TEMP = 'RPG/4' (tronque a 5)
     C                     MOVE '/400'   STRING  4
     C           'RPG'     CAT  STRING   TEMP    5

     C* Avec nombre de blancs = 0 : pas de blancs entre les chaines
     C* NAME='RPG  ', LAST='III  ', NUM=0
     C* TEMP = 'RPGIIIbbbb' (avec P, padde)
     C                     MOVE 'RPG '   NAME    5
     C                     MOVE 'III '   LAST    5
     C                     Z-ADD0        NUM    10
     C           NAME      CAT  LAST:NUM TEMP   10P

     C* Blancs de tete de Factor 2 sont conserves
     C* NAME='MR.', FIRST=' SMITH'
     C* RESULT = 'MR.bSMITH' (le blanc de tete de FIRST est garde)
     C                     MOVE 'MR.'    NAME    3
     C                     MOVE ' SMITH' FIRST   6
     C           NAME      CAT  FIRST    RESULT  9

     C* CAT sans Factor 1 : concatene Factor 2 au resultat existant
     C* FLD2='ABCbbbbbb', FLD1='XYZ'
     C* Apres CAT : FLD2='ABCbbXYZb' (2 blancs entre ABC et XYZ)
     C                     MOVE 'ABC'    FLD2    9 P
     C                     MOVE 'XYZ'    FLD1
     C                     CAT  FLD1:2   FLD2
```

### Regles CAT
- Le resultat doit etre de type caractere
- La longueur du resultat devrait etre Factor 1 + blancs + Factor 2 pour eviter la troncation
- Les constantes figuratives (*BLANKS, *ZEROS) ne sont PAS autorisees en Factor 1, Factor 2 ou resultat
- Pas de chevauchement autorise dans une data structure entre Factor 1/2 et le resultat
- Si le nombre de blancs est negatif a l'execution, il est traite comme 0
