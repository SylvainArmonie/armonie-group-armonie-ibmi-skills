# Accès aux Fichiers en RPG III

## Table des matières
1. [Introduction](#introduction)
2. [Positionnement - SETLL](#setll)
3. [Positionnement - SETGT](#setgt)
4. [Lecture - READ](#read)
5. [Lecture clé égale - READE](#reade)
6. [Lecture précédente - READP](#readp)
7. [Lecture précédente clé égale - REDPE](#redpe)
8. [Lecture sous-fichier - READC](#readc)
9. [Accès direct - CHAIN](#chain)
10. [Écriture - WRITE](#write)
11. [Mise à jour - UPDAT](#updat)
12. [Suppression - DELET](#delet)
13. [Clé composée - KLIST/KFLD](#klist-kfld)
14. [Patterns complets](#patterns-complets)

---

## 1. Introduction

Les opérations d'accès fichiers en RPG III se font via les spécifications C.
Le fichier doit être déclaré en spécification F avec le bon mode d'accès :
- **I** (Input) : lecture seule
- **O** (Output) : écriture seule
- **U** (Update) : lecture + modification + suppression
- **C** (Combined) : lecture + écriture (écrans WORKSTN)

L'indicateur de fin de fichier se place en **colonnes 58-59** de la spec C.
Convention courante : indicateur **90** pour fin de fichier.

### Verrouillage des enregistrements (Option N)

Pour les fichiers en mode Update (U), les opérations de lecture verrouillent l'enregistrement par défaut. Pour lire **sans verrouiller**, spécifier **N en position 53** de la spec C. Cette option est disponible sur : READ, READE, READP, REDPE, CHAIN.

```
     C* Lecture SANS verrouillage (N en position 53)
     C                     READ REC1     N 64 END OF FILE
     C* Lecture AVEC verrouillage (position 53 vide = défaut)
     C                     READ REC1       64 END OF FILE
```

**Règle** : Si le fichier est en Input (I), tous les enregistrements sont lus sans verrou et la position 53 doit rester vide.

---

## 2. SETLL - Positionnement (clé inférieure ou égale)

**Rôle** : Positionne le pointeur de lecture sur l'enregistrement ayant une clé exacte ou immédiatement supérieure à la valeur fournie. Ne lit PAS l'enregistrement.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| SETLL   | Search        | File name       |                | NR ER EQ      |
|         | argument      |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 54-55 (NR)** : activé si aucun enregistrement avec clé >= argument de recherche
- **Col 56-57 (ER)** : activé si erreur pendant l'opération
- **Col 58-59 (EQ)** : activé si un enregistrement avec clé **exactement égale** existe

**Exemples** :
```
     C           *LOVAL    SETLLCLIENT
```
→ Positionne au tout début du fichier (plus petite clé possible)

```
     C           00002     SETLLCLIENT
```
→ Positionne sur l'enregistrement avec clé 00002

```
     C           *HIVAL    SETLLCLIENT
```
→ Positionne après le dernier enregistrement (utile avant READP)

**Utilisation de l'indicateur EQ (col 58-59)** :
```
     C           ORDER     SETLLORDFIL                    55
```
→ L'indicateur 55 est activé si un enregistrement avec clé exactement égale à ORDER existe. Ceci est **plus performant qu'un CHAIN** pour simplement vérifier l'existence d'une clé, car SETLL n'accède pas aux données du record.

**Exemple complet avec READE** (tiré de la doc IBM) :
```
     C* Imprimer tous les enregistrements avec ORDER = 101
     C           ORDER     SETLLORDFIL                    55
     C  N55      GOTO NOTFND
     C           LOOP      TAG
     C           ORDER     READEORDFIL                    56
     C  N56      EXCPTDETAIL                                   PRINT A LINE
     C  N56      GOTO LOOP
     C           NOTFND    TAG
```

**Constantes figuratives** :
- *LOVAL = positionne avant le premier enregistrement en ordre croissant
- *HIVAL = positionne après le dernier enregistrement → un READ après donne EOF, un READP lit le dernier

**⚠ Cas particuliers avec clés numériques** :
- Avec un fichier décrit externé en ordre décroissant : *HIVAL positionne pour que le premier READ donne le premier record (clé la plus haute), et *LOVAL positionne pour que READP donne le dernier (clé la plus basse)
- *LOVAL = X'99...9D' et *HIVAL = X'99...9F' en interne. Des données character dans une clé packed peuvent dépasser ces valeurs.

**Règles** :
- Toujours suivre d'un READ ou READE pour lire l'enregistrement
- Quand EOF est atteint, un nouveau SETLL peut repositionner le fichier
- Après un SETLL réussi, un autre job peut supprimer le record avant votre READ
- Pour vérifier l'existence d'une clé sans lire, SETLL + indicateur EQ est plus performant que CHAIN

---

## 3. SETGT - Positionnement (clé strictement supérieure)

**Rôle** : Positionne le pointeur sur l'enregistrement ayant une clé **strictement supérieure** à la valeur fournie.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| SETGT   | Search        | File name       |                | NR ER _       |
|         | argument      |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 54-55 (NR)** : activé si aucun enregistrement avec clé > argument
- **Col 56-57 (ER)** : activé si erreur pendant l'opération

**Exemples** :
```
     C* Positionner après la clé 98, puis lire le suivant (clé 100)
     C           KEY       SETGTFILEA                          GREATER THAN
     C                     READ FILEA                     64   READ NEXT
```

**Lire le dernier enregistrement d'un groupe de clés** :
```
     C* KEY = 70 : positionner après le dernier 70, puis READP lit le dernier 70
     C           KEY       SETGTFILEB                          GREATER THAN
     C                     READPFILEB                     64   READ LAST
```

**Utilisation de *LOVAL et *HIVAL** :
```
     C* *LOVAL : positionne AVANT le premier enregistrement
     C* Le READ suivant lit le premier record (clé 97)
     C           *LOVAL    SETGTRECDA                          GREATER THAN
     C                     READ RECDA                     64   READ NEXT

     C* *HIVAL : positionne APRES le dernier enregistrement
     C* Le READP suivant lit le dernier record (clé 91)
     C           *HIVAL    SETGTRECDB                          GREATER THAN
     C                     READPRECDB                     64   READ LAST
```

**Différence SETLL vs SETGT** :
- SETLL clé=5 → positionne sur le premier enregistrement avec clé >= 5
- SETGT clé=5 → positionne sur le premier enregistrement avec clé > 5

**⚠ Si SETGT échoue** (no-record-found), le fichier est positionné en fin de fichier.

---

## 4. READ - Lecture séquentielle

**Rôle** : Lit l'enregistrement courant et avance le pointeur au suivant.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| READ    |               | File name,      | Data           | _ ER EOF      |
| (N)     |               | Record name     | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 56-57 (ER)** : activé si erreur (optionnel)
- **Col 58-59 (EOF)** : activé si fin de fichier (OBLIGATOIRE)

**Factor 2** : nom du fichier OU nom de format (format uniquement pour fichiers externes E).

**Option N (position 53)** : lecture sans verrouillage pour fichiers en Update.

**Résultat** : peut contenir un nom de data structure uniquement pour les fichiers décrits programme (F en position 19 de la spec F).

**Exemple complet** :
```
     FCLIENT  IF  E           K        DISK
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C           PRECLI    DSPLY
     C                     READ CLIENT                   90
     C                     ENDDO
     C                     SETON                     LR
```

**Lecture par format sans verrouillage** :
```
     C* N en position 53 = pas de verrouillage
     C                     READ REC1     N 64 END OF FILE
     C   64                GOTO EOF
```

**Règles importantes** :
- Après un READ réussi, le fichier est positionné sur le record suivant
- Si un indicateur (ER ou EOF) est activé, il faut repositionner le fichier (CHAIN, SETLL ou SETGT) avant le prochain READ
- L'indicateur EOF est positionné à chaque exécution du READ (on/off)

---

## 5. READE - Lecture clé égale

**Rôle** : Lit l'enregistrement suivant ayant la **même clé** que la position courante. Active l'indicateur quand il n'y a plus d'enregistrements avec cette clé.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| READE   | Search        | File name,      | Data           | _ ER EOF      |
| (N)     | argument      | Record name     | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Factor 1 (optionnel)** : valeur de la clé à comparer. Si vide, compare avec la clé complète du record courant.

**Comportement selon Factor 1** :
- **Avec Factor 1** : la comparaison se fait dans le programme RPG. Si le fichier est en Update, un verrou temporaire est posé puis relâché si les clés ne correspondent pas.
- **Sans Factor 1** : la comparaison se fait au niveau Data Management (plus performant).

**Exemples** :
```
     C* Avec Factor 1 spécifié
     C           KEYFLD    READEFILEA                     55   NOT EQUAL

     C* Avec format (fichier externe) et sans verrouillage
     C                     READEREC1     N                56   NOT EQUAL

     C* Sans Factor 1 (compare avec clé courante)
     C                     READEFILEA                     55   NOT EQUAL
```

**⚠ Piège avec les clés numériques packed** :
Si le fichier physique utilise une clé packed de X'123C' pour +123, et que l'argument de recherche est 123, le READE utilisera X'123F' et retournera EOF car les représentations internes diffèrent. La valeur doit correspondre **exactement** au format interne de la clé.

**Exemple complet - Lire tous les enregistrements d'un même client** :
```
     C           NUMCLI    SETLLCOMMANDE
     C           NUMCLI    READECOMMANDE                 90
     C           *IN90     DOWEQ'0'
     C           MNTCMD    DSPLY
     C           NUMCLI    READECOMMANDE                 90
     C                     ENDDO
```

**Règle** : Un READE sans Factor 1 juste après un OPEN ou un EOF provoque une erreur. Toujours positionner le fichier d'abord.

---

## 6. READP - Lecture précédente

**Rôle** : Lit l'enregistrement **précédent** dans le fichier (lecture arrière).

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| READP   |               | File name,      | Data           | _ ER BOF      |
| (N)     |               | Record name     | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 56-57 (ER)** : activé si erreur (optionnel)
- **Col 58-59 (BOF)** : activé si début de fichier atteint (OBLIGATOIRE)

**Factor 2** : si un nom de format est spécifié, seuls les records de ce type sont lus. Les records intermédiaires d'autres types sont ignorés.

**Exemples** :
```
     C* Lire le record précédent de FILEA
     C                     READPFILEA                     71   BOF
     C   71                GOTO BOF                            BEG OF FILE

     C* Lire le record précédent de type REC1 (format)
     C                     READPREC1                      7272 = BOF
     C   72                GOTO BOF
```

**Lire le dernier enregistrement** :
```
     C           *HIVAL    SETLLCLIENT
     C                     READPCLIENT                   90
```

**Règles** :
- Si READP échoue (BOF), repositionner le fichier avant le prochain READP
- Option N en position 53 pour lecture sans verrouillage

---

## 7. REDPE - Lecture précédente clé égale

**Rôle** : Lit l'enregistrement **précédent** ayant la même clé que l'argument de recherche.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| REDPE   | Search        | File name,      | Data           | _ ER BOF      |
| (N)     | argument      | Record name     | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 56-57 (ER)** : activé si erreur (optionnel)
- **Col 58-59 (BOF)** : activé si clé différente ou début de fichier

**Factor 1 (optionnel)** : valeur de la clé. Si absent, compare avec la clé complète du record courant.

**Exemples** :
```
     C* Avec Factor 1 : lire le précédent avec même clé que FIELDA
     C           FIELDA    REDPEFILEA                     99

     C* Avec data structure et indicateur erreur
     C           FIELDB    REDPEFILEB    DS1              8899

     C* Avec format et indicateurs erreur + BOF
     C           FIELDC    REDPERECA                      8899

     C* Sans Factor 1 : comparer avec la clé du record courant
     C                     REDPEFILEA                     99

     C* Sans Factor 1, vers une data structure
     C                     REDPEFILEB    DS1              99

     C* Sans Factor 1, par format
     C                     REDPERECA                      8899
```

**⚠ Règles critiques** :
- Un REDPE avec Factor 1 juste après OPEN ou BOF retourne BOF
- Un REDPE sans Factor 1 juste après OPEN ou BOF provoque une **erreur** (indicateur ER activé)
- **Ne PAS utiliser SETGT** pour positionner avant un REDPE : le record précédent n'aura jamais la même clé que le record courant après SETGT
- Utiliser plutôt CHAIN, SETLL, READ, READP ou READE (avec Factor 1) pour positionner avant un REDPE sans Factor 1

**⚠ Piège clé packed** : Même avertissement que READE - les clés packed doivent correspondre exactement.

---

## 8. READC - Lecture sous-fichier modifié

**Rôle** : Lit les enregistrements **modifiés** d'un sous-fichier (SFL).

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| READC   |               | Record name     |                | _ ER EOF      |
*---------*---------------*-----------------*----------------*---------------*
```

**Factor 2 (obligatoire)** : nom du format SFL (déclaré avec SFILE dans les specs F), **pas** le SFLCTL.

**Indicateurs** :
- **Col 56-57 (ER)** : erreur (optionnel)
- **Col 58-59 (EOF)** : plus de records modifiés dans le SFL (obligatoire)

**Exemple dans un programme sous-fichier** :
```
     C                     READCSFL1                     90
     C           *IN90     DOWEQ'0'
     C* Traiter l'enregistrement modifié
     C                     READCSFL1                     90
     C                     ENDDO
```

**Important** : READC ne lit que les lignes que l'utilisateur a modifiées dans le sous-fichier. Pour un fichier multi-device, le READC lit depuis le sous-fichier associé au device identifié dans l'entrée ID des specs F.

---

## 9. CHAIN - Accès direct par clé

**Rôle** : Recherche et lit un enregistrement spécifique par sa clé. Combine SETLL + READ en une seule opération.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| CHAIN   | Search        | File name       | Data           | NR ER _       |
| (N)     | argument      |                 | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Positions des indicateurs** :
- **Col 54-55 (NR)** : activé si enregistrement **non trouvé** (OBLIGATOIRE)
- **Col 56-57 (ER)** : activé si erreur (optionnel)
- **Col 58-59** : doit être vide

**Factor 1** : clé de recherche. Pour un fichier externe, peut être un champ, une constante, une figurative, un littéral ou un **nom de KLIST**.

**Factor 2** : nom du fichier ou nom de format (format seulement pour fichiers externes).
- Si Factor 2 = nom de fichier → lit le premier record avec la clé correspondante
- Si Factor 2 = nom de format → lit le premier record du type spécifié avec la clé correspondante

**Option N (position 53)** : lecture sans verrouillage pour fichiers en Update.

**Data structure** : le résultat peut contenir un nom de data structure **uniquement** pour les fichiers décrits programme.

**Exemples** :
```
     C* Recherche simple avec indicateur non trouvé (col 54-55)
     C           KEY       CHAINFILEX                     60   INDICATOR 60
     C   60                GOTO NOTFND

     C* Recherche par format avec clé composée et sans verrouillage
     C           KEY       CHAINREC1     N                72   INDICATOR 72
     C           KEY       KLIST
     C                     KFLD                     FLD1
     C                     KFLD                     FLD2
     C           *IN72     IFEQ *OFF
     C* Record trouvé et verrouillé par défaut, possible UPDAT
     C                     UPDATREC1
     C                     ENDIF
```

**Après un CHAIN réussi** : le fichier est positionné pour que le prochain READ lise le record séquentiel suivant.

**Après un CHAIN échoué** : le fichier doit être repositionné (CHAIN ou SETLL) avant un READ.

**Pour WORKSTN** : CHAIN récupère un record de sous-fichier.

**Indicateur CHAIN** :
- *IN90 = '0' → Enregistrement **trouvé**
- *IN90 = '1' → Enregistrement **non trouvé**

---

## 10. WRITE - Écriture d'un enregistrement

**Rôle** : Écrit un nouvel enregistrement dans un fichier.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| WRITE   |               | File name       | Data           | _ ER _        |
|         |               |                 | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Factor 2** :
- Fichier externe (E) : nom de **format** obligatoire (ex: CLIENTF)
- Fichier programme (F) : nom de **fichier** obligatoire + data structure dans le résultat

**Indicateurs** :
- **Col 56-57 (ER)** : erreur (optionnel). Aussi activé si overflow atteint sur un fichier imprimante externe sans indicateur d'overflow.
- **Col 58-59** : pour WRITE dans un SFL (sous-fichier), activé quand le SFL est plein.

**Exemples** :
```
     C* Écriture dans un fichier externe (par format)
     C                     WRITECLIENTF

     C* Écriture dans un fichier programme (par nom fichier + data structure)
     C                     WRITEFILE1    DS1              ADD RECORD

     C* Écriture dans un sous-fichier
     C                     WRITESFL1
```

**Règles importantes** :
- Quand Factor 2 contient un nom de format, les valeurs courantes de **tous** les champs du format sont utilisées
- Pour écrire dans un fichier DISK, spécifier **A** en position 66 de la spec F
- Le champ RECNO (numéro relatif) doit être mis à jour pour les fichiers en accès par numéro relatif
- Les fonctions device-dépendantes (saut de page, espacement) ne sont pas disponibles via WRITE → utiliser la description externe DDS

---

## 11. UPDAT - Mise à jour d'un enregistrement

**Rôle** : Modifie l'enregistrement **actuellement lu et verrouillé** dans le fichier.

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
|         |               |                 | FIELD          |               |
*---------*---------------*-----------------*----------------*---------------*
| UPDAT   |               | File name       | Data           | _ ER _        |
|         |               |                 | structure      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Factor 2** :
- Fichier externe : nom de **format** obligatoire (doit être le format du dernier record lu)
- Fichier programme : nom de **fichier** obligatoire + data structure en résultat

**Prérequis OBLIGATOIRES** :
1. Fichier déclaré en mode **U** (Update)
2. Un READ, READC, READE, READP, REDPE ou CHAIN **avec verrouillage** doit avoir été fait AVANT (position 53 vide = verrouillage par défaut)
3. Si la lecture était avec N (sans verrouillage), le record n'est PAS verrouillé → UPDAT échoue
4. **Aucune autre opération** sur le fichier entre le READ/CHAIN et l'UPDAT

**Exemple complet** :
```
     FCLIENT  UF  E           K        DISK
     C           00004     CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     MOVEL'Jean'   PRECLI
     C                     UPDATCLIENTF
     C                     ENDIF
     C                     SETON                     LR
```

**⚠ Règles critiques** :
- Des UPDAT consécutifs sans READ intermédiaire sont invalides
- Pour mettre à jour seulement **certains champs**, utiliser les specs de sortie (O) plutôt que UPDAT
- **Attention en total calculations** : les champs du record courant n'ont pas encore été chargés → UPDAT modifie avec les champs du record précédent
- Pour un fichier multi-device avec SFL, le device du UPDAT doit être le même que celui de l'opération d'entrée précédente

---

## 12. DELET - Suppression d'un enregistrement

**Rôle** : Supprime physiquement l'enregistrement actuellement lu.

**Prérequis** :
- Fichier déclaré en mode **U** (Update)
- Un READ ou CHAIN **avec verrouillage** doit avoir été fait **avant**

**Syntaxe** :
```
     C                     DELETformat
```

**Exemple complet** :
```
     FCLIENT  UF  E           K        DISK
     C           00004     CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     DELETCLIENTF
     C                     ENDIF
     C                     SETON                     LR
```

**⚠ RÈGLE CRITIQUE** : Comme UPDAT, DELET nécessite un READ ou CHAIN préalable avec verrouillage.

---

## 13. KLIST/KFLD - Clé composée

**Rôle** : Définit une clé composée (plusieurs champs) pour les accès fichiers.

**Syntaxe officielle IBM** :

**KLIST** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| KLIST   | KLIST name    |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**KFLD** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| KFLD    |               |                 | Key field      |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Exemple complet avec DDS** :
```
     A* DDS source du fichier
     A  R RECORD
     A    FLDA           4
     A    SHIFT          1  0
     A    FLDB          10
     A    CLOCK#         5  0
     A    FLDC          10
     A    DEPT           4
     A    FLDD           8
     A    K DEPT
     A    K SHIFT
     A    K CLOCK#
```

```
     C* Définition de la KLIST correspondante
     C           FILEKY    KLIST
     C                     KFLD                     DEPT
     C                     KFLD                     SHIFT
     C                     KFLD                     CLOCK#
```

**Règles KLIST (doc IBM)** :
- Un KLIST doit être suivi immédiatement par au moins un KFLD
- Un KLIST se termine quand une opération non-KFLD est rencontrée
- Un KLIST peut être utilisé comme argument de recherche avec : CHAIN, DELET, READE, REDPE, SETGT, SETLL
- Le même KLIST peut être utilisé pour plusieurs fichiers
- L'**ordre** des KFLD détermine l'association : le 1er KFLD correspond au champ le plus à gauche (high-order) de la clé composée
- Chaque KFLD doit correspondre en **longueur, type et décimales** au champ correspondant dans la clé du fichier
- Les noms des KFLD n'ont pas besoin d'être identiques aux champs du fichier
- Le résultat d'un KFLD ne peut pas être un nom de tableau ou de table
- Pas d'indicateur de condition autorisé sur KFLD
- KLIST et KFLD peuvent apparaître n'importe où dans les spécifications C

---

## 14. Patterns complets

### Pattern 1 : Lecture complète d'un fichier
```
     FCLIENT  IF  E           K        DISK
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C* -- Traitement de l'enregistrement --
     C           PRECLI    DSPLY
     C* -- Lecture suivante --
     C                     READ CLIENT                   90
     C                     ENDDO
     C                     SETON                     LR
```

### Pattern 2 : Recherche + traitement conditionnel
```
     FCLIENT  IF  E           K        DISK
     C           NUMRCH    CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C* -- Enregistrement trouvé --
     C           NOMCLI    DSPLY
     C                     ELSE
     C* -- Non trouvé --
     C           'NOT FOUND'DSPLY
     C                     ENDIF
     C                     SETON                     LR
```

### Pattern 3 : Lecture partielle par clé (SETLL + READE)
```
     FCMDCLI  IF  E           K        DISK
     C           NUMCLI    SETLLCMDCLI
     C           NUMCLI    READECMDCLI                   90
     C           *IN90     DOWEQ'0'
     C* -- Traiter commande du client --
     C           NUMCLI    READECMDCLI                   90
     C                     ENDDO
     C                     SETON                     LR
```

### Pattern 4 : Création d'enregistrement
```
     FCLIENT  O  E           K        DISK
     C                     MOVEL'NOM'    NOMCLI
     C                     MOVEL'PRENOM' PRECLI
     C                     WRITECLIENTF
     C                     SETON                     LR
```

### Pattern 5 : Modification d'enregistrement
```
     FCLIENT  UF  E           K        DISK
     C           NUMRCH    CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     MOVEL'NOUVEAU' NOMCLI
     C                     UPDATCLIENTF
     C                     ENDIF
     C                     SETON                     LR
```

### Pattern 6 : Suppression d'enregistrement
```
     FCLIENT  UF  E           K        DISK
     C           NUMRCH    CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     DELETCLIENTF
     C                     ENDIF
     C                     SETON                     LR
```

### Pattern 7 : Auto-incrémentation de clé (dernier + 1)
```
     FCLIENT  UF  E           K        DISK                    A
     C           *HIVAL    SETLLCLIENT
     C                     READPCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     ADD  1        NUMCLI
     C                     ELSE
     C                     Z-ADD1        NUMCLI
     C                     ENDIF
     C                     MOVEL'NOM'    NOMCLI
     C                     WRITECLIENTF
     C                     SETON                     LR
```

### Pattern 8 : Vérifier l'existence d'une clé (SETLL + EQ) - Plus performant que CHAIN
```
     FCLIENT  IF  E           K        DISK
     C           NUMRCH    SETLLCLIENT                    55
     C           *IN55     IFEQ '1'
     C* -- Clé trouvée, le record existe --
     C           'EXISTE'  DSPLY
     C                     ELSE
     C* -- Clé non trouvée --
     C           'INEXISTANT'DSPLY
     C                     ENDIF
     C                     SETON                     LR
```

### Pattern 9 : Lecture arrière avec REDPE
```
     FCLIENT  IF  E           K        DISK
     C* Positionner après le dernier record de la clé voulue
     C           NUMCLI    SETGTCLIENT
     C* Lire en arrière tant que même clé
     C           NUMCLI    REDPECLIENT                   90
     C           *IN90     DOWEQ'0'
     C* -- Traiter en ordre inverse --
     C           NUMCLI    REDPECLIENT                   90
     C                     ENDDO
     C                     SETON                     LR
```

---

## Résumé des opérations

| Opération | Factor 1 | Factor 2 | Résultat | Ind 54-55 | Ind 56-57 | Ind 58-59 | Fichier requis |
|-----------|----------|----------|----------|-----------|-----------|-----------|----------------|
| SETLL | clé | fichier/format | - | NR (>max) | ER | EQ (trouvé) | I, U, C |
| SETGT | clé | fichier/format | - | NR (>max) | ER | - | I, U, C |
| READ (N) | - | fichier/format | DS | - | ER | EOF | I, U, C |
| READE (N) | clé (opt) | fichier/format | DS | - | ER | EOF/NF | I, U, C |
| READP (N) | - | fichier/format | DS | - | ER | BOF | I, U, C |
| REDPE (N) | clé (opt) | fichier/format | DS | - | ER | BOF/NF | I, U, C |
| READC | - | format SFL | - | - | ER | EOF | C (WORKSTN) |
| CHAIN (N) | clé | fichier/format | DS | NR (non trouvé) | ER | - | I, U, C |
| WRITE | - | format/fichier | DS | - | ER | SFL plein | O, U+A, C |
| UPDAT | - | format/fichier | DS | - | ER | - | U |
| DELET | - | format/fichier | - | - | - | - | U |

**Légende indicateurs** :
- EOF = End Of File (fin de fichier)
- BOF = Beginning Of File (début de fichier)
- EQ = Equal (clé trouvée exactement)
- NR = No Record (aucun record correspondant)
- NF = Not Found (pas de record avec clé égale)
- ER = Error (erreur d'exécution)
- DS = Data Structure (uniquement pour fichiers décrits programme)
- (N) = Option No-lock en position 53 pour fichiers en Update
