# Sous-programmes et Appels Externes en RPG III

## Table des matières
1. [Sous-programmes internes (EXSR/BEGSR/ENDSR)](#sous-programmes-internes)
2. [Sous-programmes spéciaux (*PSSR, *INZSR)](#sous-programmes-speciaux)
3. [Appel de programme externe (CALL/PARM/PLIST)](#appel-externe)
4. [Groupement des références programme (doc IBM)](#groupement-references)
5. [Retour au programme appelant (RETRN)](#retrn)
6. [Libération mémoire (FREE)](#free)
7. [Sélection conditionnelle (CAS/ENDCS)](#cas-endcs)
8. [EXFMT - Write/Read combiné](#exfmt)
9. [Patterns et bonnes pratiques](#patterns)

---

## 1. Sous-programmes internes (EXSR/BEGSR/ENDSR)

### Principe

Un sous-programme interne est un bloc de code réutilisable **dans le même programme**. Il permet d'organiser le code en sections logiques et d'éviter la duplication.

### EXSR - Appeler un sous-programme

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| EXSR    |               | Subroutine name |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

- Factor 2 = nom du sous-programme à appeler
- Le nom doit correspondre au Factor 1 d'un BEGSR
- Peut apparaître n'importe où dans les spécifications de calcul
- Après exécution du SR, le programme reprend à l'instruction suivant l'EXSR

**Valeurs spéciales pour Factor 2** :
- `*PSSR` : appelle le sous-programme d'exception/erreur du programme
- `*INZSR` : appelle le sous-programme d'initialisation

### BEGSR - Début de sous-programme

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| BEGSR   | Subroutine    |                 |                |               |
|         | name          |                 |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

- Factor 1 = nom du sous-programme (doit être unique)
- Le contrôle de niveau (col 7-8) peut être SR ou vide
- Pas d'indicateurs de condition autorisés

### ENDSR - Fin de sous-programme

Le ENDSR marque la fin du sous-programme. Le contrôle retourne à l'instruction suivant l'EXSR appelant. Un GOTO vers un label extérieur au SR peut modifier ce comportement.

### Règles
- Le nom du sous-programme fait **6 caractères max**
- Chaque sous-programme doit avoir un nom **unique**
- Les sous-programmes sont placés **après** le code principal, avant SETON LR
- Un sous-programme peut appeler un autre sous-programme (EXSR imbriqués)
- Les variables sont **globales** : un SR accède à toutes les variables du programme

### Exemple simple
```
     C* Programme principal
     C                     EXSR INIT
     C                     EXSR TRAITE
     C                     EXSR FINPGM
     C* ============================================
     C* SOUS-PROGRAMME : INITIALISATION
     C* ============================================
     C           INIT      BEGSR
     C                     Z-ADD0        TOTAL  72
     C                     Z-ADD0        CPTEUR 50
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : TRAITEMENT
     C* ============================================
     C           TRAITE    BEGSR
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C                     ADD  1        CPTEUR
     C                     ADD  MNTCLI  TOTAL
     C                     READ CLIENT                   90
     C                     ENDDO
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : FIN PROGRAMME
     C* ============================================
     C           FINPGM    BEGSR
     C           TOTAL     DSPLY
     C                     SETON                     LR
     C                     ENDSR
```

---

## 2. Sous-programmes spéciaux (*PSSR, *INZSR)

### *PSSR - Sous-programme d'exception/erreur programme

**Rôle** : Sous-programme appelé automatiquement quand une erreur programme survient (division par zéro, dépassement, erreur de donnée, etc.).

```
     C           *PSSR     BEGSR
     C* Traitement de l'erreur
     C           'ERREUR!'DSPLY
     C* Optionnel : forcer fin de programme
     C                     SETON                     LR
     C                     ENDSR
```

**Règles (doc IBM)** :
- Un seul sous-programme peut être défini avec `*PSSR` en Factor 1
- Il est automatiquement invoqué sur les erreurs programme
- Peut aussi être appelé manuellement avec `EXSR *PSSR`
- Le Factor 2 de ENDSR peut contenir un label pour un branchement après l'erreur

**Usage typique** : Logger l'erreur, fermer proprement les fichiers, terminer le programme.

### *INZSR - Sous-programme d'initialisation

**Rôle** : Sous-programme exécuté automatiquement **une seule fois** pendant l'étape d'initialisation du programme, avant la première exécution du cycle RPG.

```
     C           *INZSR    BEGSR
     C* Initialisation des variables au démarrage
     C                     Z-ADD0        TOTAL  72
     C                     Z-ADD0        CPTEUR 50
     C                     MOVE *BLANKS  MSG    50
     C                     ENDSR
```

**Règles (doc IBM)** :
- Un seul sous-programme peut être défini avec `*INZSR` en Factor 1
- Exécuté automatiquement à l'initialisation du programme
- Peut aussi être appelé manuellement avec `EXSR *INZSR`

**Usage typique** : Initialiser des variables, charger des valeurs par défaut, préparer des data structures.

---

## 3. Appel de programme externe (CALL/PARM/PLIST)

### CALL - Appeler un programme externe

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| CALL    |               | Program name    | Plist          | _ ER LR       |
|         |               |                 | name           |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Factor 2** : nom du programme à appeler. Peut contenir :
- Un littéral : `'PROG2'`
- Un littéral avec bibliothèque : `'LIB/PROG'`
- Un champ, une constante nommée ou un élément de tableau
- La longueur totale (y compris le /) ne peut pas dépasser 8 caractères pour un littéral, 21 pour un champ
- `*LIBL` et `*CURLIB` ne sont **PAS supportés**

**Résultat** : nom de la PLIST contenant les paramètres. Peut être vide si les PARM suivent directement le CALL.

**Indicateurs** :
- **Col 54-55** : doit être vide
- **Col 56-57 (ER)** : activé si erreur retournée par le programme appelé
- **Col 58-59 (LR)** : activé si le programme appelé est RPG/400 et retourne avec LR ON

**⚠ Attention aux noms** :
- Les blancs avant/après le `/` sont inclus dans le nom
- Les minuscules ne sont PAS converties en majuscules
- Un nom entre guillemets ("ABC") inclut les guillemets dans le nom

### Exemple complet

**Programme appelant (PGMAIN)** :
```
     C                     MOVEL'AKTEPE' WNOM   20
     C                     Z-ADD27       WNUM   50
     C                     CALL 'PGMSUB'
     C                     PARM                     WNOM
     C                     PARM                     WNUM
     C                     PARM                     WRET   50
     C* Après retour, WRET contient le résultat
     C           WRET      DSPLY
     C                     SETON                     LR
```

**Programme appelé (PGMSUB)** :
```
     C           *ENTRY    PLIST
     C                     PARM                     PNOM   20
     C                     PARM                     PNUM   50
     C                     PARM                     PRET   50
     C* Traitement
     C           PNUM      MULT 2       PRET
     C                     RETRN
```

### Avec PLIST nommée
```
     C                     CALL 'PROGA' MALIST
     C           MALIST    PLIST
     C                     PARM                     FLDA
     C                     PARM                     FLDB
```

### PARM directement après CALL
```
     C                     CALL 'PROGA'
     C                     PARM                     FLDA
     C                     PARM                     FLDB
```
→ Les PARM peuvent suivre directement le CALL sans PLIST.

### Règles CALL/PARM
- Les PARM doivent correspondre en **nombre, type et longueur** entre appelant et appelé
- *ENTRY PLIST est obligatoire dans le programme appelé pour recevoir les paramètres
- L'ordre des PARM est crucial : le 1er PARM de l'appelant va au 1er PARM de l'appelé
- CALL charge le programme en mémoire s'il n'y est pas déjà

---

## 4. Groupement des références programme (doc IBM)

Le système RPG/400 optimise les appels de programmes en **groupant les références** pour éviter la résolution répétée.

### Règles de groupement

**Par constante nommée ou littéral** :
- Toutes les références (CALL ou FREE) à un même programme via constante ou littéral sont groupées
- Le programme n'est résolu qu'**une seule fois**
- Les références sont groupées si le nom de programme ET le nom de bibliothèque sont identiques

**Par variable** :
- Les références par variable sont groupées par **nom de variable**
- La valeur courante est comparée à la valeur du dernier CALL avec cette variable
- Si la valeur n'a pas changé → pas de résolution
- Si la valeur a changé → nouvelle résolution
- Un FREE force une résolution au prochain CALL

### Exemple de groupement (doc IBM)
```
     I 'LIB1/PGM1'                  C           CALLA
     I 'PGM1'                       C           CALLB
     I 'LIB/PGM2'                   C           CALLC

     C* Résolu une fois (CALLA = LIB1/PGM1)
     C                     CALL CALLA
     C* Groupés ensemble car même programme (PGM1) et même bibliothèque (aucune)
     C                     CALL 'PGM1'
     C                     CALL CALLB
     C* Groupés ensemble car même programme (PGM2) et même bibliothèque (LIB)
     C                     CALL 'LIB/PGM2'
     C                     FREE CALLC

     C* Appel par variable : résolu la première fois
     C                     MOVE 'PGM1'  CALLV  21
     C                     CALL CALLV
     C* Pas de résolution (valeur inchangée)
     C                     CALL CALLV
     C* FREE force la résolution au prochain CALL
     C                     FREE CALLV
     C* Résolution forcée par le FREE précédent
     C                     CALL CALLV
```

---

## 5. RETRN - Retour au programme appelant

**Rôle** : Retourne immédiatement au programme qui a fait le CALL, **sans fermer les fichiers** et **sans libérer la mémoire**.

```
     C                     RETRN
```

**Différence avec SETON LR** :

| Instruction | Fichiers | Mémoire | État |
|-------------|----------|---------|------|
| RETRN | Restent ouverts | Conservée | Programme en pause |
| SETON LR | Fermés | Libérée | Programme terminé |

**Conséquence** :
- Après RETRN, si le programme est rappelé avec CALL, il reprend dans son état précédent (variables conservées, fichiers ouverts)
- Après SETON LR, le programme repart de zéro

**Usage typique** : RETRN dans un programme appelé fréquemment pour éviter le coût de réouverture des fichiers.

---

## 6. FREE - Libération de la copie logique

**Rôle** : Supprime la copie logique d'un programme en mémoire. Au prochain CALL, le programme sera rechargé comme une nouvelle instance.

```
     C                     FREE 'PROG2'
```

**Quand utiliser FREE** :
- Quand un programme appelé doit repartir de zéro à chaque appel
- Pour libérer de la mémoire après un programme gourmand
- Quand les données du programme appelé ne doivent pas persister
- Pour forcer la résolution du programme au prochain CALL (voir groupement des références)

**Séquence typique** :
```
     C                     CALL 'PROG2'
     C                     PARM                     PARAM1
     C* ... traitement ...
     C                     FREE 'PROG2'
```

**⚠ Note (doc IBM)** : FREE lui-même ne provoque pas de résolution. Il utilise le pointeur de programme courant. C'est le CALL suivant qui résoudra le programme.

---

## 7. CAS/ENDCS - Sélection conditionnelle avec appel SR

**Rôle** : Alternative à SELEC/WHxx qui combine test et appel de sous-programme.

### Syntaxe
```
     C           fact1     CASxx fact2   nomSR
     C           fact1     CASxx fact2   nomSR2
     C                     CAS                      DEFAUT
     C                     ENDCS
```

- **CASxx** : teste la condition xx entre Factor 1 et Factor 2
- Si la condition est vraie, appelle le sous-programme indiqué dans Result
- **CAS sans xx** : cas par défaut (exécuté si aucun CASxx précédent n'est vrai)
- **ENDCS** : fin de la structure CAS

### Suffixes xx (identiques à IFxx)
| Suffixe | Condition |
|---------|-----------|
| CASEQ | Factor 1 = Factor 2 |
| CASNE | Factor 1 ≠ Factor 2 |
| CASLT | Factor 1 < Factor 2 |
| CASLE | Factor 1 ≤ Factor 2 |
| CASGT | Factor 1 > Factor 2 |
| CASGE | Factor 1 ≥ Factor 2 |

### Exemple
```
     C           OPT       CASEQ'C'     CREER
     C           OPT       CASEQ'M'     MODIF
     C           OPT       CASEQ'S'     SUPPR
     C                     CAS                      ERREUR
     C                     ENDCS
```

Équivalent avec SELEC/WHxx :
```
     C                     SELEC
     C           OPT       WHEQ 'C'
     C                     EXSR CREER
     C           OPT       WHEQ 'M'
     C                     EXSR MODIF
     C           OPT       WHEQ 'S'
     C                     EXSR SUPPR
     C                     OTHER
     C                     EXSR ERREUR
     C                     ENDSL
```

---

## 8. EXFMT - Write/Read combiné

**Syntaxe officielle IBM** :
```
*---------*---------------*-----------------*----------------*---------------*
| CODE    | FACTOR 1      | FACTOR 2        | RESULT         | INDICATORS    |
*---------*---------------*-----------------*----------------*---------------*
| EXFMT   |               | Record format   |                | _ ER _        |
|         |               | name            |                |               |
*---------*---------------*-----------------*----------------*---------------*
```

**Rôle** : Combinaison d'un WRITE suivi d'un READ sur le même format. EXFMT est un raccourci pour afficher un écran 5250 et attendre la réponse de l'utilisateur.

**Conditions d'utilisation** :
- Fichier WORKSTN uniquement
- Déclaré en Full Procedural (F en position 16)
- Combined (C en position 15)
- Externally described (E en position 19)

**Factor 2** : nom du format à écrire puis lire (obligatoire).

**Indicateurs** :
- **Col 56-57 (ER)** : activé si l'opération échoue. Si ER est activé, la partie READ n'est PAS exécutée.
- Col 54-55, 58-59 : doivent être vides.

**Exemple** :
```
     FECRAN   CF  E                    WORKSTN
     C* Affiche FMT1, attend la saisie utilisateur, puis lit les champs
     C                     EXFMTFMT1
     C* Après EXFMT, les champs de FMT1 sont disponibles
     C           *INKC     IFEQ '1'
     C* F3 pressé → sortie
     C                     LEAVE
     C                     ENDIF
```

---

## 9. Patterns et bonnes pratiques

### Structure recommandée d'un programme RPG III

```
     F* DECLARATION DES FICHIERS
     FCLIENT  UF  E           K        DISK                    A
     FECRAN   CF  E                    WORKSTN
     E* TABLEAUX (si nécessaire)
     I* DATA STRUCTURES (si nécessaire)
     C* ============================================
     C* PROGRAMME PRINCIPAL
     C* ============================================
     C                     EXSR INIT
     C           *INKC     DOWEQ'0'
     C                     EXSR AFFI
     C* Test F3
     C           *INKC     IFEQ '1'
     C                     LEAVE
     C                     ENDIF
     C                     EXSR TRAITE
     C                     ENDDO
     C                     SETON                     LR
     C* ============================================
     C* SOUS-PROGRAMME : INITIALISATION
     C* ============================================
     C           INIT      BEGSR
     C* ... initialisation des variables ...
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : AFFICHAGE
     C* ============================================
     C           AFFI      BEGSR
     C                     EXFMTFMT1
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME : TRAITEMENT
     C* ============================================
     C           TRAITE    BEGSR
     C* ... logique métier ...
     C                     ENDSR
     C* ============================================
     C* SOUS-PROGRAMME ERREUR PROGRAMME
     C* ============================================
     C           *PSSR     BEGSR
     C           'ERR PGM' DSPLY
     C                     SETON                     LR
     C                     ENDSR
```

### Convention de nommage des sous-programmes

| Préfixe | Usage | Exemple |
|---------|-------|---------|
| INIT | Initialisation | INIT, INITSF |
| AFFI | Affichage écran | AFFI, AFFI2 |
| CTL | Contrôle/validation | CTL1, CTLSAI |
| TRAIT | Traitement | TRAITE, TRTOPT |
| CALC | Calcul | CALCUL, CALIMP |
| CHARGE | Chargement SFL | CHARGE, CHGSFL |
| *PSSR | Erreur programme | (unique) |
| *INZSR | Initialisation auto | (unique) |

### Bonnes pratiques

1. **Nom explicite** : CALQUO plutôt que SR001
2. **Un SR = une responsabilité** : ne pas mélanger affichage et calcul
3. **Commentaires** : toujours commenter le rôle du SR avec `*` en col 7
4. **Séparation visuelle** : utiliser des lignes de `*` entre les SR
5. **Ordre** : programme principal en haut, SR en bas par ordre logique
6. **SETON LR** : toujours à la fin du programme principal, pas dans un SR (sauf *PSSR)
7. **Utiliser *INZSR** : pour l'initialisation automatique au lieu d'un EXSR INIT explicite
8. **Définir *PSSR** : toujours avoir un sous-programme d'erreur pour éviter les plantages non gérés
