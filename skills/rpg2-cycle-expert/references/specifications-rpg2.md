# Specifications RPG II - Guide de Reference

## Table des matieres
1. [Ordre des specifications](#ordre)
2. [Specification H (Header)](#spec-h)
3. [Specification F (Fichier)](#spec-f)
4. [Specification E (Extension)](#spec-e)
5. [Specification L (Line Counter)](#spec-l)
6. [Specification I (Input/Entree)](#spec-i)
7. [Specification C (Calculation)](#spec-c)
8. [Specification O (Output/Sortie)](#spec-o)
9. [Donnees de compilation (**)](#donnees-compilation)
10. [Codes operation courants](#codes-operation)

---

## Ordre des specifications

L'ordre OBLIGATOIRE dans un source RPG II est :

```
H  →  F  →  E  →  L  →  I  →  C  →  O  →  **
```

Moyen mnemotechnique : **H**ello **F**riend, **E**very **L**ittle **I**nput **C**ounts for **O**utput

| Spec | Nom complet | Role dans le cycle |
|------|-------------|-------------------|
| **H** | Header / Controle | Options de compilation, nom programme |
| **F** | File Description | Declaration des fichiers (primaire, secondaire, sortie) |
| **E** | Extension | Tableaux et tables |
| **L** | Line Counter | Compteur de lignes par page (fichier imprimante) |
| **I** | Input | Definition des enregistrements, champs, indicateurs entree/rupture |
| **C** | Calculation | Calculs detail et total |
| **O** | Output | Definition des sorties (H/D/T/E) |
| ** | Donnees compilation | Valeurs des tableaux charges a la compilation |

---

## Specification H (Header)

La specification H definit les options de compilation du programme.

### Colonnes cles :
```
Col 6     : H
Col 15    : 1 = Debug mode
Col 18    : Echange de symboles decimal (,/.)
Col 21-22 : Taille minimum object (obsolete)
Col 26    : Indicateur 1P inverse (N1P disponible)
Col 39    : Y = format date YYMMDD, D = DDMMYY, M = MMDDYY
Col 75-80 : Nom du programme objet
```

### Exemple :
```
     H                                     Y                       BONGAP1
```
→ Format de date YYMMDD, programme nomme BONGAP1.

**Note** : En RPG II sur AS/400 avec fichiers decrits en externe (E), la specification H est souvent minimale ou absente.

---

## Specification F (File Description)

La specification F declare chaque fichier utilise dans le programme. C'est la plus importante pour comprendre le cycle.

### Colonnes cles pour le cycle :

```
Col 6      : F
Col 7-14   : Nom du fichier
Col 15     : Type : I (Input), O (Output), U (Update), C (Combined)
Col 16     : Designation fichier :
              P = Primary → lu par le cycle (IP = Input Primary)
              S = Secondary → lu par le cycle apres le primaire
              F = Full procedural → lu manuellement (READ)
              R = Record address
              T = Table / Array file
              (vide) = fichier de sortie
Col 17     : Fin de fichier : E = gestion fin fichier
Col 18     : Sequence : A (Ascending), D (Descending), (vide)
Col 19     : Format :
              E = Externally described (DDS/DDL)
              F = Fixed format (programme-described)
Col 20-23  : Bloc de cle (taille du bloc)
Col 24-27  : Taille enregistrement (obligatoire si F en col 19)
Col 28-30  : Longueur de cle (si programme-described)
Col 31     : Type d'organisation/acces :
              K = Keyed (acces par cle)
              L = Limits
              (vide) = consecutif
Col 33-34  : Indicateur de depassement : OF, OA, OB, OC, OD, OE, OG, OV
Col 40-46  : Nom du device :
              DISK, PRINTER, WORKSTN, KEYBORD, CONSOLE, SPECIAL, CRT
Col 54-59  : Mot-cle continuation (KCOMDS etc.)
```

### Exemples commentes :

```
     FBONBONL1IP  E           K        DISK
```
**Decodage** :
- `BONBONL1` : nom du fichier
- `I` (col 15) : Input (entree)
- `P` (col 16) : Primary → **lu par le cycle**
- `E` (col 19) : Externally described
- `K` (col 31) : Acces par cle
- `DISK` : fichier disque

```
     FQPRINT  O   F     132     OF     PRINTER
```
**Decodage** :
- `QPRINT` : nom du fichier
- `O` (col 15) : Output (sortie)
- (vide col 16) : pas de designation (fichier sortie)
- `F` (col 19) : Fixed format, 132 colonnes
- `OF` (col 33-34) : indicateur de depassement
- `PRINTER` : fichier imprimante

```
     FCLIENLF IF  E           K        DISK
```
**Decodage** :
- `CLIENLF` : nom du fichier
- `I` (col 15) : Input
- `F` (col 16) : Full procedural → **PAS lu par le cycle** (READ necessaire)
- `E` (col 19) : Externally described
- `K` (col 31) : acces par cle
- `DISK` : fichier disque

### La colonne 16 est la cle du cycle :

| Col 16 | Signification | Lu par le cycle ? |
|--------|--------------|:-----------------:|
| P | Primary | **OUI** (1 seul par programme) |
| S | Secondary | **OUI** (apres le primaire) |
| F | Full procedural | NON (READ manuel) |
| T | Table/Array | Charge au demarrage |
| (vide) | Sortie | Non applicable |

---

## Specification E (Extension)

Declaration des tableaux (arrays) et tables.

### Colonnes cles :
```
Col 6      : E
Col 11-18  : Nom du tableau "From" (fichier source ou **)
Col 19-26  : Nom du tableau "To" (tableau alternant)
Col 27-32  : Nombre d'entrees par enregistrement
Col 33-35  : Nombre total d'entrees dans le tableau
Col 36-39  : Taille de chaque entree (du tableau "From")
Col 40     : P = packed, B = binary, (vide) = zoned/alpha
Col 41-42  : Nombre de decimales (tableau "From")
Col 43     : Sequence : A, D, (vide)
Col 44-47  : Taille de chaque entree (du tableau "To")
Col 48     : P = packed, B = binary
Col 49-50  : Nombre de decimales (tableau "To")
Col 51-52  : Commentaires
```

### Exemple :
```
     E                    TBB     1   2 80
```
**Decodage** :
- `TBB` : nom du tableau
- `1` : 1 entree par ligne
- `2` : 2 entrees au total
- `80` : chaque entree fait 80 caracteres

Les donnees sont apres `**` en fin de source :
```
** TBB
|-------|---------------------|---------------------|--------|
| CLE   | MARQUE              | NOM                 | PRIX   |
```

→ `TBB,1` contient la ligne de bordure, `TBB,2` contient la ligne d'en-tete.

---

## Specification L (Line Counter)

Definit le format de page pour les fichiers imprimante.

### Colonnes cles :
```
Col 6      : L
Col 7-14   : Nom du fichier imprimante
Col 15-17  : Nombre de lignes par page
Col 18-19  : FL = Form Length (FL apres le nombre)
Col 20-22  : Numero de ligne de depassement (overflow)
Col 23-24  : OL = Overflow Line
```

### Exemple :
```
     LQPRINT     66FL     60OL
```
→ Pages de 66 lignes, depassement a la ligne 60.

**Note** : Si pas de spec L, le systeme utilise les valeurs par defaut (66 lignes par page).

---

## Specification I (Input/Entree)

Double fonction : definir les enregistrements ET les champs.

### Ligne de controle d'enregistrement :

```
Col 6      : I
Col 7-14   : Nom du format (si fichier externe E, prefixe F)
Col 15-16  : Sequence (01-99 ou NS = Not Sequenced)
Col 17-18  : Numero dans la sequence
Col 19-20  : Indicateur d'entree (01-99) → active quand cet enregistrement est lu
Col 21     : Option (O = optional)
```

### Ligne de definition de champ :

```
Col 6      : I
Col 44-47  : Position debut du champ (si programme-described)
Col 48-51  : Position fin du champ
Col 43-58  : Nom du champ (en fichier externe : col 53-58 pour renommage)
Col 52     : Decimales
Col 53-58  : Nom de champ dans le programme (renommage)
Col 59-60  : Indicateur de rupture (L1-L9) → ce champ declenche une rupture
Col 61-62  : Indicateur de concordance (M1-M9)
Col 63-64  : Indicateur de champ positif (01-99)
Col 65-66  : Indicateur de champ negatif (01-99)
Col 67-68  : Indicateur de champ zero/blanc (01-99)
```

### Exemples :

```
     IFBONBON     33
```
→ Format BONBON (prefixe F car fichier externe), indicateur d'entree **33**.

```
     I                                              MARQUEL1
```
→ Champ MARQUE avec indicateur de rupture **L1**.

```
     I              COULEUR                         COLOR
```
→ Champ COULEUR renomme **COLOR** dans le programme.

---

## Specification C (Calculation)

### Structure des colonnes :
```
Col 6      : C
Col 7-8    : Niveau de controle :
              L0 = toujours en total
              L1-L9 = traitement TOTAL a la rupture
              LR = traitement total en fin de fichier
              SR = sous-programme
              AN/OR = ET/OU sur indicateurs precedents
              (vide) = traitement DETAIL
Col 9-11   : Indicateur condition 1 (Nxx = inverse)
Col 12-14  : Indicateur condition 2
Col 15-17  : Indicateur condition 3
Col 18-27  : Factor 1 (10 car)
Col 28-32  : Code operation (5 car)
Col 33-42  : Factor 2 (10 car)
Col 43-48  : Zone resultat (6 car)
Col 49-51  : Longueur zone resultat
Col 52     : Decimales zone resultat
Col 53     : H = half-adjust, P = padding, N = no-lock
Col 54-55  : Indicateur HI (positif) ou NR (non trouve)
Col 56-57  : Indicateur LO (negatif) ou ER (erreur)
Col 58-59  : Indicateur EQ (egal) ou EOF (fin fichier)
Col 60-74  : Commentaires
```

### Distinction critique : col 7-8 vs col 9-17

| Colonnes 7-8 | Colonnes 9-17 | Signification |
|-------------|--------------|---------------|
| L1 | (vide) | Traitement TOTAL a la rupture L1 (etape 11) |
| (vide) | L1 | Traitement DETAIL conditionne par L1 actif (etape 16) |
| LR | (vide) | Traitement TOTAL a fin de fichier (etape 11) |
| (vide) | 33 | Traitement DETAIL si indicateur 33 actif (etape 16) |

---

## Specification O (Output/Sortie)

### Ligne de controle d'enregistrement :

```
Col 6      : O
Col 7-14   : Nom du fichier
Col 15     : Type de sortie :
              H = Header (en-tete) → etape 2
              D = Detail → etape 2
              T = Total → etape 12
              E = Exception (EXCEPT)
Col 16-18  : Saut/espacement avant impression
              (nombre de lignes ou numero de canal)
Col 19-20  : Saut/espacement apres impression
Col 23-31  : Indicateurs de condition
              Positions pour 3 indicateurs
              Prefixe N = inverse (ex: N33 = si 33 OFF)
```

### Ligne OR (condition alternative) :
```
Col 6      : O
Col 14-16  : OR
Col 23-31  : Indicateurs de condition alternatifs
```

### Ligne de champ :
```
Col 6      : O
Col 23-31  : Indicateurs de condition (optionnel, pour masquer un champ)
Col 32-37  : Nom du champ (ou constante entre quotes)
Col 38     : Indicateur de blanquage B (blank after)
Col 38-39  : Edit code :
              1-4 = avec point decimal, signe en zone (variantes pour zero)
              A-D = comme 1-4 mais avec symbole monetaire
              J-M = comme 1-4 mais signe gauche
              Z = suppression des zeros non significatifs
Col 40-43  : Position de fin du champ (absolue) ou +n (relative)
Col 45-70  : Constante entre apostrophes
```

### Exemples detailles :

```
     OQPRINT  H  1 1   1P
     O       OR        OF
     O                         TBB,1
```
**Decodage** :
- Ligne 1 : Fichier QPRINT, sortie **H** (en-tete), saut 1 ligne avant, espacement 1 apres, condition **1P** (premiere page)
- Ligne 2 : **OR** condition alternative : **OF** (depassement de page)
- Ligne 3 : Imprimer `TBB,1` (premier element du tableau TBB)

→ L'en-tete est imprimee au premier passage (1P) ET a chaque saut de page (OF).

```
     O        D        33
     O                                      '|'
     O                         NUMBER  +  1
     O                         PRIX  4 +  1 '|'
```
**Decodage** :
- Ligne 1 : Sortie **D** (detail), condition indicateur **33** actif
- Ligne 2 : Constante `|` (separateur)
- Ligne 3 : Champ NUMBER, position relative +1
- Ligne 4 : Champ PRIX, edit code **4** (zero=blanc), position relative +1, suivi de `|`

```
     O        T        L1
     O                  50 '| TOTAL :'
     O                  TOTP  4
```
**Decodage** :
- Ligne 1 : Sortie **T** (total), condition **L1** (rupture niveau 1)
- Ligne 2 : Constante `| TOTAL :` en position 50
- Ligne 3 : Champ TOTP avec edit code 4

---

## Donnees de compilation (**)

Les lignes apres `**` en fin de source contiennent les donnees des tableaux charges a la compilation.

### Regles :
- Chaque tableau a ses donnees dans l'ordre de declaration (spec E)
- Si un tableau a un alternating table (To), les donnees alternent
- Le nombre de lignes doit correspondre au nombre d'entrees declare

### Exemple :
```
** TBB
|-------|---------------------|---------------------|--------|
| CLE   | MARQUE              | NOM                 | PRIX   |
```
→ 2 lignes de 80 caracteres pour le tableau TBB de 2 elements.

---

## Codes operation courants en RPG II

### Arithmetique
| Code | Description | Syntaxe |
|------|------------|---------|
| ADD | Addition | F1 ADD F2 = R |
| SUB | Soustraction | F1 SUB F2 = R |
| MULT | Multiplication | F1 MULT F2 = R |
| DIV | Division | F1 DIV F2 = R |
| MVR | Move Remainder | MVR = R (apres DIV) |
| Z-ADD | Zero and Add | Z-ADD F2 = R |
| Z-SUB | Zero and Subtract | Z-SUBF2 = R |
| XFOOT | Somme tableau | XFOOT ARR = R |
| SQRT | Racine carree | SQRT F2 = R |

### Mouvement de donnees
| Code | Description |
|------|------------|
| MOVE | Deplacer (alignement droite) |
| MOVEL | Deplacer (alignement gauche) |
| MOVEA | Deplacer tableau |

### Controle de flux
| Code | Description |
|------|------------|
| GOTO | Branchement a un TAG |
| TAG | Etiquette (cible du GOTO) |
| COMP | Comparaison (active HI/LO/EQ) |
| SETON | Activer un indicateur |
| SETOF | Desactiver un indicateur |

### Fichiers
| Code | Description |
|------|------------|
| CHAIN | Lecture directe par cle |
| READ | Lecture sequentielle |
| READE | Lecture sequentielle par cle egale |
| READP | Lecture arriere |
| REDPE | Lecture arriere par cle egale |
| SETLL | Positionner au debut d'une cle |
| WRITE | Ecrire un enregistrement |
| UPDAT | Mettre a jour |
| DELET | Supprimer |
| EXCPT | Sortie exception |

### Sous-programmes
| Code | Description |
|------|------------|
| EXSR | Executer sous-programme |
| BEGSR | Debut sous-programme |
| ENDSR | Fin sous-programme |

### Divers
| Code | Description |
|------|------------|
| LOKUP | Recherche dans un tableau |
| SORTA | Trier un tableau |
| CALL | Appeler un programme externe |
| PARM | Parametre (avec CALL) |
| DSPLY | Afficher un message |
| TIME | Heure courante |
| FORCE | Forcer la lecture d'un fichier specifique |
| DEBUG | Point de debug |
